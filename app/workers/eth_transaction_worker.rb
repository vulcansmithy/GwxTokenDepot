class EthTransactionWorker

  include Sidekiq::Worker

  def perform(transaction_id)
    
    eth_transaction = TopUpTransaction.where(id: transaction_id).first
    
    starting_point = eth_transaction.created_at
      ending_point = starting_point + TopUpTransaction::RECEIVING_PERIOD
          time_now = Time.zone.now
    
    # check if still in the receiving period window
    if (starting_point..ending_point).cover?(time_now)
      
      eth_service = EthUtilService.new
      
      # retrieve current_balance
      current_balance = eth_service.check_eth_wallet_balance(eth_transaction)
      
      # convert the quantity_to_receive into a BigDecimal
      expected_to_receive = BigDecimal(eth_transaction.gwx_to_transfer)
      
      if current_balance == 0

        puts "@DEBUG L:#{__LINE__}   ***************************"
        puts "@DEBUG L:#{__LINE__}      Rescheduling...      "
        puts "@DEBUG L:#{__LINE__}      Transaction ID: #{transaction_id}"
        puts "@DEBUG L:#{__LINE__}   ***************************"
        EthTransactionWorker.perform_in(TopUpTransaction::SCHEDULED_INTERVAL, eth_transaction.id)

      elsif current_balance >= expected_to_receive

        puts "@DEBUG L:#{__LINE__}   ***************************"
        puts "@DEBUG L:#{__LINE__}   *  Transaction Successful!  "
        puts "@DEBUG L:#{__LINE__}   *  Transaction ID: #{transaction_id}"
        puts "@DEBUG L:#{__LINE__}   ***************************"
        eth_transaction.confirm_transaction_successful
        
        # transfer the gwx to the gwx_wallet_address
        eth_transaction.transfer_gwx_to_gwx_wallet
        GwxTransactionWorker.perform_in(2.minutes, eth_transaction.id)
      else
        
        puts "@DEBUG L:#{__LINE__}   ***************************"
        puts "@DEBUG L:#{__LINE__}      Rescheduling...      "
        puts "@DEBUG L:#{__LINE__}      Transaction ID: #{transaction_id}"
        puts "@DEBUG L:#{__LINE__}   ***************************"
        EthTransactionWorker.perform_in(TopUpTransaction::SCHEDULED_INTERVAL, eth_transaction.id)
      end    
    else
      puts "@DEBUG L:#{__LINE__}   ***************************"
      puts "@DEBUG L:#{__LINE__}   *  Transaction FAILED!!!   "
      puts "@DEBUG L:#{__LINE__}   *  Transaction ID: #{transaction_id}"
      puts "@DEBUG L:#{__LINE__}   ***************************"
      eth_transaction.set_transaction_unssuccesful
    end
  end

end
