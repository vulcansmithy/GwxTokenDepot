require "sidekiq/web"

Rails.application.routes.draw do
  mount Rswag::Ui::Engine  => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
  mount Sidekiq::Web       => "/sidekiq"
  
  api_version(:module => "Api::V1", :header => {:name => "Accept", :value => "application/vnd.gameworks.io; version=1"}, :parameter => {:name => "version", :value => "1"}, :path => {:value => "v1"}, :defaults => {:format => "json"}, :default => true) do
    
    # setup the API endpoints for the TopUpTransactions
    resources :top_up_transactions, :only => [:index, :show, :create] do
      collection do
        get "/calculate/btc/:btc_value/to_gwx", to: "top_up_transactions#convert_btc_to_gwx"
        get "/calculate/eth/:btc_value/to_gwx", to: "top_up_transactions#convert_eth_to_gwx"
        get "/calculate/xem/:btc_value/to_gwx", to: "top_up_transactions#convert_xem_to_gwx"
      end
    end
  
  end  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end