class BtcTransactionWorker

  include Sidekiq::Worker

  def perform(transaction_id)
    
    btc_transaction = TopUpTransaction.where(id: transaction_id).first
    
    starting_point = btc_transaction.created_at
      ending_point = starting_point + TopUpTransaction::RECEIVING_PERIOD
          time_now = Time.zone.now
    
    # check if still in the receiving period window
    if (starting_point..ending_point).cover?(time_now)
      
      btc_service = BtcUtilService.new
      
      # retrieve current_balance
      current_balance = btc_service.check_btc_wallet_balance(btc_transaction)
      
      if current_balance == 0

        puts "@DEBUG L:#{__LINE__}   ***************************"
        puts "@DEBUG L:#{__LINE__}      Rescheduling...      "
        puts "@DEBUG L:#{__LINE__}      Transaction ID: #{transaction_id}"
        puts "@DEBUG L:#{__LINE__}   ***************************"
        BtcTransactionWorker.perform_in(TopUpTransaction::SCHEDULED_INTERVAL, btc_transaction.id)

      elsif current_balance >= btc_transaction.quantity_to_receive

        puts "@DEBUG L:#{__LINE__}   ***************************"
        puts "@DEBUG L:#{__LINE__}   *  Transaction Successful!  "
        puts "@DEBUG L:#{__LINE__}   *  Transaction ID: #{transaction_id}"
        puts "@DEBUG L:#{__LINE__}   ***************************"
        btc_transaction.confirm_transaction_successful
        
        # transfer the gwx to the gwx_wallet_address
        btc_transaction.transfer_gwx_to_gwx_wallet
      else
        
        puts "@DEBUG L:#{__LINE__}   ***************************"
        puts "@DEBUG L:#{__LINE__}      Rescheduling...      "
        puts "@DEBUG L:#{__LINE__}      Transaction ID: #{transaction_id}"
        puts "@DEBUG L:#{__LINE__}   ***************************"
        BtcTransactionWorker.perform_in(TopUpTransaction::SCHEDULED_INTERVAL, btc_transaction.id)
      end    
    else
      puts "@DEBUG L:#{__LINE__}   ***************************"
      puts "@DEBUG L:#{__LINE__}   *  Transaction FAILED!!!   "
      puts "@DEBUG L:#{__LINE__}   *  Transaction ID: #{transaction_id}"
      puts "@DEBUG L:#{__LINE__}   ***************************"
      btc_transaction.set_transaction_unssuccesful
    end
  end

end
