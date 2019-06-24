class TopUpTransaction < ApplicationRecord
  
  include AASM

  class TopUpTransactionError < StandardError; end
  
  TRANSACTION_TYPES = [:btc, :eth, :xem].freeze
  
  enum transaction_type: TRANSACTION_TYPES
  
  validates_presence_of :user_id,            :on => :create, :message => "can't be blank"
  validates_presence_of :quantity,           :on => :create, :message => "can't be blank"
  validates_presence_of :transaction_type,   :on => :create, :message => "can't be blank"
  validates_presence_of :gwx_wallet_address, :on => :create, :message => "can't be blank"
  
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
        begin  
          Object.const_get("#{self.transaction_type.titlecase}TransactionWorker").send(:perform_async, [self.id])
        rescue NameError => e
          raise TopUpTransactionError, e.message
        rescue Exception => e   
          raise TopUpTransactionError, e.message
        end  
      end
      
      after do
        # save the updated state
        self.save
      end
    end
    
    event :confirm_transaction_successful do
      transitions from: :pending, to: :transaction_successful
    end
    
    event :set_transaction_unssuccesful do
      transitions from: :pending, to: :transaction_unsuccessful
    end  
    
    event :transfer_gwx_to_gwx_wallet do
      transitions from: :transaction_successful, to: :gwx_transferred
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
  
end