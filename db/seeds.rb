# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

ActiveRecord::Base.transaction do
  puts "Seeding..."

  puts "Creating initial mobilities..."
  ["Scooter", "Wheelchair", "Wheelchair - Oversized", "Wheelchair - Can Transfer", "Unknown", "Ambulatory"].each do |name|
    Mobility.find_or_create_by!(:name => name)
  end

  puts "Seeding translations"

  Rake::Task["ridepilot:load_locales"].invoke

  puts "Done seeding"

end
