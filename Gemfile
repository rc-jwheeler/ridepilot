source 'http://rubygems.org'

gem 'rails', '~> 3.1.0'

gem 'jquery-rails'

gem 'pg'
gem 'cancan',               '~> 1.6.5'
gem 'devise',               '~> 1.5.3'
gem 'GeoRuby',              '~> 1.3.4'
gem 'activerecord-postgis-adapter', 
                            '~> 0.6.0' # 0.7+ require Rails 4.0+
gem 'whenever',             '~> 0.9.4'
gem 'ice_cube',             '0.6.8' # current recurring trip tracking relies on this version
gem 'validates_timeliness', '~> 3.0.11'
gem 'paperclip',            '~> 2.8.0'
gem 'will_paginate',        '~> 3.0.pre2'
gem 'attribute_normalizer', '~> 1.2.0'
gem 'userstamp',            :git => 'git@github.com:kimkong/userstamp.git'
gem 'escape_utils',         '~> 1.0.1'
gem 'rails3-jquery-autocomplete', '~> 1.0.14'
gem 'schedule_atts',              :git => 'git://github.com/zpearce/Schedule-Attributes.git'

# Deploy with Capistrano
gem "capistrano",     :require => false # We need it to be installed, but it's
gem "capistrano-ext", :require => false # not a runtime dependency
gem "rvm-capistrano", :require => false

group :production do
  gem 'exception_notification', '~> 3.0'
end

group :test, :development do
  gem 'sqlite3', :require => 'sqlite3'
  gem 'rspec-rails', '~> 2.6.1'
  gem 'capybara', '~> 1.0.0'
  gem 'fixjour'
  gem 'faker'
  gem 'byebug'
end
