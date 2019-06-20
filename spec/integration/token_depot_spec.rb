require "swagger_helper"

describe "Gameworks Token Depot API" do

  ## Top Up Transaction
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
             top_up_quantity: { type: :number },
            transaction_type: { type: :string },
          gwx_wallet_address: { type: :string },
        },
        required: ["user_id", "top_up_quantity", "transaction_type", "gwx_wallet_address"]
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
                        "top_up_quantity" => "500.0",
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
  
 
=begin
  ## Transaction
  path "/api/v1/transactions/pending" do
    get "Retrieve all Pending Transaction" do
      tags "Transaction"
      description "Retrieve all Pending Transactions."
      produces "application/json"
      parameter name: :wallet_address, in: :body, schema: {
        type: :object,
        properties: {
          wallet_address: { type: :string },
        },
        required: ["wallet_address"]
      }
      
      response "200", "Return pending Transaction(s)." do
        run_test!
      end
      
      response "400", "Parameter 'wallet_address' is required." do
        run_test!
      end 
    end
  end
  
  path "/api/v1/transactions/xem" do
    post "Perform a XEM Transaction" do
      tags "Transaction"
      description "Perform a XEM Transaction."
      produces "application/json"
      parameter name: :transaction, in: :body, schema: {
        type: :object,
        properties: {
          destination_wallet_address: { type: :string },
               source_wallet_address: { type: :string },
                            quantity: { type: :number },
        },
        required: ["destination_wallet_address", "source_wallet_address", "quantity"]
      }
      
      response "200", "XEM transaction successfully processed." do
        run_test!
      end
      
      response "422", "Transaction failed." do
        run_test!
      end 
    end
  end

  path "/api/v1/transactions" do
    get "Retrieve all Transactions" do
      tags "Transaction"
      description "Retrieve all Transactions."
      produces "application/json" 
      
      response "200", "Return all trasactions." do
        run_test!
      end   
    end
  end

  path "/api/v1/transactions" do
    post "Perform a GWX Transaction" do
      tags "Transaction"
      description "Perform a GWX Transaction."
      produces "application/json"
      parameter name: :transaction, in: :body, schema: {
        type: :object,
        properties: {
          destination_wallet_address: { type: :string },
               source_wallet_address: { type: :string },
                            quantity: { type: :number },
        },
        required: ["destination_wallet_address", "source_wallet_address", "quantity"]
      }
      
      response "200", "GWX transaction successfully processed." do
        run_test!
      end
      
      response "422", "Transaction failed." do
        run_test!
      end 
    end
  end
  
  path "/api/v1/transactions/{id}" do
    get "Retrieve all Transactions" do
      tags "Transaction"
      description "Retrieve all Transactions."
      produces "application/json" 
      parameter name: :id, in: :path, description: " transaction 'id'", required: true, type: :integer
      
      
      response "200", "Return a specific Transaction." do
        run_test!
      end   
    end
  end
  
  
  # Shard
  path "/api/v1/shards" do
    post "Create a Shard entry" do
      tags "Shard"
      description "Create a new Shard entry"
      produces "application/json"
      parameter name: :shard, in: :body, schema: {
        type: :object,
        properties: {
          wallet_address: { type: :string, example: "TDZ5TE7WLDM6MHNXJFTYQUCLC3HE5ULRZVBX2OZT" },
           custodian_key: { type: :string, example: "gpIogXS9lFkV1NLB-rvI6tIvG_P70APYCzU1hUSLiP4=eL-unUmbSNeqSCLQ_KmKM7X3tyUdDJn3vTfAc0aqJIo=kvAXuc4EVp__3pQ1tRTYwygWag26RI8yfppVWleQx3E=sEw8a1TReBwAiteqdaR0uBy8BmZ_Ts5uV9Bey9sjNsk=" },
        },
        required: ["wallet_address", "custodian_key"]
      }

      response "201", "Shard entry created." do
        
        examples "application/json" => {
          "data" => {
                      "id" => "46",
                    "type" => "shard",
              "attributes" => {
                  "walletAddress" => "TDZ5TE7WLDM6MHNXJFTYQUCLC3HE5ULRZVBX2OZT",
                   "custodianKey" => "gpIogXS9lFkV1NLB-rvI6tIvG_P70APYCzU1hUSLiP4=eL-unUmbSNeqSCLQ_KmKM7X3tyUdDJn3vTfAc0aqJIo=kvAXuc4EVp__3pQ1tRTYwygWag26RI8yfppVWleQx3E=sEw8a1TReBwAiteqdaR0uBy8BmZ_Ts5uV9Bey9sjNsk="
              }
          }
        }

        run_test!
      end 
      
    end  
  end

  path "/api/v1/shards{:wallet_address}" do
    get "Retreive a particular Shard" do
      tags "Shard"
      description "Retrieve a particular Shard."
      produces "application/json" 
      parameter name: :wallet_address, in: :path, description: "the 'wallet_address'", required: true, type: :string
      
      response "200", "Return a specific Shard." do
        
        examples "application/json" => {
          "data" => {
                      "id" => "46",
                    "type" => "shard",
              "attributes" => {
                  "walletAddress" => "TDZ5TE7WLDM6MHNXJFTYQUCLC3HE5ULRZVBX2OZT",
                   "custodianKey" => "gpIogXS9lFkV1NLB-rvI6tIvG_P70APYCzU1hUSLiP4=eL-unUmbSNeqSCLQ_KmKM7X3tyUdDJn3vTfAc0aqJIo=kvAXuc4EVp__3pQ1tRTYwygWag26RI8yfppVWleQx3E=sEw8a1TReBwAiteqdaR0uBy8BmZ_Ts5uV9Bey9sjNsk="
              }
          }
        }
        
        run_test!
      end  
    end
  end
=end
  
end
