Rails.application.routes.draw do
  api_version(:module => "Api::V1", :header => {:name => "Accept", :value => "application/vnd.gameworks.io; version=1"}, :parameter => {:name => "version", :value => "1"}, :path => {:value => "v1"}, :defaults => {:format => "json"}, :default => true) do
    resources :gwx_tokens, :only => [] do
      collection do
        post ":wallet_address/buy",                                 to: "gwx_tokens#buy"
        post ":dest_wallet_address/send",                           to: "gwx_tokens#send"
        get  ":wallet_address/balance",                             to: "gwx_tokens#balance"
        get  ":wallet_address/history",                             to: "gwx_tokens#history"
      end
    end
    
    resources :gwx_wallets, :only => [] do
      collection do
        post "create"
        post "send/:source_wallet_address/to/:dest_wallet_address", to: "gwx_wallets#send"  
        get  ":wallet_address/balance",                             to: "gwx_wallets#balance"
        get  ":wallet_address/history",                             to: "gwx_wallets#history"
      end
      
    end  
  end  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
