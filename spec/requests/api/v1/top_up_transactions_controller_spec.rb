require "rails_helper"

describe Api::V1::TopUpTransactionsController do

  it "should do something" do
    
    # setup params payload
    payload = {
                 user_id: 433,
                quantity: 500.000000,
        transaction_type: "btc",
      gwx_wallet_address: "TCP33TIK2FSSFWXUIBHWXNUZDGISPTCZE5YSSTJW"
    }
    
    
    # call the API endpoint
    post "/top_up_transactions", params: payload
    
    expect(response.status).to eq 200
    
    result = JSON.parse(response.body)
    puts "@DEBUG L:#{__LINE__}   #{ap result}"
    
    puts "@DEBUG L:#{__LINE__}   #{ap TopUpTransaction.first}"
    
  end
end
