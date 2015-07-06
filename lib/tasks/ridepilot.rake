namespace :ridepilot do
  desc 'Seed default trip purposes'
  task :seed_trip_purposes => :environment do
    seed_file = File.join(Rails.root, 'db', 'tasks', 'seed_trip_purposes.rb')
    load(seed_file) if File.exist?(seed_file)

    puts 'Finished seeding trip purposes'
  end
end
