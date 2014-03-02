AviationData::Application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config

  ActiveAdmin.routes(self)

  mount AviationData::Api => '/'
end
