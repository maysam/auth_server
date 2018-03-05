Rails.application.routes.draw do
  get 'users/profile' => 'user#profile'
  post 'users' => 'user#sign_up'

  post 'user_token' => 'user_token#create'
  post 'fb_login' => 'user#fb_login'
  get 'fb_login' => 'user#login_on_fb'
  get 'fb_return' => 'user#fb_return'

  mount Knock::Engine => "/knock"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
