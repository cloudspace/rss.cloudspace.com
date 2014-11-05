EasyReaderRSS::Application.routes.draw do
  namespace :v2 do
    resources :feeds, only: [:create, :show] do
      collection do
        get 'default'
        get 'search'
      end
    end

    resources :feed_items, only: [:index]
  end
end
