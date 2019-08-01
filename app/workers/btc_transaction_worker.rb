class BtcTransactionWorker
  
  include Sidekiq::Worker
  include TransactionWorkerUtil

  def perform(transaction_id)
    
    # retrieve the btc transaction
    btc_transaction = TopUpTransaction.where(id: transaction_id).first
    
    check_transaction(btc_transaction)
  end

end
