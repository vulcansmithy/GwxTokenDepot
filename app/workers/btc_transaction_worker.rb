class BtcTransactionWorker

  include Sidekiq::Worker

  def perform(transaction_id)
    
    # @TODO
    
    btc_transaction = TopUpTransaction.where(id: transaction_id).first
    
    starting_point = btc_transaction.created_at
      ending_point = starting_point + TopUpTransaction::RECEIVING_PERIOD
          time_now = Time.zone.now
      
    puts "@DEBUG L:#{__LINE__}    starting_point: #{starting_point    }" 
    puts "@DEBUG L:#{__LINE__}      ending_point: #{ending_point      }" 
    puts "@DEBUG L:#{__LINE__}          time_now: #{time_now          }"
    
    if (starting_point..ending_point).cover?(time_now)
      puts "@DEBUG L:#{__LINE__}   *******************"
      puts "@DEBUG L:#{__LINE__}     Rescheduling...  "
      puts "@DEBUG L:#{__LINE__}     Transaction ID: #{transaction_id}"
      puts "@DEBUG L:#{__LINE__}   *******************"
      BtcTransactionWorker.perform_in(TopUpTransaction::SCHEDULED_INTERVAL, btc_transaction.id)
    else
      puts "@DEBUG L:#{__LINE__}   ***************************"
      puts "@DEBUG L:#{__LINE__}     Transaction successful!  "
      puts "@DEBUG L:#{__LINE__}     Transaction ID: #{transaction_id}"
      puts "@DEBUG L:#{__LINE__}   ***************************"
      btc_transaction.confirm_transaction_successful
      puts "@DEBUG L:#{__LINE__}   #{ap btc_transaction}"
    end    
  end

end
