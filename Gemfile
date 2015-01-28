source 'http://rubygems.org'

gem 'rails', '~> 3.2.0'

# TODO enable this block when we're ready to move to asset pipeline
# group :assets do
#   gem 'sass-rails', '~> 3.2.6'
#   gem 'coffee-rails', '~> 3.2.2'
#   gem 'uglifier', '>= 1.0.3'
# end

gem 'jquery-rails'

gem 'pg'
gem 'cancancan',            '~> 1.10.1'
gem 'devise',               '~> 3.4.1'
gem 'GeoRuby',              '~> 1.3.4'
gem 'activerecord-postgis-adapter', 
                            '~> 0.6.0' # 0.7+ require Rails 4.0+
gem 'whenever',             '~> 0.9.4', :require => false
gem 'ice_cube',             '0.6.8' # current recurring trip tracking relies on this version
gem 'validates_timeliness', '~> 3.0.14'
gem 'paperclip',            '~> 2.8.0' # TODO latest?
gem 'will_paginate',        '~> 3.0.7'
gem 'attribute_normalizer', '~> 1.2.0'
gem 'userstamp',            :git => 'git@github.com:kimkong/userstamp.git'
gem 'escape_utils',         '~> 1.0.1'
gem 'rails3-jquery-autocomplete', 
                            '~> 1.0.15' # TODO latest?
gem 'schedule_atts',        :git => 'git://github.com/zpearce/Schedule-Attributes.git' # RADAR Not updated since 2011

# Deploy with Capistrano
gem "capistrano",     :require => false # We need it to be installed, but it's
gem "capistrano-ext", :require => false # not a runtime dependency
gem "rvm-capistrano", :require => false

group :production do
  gem 'exception_notification', '~> 4.0'
end

group :test, :development do
  gem 'sqlite3', :require => 'sqlite3'
  gem 'rspec-rails', '~> 3.1'
  gem 'capybara', '~> 2.4'
  gem 'fixjour'
  gem 'faker'
  gem 'byebug'
end
