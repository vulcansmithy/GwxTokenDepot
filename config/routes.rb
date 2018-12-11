Rails.application.routes.draw do
  api_version(:module => "Api::V1", :header => {:name => "Accept", :value => "application/vnd.gameworks.io; version=1"}, :parameter => {:name => "version", :value => "1"}, :path => {:value => "v1"}, :defaults => {:format => "json"}, :default => true) do
    resources :gwx_token_depot, :only => [] do
      collection do
        post "publisher/:publisher_id/buy",        to: "gwx_token_depot#publisher_buy"
        post "player/:player_id/buy",              to: "gwx_token_depot#player_buy"
        get  "balance",                            to: "gwx_token_depot#balance"
        get  "transaction/:transaction_id/status", to: "gwx_token_depot#status"
      end    
    end
  end  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
