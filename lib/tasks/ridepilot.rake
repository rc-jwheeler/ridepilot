namespace :ridepilot do

  #------------- Incremental Seeding ------------------
  desc 'Seed default trip purposes'
  task :seed_trip_purposes => :environment do
    seed_file = File.join(Rails.root, 'db', 'tasks', 'seed_trip_purposes.rb')
    load(seed_file) if File.exist?(seed_file)

    puts 'Finished seeding trip purposes'
  end

  desc 'Seed default trip results'
  task :seed_trip_results => :environment do
    seed_file = File.join(Rails.root, 'db', 'tasks', 'seed_trip_results.rb')
    load(seed_file) if File.exist?(seed_file)

    puts 'Finished seeding trip results'
  end

  desc 'Seed default service levels'
  task :seed_service_levels => :environment do
    seed_file = File.join(Rails.root, 'db', 'tasks', 'seed_service_levels.rb')
    load(seed_file) if File.exist?(seed_file)

    puts 'Finished seeding service levels'
  end

  desc 'Seed lookup table configurations'
  task :seed_lookup_table_configurations => :environment do
    seed_file = File.join(Rails.root, 'db', 'tasks', 'seed_lookup_table_configurations.rb')
    load(seed_file) if File.exist?(seed_file)

    puts 'Finished seeding lookup table configurations'
  end

  #------------- End of Incremental Seeding --------------
end
