RSpec.configure do |config|
  config.before(:suite) do
    begin
      factories_to_lint = FactoryGirl.factories.reject do |factory|
        # Do not lint the document factory since it requires a trait to be valid
        factory.name == :document
      end
      
      FactoryGirl.lint factories_to_lint
    ensure
      DatabaseCleaner.clean
    end
  end
end
