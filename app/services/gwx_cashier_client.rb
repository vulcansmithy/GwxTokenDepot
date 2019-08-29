class GwxCashierClient
  include HTTParty
  base_uri Rails.application.secret.base_uri


  def create_transaction(args)
    post("/transactions", body: args[:transaction_params])
  end

  def get_transaction(args)
    get("/transactions/#{:args}")
  end
end