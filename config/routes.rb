LearningPortal::Application.routes.draw do

  devise_for :users

  resource :search
  root :to => 'searches#build'
end
