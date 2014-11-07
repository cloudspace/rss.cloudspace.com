require 'resque-retry'
require 'resque/server'
require 'resque/failure/redis'

require 'resque-scheduler'
require 'resque/scheduler/server'

Resque::Server.use(Rack::Auth::Basic) do |_user, password|
  password == ENV['RESQUE_ADMIN_PASSWORD']
end

Resque::Failure::MultipleWithRetrySuppression.classes = [Resque::Failure::Redis]
Resque::Failure.backend = Resque::Failure::MultipleWithRetrySuppression
