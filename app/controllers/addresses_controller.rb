require 'open-uri'

class AddressesController < ApplicationController
  load_resource :only => [:edit, :update, :destroy]
  authorize_resource

  def autocomplete
    term = parse_search_term

    #three ways to match:
    #- name
    #- building name
    #- substring of textified address (split at comma into address,
    #  city/state/zip)

    address, city_state_zip = term.split(",")
    address.strip!
    if city_state_zip
      city_state_zip.strip!
    else
      city_state_zip = ''
    end

    addresses = Address.accessible_by(current_ability)
      .where(is_driver_associated: false)
      .where(["((LOWER(address) like '%' || ? || '%' ) and  (city || ', ' || state || ' ' || zip like ? || '%')) or LOWER(building_name) like '%' || ? || '%' or LOWER(name) like '%' || ? || '%' ", address, city_state_zip, term, term]).where(:provider_id => current_provider_id, :inactive => false)
    if params[:customer_id].present?
      addresses = addresses.where("customer_id is NULL or customer_id = ?", params[:customer_id]) 
    else
      addresses = addresses.where("customer_id is NULL") #only provider common addresses if customer is not given
    end

    if params[:exclude].present?
      addresses = addresses.where.not(id: params[:exclude].split(','))
    end

    if addresses.size > 0

      #there are some existing addresses
      address_json = addresses.map { |address| address.json }

      address_json << Address::NewAddressOption unless request.env["HTTP_REFERER"].try(:match, /addresses\/[0-9]+\/edit/)

      render :json => address_json
    else
      #no existing addresses
      return render :json => [Address::NewAddressOption]
    end
  end

  def autocomplete_public
    term = parse_search_term

    address_json = GeocodingService.new(term, current_provider).execute

    render :json => address_json
  end

  def edit; end
  
  def create
    the_geom       = params[:lat].to_s.size > 0 ? RGeo::Geographic.spherical_factory(srid: 4326).point(params[:lon].to_f, params[:lat].to_f) : nil
    prefix         = params['prefix'] || ""
    address_params = {}
    
    # Some kind of faux strong parameters...
    for param in ['name', 'building_name', 'address', 'city', 'state', 'zip', 'phone_number', 'in_district', 'trip_purpose_id', 'notes']
      address_params[param] = params[prefix][param]
    end

    address_params[:provider_id] = current_provider_id
    address_params[:the_geom]    = the_geom

    if params[:address_id].present?
      address = Address.find(params[:address_id])
      authorize! :edit, address
      address.attributes = address_params
    else
      address_params[:customer_id] = params[:customer_id] if params[:customer_id].present?
      authorize! :new, Address
      address = Address.new(address_params)
    end

    if address.save
      attrs = address.attributes
      attrs[:label] = address.text.gsub(/\s+/, ' ')
      attrs[:prefix] = prefix
      render :json => attrs.to_json
    else
      errors = address.errors.messages
      errors['prefix'] = prefix
      render :json => errors
    end
  end

  def validate
    the_geom       = params[:lat].to_s.size > 0 ? RGeo::Geographic.spherical_factory(srid: 4326).point(params[:lon].to_f, params[:lat].to_f) : nil
    prefix         = params['prefix'] || ""
    address_params = {}

    # Some kind of faux strong parameters...
    for param in ['name', 'building_name', 'address', 'city', 'state', 'zip', 'phone_number', 'in_district', 'trip_purpose_id', 'notes']
      address_params[param] = params[prefix][param]
    end

    address_params[:provider_id] = current_provider_id
    address_params[:the_geom]    = the_geom

    if params[:address_id].present?
      address = Address.find(params[:address_id])
      address.attributes = address_params
    else
      address = Address.new(address_params)
    end

    if address.valid?
      label = address.address_text
      render :json => {
        success: true,
        prefix: prefix,
        address_text: label,
        attributes: address.attributes.merge({label: label})
      }
    else
      errors = address.errors.messages
      errors[:prefix] = prefix
      render :json => errors
    end
  end

  def search
    @term      = params[:name].downcase
    @provider  = Provider.find params[:provider_id]
    @addresses = Address.accessible_by(current_ability).for_provider(@provider).where(customer_id: nil).order(:address, :name).search_for_term(@term)

    respond_to do |format|
      format.json { render :text => render_to_string(:partial => "results.html") }
    end
  end

  def update
    new_addr_params = address_params
    the_geom       = params[:lat].to_s.size > 0 ? RGeo::Geographic.spherical_factory(srid: 4326).point(params[:lon].to_f, params[:lat].to_f) : nil
    new_addr_params[:the_geom] = the_geom
    
    if @address.update_attributes new_addr_params
      flash.now[:notice] = "Address '#{@address.name}' was successfully updated"
      redirect_to provider_path(@address.provider)
    else
      render :action => :edit
    end
  end

  def destroy
    if @address.trips.present?
      if new_address = @address.replace_with!(params[:address_id])
        redirect_to new_address.provider, :notice => "Address #{@address.name} was successfully replaced with new address #{new_address.name}."
      else
        redirect_to edit_address_path(@address), :notice => "Address #{@address.name} can't be deleted without associating trips with another address."
      end
    else
      @address.destroy
      redirect_to current_provider, :notice => "Address #{@address.name} was successfully deleted."
    end
  end

  def check_loading_status
    status = {
      is_loading: current_provider.address_upload_flag.is_loading 
    }

    status[:summary] = TranslationEngine.translate_text(:address_file_uploaded) if !status[:is_loading]

    render json: status
  end

  def upload
    error_msgs = []

    if !can?(:load, Address)
      error_msgs << TranslationEngine.translate_text(:not_authorized)
    else
      address_file = params[:address][:file] if params[:address]
      
      if !address_file.nil?
        if File.extname(address_file.original_filename) != '.csv'
          error_msgs << TranslationEngine.translate_text(:address_file_should_be_csv)
        elsif current_provider.address_upload_flag.is_loading
          error_msgs << TranslationEngine.translate_text(:address_file_being_uploading)
        else
          begin
            if S3_BUCKET
            # Make an object in your bucket for your upload
              s3_file = S3_BUCKET.object("/provider_addresses/" + address_file.original_filename)
              # Upload the file
              s3_file.put(body: address_file, acl: 'public-read')

              file_url = s3_file.public_url
            else
              file_url = address_file.path
            end

            AddressUploadWorker.perform_async(file_url, current_provider.id) #sidekiq needs to run
          rescue Exception => ex
            current_provider.address_upload_flag.uploaded!
            error_msgs << ex.message
          end
        end
      else
        error_msgs << TranslationEngine.translate_text(:select_address_file_to_upload)
      end
    end

    if error_msgs.size > 0
      full_error_msg = error_msgs.join(' ')
    end

    respond_to do |format|
      format.js
      format.html {redirect_to provider_url(current_provider), alert: full_error_msg }
    end
  end

  private
  
  def address_params
    params.require(:address).permit(:name, :building_name, :address, :city, :state, :zip, :in_district, :provider_id, :phone_number, :inactive, :trip_purpose_id, :notes)
  end

  def parse_search_term
    term = params['term'].downcase.strip

    #clean up address
    term.gsub!(' apt ', ' #')
    term.gsub!(' apartment ', ' #')
    term.gsub!(' suite ', ' #')

    term.gsub!(' n ', ' north ')
    term.gsub!(' ne ', ' northeast ')
    term.gsub!(' e ', ' east ')
    term.gsub!(' se ', ' southeast ')
    term.gsub!(' s ', ' south ')
    term.gsub!(' sw ', ' southwest ')
    term.gsub!(' w ', ' west ')
    term.gsub!(' nw ', ' northwest ')

    term.gsub!(' ave,', 'avenue,')
    term.gsub!(' dr,', 'drive,')
    term.gsub!(' st,', 'street,')
    term.gsub!(' blvd,', 'boulevard,')
    term.gsub!(' pkwy,', 'parkway,')

    term
  end
end
