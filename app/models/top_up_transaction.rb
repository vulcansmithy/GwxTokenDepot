class TopUpTransaction < ApplicationRecord
  
  include AASM

  class TopUpTransactionError < StandardError; end
  
  TRANSACTION_TYPES  = [:btc, :eth, :xem].freeze
  INITIAL_INTERVAL = Rails.env.production? ?  2.minutes : 15.seconds
  SCHEDULED_INTERVAL = Rails.env.production? ? 20.minutes : 30.seconds
  RECEIVING_PERIOD   = Rails.env.production? ? 24.hours   : 6.hours
  
  enum transaction_type: TRANSACTION_TYPES
  
  attr_encrypted :top_up_receiving_wallet_pk, key: Rails.application.secrets.top_up_receiving_wallet_pk
  
  validates_presence_of :user_id,             :on => :create, :message => "can't be blank"
  validates_presence_of :quantity_to_receive, :on => :create, :message => "can't be blank"
  validates_presence_of :gwx_to_transfer,     :on => :create, :message => "can't be blank"
  validates_presence_of :transaction_type,    :on => :create, :message => "can't be blank"
  validates_presence_of :gwx_wallet_address,  :on => :create, :message => "can't be blank"
  
  validates :transaction_type, inclusion: { in: TRANSACTION_TYPES.map {|t| t.to_s } }
  
  aasm no_direct_assignment: true, whiny_transitions: false  do
 
    state :initiated, initial: true
    state :payment_receiving_wallet_assigned
    state :pending
    state :purchase_confirmed
    state :failed
    state :pending_gwx_transfer
    state :gwx_transferred
    state :cancelled

    event :assign_payment_receiving_wallet do
      transitions from: :initiated, to: :payment_receiving_wallet_assigned
      
      before do
        begin  
          coin_util_service = "#{self.transaction_type.titlecase}UtilService".constantize.new
        rescue NameError => e
          raise TopUpTransactionError, e.message
        rescue Exception => e   
          raise TopUpTransactionError, e.message
        else 
          coin_util_service.assign_receiving_wallet(self)
        end  
      end
      
      after do
      end
    end  
    
    event :start_listening_for_incoming_transfer do
      transitions from: [:payment_receiving_wallet_assigned, :purchase_confirmed, :failed, :cancelled], to: :pending

      before do
        schedule_the_appropriate_job(self)
      end
      
      after do
        # save the updated state
        self.save
      end
    end
    
    event :confirm_transaction_successful do
      transitions from: :pending, to: :purchase_confirmed
      
      after do
        # save the updated state
        self.save
      end
    end
    
    event :set_transaction_unssuccesful do
      transitions from: :pending, to: :cancelled
      
      after do
        # save the updated state
        self.save
      end
    end  
    
    event :transfer_gwx_to_gwx_wallet do
      transitions from: :purchase_confirmed, to: :pending_gwx_transfer
      
      before do
        # @TODO call transfer
      end
      
      after do
        puts "@DEBUG L:#{__LINE__}   Transfer complete!"
        
        # transfer x amount of gwx tokens to the provided gwx_wallet
        result = GwxCashierClient.create_transaction(transaction_params: {
          source_wallet_address: Rails.application.secrets.gwx_distribution_wallet,
          destination_wallet_address: self.gwx_wallet_address,
          quantity: self.quantity_to_receive
        })
        self.outgoing_id = result["data"]["id"]
        # save the updated state
        self.save

        outgoing_tx = GwxCashierClient.get_transaction(id: result["data"]["id"])

        raise TopUpTransactionError, "Can't transfer the amount of #{self.gwx_to_transfer} gwx to the specified gwx wallet." unless result[:status] == "success"
      end
    end

    event :confirm_gwx_status_from_cashier do
      transitions from: :pending_gwx_transfer, to: :gwx_transferred, guard: :gwx_transaction_hash.present? && :gwx_transaction_status_success?

      before do
      end

      after do
        puts "============"
        puts "FROM CASHIER"
        puts "============"

        if self.outgoing_id
          result = GwxCashierClient.get_transaction(id: self.outgoing_id)
          self.gwx_transaction_hash = result["data"]["attributes"]["txHash"]
          self.gwx_transaction_message = result["data"]["attributes"]["transactionDetails"]["message"]
          self.gwx_transaction_status = result["data"]["attributes"]["transactionDetails"]["status"]
          self.save
        end
      end
    end

    event :validate_gwx_status_from_cashier do
      transitions from: :pending_gwx_transfer, to: :failed, guard: :gwx_transaction_status_failed?

      before do
      end

      after do

        if self.outgoing_id
          result = GwxCashierClient.get_transaction(id: self.outgoing_id)
          self.gwx_transaction_hash = result["data"]["attributes"]["txHash"]
          self.gwx_transaction_message = result["data"]["attributes"]["transactionDetails"]["message"]
          self.gwx_transaction_status = result["data"]["attributes"]["transactionDetails"]["status"]
          self.save
        end
      end
    end
  end

  def status
    result = case self.aasm_state.to_sym
    when TopUpTransaction::STATE_INITIATED
      self.aasm_state
    when TopUpTransaction::STATE_PAYMENT_RECEIVING_WALLET_ASSIGNED, 
         TopUpTransaction::STATE_PENDING  
      TopUpTransaction::STATE_PENDING
    when TopUpTransaction::STATE_FAILED
      self.aasm_state
    when TopUpTransaction::STATE_PENDING_GWX_TRANSFER
      self.aasm_state
    when TopUpTransaction::STATE_GWX_TRANSFERRED
      self.aasm_state
    when TopUpTransaction::STATE_PURCHASE_CONFIRMED
      self.aasm_state
    when TopUpTransaction::STATE_CANCELLED
      self.aasm_state
    else
      :unrecognized_status
    end
    
    return result
  end
  
  def schedule_the_appropriate_job(transaction)
    begin  

      worker_object = "#{transaction.transaction_type.titlecase}TransactionWorker".constantize.new
      worker_object.class.perform_at(INITIAL_INTERVAL, transaction.id)

    rescue NameError => e
      raise TopUpTransactionError, e.message
    rescue Exception => e   
      raise TopUpTransactionError, e.message
    end  
  end

  def gwx_transaction_hash_present?
    self.gwx_transaction_hash.present?
  end

  def gwx_transaction_status_success?
    self.gwx_transaction_status === 'success'
  end

  def gwx_transaction_status_failed?
    self.gwx_transaction_status === 'failed'
  end
end