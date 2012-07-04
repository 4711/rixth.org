# See http://unicorn.bogomips.org/Unicorn/Configurator.html for complete
# documentation.

app_name = "rixth.org"

worker_processes 4
listen "/tmp/#{app_name}.socket", :backlog => 64
pid "/tmp/unicorn.#{app_name}.pid"
preload_app true
timeout 30
working_directory "/var/www/#{app_name}/current"
stderr_path "/var/www/#{app_name}/shared/log/unicorn.stderr.log"
stdout_path "/var/www/#{app_name}/shared/log/unicorn.stdout.log"