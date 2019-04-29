# frozen_string_literal: true

Rails.application.routes.draw do
  defaults format: :json do
    resources :users, only: %i[create index], format: false do
      get :search, on: :collection
      resources :orders, only: %i[create index]
    end
    resources :orders, only: %i[create index], format: false
  end
end
