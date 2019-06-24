class BtcUtilService < BaseUtilService
  
  class BtcUtilServiceError < StandardError; end

  def assign_receiving_wallet(transaction)

    master_private_key = Rails.application.secrets.btc_master_private_key
    parent_node = MoneyTree::Node.from_bip32(master_private_key)
    
    result = TopUpTransaction.where(transaction_type: "btc").where.not(bip32_address_path: nil).order("created_at ASC")
    if result.empty?
      child_node  = parent_node.node_for_path("m/0/0")
      
      transaction.top_up_receiving_wallet_address = child_node.to_address(network: :bitcoin_testnet)
      transaction.bip32_address_path = "m/0/0"
    else
      # retrieve the last node count
      count = (result.last).bip32_address_path.scan(/\d*\z/).first.to_i
      
      # increment the count by 1
      count += 1
      
      bip32_address_path = "m/0/#{count}"

      # retrieve the child_node from the computed bip32_address_path
      child_node = parent_node.node_for_path(bip32_address_path)

      # save the receiving wallet_address
      transaction.top_up_receiving_wallet_address = child_node.to_address(network: :bitcoin_testnet)
      
      # save the bip32_address_path
      transaction.bip32_address_path = bip32_address_path
    end 

    transaction.save   


    return transaction
  end  
    
end