# Load DSL and set up stages
require "capistrano/setup"

# Include default deployment tasks
require "capistrano/deploy"

require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git
require "capistrano/bundler"
require "capistrano/rbenv"
require "capistrano/rbenv_install"
require "capistrano/puma"
install_plugin Capistrano::Puma
install_plugin Capistrano::Puma::Nginx

require "capistrano/sidekiq"


# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }