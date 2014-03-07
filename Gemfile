source 'https://rubygems.org'

gem 'rails', '4.0.3'
gem 'pg'

# loads environment variables
gem 'dotenv-rails'

gem 'active_model_serializers'
gem 'aws-sdk'
gem 'dalli'
gem 'factory_girl'
gem 'feedzirra'
gem 'httparty'
gem 'nokogiri'
gem 'paperclip'
gem 'whenever', :require => false

group :production, :staging do
  gem 'unicorn'
end

# Use debugger
gem 'debugger', group: [:development, :test]

group :development do
  # Deploy with Capistrano
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'

  # Code Metric Gems
  gem 'rails_best_practices'
  gem 'rubocop'
  gem 'metric_fu'
end

group :test do
  # rspec
  gem 'rspec'
  gem 'rspec-rails'
  gem 'shoulda'
  gem 'database_cleaner'
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

# gem 'ruby-readability'
# gem 'link_thumbnailer'
# gem 'mini_magick'
# gem 'node'
# gem 'fastimage'
# gem 'socksify'
# gem 'haml'
# gem 'www-favicon'
# gem 'thread_safe'

# activeadmin requirements
# gem 'activeadmin', github: 'gregbell/active_admin'

# # Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'

# # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 1.2'

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.1.2'
