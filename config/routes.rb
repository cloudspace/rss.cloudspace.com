require 'resque_web'

EasyReaderRSS::Application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  namespace :v2 do
    resources :feeds, only: [:create, :show] do
      collection do
        get 'default'
        get 'search'
      end
    end

    resources :feed_items, only: [:index]
  end

  mount ResqueWeb::Engine => '/resque_web'
end
