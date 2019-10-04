class GwxCashierClient
  include HTTParty
  base_uri Rails.application.secrets.cashier_base_uri

  class << self
    def create_transaction(args)
      post("/transactions", body: args[:transaction_params])
    end

    def get_transaction(args)
      get("/transactions/#{args[:id]}")
    end

    def create_xem_transaction(args)
      post("/transactions/xem", body: args[:transaction_params])
    end
  end
end