class Wallet
  include Mongoid::Document
  
  field :wallet_address, type: String
  field :primary,        type: Boolean, default: false
end
