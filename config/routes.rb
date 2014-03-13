Ridepilot::Application.routes.draw do
  root :to => "home#index"

  devise_for :users, :controllers=>{:sessions=>"users"} do
    get "check_session" => "users#check_session"
    get "init" => "users#show_init"
    get "new_user" => "users#new_user"
    get "show_change_password" => "users#show_change_password"
    get "touch_session" => "users#touch_session"
    match "change_password"  => "users#change_password"
    post "change_provider" => "users#change_provider"
    post "create_user" => "users#create_user"
    post "init" => "users#init"
    put "create_user" => "users#create_user"
  end

  resources :customers do
    post :inactivate, :as => :inactivate
    
    collection do
      get :all
      get :autocomplete
      get :found
      get :search
    end
  end

  resources :trips do 
    get :reconcile_cab, :on=>:collection
    get :trips_requiring_callback, :on=>:collection
    get :unscheduled, :on=>:collection
    post :confirm, :as => :confirm
    post :no_show, :as => :no_show
    post :reached, :as => :reached
    post :send_to_cab, :as => :send_to_cab
    post :turndown, :as => :turndown
  end

  resources :repeating_trips

  resources :providers do
    post :change_role
    post :delete_role
    member do
      post :change_dispatch
      post :change_reimbursement_rates
      post :change_scheduling
      post :change_allow_trip_entry_from_runs_page
      post :save_region
      post :save_viewport
    end
  end

  resources :addresses do
    collection do
      get :autocomplete
      get :search
    end
  end
  
  resources :device_pools, :except => [:index] do
    resources :device_pool_drivers, :only => [:create, :destroy]
  end
  
  resources :drivers
  resources :funding_sources
  resources :monthlies
  resources :provider_ethnicities
  resources :vehicles
  resources :vehicle_maintenance_events

  resources :runs do
    collection do
      get :for_date
      get :uncompleted_runs
    end
  end
  
  resources :cab_trips, :only => [:index] do
    collection do
      get :edit_multiple
      put :update_multiple
    end
  end

  scope :via => :post, :constraints => { :format => "json" , :protocol => "https" } do
    match "device_pool_drivers/" => "v1/device_pool_drivers#index", :as => "v1_device_pool_drivers"
    match "v1/device_pool_drivers/:id" => "v1/device_pool_drivers#update", :as => "v1_device_pool_driver"
  end
  
  match "dispatch", :controller => :dispatch, :action => :index
  match "reports", :controller=>:reports, :action=>:index
  match "reports/:action", :controller=>:reports
  match "reports/:action/:id", :controller=>:reports
  match "test_exception_notification" => "application#test_exception_notification"

  root :to => "home#index"
end
