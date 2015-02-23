require "rails_helper"

RSpec.describe FundingSourcesController, type: :controller do
  # This controller requires super_admin access
  login_super_admin_as_current_user

  # This should return the minimal set of attributes required to create a valid
  # FundingSource. As you add validations to FundingSource, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    attributes_for(:funding_source)
  }

  let(:invalid_attributes) {
    attributes_for(:funding_source, :name => "")
  }

  describe "GET #index" do
    it "assigns all funding_sources as @funding_sources" do
      funding_source = create(:funding_source)
      get :index, {}
      expect(assigns(:funding_sources)).to eq([funding_source])
    end
  end

  describe "GET #show" do
    it "redirects to the edit path of the requested funding_source" do
      funding_source = create(:funding_source)
      get :show, {:id => funding_source.to_param}
      expect(response).to redirect_to(edit_funding_source_path(funding_source))
    end
  end

  describe "GET #new" do
    it "assigns a new funding_source as @funding_source" do
      get :new, {}
      expect(assigns(:funding_source)).to be_a_new(FundingSource)
    end
  end

  describe "GET #edit" do
    it "assigns the requested funding_source as @funding_source" do
      funding_source = create(:funding_source)
      get :edit, {:id => funding_source.to_param}
      expect(assigns(:funding_source)).to eq(funding_source)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new FundingSource" do
        expect {
          post :create, {:funding_source => valid_attributes, :provider => [@current_user.current_provider]}
        }.to change(FundingSource, :count).by(1)
      end

      it "assigns a newly created funding_source as @funding_source" do
        post :create, {:funding_source => valid_attributes, :provider => [@current_user.current_provider]}
        expect(assigns(:funding_source)).to be_a(FundingSource)
        expect(assigns(:funding_source)).to be_persisted
      end

      it "creates a funding source visibility for each provider specified" do
        provider_1 = create(:provider)
        provider_2 = create(:provider)
        post :create, {:funding_source => valid_attributes, :provider => [@current_user.current_provider, provider_1.id, provider_2.id]}
        expect(assigns(:funding_source).funding_source_visibilities.collect(&:provider)).to include(@current_user.current_provider)
        expect(assigns(:funding_source).funding_source_visibilities.collect(&:provider)).to include(provider_1)
        expect(assigns(:funding_source).funding_source_visibilities.collect(&:provider)).to include(provider_2)
      end

      it "redirects to the created funding_source" do
        post :create, {:funding_source => valid_attributes, :provider => [@current_user.current_provider.id]}
        expect(response).to redirect_to(FundingSource.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved funding_source as @funding_source" do
        post :create, {:funding_source => invalid_attributes}
        expect(assigns(:funding_source)).to be_a_new(FundingSource)
      end

      it "re-renders the 'new' template" do
        post :create, {:funding_source => invalid_attributes}
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        { :name => "Gary" }
      }

      it "updates the requested funding_source" do
        funding_source = create(:funding_source, :name => "Patrick")
        expect {
          put :update, {:id => funding_source.to_param, :funding_source => new_attributes}
        }.to change { funding_source.reload.name }.from("Patrick").to("Gary")
      end

      it "assigns the requested funding_source as @funding_source" do
        funding_source = create(:funding_source)
        put :update, {:id => funding_source.to_param, :funding_source => valid_attributes}
        expect(assigns(:funding_source)).to eq(funding_source)
      end

      it "creates a funding source visibility for each new provider specified" do
        provider_1 = create(:provider)
        provider_2 = create(:provider)
        funding_source = create(:funding_source, :provider => [@current_user.current_provider, provider_1])
        put :update, {:id => funding_source.to_param, :funding_source => valid_attributes, :provider => [provider_2.id]}
        expect(assigns(:funding_source).funding_source_visibilities.collect(&:provider)).to include(provider_2)
      end

      it "destroys the funding source visibility for each provider not specified" do
        provider_1 = create(:provider)
        provider_2 = create(:provider)
        funding_source = create(:funding_source, :provider => [@current_user.current_provider, provider_1])
        put :update, {:id => funding_source.to_param, :funding_source => valid_attributes, :provider => [provider_2.id]}
        expect(assigns(:funding_source).funding_source_visibilities.collect(&:provider)).to_not include(@current_user.current_provider)
        expect(assigns(:funding_source).funding_source_visibilities.collect(&:provider)).to_not include(provider_1)
      end

      it "redirects to the funding_source" do
        funding_source = create(:funding_source)
        put :update, {:id => funding_source.to_param, :funding_source => valid_attributes}
        expect(response).to redirect_to(funding_source)
      end
    end

    context "with invalid params" do
      it "assigns the funding_source as @funding_source" do
        funding_source = create(:funding_source)
        put :update, {:id => funding_source.to_param, :funding_source => invalid_attributes}
        expect(assigns(:funding_source)).to eq(funding_source)
      end

      it "re-renders the 'edit' template" do
        funding_source = create(:funding_source)
        put :update, {:id => funding_source.to_param, :funding_source => invalid_attributes}
        expect(response).to render_template("edit")
      end
    end
  end

end
