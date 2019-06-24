class BtcTransactionWorker

  include Sidekiq::Worker

  def perform(transaction_id)
    # @TODO
    btc_transaction = TopUpTransaction.where(id: transaction_id).first
    
    puts "@DEBUG L:#{__LINE__}    transaction_id: #{transaction_id    }"
    puts "@DEBUG L:#{__LINE__}   btc_transaction: #{ap btc_transaction}"
  end

end
