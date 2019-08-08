server "52.221.192.127", port: 22, roles: [:web, :app, :db], primary: true
set :stage, :production
set :branch, :master
