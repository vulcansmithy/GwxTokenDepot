class TopUpTransactionSerializer < ActiveModel::Serializer

  include FastJsonapi::ObjectSerializer

  attribute :transaction_id do |transaction|
    transaction.id
  end

  attributes :user_id,
    :quantity_to_receive,
    :transaction_type,
    :gwx_to_transfer,
    :top_up_receiving_wallet_address,
    :created_at
#   :top_up_transaction_hash,
#   :top_up_transaction_at,
#   :gwx_transaction_hash,
#    :gwx_transaction_at

  attribute :status do |transaction|
    transaction.status
  end    
  
end
