module TransactionWorkerUtil
  
  def check_transaction(transaction)
    
    transaction_type = transaction.transaction_type
    starting_point   = transaction.created_at
      ending_point   = starting_point + TopUpTransaction::RECEIVING_PERIOD
          time_now   = Time.zone.now
    
    # check if still in the receiving period window
    if (starting_point..ending_point).cover?(time_now)
      
      # instantiate specific coin service
      coin_service = "#{transaction_type.titlecase}UtilService".constantize.new
 
      # retrieve current_balance
      result          = coin_service.send("check_#{transaction_type.lowercase}.wallet_balance", transaction)
      current_balance = BigDecimal(result.to_s)

      # convert the quantity_to_receive into a BigDecimal
      expected_to_receive = BigDecimal(transaction.quantity_to_receive)
      
      if current_balance == 0.0

        puts "@DEBUG L:#{__LINE__}   ***************************"
        puts "@DEBUG L:#{__LINE__}      Rescheduling...      "
        puts "@DEBUG L:#{__LINE__}      Transaction ID: #{transaction_id}"
        puts "@DEBUG L:#{__LINE__}   ***************************"
        
        # reschedule the worker
        ("#{transaction_type.titlecase}TransactionWorker".constantize.new).perform_in(TopUpTransaction::SCHEDULED_INTERVAL, transaction.id)

      elsif current_balance >= expected_to_receive

        puts "@DEBUG L:#{__LINE__}   ***************************"
        puts "@DEBUG L:#{__LINE__}   *  Transaction Successful!  "
        puts "@DEBUG L:#{__LINE__}   *  Transaction ID: #{transaction_id}"
        puts "@DEBUG L:#{__LINE__}   ***************************"
        transaction.confirm_transaction_successful
        
        # transfer the gwx to the gwx_wallet_address
        transaction.transfer_gwx_to_gwx_wallet
      else
        
        puts "@DEBUG L:#{__LINE__}   ***************************"
        puts "@DEBUG L:#{__LINE__}      Rescheduling...      "
        puts "@DEBUG L:#{__LINE__}      Transaction ID: #{transaction_id}"
        puts "@DEBUG L:#{__LINE__}   ***************************"
        
        # reschedule the worker
        ("#{transaction_type.titlecase}TransactionWorker".constantize.new).perform_in(TopUpTransaction::SCHEDULED_INTERVAL, transaction.id)
      end    
    else
      puts "@DEBUG L:#{__LINE__}   ***************************"
      puts "@DEBUG L:#{__LINE__}   *  Transaction FAILED!!!   "
      puts "@DEBUG L:#{__LINE__}   *  Transaction ID: #{transaction_id}"
      puts "@DEBUG L:#{__LINE__}   ***************************"
      transaction.set_transaction_unssuccesful
    end
  end
  
end