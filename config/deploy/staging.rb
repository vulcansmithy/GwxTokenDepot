server "54.251.162.83", port: 22, roles: [:web, :app, :db], primary: true
set :stage, :staging
set :branch, :develop