class BtcUtilService < BaseUtilService

  GWX_TO_USD                                  = 0.019

  BLOCKCHAIN_NETWORK                          = Rails.env.production? ? "btc" : "test3"
  BLOCKCYPHER_API_GET_BTC_ADDRESS_BALANCE_URL = "https://api.blockcypher.com/v1/#{BLOCKCHAIN_NETWORK}/main/addrs/"
  COINCAP_API_GET_BTC_TO_USD_PRICE_URL        = "https://api.coincap.io/v2/assets?ids=bitcoin"

  class BtcUtilServiceError < StandardError; end

  def assign_receiving_wallet(transaction)

    master_private_key = Rails.application.secrets.btc_master_private_key
    parent_node = MoneyTree::Node.from_bip32(master_private_key)

    result = TopUpTransaction.where(transaction_type: "btc").where.not(bip32_address_path: nil).order("created_at ASC")
    if result.empty?
      # retrieve the child_node from the computed bip32_address_path
      child_node  = parent_node.node_for_path("m/0/0")

      # save the bip32_address_path
      transaction.bip32_address_path = "m/0/0"
    else
      # retrieve the last node count
      count = (result.last).bip32_address_path.scan(/\d*\z/).first.to_i

      # increment the count by 1
      count += 1

      bip32_address_path = "m/0/#{count}"

      # retrieve the child_node from the computed bip32_address_path
      child_node = parent_node.node_for_path(bip32_address_path)

      # save the bip32_address_path
      transaction.bip32_address_path = bip32_address_path
    end

    # save the receiving wallet_address
    transaction.top_up_receiving_wallet_address = Rails.env.production? ? child_node.to_address : child_node.to_address(network: :bitcoin_testnet)

    raise BtcUtilServiceError, "Transaction save failed." unless transaction.save


    return transaction
  end

  def check_btc_wallet_balance(transaction)
    begin
      # call the API endpoint
      puts "ERROR HANDLING"
      puts request = "#{BLOCKCYPHER_API_GET_BTC_ADDRESS_BALANCE_URL}#{transaction.top_up_receiving_wallet_address}"
      puts "=============="

      response = HTTParty.get("#{BLOCKCYPHER_API_GET_BTC_ADDRESS_BALANCE_URL}#{transaction.top_up_receiving_wallet_address}")
      puts "=====RESPONSE===="
      puts response
      puts "================="
      # make sure the response code is :ok before continuing
      raise BtcUtilServiceError, "Can't reach API endpoint." unless response.code == 200

      # parse the returned data
      result = JSON.parse(response.body)

      # retrieve confirmed_balance data
      confirmed_balance = result["balance"]
      puts "====BALANCE===="
      puts confirmed_balance
      puts "==============="

      raise "Was not able to returned JSON data 'balance' "if confirmed_balance.nil?

    rescue Exception => e
      raise BtcUtilServiceError, e.message
    else
      return BigDecimal(confirmed_balance)
    end
  end

  def get_btc_usd_conversion_rate
    response = HTTParty.get(COINCAP_API_GET_BTC_TO_USD_PRICE_URL)

    # make sure the response code is :ok before continuing
    raise BtcUtilServiceError, "Can't reach API endpoint." unless response.code == 200

    # parse the returned data
    result = JSON.parse(response.body)

    # get the btc to USD exchange rate
    exchange_rate = (result["data"][0]["priceUsd"]).to_f
    raise BtcUtilServiceError, "Can't reach the API endpoint. Was not able to get the 'priceUsd' value." if exchange_rate.nil?

    return exchange_rate.to_f
  end

  def convert_btc_to_gwx(btc_value)

    btc_to_usd_conversation_rate = self.get_btc_usd_conversion_rate

    return (btc_value * btc_to_usd_conversation_rate) / GWX_TO_USD
  end

end
