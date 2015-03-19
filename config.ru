# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

# Let rack know if we're running relative to a subdirectory
map Rails.application.config.relative_url_root || "/" do
  run Rails.application
end
