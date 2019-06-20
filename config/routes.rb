Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  api_version(:module => "Api::V1", :header => {:name => "Accept", :value => "application/vnd.gameworks.io; version=1"}, :parameter => {:name => "version", :value => "1"}, :path => {:value => "v1"}, :defaults => {:format => "json"}, :default => true) do
    resources :top_up_transactions
    
    # setup the API endpoints for the TopUpTransactions
    resources :top_up_transactions, :only => [:index, :show, :create]
  
  end  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
