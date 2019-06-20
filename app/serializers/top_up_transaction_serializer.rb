class TopUpTransactionSerializer < ActiveModel::Serializer

  include FastJsonapi::ObjectSerializer

  attributes :top_up_quantity,
    :transaction_type,
    :top_up_transaction_hash,
    :top_up_transaction_at,
    :gwx_transaction_hash,
    :gwx_transaction_at

  attribute :status do |transaction|
    transaction.status
  end    
  
end
