class Api::V1::TopUpTransactionsController < Api::V1::BaseController

  def index
    if params[:user_id]
      top_up_transactions = TopUpTransaction.where(user_id: params[:user_id])
      success_response(TopUpTransactionSerializer.new(top_up_transactions).serialized_json)
    else
      error_response("", "Missing 'user_id' parameter.", :bad_request)
    end    
  end
  
  def create
    new_top_up_transaction = TopUpTransaction.new(top_up_transactions_params)
    if new_top_up_transaction.save
      
      new_top_up_transaction.assign_payment_receiving_wallet
      new_top_up_transaction.start_listening_for_incoming_transfer
      
      success_response(TopUpTransactionSerializer.new(new_top_up_transaction).serialized_json, :created)
    else
      error_response("Unable to create a new TopUpTransaction", new_top_up_transaction.errors.full_messages, :bad_request)
    end
  end
  
  def show
    top_up_transaction = TopUpTransaction.find_by(id: params[:id])
    if @wallet
      success_response(TopUpTransactionSerializer.new(top_up_transaction).serialized_json)
    else
      error_response("", "Top Up Transaction not found", :not_found)
    end
  end
  
  private

  def top_up_transactions_params
    params.permit(:user_id,    
      :quantity, 
      :transaction_type,
      :gwx_wallet_address)
  end
end