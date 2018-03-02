Rails.application.routes.draw do
  get 'users/profile' => 'application#profile'

  post 'user_token' => 'user_token#create'
  post 'sign_up' => 'user#sign_up'
  post 'fb_login' => 'user#fb_login'

  mount Knock::Engine => "/knock"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
