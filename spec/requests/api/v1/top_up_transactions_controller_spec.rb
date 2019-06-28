require "rails_helper"

describe Api::V1::TopUpTransactionsController do

  it "should be able to successfully cal POST /top_up_transactions" do
    
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


    puts "@DEBUG L:#{__LINE__}   #{ap TopUpTransaction.all}"
  end
end
