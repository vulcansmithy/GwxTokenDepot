class RealTimeRateSerializer < ActiveModel::Serializer

  include FastJsonapi::ObjectSerializer

  attributes :btc_rate,
    :eth_rate,
    :xem_rate,
    :real_time_at
end
