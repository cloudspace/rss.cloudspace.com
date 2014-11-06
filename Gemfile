source 'https://rubygems.org'

gem 'rails', '~> 4.1.7'
gem 'pg', '~> 0.17.1'

gem 'active_model_serializers', '~> 0.9.0'
gem 'rails-api', '~> 0.3.1'

# loads environment variables
gem 'dotenv-rails'

gem 'aws-sdk', '~> 1.57.0'
gem 'dalli', '~> 2.7.2'
gem 'feedjira', '~> 1.5.0'
gem 'httparty', '~> 0.13.2'
gem 'nokogiri', '~> 1.6.4'
gem 'paperclip', '~> 4.2.0'

gem 'posix-spawn', '~> 0.3.9' # needed to prevent out of memory errors in paperclip processing

gem 'fastimage', '~> 1.6.4' # needed to rapidly find the largest image on a page
gem 'hashie', '~> 3.3.1'
gem 'asset_sync', '~> 1.1.0'
gem 'libv8', '~> 3.16.14.5'

gem 'mini_magick', '~> 3.8.1'

gem 'resque', '~> 1.25.2'
gem 'resque-scheduler', '~> 3.0.0'
gem 'resque-retry', '~> 1.3.2'

gem 'dot_configure', '~> 0.0.1'

group :production, :staging do
  gem 'unicorn', '~> 4.8.3'
end

group :development, :test do
  gem 'pry-byebug', '~> 2.0.0'

  # Deploy with Capistrano
  gem 'capistrano', '~> 3.2.1'
  gem 'capistrano-bundler', '~> 1.1.3'
  gem 'capistrano-rails', '~> 1.1.2'

  # Code Metric Gems
  gem 'clint_eastwood', '~> 0.0.1'
  
  # rspec
  gem 'rspec', '~> 3.1.0'
  gem 'rspec-rails', '~> 3.1.0'
  gem 'shoulda', '~> 3.5.0'
  gem 'database_cleaner', '~> 1.3.0'

  gem 'factory_girl_rails', '~> 4.5.0'
  gem 'faker'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'jquery-rails'
  gem 'sass-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platforms => :ruby
  gem 'uglifier'
end

group :doc do
  gem 'yard'
  gem 'yard-activerecord'
  gem 'redcarpet'
  gem 'github-markup'
end
