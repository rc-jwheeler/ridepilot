# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if !Provider.exists?(1)
  provider = Provider.new(:name => 'Ride Connection', :dispatch => true)
  provider.logo = File.open(Rails.root.join("public", "ride_connection_logo.png"))
  provider.save!
end

f = File.new(Rails.root.join('db', 'trimet.wkt'))
wkt = f.read
f.close
poly = RGeo::Geos.factory(srid: 4326).polygon(wkt)
region = Region.create(:name => "TriMet", :the_geom => poly)

for name in ["Scooter", "Wheelchair", "Wheelchair - Oversized", "Wheelchair - Can Transfer", "Unknown", "Ambulatory"]
  Mobility.create(:name=>name)
end
