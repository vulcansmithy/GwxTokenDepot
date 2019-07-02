require "swagger_helper"

describe "Gameworks Token Depot API" do

=begin
  path "/v1/top_up_transactions" do
    get "Retrieve all Top Up Transactions for a particular User" do
      tags "Top Up Transaction"
      description "Retrieve all Top Up Transactions for a particular User."
      produces "application/json"
      parameter name: :user_id, in: :path, type: :string, description: "the id of the user"

      
      response "200", "Return All Top Up Transaction(s) for a particular user." do
        run_test!
      end
      
      response "400", "Missing 'user_id' parameter." do
        run_test!
      end 
    end
  end
  
  path "/v1/top_up_transactions" do
    post "Create a new Top Up Transaction" do
      tags "Top Up Transaction"
      description "Create a new Top Up Transaction."
      produces "application/json"
      parameter name: :top_up_transaction, in: :body, schema: {
        type: :object,
        properties: {
                        user_id: { type: :string },
            quantity_to_receive: { type: :number },
                gwx_to_transfer: { type: :string },
               transaction_type: { type: :string },
             gwx_wallet_address: { type: :string },
        },
        required: ["user_id", "quantity_to_receive", "gwx_to_transfer", "transaction_type", "gwx_wallet_address"]
      }
      
      response "200", "New Top Up Transaction successfully created." do
        run_test!
      end
      
      response "422", "Transaction failed." do
        run_test!
      end 
    end
  end
  
  path "/v1/top_up_transactions/{:id}" do
    get "Retreive a particular TopUpTransaction" do
      tags "Top Up Transaction"
      description "Retreive a particular TopUpTransaction."
      produces "application/json" 
      parameter name: :id, in: :path, description: "the TopUpTransaction 'id'", required: true, type: :string
      
      response "200", "Return a specific TopUpTransaction." do
        
        examples "application/json" => {
          "data" => {
                      "id" => "230",
                    "type" => "top_up_transaction",
              "attributes" => {
                                "user_id" => "417",
                    "quantity_to_receive" => "500.0",
                       "transaction_type" => "btc",
                "top_up_transaction_hash" => "nil",
                  "top_up_transaction_at" => "nil",
                   "gwx_transaction_hash" => "nil",
                     "gwx_transaction_at" => "nil",
                                 "status" => "pending"
              }
          }
        }
        
        run_test!
      end  
    end
  end

  path "/v1/top_up_transactions/calculate/btc/{:btc_value}/to_gwx" do
    get "Calculate the gwx from the btc value" do
      tags "Top Up Transaction"
      description "Calculate the gwx from the btc value."
      produces "application/json" 
      parameter name: :btc_value, in: :path, description: "the btc value to be converted", required: true, type: :string
      
      response "200", "Return a the calculated gwx from the btc value." do
        
        examples "application/json" => { 
          "btc": 1.5, 
          "gwx": 5131068.1825 
        }
        
        run_test!
      end  
    end
  end

  path "/v1/top_up_transactions/calculate/xem/{:xem_value}/to_gwx" do
    get "Calculate the xem from the btc value" do
      tags "Top Up Transaction"
      description "Calculate the xem from the btc value."
      produces "application/json" 
      parameter name: :xem_value, in: :path, description: "the xem value to be converted", required: true, type: :string
      
      response "200", "Return a the calculated xem from the btc value." do
        
        examples "application/json" => { 
          "xem": 1.5, 
          "gwx": 44.58296715233445 
        }
        
        run_test!
      end  
    end
  end
=end
  
end