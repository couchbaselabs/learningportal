LearningPortal::Application.routes.draw do

  devise_for :users

  resource :search do
    collection do
      get :result
    end
  end
  root :to => 'searches#build'
end
