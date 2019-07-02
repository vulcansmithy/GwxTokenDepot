class TopUpTransaction < ApplicationRecord
  
  include AASM

  class TopUpTransactionError < StandardError; end
  
  TRANSACTION_TYPES  = [:btc, :eth, :xem].freeze
    INITIAL_INTERVAL = Rails.env.production? ?  2.minutes : 15.seconds
  SCHEDULED_INTERVAL = Rails.env.production? ? 20.minutes : 30.seconds
  RECEIVING_PERIOD   = Rails.env.production? ? 24.hours   : 20.minutes
  
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
    state :transaction_successful
    state :transaction_unsuccessful
    state :gwx_transferred

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
      transitions from: [:payment_receiving_wallet_assigned, :transaction_successful, :transaction_unsuccessful], to: :pending

      before do
        schedule_the_appropriate_job(self)
      end
      
      after do
        # save the updated state
        self.save
      end
    end
    
    event :confirm_transaction_successful do
      transitions from: :pending, to: :transaction_successful
      
      after do
        # save the updated state
        self.save
      end
    end
    
    event :set_transaction_unssuccesful do
      transitions from: :pending, to: :transaction_unsuccessful
      
      after do
        # save the updated state
        self.save
      end
    end  
    
    event :transfer_gwx_to_gwx_wallet do
      transitions from: :transaction_successful, to: :gwx_transferred
      
      before do
        # @TODO call transfer
      end
      
      after do
        puts "@DEBUG L:#{__LINE__}   Transfer complete!"
        
        # save the updated state
        self.save
        
        # instantiate gwx cashier
        gwx_cashier = GwxCashierLib.new
        
        # transfer x amount of gwx tokens to the provided gwx_wallet
        result = cashier.xem_transfer(
          Rails.application.secrets.gwx_distribution_wallet,
          Rails.application.secrets.gwx_distribution_wallet_pk,
          self.gwx_wallet_address,
          self.gwx_to_transfer
        )
        
        raise TopUpTransactionError, "Can't transfer the amount of #{self.gwx_to_transfer} gwx to the specified gwx wallet." unless result[:status] == "success"
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
    when TopUpTransaction::STATE_TRANSACTION_SUCCESSFUL
      self.aasm_state
    when TopUpTransaction::STATE_TRANSACTION_UNSUCCESSFUL
      self.aasm_state
    default
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
  
end