class TopUpTransactionWorker

  include Sidekiq::Worker

  def perform(top_up_transaction_id)
    # @TODO
    top_up_transaction = TopUpTransaction.where(id: top_up_transaction_id).first
    
    puts "@DEBUG L:#{__LINE__}   #{ap top_up_transaction}"
  end

end
