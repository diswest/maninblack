app_dir = '/var/www/test.vlastelin.io'

worker_processes 8
pid "#{app_dir}/tmp/pids/unicorn.pid"
working_directory app_dir
listen "#{app_dir}/tmp/sockets/unicorn.sock", backlog: 4096
timeout 30

stderr_path "#{app_dir}/log/unicorn.stderr.log"
stdout_path "#{app_dir}/log/unicorn.stdout.log"

preload_app true

Unicorn::HttpServer::START_CTX[0] = "#{app_dir}/bundle/ruby/2.2.0/bin/unicorn"

GC.copy_on_write_friendly = true if GC.respond_to?(:copy_on_write_friendly=)

# use correct Gemfile on restarts
before_exec do |_server|
  ENV['BUNDLE_GEMFILE'] = "#{app_dir}/Gemfile"
end
