set :application, "rixth.org"

set :scm, :git
set :repository, "git@github.com:rixth/#{application}.git"
set :branch, "master"

server "10.0.1.30", :app, :web, :db
set :deploy_to, "/var/www/#{application}"
set :current_path, deploy_to + '/current'
set :use_sudo, false

set :unicorn_pid, "/tmp/unicorn.#{application}.pid"

set :rvm_install_ruby, :install
set :rvm_ruby_string, ENV['GEM_HOME'].gsub(/.*\//,"")
before 'deploy:setup', 'rvm:install_rvm'
before 'deploy:setup', 'rvm:install_ruby'
before 'deploy:setup', 'rvm:create_gemset'

set :ssh_options, { :forward_agent => true }

require 'rvm/capistrano'
require 'bundler/capistrano'
require 'capistrano-unicorn'