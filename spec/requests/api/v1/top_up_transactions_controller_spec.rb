require "rails_helper"
require "sidekiq/testing"

Sidekiq::Testing.fake!

describe Api::V1::TopUpTransactionsController do

  it "should be able to successfully call POST /top_up_transactions" do
    
    # setup params payload 1
    payload = {
                  user_id: 433,
      quantity_to_receive: 20999999.9769,
          gwx_to_transfer: 10.00000000,
         transaction_type: "btc",
       gwx_wallet_address: "TCP33TIK2FSSFWXUIBHWXNUZDGISPTCZE5YSSTJ1"
    }
    
    # call the API endpoint
    post "/top_up_transactions", params: payload
    
    # make sure the response status was 201 or :created
    expect(response.status).to eq 201

    # setup params payload 2
    payload = {
                  user_id: 586,
      quantity_to_receive: 1.000000,
          gwx_to_transfer: 20.00,
         transaction_type: "btc",
       gwx_wallet_address: "TCP33TIK2FSSFWXUIBHWXNUZDGISPTCZE5YSSTJ2"
    }
    
    # call the API endpoint
    post "/top_up_transactions", params: payload
    
    # make sure the response status was 201 or :created
    expect(response.status).to eq 201

    # setup params payload 3
    payload = {
                  user_id: 983,
      quantity_to_receive: 2.000000,
          gwx_to_transfer: 30.00,
         transaction_type: "xem",
       gwx_wallet_address: "TCP33TIK2FSSFWXUIBHWXNUZDGISPTCZE5YSSTJ3"
    }
    
    # call the API endpoint
    post "/top_up_transactions", params: payload
    
    # make sure the response status was 201 or :created
    expect(response.status).to eq 201  
    
    result = JSON.parse(response.body)
    
    # make sure the returned 'quantity_to_receive' matches with the request
    expect(result["data"]["attributes"]["quantity_to_receive"]).to eq "2.0"
    
    # make sure the returned 'gwx_to_transfer' matches with the request
    expect(result["data"]["attributes"]["gwx_to_transfer"]).to eq "30.0"

    # make sure the returned 'top_up_receiving_wallet_address' is not nil
    expect((result["data"]["attributes"]["top_up_receiving_wallet_address"]).nil?).to eq false
    
    # make sure the returned 'status' is set to 'pending'
    expect(result["data"]["attributes"]["status"]).to eq "pending"
  end

  it "should be able to successfully call GET /top_up_transactions/calculate/btc/{btc_value}/to_gwx" do
    
    # call the API endpoint
    get "/top_up_transactions/calculate/btc/1.0/to_gwx"
    
    # make sure the response status was 200 or :ok
    expect(response.status).to eq 200
    
    # call the API endpoint
    get "/top_up_transactions/calculate/btc/0.5/to_gwx"
    
    # make sure the response status was 200 or :ok
    expect(response.status).to eq 200
    
    result = JSON.parse(response.body)
    
    # make sure the gwx has a value
    expect(result["gwx"].nil?).to eq false
    
    result = JSON.parse(response.body)
    
    # make sure the response has the 'btc' value
    expect(result["btc"].nil?).to eq false
    
    # make sure the response has the 'gwx' value
    expect(result["gwx"].nil?).to eq false
  end

  it "should be able to successfully call GET /top_up_transactions/calculate/xem/{xem_value}/to_gwx" do
    
    # call the API endpoint
    get "/top_up_transactions/calculate/xem/10/to_gwx"
    
    # make sure the response status was 200 or :ok
    expect(response.status).to eq 200
    
    result = JSON.parse(response.body)
    
    puts "@DEBUG L:#{__LINE__}   #{ap result}"
    
    # make sure the response has the 'xem' value
    expect(result["xem"].nil?).to eq false
    
    # make sure the response has the 'gwx' value
    expect(result["gwx"].nil?).to eq false
  end

end
