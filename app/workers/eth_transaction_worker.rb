class EthTransactionWorker

  include Sidekiq::Worker

  def perform(transaction_id)
    # @TODO
    eth_transaction = TopUpTransaction.where(id: transaction_id).first
    
    puts "@DEBUG L:#{__LINE__}    transaction_id: #{transaction_id    }"
    puts "@DEBUG L:#{__LINE__}   eth_transaction: #{ap eth_transaction}"
  end

end
