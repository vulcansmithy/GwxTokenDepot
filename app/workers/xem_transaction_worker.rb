class XemTransactionWorker

  include Sidekiq::Worker

  def perform(transaction_id)
    # @TODO
    xem_transaction = TopUpTransaction.where(id: transaction_id).first
    
    puts "@DEBUG L:#{__LINE__}    transaction_id: #{transaction_id    }"
    puts "@DEBUG L:#{__LINE__}   xem_transaction: #{ap xem_transaction}"
  end


end
