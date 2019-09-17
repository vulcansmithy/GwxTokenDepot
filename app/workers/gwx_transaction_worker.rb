class GwxTransactionWorker

  include Sidekiq::Worker

  def perform(tx_id)
    transaction = TopUpTransaction.find(tx_id)
    transaction.confirm_gwx_status_from_cashier
    transaction.validate_gwx_status_from_cashier
  
    if transaction.gwx_transaction_hash.nil?
      puts "Rescheduling worker"
  
      GwxTransactionWorker.perform_in(2.minutes, transaction.id)
    end
  end
end
