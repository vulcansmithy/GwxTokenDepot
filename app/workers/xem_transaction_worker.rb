class XemTransactionWorker

  include Sidekiq::Worker

  def perform(transaction_id)
    
    xem_transaction = TopUpTransaction.where(id: transaction_id).first
    
    starting_point = xem_transaction.created_at
      ending_point = starting_point + TopUpTransaction::RECEIVING_PERIOD
          time_now = Time.zone.now
    
    # check if still in the receiving period window
    if (starting_point..ending_point).cover?(time_now)
      
      xem_service = XemUtilService.new
      
      # retrieve current_balance
      current_balance = xem_service.check_xem_wallet_balance(xem_transaction)
      
      # convert the quantity_to_receive into a BigDecimal
      expected_to_receive = BigDecimal(xem_transaction.quantity_to_receive)
      
      if current_balance == 0

        puts "@DEBUG L:#{__LINE__}   ***************************"
        puts "@DEBUG L:#{__LINE__}      Rescheduling...      "
        puts "@DEBUG L:#{__LINE__}      Transaction ID: #{transaction_id}"
        puts "@DEBUG L:#{__LINE__}   ***************************"
        XemTransactionWorker.perform_in(TopUpTransaction::SCHEDULED_INTERVAL, xem_transaction.id)

      elsif current_balance >= expected_to_receive

        puts "@DEBUG L:#{__LINE__}   ***************************"
        puts "@DEBUG L:#{__LINE__}   *  Transaction Successful!  "
        puts "@DEBUG L:#{__LINE__}   *  Transaction ID: #{transaction_id}"
        puts "@DEBUG L:#{__LINE__}   ***************************"
        xem_transaction.confirm_transaction_successful
        
        # transfer the gwx to the gwx_wallet_address
        xem_transaction.transfer_gwx_to_gwx_wallet
        GwxTransactionWorker.perform_in(2.minutes, xem_transaction.id)
      else
        
        puts "@DEBUG L:#{__LINE__}   ***************************"
        puts "@DEBUG L:#{__LINE__}      Rescheduling...      "
        puts "@DEBUG L:#{__LINE__}      Transaction ID: #{transaction_id}"
        puts "@DEBUG L:#{__LINE__}   ***************************"
        XemTransactionWorker.perform_in(TopUpTransaction::SCHEDULED_INTERVAL, xem_transaction.id)
      end    
    else
      puts "@DEBUG L:#{__LINE__}   ***************************"
      puts "@DEBUG L:#{__LINE__}   *  Transaction FAILED!!!   "
      puts "@DEBUG L:#{__LINE__}   *  Transaction ID: #{transaction_id}"
      puts "@DEBUG L:#{__LINE__}   ***************************"

      xem_transaction.message = "As of #{Time.now}, the receiving wallet current balance is #{current_balance}. The expected balance was #{expected_to_receive}. This transaction was unsuccessful."
      puts "@DEBUG L:#{__LINE__}   transaction.save=#{xem_transaction.save}"

      xem_transaction.set_transaction_unssuccesful
    end
  end



end
