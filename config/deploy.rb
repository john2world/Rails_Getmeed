require 'bundler/capistrano'
require 'rvm/capistrano'
require 'capistrano/sidekiq'
require 'whenever/capistrano'
before 'deploy:assets:precompile', 'bundle:install'

set :application, 'meed'
set :repository, 'https://github.com/ssravi/futura-project.git'
set :scm, 'git'
role :web, 'ec2-54-215-25-61.us-west-1.compute.amazonaws.com', 'ec2-54-177-31-88.us-west-1.compute.amazonaws.com'
role :app, 'ec2-54-215-25-61.us-west-1.compute.amazonaws.com', 'ec2-54-177-31-88.us-west-1.compute.amazonaws.com'
set :user, 'ubuntu'
set :deploy_to, '/home/ubuntu/resume'
set :rvm_ruby_version, '2.2.1'
set :deploy_via, :copy
set :pty,  false

set :sidekiq_config, "#{current_path}/config/sidekiq.yml"

set :use_sudo, false
ssh_options[:keys] = %w(~/.ec2/resume-ravi)
ssh_options[:forward_agent] = true

default_run_options[:pty] = true

after 'deploy:update', 'bundle:install'
after :deploy, 'deploy:restart'
after 'deploy:update_code', 'sitemaps:create_symlink'

namespace :sitemaps do
  task :create_symlink, roles: :app do
    run "mkdir -p #{shared_path}/sitemaps"
    run "rm -rf #{release_path}/public/sitemaps"
    run "ln -s #{shared_path}/sitemaps #{release_path}/public/sitemaps"
  end
end

namespace :deploy do
  task :start, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end

  task :stop, :roles => :app do
    # Do nothing.
  end

  desc 'Restart Application'
  task :restart, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end

end

set :whenever_command, "bundle exec whenever"
require 'whenever/capistrano'

