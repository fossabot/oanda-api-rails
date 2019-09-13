rails_env = ENV['RAILS_ENV'] || 'development'
rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/..'
app_name = 'oanda_api_rails'

1.times do |num|
  God.watch do |w|
    w.dir = rails_root
    w.name = "resque-#{app_name}-#{num}"
    w.group = "resque-#{app_name}"
    w.interval = 30.seconds
    w.env = {'QUEUE' => 'normal', 'RAILS_ENV' => rails_env}
    w.start = "bundle exec rake -f #{rails_root}/Rakefile environment resque:work"
    w.log = "#{w.dir}/log/#{w.name}.log"
    w.err_log = "#{w.dir}/log/#{w.name}_error.log"
    w.start_grace  = 10.seconds
    w.stop_signal  = 'QUIT'
    w.stop_timeout = 300.seconds

    #    w.uid = 'git'
    #    w.gid = 'git'

    # restart if memory gets too high
    w.transition(:up, :restart) do |on|
      on.condition(:memory_usage) do |c|
        c.above = 350.megabytes
        c.times = 2
      end
    end

    # determine the state on startup
    w.transition(:init, true => :up, false => :start) do |on|
      on.condition(:process_running) do |c|
        c.running = true
      end
    end

    # determine when process has finished starting
    w.transition([:start, :restart], :up) do |on|
      on.condition(:process_running) do |c|
        c.running = true
        c.interval = 5.seconds
      end

      # failsafe
      on.condition(:tries) do |c|
        c.times = 5
        c.transition = :start
        c.interval = 5.seconds
      end
    end

    # start if process is not running
    w.transition(:up, :start) do |on|
      on.condition(:process_running) do |c|
        c.running = false
      end
    end
  end
end

1.times do |num|
  God.watch do |w|
    w.dir = rails_root
    w.name = "resque-scheduler-#{app_name}-#{num}"
    w.group = "resque-#{app_name}"
    w.interval = 30.seconds
    w.env = {'RAILS_ENV' => rails_env, 'DYNAMIC_SCHEDULE' => true}
    w.start = "bundle exec rake -f #{rails_root}/Rakefile environment resque:scheduler"
    w.log = "#{w.dir}/log/#{w.name}.log"
    w.err_log = "#{w.dir}/log/#{w.name}_error.log"
    w.start_grace  = 10.seconds
    w.stop_signal  = 'QUIT'
    w.stop_timeout = 300.seconds

    #    w.uid = 'git'
    #    w.gid = 'git'

    # restart if memory gets too high
    w.transition(:up, :restart) do |on|
      on.condition(:memory_usage) do |c|
        c.above = 350.megabytes
        c.times = 2
      end
    end

    # determine the state on startup
    w.transition(:init, true => :up, false => :start) do |on|
      on.condition(:process_running) do |c|
        c.running = true
      end
    end

    # determine when process has finished starting
    w.transition([:start, :restart], :up) do |on|
      on.condition(:process_running) do |c|
        c.running = true
        c.interval = 5.seconds
      end

      # failsafe
      on.condition(:tries) do |c|
        c.times = 5
        c.transition = :start
        c.interval = 5.seconds
      end
    end

    # start if process is not running
    w.transition(:up, :start) do |on|
      on.condition(:process_running) do |c|
        c.running = false
      end
    end
  end
end
