Rails.application.routes.draw do
  namespace :api do
    namespace :planning do
      resources :reservations, only: [:index, :create]
    end
  end
end
