app_dir = '/home/vlastelin/site'
current_dir = "#{app_dir}/current"
shared_dir = "#{app_dir}/shared"

worker_processes 8
pid "#{shared_dir}/tmp/pids/unicorn.pid"
working_directory current_dir
listen "#{shared_dir}/tmp/sockets/unicorn.sock", backlog: 4096
timeout 30

stderr_path "#{shared_dir}/log/unicorn.stderr.log"
stdout_path "#{shared_dir}/log/unicorn.stdout.log"

preload_app true

Unicorn::HttpServer::START_CTX[0] = "#{shared_dir}/bundle/ruby/2.2.1/bin/unicorn"

GC.copy_on_write_friendly = true if GC.respond_to?(:copy_on_write_friendly=)

# use correct Gemfile on restarts
before_exec do |_server|
  ENV['BUNDLE_GEMFILE'] = "#{current_dir}/Gemfile"
end

before_fork do |server, worker|
  ActiveRecord::Base.connection.disconnect!

  old_pid = [server.config[:pid], 'oldbin'].join('.')
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) && ActiveRecord::Base.establish_connection
  # if Process.ppid > 1
  child_pid = server.config[:pid].sub('.pid', ".#{worker.nr}.pid")
  system("echo #{Process.pid} > #{child_pid}")
  # end
end
