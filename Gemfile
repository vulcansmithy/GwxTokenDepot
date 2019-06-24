source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.5.1"

# Bundle edge Rails instead: gem "rails", github: "rails/rails"
gem "rails", "~> 5.2.1"

gem "pg", "1.1.4"

# Use Puma as the app server
gem "puma", "~> 3.11"

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem "jbuilder", "~> 2.5"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use ActiveModel has_secure_password
# gem "bcrypt", "~> 3.1.7"

# Use ActiveStorage variant
# gem "mini_magick", "~> 4.8"

# Use Capistrano for deployment
# gem "capistrano-rails", group: :development

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.1.0", require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem "rack-cors"

group :development, :test do
  # Call "byebug" anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  
  gem "rspec-rails",            "3.8.1"    # https://github.com/rspec/rspec-rails
  gem "guard-rspec",            "4.7.3"    # https://github.com/guard/guard-rspec
  gem "factory_bot_rails",      "4.11.1"   # https://github.com/thoughtbot/factory_bot_rails
  gem "faker",                  "1.9.1"    # https://github.com/stympy/faker
  gem "awesome_print",          "1.8.0"    # https://github.com/awesome-print/awesome_print
  
  # https://github.com/colszowka/simplecov
  gem "simplecov",              "0.16.1", require: false   
end

group :development do
  gem "listen", ">= 3.0.5", "< 3.2"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring", "2.1.0"
  gem "spring-watcher-listen", "2.0.1"
end


# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem "versionist",               "1.7.0"    # https://github.com/bploetz/versionist
gem "money-tree",               "0.10.0"   # https://github.com/GemHQ/money-tree
gem "bitcoin-ruby",             "0.0.19"   # https://github.com/lian/bitcoin-ruby
gem "aasm",                     "5.0.5"    # https://github.com/aasm/aasm
gem "active_model_serializers", "0.10.9"   # https://github.com/rails-api/active_model_serializers
gem "fast_jsonapi",             "1.5"      # https://github.com/Netflix/fast_jsonap
gem "rswag",                    "2.0.5"    # https://github.com/domaindrivendev/rswag


