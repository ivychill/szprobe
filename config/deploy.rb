set :application, "set your application name here"
set :repository,  "set your repository location here"

set :application, "szprobe2"
set :repository,  "git@github.com:ivychill/szprobe-2.x.git"

set :scm, :git
set :user, "caiqingfeng"
set :deploy_to, "/home/caiqingfeng/webapps/#{application}"
set :keep_release, 5
set :rvm_type, :system
set :use_sudo, false

role :web, "luyun-server.com"                          # Your HTTP server, Apache/etc
role :app, "luyun-server.com"                          # This may be the same as your `Web` server
role :db,  "luyun-server.com", :primary => true # This is where Rails migrations will run
role :db,  "luyun-server.com"


# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

desc "run utils in daemon"
daemon_script = current_path+'/script/daemon'
production_env = 'RAILS_ENV=production '
namespace :deploy do
  task :utils do
    for tsk in 1..10 do 
      worker = "utils/traffic-crawler-worker-"+tsk.to_s+".rb"
      run production_env+daemon_script+" stop "+worker
      run production_env+daemon_script+" start "+worker
    end
  end
end
