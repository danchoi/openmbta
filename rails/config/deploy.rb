# If you have previously been relying upon the code to start, stop 
# and restart your mongrel application, or if you rely on the database
# migration code, please uncomment the lines you require below

# If you are deploying a rails app you probably need these:

#load 'ext/rails-database-migrations.rb'
#load 'ext/rails-shared-directories.rb'

# There are also new utility libaries shipped with the core these 
# include the following, please see individual files for more
# documentation, or run `cap -vT` with the following lines commented
# out to see what they make available.

# load 'ext/spinner.rb'              # Designed for use with script/spin
# load 'ext/passenger-mod-rails.rb'  # Restart task for use with mod_rails
# load 'ext/web-disable-enable.rb'   # Gives you web:disable and web:enable

set :application, "iphonembta"
set :domain,      "iphonembta.org"
set :use_sudo,    false
set :deploy_to,   "/home/zoe2/#{application}"
set :user, "zoe2"

set :scm,         :none # "git"
set :repository, "."
set :deploy_via, :copy
set :copy_exclude, ["coverage", "screenshots", ".git", "test", "doc", "tmp", "log", "*.swp", "*.swo", "*.sql", "*.csv", "db/sphinx/*", "backups", "config/development.sphinx.conf", "config/production.sphinx.conf", "netflix_index.xml", "public/iphone/"]

set :keep_releases, 4


role :app, domain
role :web, domain
role :db,  domain, :primary => true

after "deploy:update_code", "deploy:cleanup" #, "deploy:reload_homepage"
namespace :deploy do

  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
end
