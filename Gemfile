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

gem 'daemons'
gem 'posix-spawn' # needed to prevent out of memory errors in paperclip processing

gem 'fastimage', '~> 1.6.4' # needed to rapidly find the largest image on a page
gem 'hashie', '~> 3.3.1'
gem 'asset_sync', '~> 1.1.0'
gem 'libv8', '~> 3.16.14.5'

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
  gem 'clint_eastwood', '~> 0.0.1'
  
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
