require "sidekiq/web"

Rails.application.routes.draw do
  mount Rswag::Ui::Engine  => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
  mount Sidekiq::Web       => "/sidekiq"

  api_version(:module => "Api::V1", :header => {:name => "Accept", :value => "application/vnd.gameworks.io; version=1"}, :parameter => {:name => "version", :value => "1"}, :path => {:value => "v1"}, :defaults => {:format => "json"}, :default => true) do

    # setup the API endpoints for the TopUpTransactions
    resources :top_up_transactions, :only => [:index, :show, :create] do
      member do
        get "/calculate/btc/:btc_value/to_gwx", to: "top_up_transactions#convert_btc_to_gwx", btc_value: /.*/
        get "/calculate/eth/:eth_value/to_gwx", to: "top_up_transactions#convert_eth_to_gwx", eth_value: /.*/
        get "/calculate/xem/:xem_value/to_gwx", to: "top_up_transactions#convert_xem_to_gwx", xem_value: /.*/
      end
    end

    get '/get_rates', to: 'real_time_rates#get_rates'
    get '/get_current_rate', to: 'real_time_rates#get_current_rate'

  end  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
