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
  
  def check_btc_wallet_balance(transaction)

    begin
      # call the API endpoint
      response = HTTParty.get("https://api.blockcypher.com/v1/eth/main/addrs/#{transaction.top_up_receiving_wallet_address}/balance")
      
      # make sure the response code is :ok before continuing
      raise BtcUtilServiceError, "Can't reach API endpoint." unless response.code == 200
      
      # parse the returned data
      result = JSON.parse(response.body)

      # retrieve balance data
      balance = result["balance"]
      raise "Was not able to returned JSON data 'balance' "if balance.nil?

    rescue Exception => e
      raise BtcUtilServiceError, e.message
    else
      return BigDecimal(balance)
    end  
  end 
  
end