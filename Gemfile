source 'https://rubygems.org'

ruby '2.2.1'

gem 'rails', '~> 4.1.0'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.0'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'pg'
gem 'cancancan', '~> 1.10.1'
gem 'devise', '~> 3.4.1'

# RADAR v3.x will support ActiveRecord 4.2
gem 'activerecord-postgis-adapter', '~> 2.2.1'

gem 'whenever', '~> 0.9.4', :require => false

# RADAR current version is 0.12.1, but current recurring trip tracking relies 
# on 0.6.8
gem 'ice_cube', '0.6.8' 

# Fork with Rails 4.x compatibility
gem 'jc-validates_timeliness', '~> 3.1.1'

gem 'paperclip', '~> 4.2.1'
gem 'will_paginate', '~> 3.0.7'
gem 'attribute_normalizer', '~> 1.2.0'

# For change tracking and auditing
gem 'paper_trail', '~> 3.0.6'

# Support for Rails 4 since 1.0.12
gem 'rails3-jquery-autocomplete', '~> 1.0.15'

# RADAR Not updated since 2011
gem 'schedule_atts', :git => 'git://github.com/zpearce/Schedule-Attributes.git'

group :development do
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem "spring-commands-rspec"
  
  # Use Capistrano for deployment
  gem 'capistrano', '~> 3.4'
  gem 'capistrano-rvm', '~> 0.1', require: false
  gem 'capistrano-rails', '~> 1.1', require: false
  gem 'capistrano-passenger', '~> 0.0', require: false
  gem 'capistrano-secrets-yml', '~> 1.0', require: false
end

group :production do
  gem 'exception_notification', '~> 4.0'
end

group :test, :development do
  gem 'byebug'

  gem 'rspec-rails', '~> 3.2'
  
  gem 'capybara', '~> 2.4'

  gem 'factory_girl_rails', '~> 4.5'
  
  gem 'database_cleaner', '~> 1.4'

  gem 'faker', '~> 1.4'
end
