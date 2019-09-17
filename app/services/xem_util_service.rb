class XemUtilService < BaseUtilService

  GWX_TO_USD = 0.019

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
    exchange_rate = RealTimeRate.last.xem_rate.to_f

    return exchange_rate.to_f
  end

  def convert_xem_to_gwx(xem_value)
    xem_to_usd_conversation_rate = self.get_xem_usd_conversion_rate

    return (xem_value * GWX_TO_USD) / xem_to_usd_conversation_rate
  end

end
