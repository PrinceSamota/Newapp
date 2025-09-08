Rails.application.routes.draw do
  
  resources :onboardings, only: [:index] do
    collection do
      post "upload"
    end
  end
  resources :reports do
    collection do
      get :new_order_report
    end
  end
  resources :dispatches do
    get :new_item_row, on: :collection
    get :order_details, on: :collection
    get :new_item_row_edit, on: :collection
  end
  resources :bill_of_materials, only: [:index, :new, :create, :show] do
    member do
      get :clone 
      post :update_stock
    end
  end
  resources :fuse_types, only: [:index, :create]
  resources :ccts, only: [:index, :create]
  resources :cover_types, only: [:index, :create]
  resources :item_types, only: [:index, :create]
  resources :lengths, only: [:index, :create]
  resources :loops, only: [:index, :create]
  resources :profiles, only: [:index, :create]
  resources :voltages, only: [:index, :create]
  resources :wattages, only: [:index, :create]
  resources :production_orders do
    member do   
    post :update_stock
    post :bom_details
    end
  end
  resources :clients, only: [:create]
  resources :order_entries 
get '/boms/find_by_sku', to: 'bill_of_materials#find_by_sku'
# get "/production_orders/:sku_id/:item_name/bom_details", to: "production_orders#bom_details", as: :production_order_bom_details
# config/routes.rb
get "item_masters/fetch_by_article", to: "item_masters#fetch_by_article"
post '/manual_decode', to: 'order_entries#manual_decode', as: :manual_decode
get '/manual_decode', to: 'order_entries#manual_decode'
get 'bill_of_materials/:sku_id/:item_name/bom_details', to: 'bill_of_materials#bom_details', as: :bill_of_material_bom_details
patch 'bill_of_materials/:id/update_bom_all_items', to: 'bill_of_materials#update_bom_all_items', as: :update_bom_all_items
resources :extras, only: [:create]
resources :statuses, only: [:create]
resources :raw_material_stock_batches
  resources :boms, only: [:index, :new, :create]
get "/check_bom", to: "item_masters#check_bom"
get "/check_bom_usage", to: "item_masters#check_bom_usage"
  get 'item_masters/:id/details', to: 'item_masters#details'
post 'item_masters/decode_article', to: 'item_masters#decode_article'
get '/dispatches/new_item_row', to: 'dispatches#new_item_row'
resources :suppliers, only: [:create]
resources :locations, only: [:create]
  resources :bom_raw_materials
  resources :raw_material_inwards
  resources :orders, only: [:show]
  resources :availabilities, only: [:new, :create, :index]
  resources :item_masters do
    member do
      patch :update_stock
      get :versions
    end
  end
  resources :organizations
  resources :measurements, only: [:new, :create, :index]
  resources :categories, only: [:new, :create, :index]
  root 'item_masters#index'
  resources :uploads, only: [:index, :create, :show]
get 'manual_decode_result', to: 'articles#manual_decode_result'
  devise_for :users
  resources :posts
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
   
end
