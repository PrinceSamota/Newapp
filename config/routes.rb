Rails.application.routes.draw do
  resources :bill_of_materials
  resources :raw_material_stock_batches, only: [:new, :create, :index]
  resources :boms, only: [:index, :new, :create]
  get 'item_masters/:id/details', to: 'item_masters#details'
  post 'manual_decode', to: 'articles#manual_decode'
post 'item_masters/decode_article', to: 'item_masters#decode_article'
  resources :bom_raw_materials
  resources :raw_material_inwards
  resources :orders, only: [:show]
  resources :availabilities, only: [:new, :create, :index]
  resources :item_masters, only: [:create, :show]
  resources :organizations
  resources :measurements, only: [:new, :create, :index]
  resources :categories, only: [:new, :create, :index]
  root 'uploads#index'
  resources :uploads, only: [:index, :create, :show]
  post 'decode_article', to: 'articles#decode'
get  'manual_decode', to: 'articles#manual_decode'
post 'manual_decode', to: 'articles#manual_decode_post'
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
