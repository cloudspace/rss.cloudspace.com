require 'resque_web'
ResqueWeb::Engine.eager_load!

EasyReaderRSS::Application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  namespace :v2 do
    get '/', to: redirect('https://github.com/cloudspace/rss.cloudspace.com')
    match 'callback', via: [:get, :post]
    resources :feeds, only: [:create, :show] do
      collection do
        get 'default'
        get 'search'
      end
      member do
        post 'processed', to: 'feeds#processed'
      end
    end

    resources :feed_items, only: [:index] do
      collection do
        match 'callback', via: [:get, :post]
      end
      member do
        match 'complete', via: [:get, :post]
        match 'image_processed', via: [:get, :post]
      end
    end
  end

  mount ResqueWeb::Engine => '/resque_web'
  get '/', to: redirect('https://github.com/cloudspace/rss.cloudspace.com')
end
