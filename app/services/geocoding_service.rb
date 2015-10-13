class GeocodingService

  attr_reader :term, :provider

  def initialize(search_str, provider)
    @term = search_str
    @provider = provider
    @base_url = "http://open.mapquestapi.com/nominatim/v1/search.php?key=#{ENV['MAPREQUEST_API_KEY']}&format=json&addressdetails=1&countrycodes=us&limit=10"
  end

  def execute
    url = @base_url + "&q=" + CGI.escape(@term)
    viewbox_str = add_search_viewbox_to_url #only addresses within one decimal degree of the district
    url += viewbox_str if viewbox_str

    result = OpenURI.open_uri(url).read

    addresses = ActiveSupport::JSON.decode(result)

    #now, convert addresses to local json format
    address_json = addresses.map { |raw_address|
      # TODO add apt numbers
      address = raw_address['address']
      street_address = '%s %s' % [address['house_number'], address['road']]
      city = address['city'] || address['town'] || address['hamlet']
      state = STATE_NAME_TO_POSTAL_ABBREVIATION[address['state'].upcase]

      address_obj = Address.new(
                  :address => street_address,
                  :city => city,
                  :state => state,
                  :zip => address['postcode'],
                  :the_geom => RGeo::Geographic.spherical_factory(srid: 4326).point(raw_address['lon'].to_f, raw_address['lat'].to_f)
                  )
      next if !address_obj.valid?
      address_obj.json

    }

    address_json.compact
  end

  private

  def add_search_viewbox_to_url
    if @provider && @provider.region_nw_corner && @provider.region_se_corner
      min_lon = @provider.region_nw_corner.x 
      max_lon = @provider.region_se_corner.x 
      min_lat = @provider.region_se_corner.y 
      max_lat = @provider.region_nw_corner.y 
    elsif GOOGLE_MAP_DEFAULTS && GOOGLE_MAP_DEFAULTS[:bounds]
      min_lon = GOOGLE_MAP_DEFAULTS[:bounds][:west]
      max_lon = GOOGLE_MAP_DEFAULTS[:bounds][:east]
      min_lat = GOOGLE_MAP_DEFAULTS[:bounds][:south]
      max_lat = GOOGLE_MAP_DEFAULTS[:bounds][:north]
    end

    viewbox_str = "&viewbox=#{min_lon},#{max_lat},#{max_lon},#{min_lat}" if min_lon && max_lat && max_lon && min_lat

    viewbox_str
  end

end