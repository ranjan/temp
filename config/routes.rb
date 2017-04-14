Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :home

  resources :parser do
    collection do
      post 'get_property_list'
      post 'property_details'
    end
  end
end
