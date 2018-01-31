source 'https://rubygems.org'

ruby '2.4.2'

gem 'rails', '5.0.6'

# Use SCSS for stylesheets
gem 'sass-rails'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

gem 'translation_engine', github: 'camsys/translation_engine', branch: 'rails_5'
#gem 'translation_engine', path: '~/translation_engine'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.0'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', group: :doc

gem 'pg', '~> 0.11'
gem 'cancancan'
gem 'devise'
gem 'devise_account_expireable'

gem 'devise_security_extension', github: 'camsys/devise_security_extension'
#gem 'devise_security_extension', path: '~/devise_security_extension'

# RADAR v3.x will support ActiveRecord 4.2
gem 'rgeo'
gem "rgeo-proj4"
gem 'activerecord-postgis-adapter'

# Manage app-specific cron tasks using a Ruby DSL, see config/schedule.rb
gem 'whenever', :require => false

# RADAR current version is 0.13.0, but schedule_atts requires > 0.7.0 
gem 'ice_cube', '~> 0.6.8'

# Fork with Rails 4.x compatibility
gem 'jc-validates_timeliness'

# For attachment processing. Using Fog for storage so that we can use
# AWS SDK v2 separately for other tasks.
gem 'paperclip'
gem 'fog-aws'
gem 'remotipart' # allows remote multipart (file upload) forms

gem 'will_paginate'
gem 'attribute_normalizer'

# For Address Uploading
# Note: not used by Paperclip internally per
# https://github.com/thoughtbot/paperclip/issues/1764
gem 'aws-sdk'

# For change tracking and auditing
gem 'paper_trail'

gem 'rails-jquery-autocomplete'
# needed for trip address picker
gem 'twitter-typeahead-rails', github: 'camsys/twitter-typeahead-rails'
gem 'handlebars_assets'

# RADAR Not updated since 2011, used by RecurringTrip model
# TODO could recurring_select gem replace this?
gem 'schedule_atts', :git => 'git://github.com/zpearce/Schedule-Attributes.git'

gem 'haml'

# ENV var management
gem 'figaro'

# datatables
gem 'jquery-datatables-rails'

# bootstrap
gem 'bootstrap-sass'

# soft-delete
gem "paranoia"

# Manage application-level settings
gem 'rails-settings-cached'

# Use redis as the cache_store for Rails
gem 'redis-rails'

# font-awesome icons
gem "font-awesome-rails"

# jQuery full calendar plugin with resource views
#gem 'rails-fullcalendar-resourceviews', '~> 1.6.5.7', github: 'xudongcamsys/rails-fullcalendar-resourceviews'

# overcome IE9 4096 per stylesheet limit
gem 'css_splitter'

# background workder
gem 'sidekiq'

# Form helper for accepts_nested_attributes_for
gem 'nested_form'

# reporting engine
gem 'reporting', github: 'camsys/reporting', branch: 'rails_5'
#gem 'reporting', path: '~/reporting'

# styling
gem 'bootstrap-kaminari-views'

# momentjs for datetime parsing
gem 'momentjs-rails'

# phone number validation and display
gem 'phony_rails'

# logging activities for Tracker Action Log
gem 'public_activity' 

# twitter typeahed
#gem 'twitter-typeahead-rails'

# new relic for app monitoring
#gem 'newrelic_rpm'

# Printing
gem 'wicked_pdf'

# In-line editing
gem 'bootstrap-editable-rails'

# Excel
#gem 'axlsx', git: "https://github.com/randym/axlsx.git"
#gem 'axlsx_rails'
gem 'rubyXL'

gem 'responders', '~> 2.0'

group :integration, :qa, :production do 
  gem 'rails_12factor'
  gem 'unicorn'
  gem 'rack-timeout'
  gem 'wkhtmltopdf-binary'
end

group :development do
  # preview mail in dev
  gem "letter_opener"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem "spring-commands-rspec"
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'web-console', '~> 2.0'
end

group :production do
  gem 'exception_notification'
end

group :test, :development do
  gem 'byebug'
  gem 'rspec-rails'
  gem 'rails-controller-testing'
  gem 'capybara'
  gem 'factory_bot_rails'
  gem 'database_cleaner'
  gem 'faker'
  gem 'timecop'
end

group :test do 
  gem 'launchy'
  gem 'selenium-webdriver'
end
