Rails.application.routes.draw do
  api_version(:module => "Api::V1", :header => {:name => "Accept", :value => "application/vnd.gameworks.io; version=1"}, :parameter => {:name => "version", :value => "1"}, :path => {:value => "v1"}, :defaults => {:format => "json"}, :default => true) do
    
    # setup the API endpoints for the TopUpTransactions
    resources :top_up_transactions, :only => [:index, :show, :create]
  
  end  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
