class API::V1::TripPurposesController < API::ApiController
  
  def index
    provider = Provider.find_by_id(params[:provider_id])

    if !provider
      error(:unprocessable_entity, TranslationEngine.translate_text(:provider_not_exist))
    else
      render json: { trip_purposes: TripPurpose.by_provider(provider).map(&:as_api_json) }
    end

  end
 
end
