Rails.application.routes.draw do
  root 'man#index'
  get '/validate' => 'man#validate'
end
