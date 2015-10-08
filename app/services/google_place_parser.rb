class GooglePlaceParser

  attr_reader :raw_data

  def initialize(raw_data)
    @raw_data = raw_data
  end

  def parse

    begin
      address_data = parse_address_data
      
      {
        phone_number: @raw_data[:formatted_phone_number],
        address: address_data[:street_address],
        city: address_data[:city],
        state: address_data[:state],
        zip: address_data[:zipcode],
        building_name: @raw_data[:name],
        the_geom: parse_geom
      }
    rescue => e
      Rails.logger.error e.message
    end
  end

  private

  def parse_address_data
    address_params = @raw_data[:address_components]

    address_data = {}
    if !address_params.empty?
      address_params.each do |comp|
        if comp && comp.keys.index(:types)
          if comp[:types].index("street_address")
            address_data[:street_address] = comp[:long_name]
          elsif comp[:types].index("locality")
            address_data[:city] = comp[:long_name]
          elsif comp[:types].index("administrative_area_level_1")
            address_data[:state] = comp[:long_name]
          elsif comp[:types].index("postal_code")
            address_data[:zipcode] = comp[:long_name]
          end 
        end
      end
    end

    address_data
  end

  def parse_geom
    location = @raw_data[:geometry][:location] rescue nil
    lat = location[:lat].to_f rescue nil
    lng = location[:lng].to_f rescue nil

    RGeo::Geographic.spherical_factory(srid: 4326).point(lng, lat) if lat && lng
  end

end