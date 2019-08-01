module TransactionWorkerUtil
  
  def check_transaction(transaction)
    
    transaction_type = transaction.transaction_type
    starting_point   = transaction.created_at
      ending_point   = starting_point + TopUpTransaction::RECEIVING_PERIOD
          time_now   = Time.zone.now
    
    current_balance     = nil 
    expected_to_receive = nil
    # check if still in the receiving period window
    if (starting_point..ending_point).cover?(time_now)
      
      # instantiate specific coin service
      coin_service = "#{transaction_type.titlecase}UtilService".constantize.new
 
      # retrieve current_balance
      result          = coin_service.send("check_#{transaction_type.downcase}_wallet_balance", transaction)
      current_balance = BigDecimal(result.to_s)

      # convert the quantity_to_receive into a BigDecimal
      expected_to_receive = BigDecimal(transaction.quantity_to_receive)
      
      if current_balance == 0.0

        puts "@DEBUG L:#{__LINE__}   ***************************"
        puts "@DEBUG L:#{__LINE__}      Rescheduling...      "
        puts "@DEBUG L:#{__LINE__}      Transaction ID: #{transaction.id}"
        puts "@DEBUG L:#{__LINE__}   ***************************"

        transaction.message = "As of #{Time.now}, the receiving wallet has #{current_balance} balance. This transaction is to be rescheduled for checking."
        puts "@DEBUG L:#{__LINE__}   transaction.save=#{transaction.save}"
        
        # reschedule the worker
        Object.const_get("#{transaction_type.titlecase}TransactionWorker").perform_in(TopUpTransaction::SCHEDULED_INTERVAL, transaction.id)
        
      elsif current_balance >= expected_to_receive

        puts "@DEBUG L:#{__LINE__}   ***************************"
        puts "@DEBUG L:#{__LINE__}   *  Transaction Successful!  "
        puts "@DEBUG L:#{__LINE__}   *  Transaction ID: #{transaction.id}"
        puts "@DEBUG L:#{__LINE__}   ***************************"
        transaction.confirm_transaction_successful
        
        transaction.message = "As of #{Time.now}, the receiving wallet current balance is #{current_balance}. This transaction was successful."
        puts "@DEBUG L:#{__LINE__}   transaction.save=#{transaction.save}"
        
        # transfer the gwx to the gwx_wallet_address
        transaction.transfer_gwx_to_gwx_wallet
      else
        
        puts "@DEBUG L:#{__LINE__}   ***************************"
        puts "@DEBUG L:#{__LINE__}      Rescheduling...      "
        puts "@DEBUG L:#{__LINE__}      Transaction ID: #{transaction.id}"
        puts "@DEBUG L:#{__LINE__}   ***************************"
        
        transaction.message = "As of #{Time.now}, the receiving wallet current balance is #{current_balance}. The expected balance was #{expected_to_receive}. This transaction is to be rescheduled for checking."
        puts "@DEBUG L:#{__LINE__}   transaction.save=#{transaction.save}"

        # reschedule the worker
        Object.const_get("#{transaction_type.titlecase}TransactionWorker").perform_in(TopUpTransaction::SCHEDULED_INTERVAL, transaction.id)  
      end    
    else
      puts "@DEBUG L:#{__LINE__}   ***************************"
      puts "@DEBUG L:#{__LINE__}   *  Transaction FAILED!!!   "
      puts "@DEBUG L:#{__LINE__}   *  Transaction ID: #{transaction.id}"
      puts "@DEBUG L:#{__LINE__}   ***************************"
      
      transaction.message = "As of #{Time.now}, the receiving wallet current balance is #{current_balance}. The expected balance was #{expected_to_receive}. This transaction was unsuccessful."
      puts "@DEBUG L:#{__LINE__}   transaction.save=#{transaction.save}"
      
      transaction.set_transaction_unssuccesful
    end
  end
  
end