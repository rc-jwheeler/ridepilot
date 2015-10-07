class API::V1::ProvidersController < API::ApiController
  
  def show
    Provider = Provider.find_by_id(params[:provider_id])

    if !Provider
      error(:unprocessable_entity, TranslationEngine.translate_text(:provider_not_exist))
    else
      render json: {}
    end

  end
 
end
