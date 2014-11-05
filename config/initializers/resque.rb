require 'resque-retry'
require 'resque/server'
require 'resque/failure/redis'

Resque::Server.use(Rack::Auth::Basic) do |_user, password|
  password == ENV['RESQUE_ADMIN_PASSWORD']
end

Resque::Failure::MultipleWithRetrySuppression.classes = [Resque::Failure::Redis]
Resque::Failure.backend = Resque::Failure::MultipleWithRetrySuppression
