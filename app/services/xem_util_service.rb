class XemUtilService < BaseUtilService
  
  class XemUtilServiceError < StandardError; end

  def assign_receiving_wallet(transaction)
    account = NemService.create_account
    
    transaction.top_up_receiving_wallet_address = account[:address ]
    transaction.top_up_receiving_wallet_pk      = account[:priv_key]
    
    transaction.save 
    
    return transaction
  end  
  
  def check_btc_wallet_balance(transaction)
    result = NemService.check_balance(transaction.top_up_receiving_wallet_address)
    
    return result[:xem]
  end
  
  def get_btc_usd_conversion_rate
    # @TODO
  end
  
  def convert_btc_to_gwx((btc_value))
    # @TODO
  end  
  
end