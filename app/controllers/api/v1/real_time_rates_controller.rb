class Api::V1::RealTimeRatesController < Api::V1::BaseController
  include HTTParty

  def get_rates
    response = HTTParty.get("http://api.coinlayer.com/live?access_key=#{Rails.application.secrets.coinlayer_api_key}")
    result = JSON.parse(response.body)
    rates = RealTimeRate.new({
      btc_rate: result["rates"]["BTC"],
      eth_rate: result["rates"]["ETH"],
      xem_rate: result["rates"]["XEM"],
      real_time_at: Time.at(result["timestamp"]).to_datetime
    })
    if rates.save
      success_response(RealTimeRateSerializer.new(rates).serialized_json)
    else
      raise "Unable to fetch data on coinlayer"
    end
  end


  def get_current_rate
    success_response(RealTimeRateSerializer.new(RealTimeRate.last).serialized_json, :created)
  end

end
