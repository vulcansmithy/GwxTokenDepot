class XemUtilService < BaseUtilService
  
  GWX_TO_USD = 0.20
  
  class XemUtilServiceError < StandardError; end

  def assign_receiving_wallet(transaction)
    account = NemService.create_account

    transaction.top_up_receiving_wallet_address = account[:address ]
    transaction.top_up_receiving_wallet_pk      = account[:priv_key]

    r=transaction.save 
    
    return transaction
  end  
  
  def check_xem_wallet_balance(transaction)
    result = NemService.check_balance(transaction.top_up_receiving_wallet_address)
    
    return result[:xem]
  end
  
  def get_xem_usd_conversion_rate
    response = HTTParty.get("https://api.coincap.io/v2/assets?ids=nem,bitcoin,ethereum")
    
    # make sure the response code is :ok before continuing
    raise BtcUtilServiceError, "Can't reach API endpoint." unless response.code == 200
    
    # parse the returned data
    result = JSON.parse(response.body)
    
    # get the btc to USD exchange rate
    exchange_rate = (result["data"][2]["priceUsd"]).to_f
    raise BtcUtilServiceError, "Can't reach the API endpoint. Was not able to get the 'priceUsd' value." if exchange_rate.nil?

    return exchange_rate
  end
  
  def convert_xem_to_gwx(xem_value)
    xem_to_usd_conversation_rate = self.get_xem_usd_conversion_rate
    
    return (xem_value * xem_to_usd_conversation_rate) / GWX_TO_USD
  end
  
end