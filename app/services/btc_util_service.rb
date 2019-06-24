class BtcUtilService < BaseUtilService

  def assign_receiving_wallet(transaction)
    puts "@DEBUG L:#{__LINE__}   Running BtcUtilService..."
    # @TODO include core code for actual assignment of wallet address
    
    master_private_key = Rails.application.secrets.master_private_key
    puts "@DEBUG L:#{__LINE__}   master_private_key='#{master_private_key}'"
    
    transaction.top_up_receiving_wallet_address = "abc123def456"
    transaction.bip32_address_path              = "m/0/5"
    
    return transaction
  end  
    
end