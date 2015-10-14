Rails.application.routes.draw do
  root 'man#index'
  get '/validate' => 'man#validate'

  post '/share' => 'man#save_share_image'
end
