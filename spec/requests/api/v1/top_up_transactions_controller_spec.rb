require "rails_helper"

describe Api::V1::TopUpTransactionsController do

  it "should do something" do
    
    # setup params payload 1
    payload = {
                 user_id: 433,
                quantity: 500.000000,
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
                quantity: 1.000000,
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
                quantity: 2.000000,
        transaction_type: "xem",
      gwx_wallet_address: "TCP33TIK2FSSFWXUIBHWXNUZDGISPTCZE5YSSTJ3"
    }
    
    # call the API endpoint
    post "/top_up_transactions", params: payload
    
    # make sure the response status was 201 or :created
    expect(response.status).to eq 201  


    puts "@DEBUG L:#{__LINE__}   #{ap TopUpTransaction.all}"
  end
end
