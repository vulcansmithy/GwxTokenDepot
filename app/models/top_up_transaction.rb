class TopUpTransaction < ApplicationRecord
  
  include AASM

  aasm no_direct_assignment: true, whiny_transitions: false  do
 
    state :initiated, initial: true
    state :receiving_wallet_assigned
    state :pending
    state :transaction_successful
    state :transaction_unsuccessful

    event :assign_receiving_wallet do
      transitions from: :initiated, to: :receiving_wallet_assigned
      
      before do
        puts "@DEBUG L:#{__LINE__}   Running before 'assign_receiving_wallet'"
      end
      
      after do
        puts "@DEBUG L:#{__LINE__}   Running after 'assign_receiving_wallet'"
      end
    end  
    
    event :check_for_incoming_tranfer do
      transitions from: [:receiving_wallet_assigned, :transaction_successful, :transaction_unsuccessful], to: :pending
      
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
  end

  def status
    result = case self.aasm_state.to_sym
    when TopUpTransaction::STATE_INITIATED
      self.aasm_state
    when TopUpTransaction::STATE_RECEIVING_WALLET_ASSIGNED, TopUpTransaction::STATE_PENDING  
      TopUpTransaction::STATE_PENDING
    when TopUpTransaction::STATE_TRANSACTION_SUCCESSFUL
      self.aasm_state
    when TopUpTransaction::STATE_TRANSACTION_UNSUCCESSFUL
      self.aasm_state
    default
      "Unrecognized Status"
    end
    
    return result
  end
    
end
