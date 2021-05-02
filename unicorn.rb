# frozen_string_literal: true

listen "0.0.0.0:#{ENV.fetch('WEB_PORT', '8080')}", tcp_nopush: true

pid '/tmp/unicorn.pid'

preload_app ENV.key?('WEB_PRELOAD_APP')

timeout ENV.fetch('WEB_TIMEOUT', 60).to_i

worker_processes ENV.fetch('WEB_CONCURRENCY', 8).to_i
