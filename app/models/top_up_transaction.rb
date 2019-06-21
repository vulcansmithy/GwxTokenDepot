class TopUpTransaction < ApplicationRecord
  
  include AASM
  
  TRANSACTION_TYPES = [:btc, :eth, :nem]
  
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
        puts "@DEBUG L:#{__LINE__}   Running before 'assign_payment_receiving_wallet'"
      end
      
      after do
        puts "@DEBUG L:#{__LINE__}   Running after 'assign_payment_receiving_wallet'"
      end
    end  
    
    event :check_for_incoming_tranfer do
      transitions from: [:payment_receiving_wallet_assigned, :transaction_successful, :transaction_unsuccessful], to: :pending
      
      before do
        puts "@DEBUG L:#{__LINE__}   Running before 'check_for_incoming_tranfer'"
      end
      
      after do
        puts "@DEBUG L:#{__LINE__}   Running after 'check_for_incoming_tranfer'"
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
