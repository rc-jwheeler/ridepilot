source 'http://rubygems.org'

gem 'rails', '3.0.19'

gem 'pg'
gem 'cancan',               '~> 1.6.5'
gem 'devise',               '~> 1.5.3'
gem 'GeoRuby',              '~> 1.3.4'
gem 'spatial_adapter',      '~> 1.2.0'
gem 'jquery-rails',         '~> 1.0.2'
gem 'whenever',             '0.6.8'
gem 'ice_cube',             '0.6.8' # current recurring trip tracking relies on this version
gem 'validates_timeliness', '~> 3.0.11'
gem 'paperclip',            '~> 2.8.0'
gem 'will_paginate',        '3.0.pre2'
gem 'attribute_normalizer', '~> 0.3.1'
gem 'userstamp',            '~> 2.0.1'
gem 'bartt-ssl_requirement','~> 1.2.7', :require => 'ssl_requirement'
gem 'escape_utils',         '~> 0.2.4'
gem 'rails3-jquery-autocomplete', :git => 'git://github.com/juliamae/rails3-jquery-autocomplete'
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
  gem 'debugger'
end
