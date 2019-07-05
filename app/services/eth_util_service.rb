class EthUtilService < BaseUtilService
  
  class EthUtilServiceError < StandardError; end

  def assign_receiving_wallet(transaction)

    eth_master_seed    = Rails.application.secrets.eth_master_seed
    bip44_address_path = nil
    
    raise EthUtilServiceError, "This transaction is not of type 'eth'." unless transaction.transaction_type == "eth"

    # get the latest entry for TopUpTransactions of type eth and its bip44_address_path is not nil  
    result = TopUpTransaction.where(transaction_type: "eth").where.not(bip44_address_path: nil).order("created_at ASC")
    if result.empty?
      bip44_address_path = "m/44'/60'/0'/0"
      wallet = Bip44::Wallet.from_seed(eth_master_seed, bip44_address_path)
    else
      # retrieve the last wallet count
      count = (result.last).bip44_address_path.scan(/\d*\z/).first.to_i
      
      # increment the count by 1
      count += 1
      
      bip32_address_path = "m/44'/60'/0'/#{count}"

      # retrieve the wallet from the computed bip44_address_path
      wallet = Bip44::Wallet.from_seed(eth_master_seed, bip44_address_path)
    end 

    # save the eth wallet address
    transaction.top_up_receiving_wallet_address = wallet.ethereum_address 
    
    # save the bip44_address_path
    transaction.bip44_address_path = bip44_address_path
    
    # save the transaction
    raise EthUtilServiceError, "Transaction save failed." unless transaction.save   


    return transaction
  end   
  
end