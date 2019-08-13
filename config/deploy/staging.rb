server "3.1.79.242", port: 22, roles: [:web, :app, :db], primary: true
set :stage, :staging
set :branch, :develop