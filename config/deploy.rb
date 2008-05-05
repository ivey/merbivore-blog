# Please install the Engine Yard Capistrano gem
# gem install eycap --source http://gems.engineyard.com

require 'eycap/recipes'

# =============================================================================
# ENGINE YARD REQUIRED VARIABLES
# =============================================================================
# You must always specify the application and repository for every recipe. The
# repository must be the URL of the repository you want this recipe to
# correspond to. The :deploy_to variable must be the root of the application.

set :keep_releases, 3
set :application,   'blog'
set :repository,    'git@github.com:ivey/merbivore-blog.git'
set :scm_username,  ''
set :scm_password,  ''
set :user,          'merbivore'
set :password,      '3rAyaxut'
set :deploy_to,     "/data/#{application}"
set :deploy_via,    :copy
set :monit_group,   'blog'
set :scm,           :git

set :production_database,'merbivoreblog_prod'
set :production_dbhost, 'mysql50-3-master'

# comment out if it gives you trouble. newest net/ssh needs this set.
ssh_options[:paranoid] = false

# =============================================================================
# ROLES
# =============================================================================
# You can define any number of roles, each of which contains any number of
# machines. Roles might include such things as :web, or :app, or :db, defining
# what the purpose of each machine is. You can also specify options that can
# be used to single out a specific subset of boxes in a particular role, like
# :primary => true.

task :production do
  
  role :web, '74.201.254.36:8067' # wiki [merb] [mysql50-3-master]
  role :app, '74.201.254.36:8067', :merb => true
  role :db, '74.201.254.36:8067', :primary => true
  
  set :rails_env, 'production'
  set :environment_database, defer { production_database }
  set :environment_dbhost, defer { production_dbhost }
  
end

# =============================================================================
# Any custom after tasks can go here.
# after "deploy:symlink_configs", "wiki_custom"
# task :wiki_custom, :roles => :app, :except => {:no_release => true, :no_symlink => true} do
#   run <<-CMD
#   CMD
# end
# =============================================================================

namespace :deploy do

  desc "Custom restart task for Merb"
  task :restart, :roles => :app do
    deploy.stop
    deploy.start
  end

  desc "Custom start task for Merb"
  task :start, :roles => :app do
    run "merb -c 2 --daemonize --environment production --port 5100 --log #{shared_path}/log/production.log --merb-root #{deploy_to}/current"
  end

  desc "Custom stop task for Merb"
  task :stop, :roles => :app do
    run "cd #{deploy_to}/current && merb --kill all"
  end

end


# Don't change unless you know what you are doing!

after "deploy", "deploy:cleanup"
after "deploy:migrations", "deploy:cleanup"
after "deploy:update_code","deploy:symlink_configs"

# uncomment the following to have a database backup done before every migration
# before "deploy:migrate", "db:dump"

