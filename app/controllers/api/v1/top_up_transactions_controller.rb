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
    # @TODO to be implemented
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
      :top_up_quantity, 
      :transaction_type,
      :top_up_receiving_wallet_address,  
      :gwx_wallet_address)
