require "rails_helper"

RSpec.describe ProviderEthnicitiesController, type: :controller do
  login_admin_as_current_user

  # This should return the minimal set of attributes required to create a valid
  # ProviderEthnicity. As you add validations to ProviderEthnicity, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    attributes_for(:provider_ethnicity)
  }

  let(:invalid_attributes) {
    attributes_for(:provider_ethnicity, :name => "")
  }

  describe "GET #index" do
    it "redirects to the current user's provider" do
      get :index, {}
      expect(response).to redirect_to(@current_user.current_provider)
    end
  end

  describe "GET #show" do
    it "assigns the requested provider_ethnicity as @provider_ethnicity" do
      provider_ethnicity = create(:provider_ethnicity, :provider => @current_user.current_provider)
      get :show, {:id => provider_ethnicity.to_param}
      expect(assigns(:provider_ethnicity)).to eq(provider_ethnicity)
    end
  end

  describe "GET #new" do
    it "assigns a new provider_ethnicity as @provider_ethnicity" do
      get :new, {}
      expect(assigns(:provider_ethnicity)).to be_a_new(ProviderEthnicity)
    end
  end

  describe "GET #edit" do
    it "assigns the requested provider_ethnicity as @provider_ethnicity" do
      provider_ethnicity = create(:provider_ethnicity, :provider => @current_user.current_provider)
      get :edit, {:id => provider_ethnicity.to_param}
      expect(assigns(:provider_ethnicity)).to eq(provider_ethnicity)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new ProviderEthnicity" do
        expect {
          post :create, {:provider_ethnicity => valid_attributes}
        }.to change(ProviderEthnicity, :count).by(1)
      end

      it "assigns a newly created provider_ethnicity as @provider_ethnicity" do
        post :create, {:provider_ethnicity => valid_attributes}
        expect(assigns(:provider_ethnicity)).to be_a(ProviderEthnicity)
        expect(assigns(:provider_ethnicity)).to be_persisted
      end

      it "redirects to the current user's provider" do
        post :create, {:provider_ethnicity => valid_attributes}
        expect(response).to redirect_to(@current_user.current_provider)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved provider_ethnicity as @provider_ethnicity" do
        post :create, {:provider_ethnicity => invalid_attributes}
        expect(assigns(:provider_ethnicity)).to be_a_new(ProviderEthnicity)
      end

      it "re-renders the 'new' template" do
        post :create, {:provider_ethnicity => invalid_attributes}
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        {
          :name => "Bar"
        }
      }

      it "updates the requested provider_ethnicity" do
        provider_ethnicity = create(:provider_ethnicity, :provider => @current_user.current_provider, :name => "Foo")
        expect {
          put :update, {:id => provider_ethnicity.to_param, :provider_ethnicity => new_attributes}
        }.to change{ provider_ethnicity.reload.name }.from("Foo").to("Bar")
      end

      it "assigns the requested provider_ethnicity as @provider_ethnicity" do
        provider_ethnicity = create(:provider_ethnicity, :provider => @current_user.current_provider)
        put :update, {:id => provider_ethnicity.to_param, :provider_ethnicity => valid_attributes}
        expect(assigns(:provider_ethnicity)).to eq(provider_ethnicity)
      end

      it "redirects to the current user's provider" do
        provider_ethnicity = create(:provider_ethnicity, :provider => @current_user.current_provider)
        put :update, {:id => provider_ethnicity.to_param, :provider_ethnicity => valid_attributes}
        expect(response).to redirect_to(@current_user.current_provider)
      end
    end

    context "with invalid params" do
      it "assigns the provider_ethnicity as @provider_ethnicity" do
        provider_ethnicity = create(:provider_ethnicity, :provider => @current_user.current_provider)
        put :update, {:id => provider_ethnicity.to_param, :provider_ethnicity => invalid_attributes}
        expect(assigns(:provider_ethnicity)).to eq(provider_ethnicity)
      end

      it "re-renders the 'edit' template" do
        provider_ethnicity = create(:provider_ethnicity, :provider => @current_user.current_provider)
        put :update, {:id => provider_ethnicity.to_param, :provider_ethnicity => invalid_attributes}
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested provider_ethnicity" do
      provider_ethnicity = create(:provider_ethnicity, :provider => @current_user.current_provider)
      expect {
        delete :destroy, {:id => provider_ethnicity.to_param}
      }.to change(ProviderEthnicity, :count).by(-1)
    end

    it "redirects to the current user's provider" do
      provider_ethnicity = create(:provider_ethnicity, :provider => @current_user.current_provider)
      delete :destroy, {:id => provider_ethnicity.to_param}
      expect(response).to redirect_to(@current_user.current_provider)
    end
  end

end
