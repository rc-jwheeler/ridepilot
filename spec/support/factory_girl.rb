RSpec.configure do |config|
  config.before(:suite) do
    begin
      FactoryGirl.lint
    ensure
      DatabaseCleaner.clean
    end
  end
end
