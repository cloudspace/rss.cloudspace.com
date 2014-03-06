source 'https://rubygems.org'

# loads environment variables
gem 'dotenv-rails'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.3'

# # Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'

# # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 1.2'

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.1.2'

# Use unicorn as the app server
# gem 'unicorn'

# Use debugger
# gem 'debugger', group: [:development, :test]

gem 'nokogiri'
gem 'feedzirra'
gem 'ruby-readability'
gem 'link_thumbnailer'
gem 'mini_magick'
gem 'pg'
# gem 'node'
# gem 'fastimage'
gem 'whenever', :require => false
# gem 'socksify'
gem 'paperclip'
# gem 'haml'
gem 'aws-sdk'
gem 'dalli'
gem 'www-favicon'

# activeadmin requirements
# gem 'activeadmin', github: 'gregbell/active_admin'

gem 'jquery-rails'
gem 'active_model_serializers'
gem 'thread_safe'
gem 'httparty'

# Deploy with Capistrano
gem 'capistrano'
gem 'capistrano-bundler'
gem 'capistrano-rails'

group :production, :staging do
  gem 'unicorn'
end

group :development do
  gem 'debugger'

  # Code Metric Gems
  gem 'rails_best_practices'
  gem 'rubocop'
  gem 'metric_fu'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platforms => :ruby
  gem 'uglifier', '>= 1.3'
end

group :test do
  # rspec
  gem 'rspec'
  gem 'rspec-rails'
  gem 'shoulda'
  gem 'database_cleaner'
end

group :doc do
  gem 'yard', '~> 0.8.7.3'
  gem 'yard-activerecord', '~> 0.0.11'
  gem 'redcarpet', '~> 3.0.0'
  gem 'github-markup', '~> 1.0.0'
end
