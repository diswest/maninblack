require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rvm' # for rvm support. (http://rvm.io)
require 'mina/unicorn'

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :domain, 'vlastelin.io'
set :deploy_to, '/home/vlastelin/site'
set :repository, 'git@github.com:diswest/maninblack.git'
set :branch, 'master'

# For system-wide RVM install.
set :rvm_path, '/usr/local/rvm/scripts/rvm'

# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_paths, %w(config/secrets.yml config/database.yml log tmp/pids tmp/sockets tmp/pids)

# Optional settings:
set :user, 'vlastelin' # Username in the server to SSH to.
set :keep_releases, 3
#   set :port, '30000'     # SSH port number.
#   set :forward_agent, true     # SSH forward_agent.

set :term_mode, nil

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .rbenv-version to your repository.
  # invoke :'rbenv:load'

  queue! '[[ -s "/usr/local/rvm/scripts/rvm" ]] &&  source "/usr/local/rvm/scripts/rvm"'

  # For those using RVM, use this to load an RVM version@gemset.
  invoke :'rvm:use[2.2.1]'
end

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task setup: :environment do
  queue! %(mkdir -p "#{deploy_to}/#{shared_path}/log")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/log")

  queue! %(mkdir -p "#{deploy_to}/#{shared_path}/config")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/config")

  queue! %(touch "#{deploy_to}/#{shared_path}/config/database.yml")
  queue %(echo "-----> Be sure to edit '#{deploy_to}/#{shared_path}/config/database.yml'.")

  queue! %(mkdir -p "#{deploy_to}/#{shared_path}/public")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/public")

  queue! %(mkdir -p "#{deploy_to}/#{shared_path}/public/uploads")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/public/uploads")

  queue! %(mkdir -p "#{deploy_to}/#{shared_path}/public/uploads/i18n_images")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/public/uploads/i18n_images")

  queue! %(mkdir -p "#{deploy_to}/#{shared_path}/tmp/sockets")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/tmp/sockets")

  queue! %(mkdir -p "#{deploy_to}/#{shared_path}/tmp/pids")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/tmp/pids")

  queue! %(mkdir -p "#{deploy_to}/#{shared_path}/pids/")
  queue! %(mkdir -p "#{deploy_to}/#{shared_path}/log/")
end

desc 'Deploys the current version to the server.'
task deploy: :environment do
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    to :launch do
      invoke :'unicorn:restart'
    end
  end
end

task :logs do
  queue "tail -f #{deploy_to}/#{shared_path}/log/production.log"
end
# For help in making your deploy script, see the Mina documentation:
#
#  - http://nadarei.co/mina
#  - http://nadarei.co/mina/tasks
#  - http://nadarei.co/mina/settings
#  - http://nadarei.co/mina/helpers
