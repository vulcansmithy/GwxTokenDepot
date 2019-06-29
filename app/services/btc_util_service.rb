class BtcUtilService < BaseUtilService
  
  GWX_TO_USD                           = 0.003

  BLOCKCHAIN_NETWORK                   = Rails.env.production? ? "BTC" : "BTCTEST"
  CHAIN_SO_API_GET_ADDRESS_BALANCE_URL = "https://chain.so/api/v2/get_address_balance/" 
  CHAIN_SO_API_GET_PRICE_URL           = "https://chain.so/api/v2/get_price"
  
  class BtcUtilServiceError < StandardError; end

  def assign_receiving_wallet(transaction)

    master_private_key = Rails.application.secrets.btc_master_private_key
    parent_node = MoneyTree::Node.from_bip32(master_private_key)
    
    result = TopUpTransaction.where(transaction_type: "btc").where.not(bip32_address_path: nil).order("created_at ASC")
    if result.empty?
      child_node  = parent_node.node_for_path("m/0/0")
      
      transaction.top_up_receiving_wallet_address = 
        if Rails.env.production? 
          child_node.to_address 
        else
          child_node.to_address(network: :bitcoin_testnet)
        end  
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
      transaction.top_up_receiving_wallet_address = if Rails.env.production? 
         child_node.to_address 
        else
          child_node.to_address(network: :bitcoin_testnet)
        end  
      
      # save the bip32_address_path
      transaction.bip32_address_path = bip32_address_path
    end 

    transaction.save   


    return transaction
  end  
  
  def check_btc_wallet_balance(transaction)

    begin
      # call the API endpoint
      response = HTTParty.get("#{CHAIN_SO_API_GET_ADDRESS_BALANCE_URL}#{BLOCKCHAIN_NETWORK}/#{transaction.top_up_receiving_wallet_address}")
      
      # make sure the response code is :ok before continuing
      raise BtcUtilServiceError, "Can't reach API endpoint." unless response.code == 200
      
      # parse the returned data
      result = JSON.parse(response.body)

      # retrieve confirmed_balance data
      confirmed_balance = result["data"]["confirmed_balance"]
      raise "Was not able to returned JSON data 'confirmed_balance' "if confirmed_balance.nil?

    rescue Exception => e
      raise BtcUtilServiceError, e.message
    else
      return BigDecimal(confirmed_balance)
    end  
  end  

  def get_btc_usd_conversion_rate
    response = HTTParty.get("#{CHAIN_SO_API_GET_PRICE_URL}/BTC/USD")
    
    # make sure the response code is :ok before continuing
    raise BtcUtilServiceError, "Can't reach API endpoint." unless response.code == 200
    
    # parse the returned data
    result = JSON.parse(response.body)
    
    # get the btc to USD exchange rate
    exchange_rate = result["data"]["prices"][0]["price"]
    raise BtcUtilServiceError, "Can't reach the API endpoint. Was not able to get the 'price' value." if exchange_rate.nil?
    
    # get the timestamp
    timestamp = result["data"]["prices"][0]["time"] 
    raise BtcUtilServiceError, "Can't reach the API endpoint. Was not able to get the 'time' value." if timestamp.nil?
    
    return exchange_rate.to_f, Time.at(timestamp).utc
  end
  
  def convert_btc_to_gwx(btc_value)
    
    btc_to_usd_conversation_rate = (self.get_btc_usd_conversion_rate)[0]
    
    return (btc_value * btc_to_usd_conversation_rate) / GWX_TO_USD
  end

end