source 'https://rubygems.org'

gem 'rails', '4.0.3'
gem 'pg'

# loads environment variables
gem 'dotenv-rails'

gem 'active_model_serializers'
gem 'rails-api'

gem 'aws-sdk'
gem 'dalli'
gem 'feedjira'
gem 'httparty'
gem 'nokogiri'
gem 'paperclip'
gem 'posix-spawn' # needed to prevent out of memory errors in paperclip processing
gem 'whenever', :require => false
gem 'fastimage' # needed to rapidly find the largest image on a page
gem 'hashie'
gem 'asset_sync'
gem 'debugger'

group :production, :staging do
  gem 'unicorn'
end

group :development, :test do
  gem 'pry-byebug'

  # Deploy with Capistrano
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'

  # Code Metric Gems
  gem 'rails_best_practices'
  gem 'rubocop'
  gem 'metric_fu'
  gem 'reek'
  
  # rspec
  gem 'rspec'
  gem 'rspec-rails'
  gem 'shoulda'
  gem 'database_cleaner'

  gem 'factory_girl_rails'
  gem 'faker'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails'
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

# gem 'fastimage'
# gem 'haml'
# gem 'link_thumbnailer'
gem 'mini_magick'
# gem 'node'
# gem 'ruby-readability'
# gem 'socksify'
# gem 'thread_safe'
# gem 'www-favicon'

# activeadmin requirements
# gem 'activeadmin', github: 'gregbell/active_admin'

# # Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'

# # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 1.2'

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.1.2'
