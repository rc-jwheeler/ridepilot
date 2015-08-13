Rake.application.instance_variable_get('@tasks').delete('db:test:prepare')
namespace :db do
  namespace :test do
    task :prepare => :environment do
      Rake::Task["db:drop"].invoke
      Rake::Task["db:create"].invoke
      Rake::Task["db:schema:load"].invoke
      Rake::Task["ridepilot:load_locales"].invoke
    end
  end
end
