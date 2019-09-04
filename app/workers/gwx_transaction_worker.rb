class GwxTransactionWorker

  include Sidekiq::Worker

  def perform(transaction_id)

    gwx_transaction = TopUpTransaction.where(id: transaction_id)

    if gwx_transaction.gwx_transaction_hash

      puts "@DEBUG L:#{__LINE__}   ***************************"
      puts "@DEBUG L:#{__LINE__}   *  Transaction Successful!  "
      puts "@DEBUG L:#{__LINE__}   *  Transaction ID: #{gwx_transaction_id}"
      puts "@DEBUG L:#{__LINE__}   ***************************"
      transaction.confirm_gwx_status_from_cashier

    else

      puts "@DEBUG L:#{__LINE__}   ***************************"
      puts "@DEBUG L:#{__LINE__}      Rescheduling...      "
      puts "@DEBUG L:#{__LINE__}      Transaction ID: #{gwx_transaction_id}"
      puts "@DEBUG L:#{__LINE__}   ***************************"
      GwxTransactionWorker.perform_in(2.minutes, gwx_transaction.id)

    end
  end
end
