LearningPortal::Application.routes.draw do

  devise_for :users, :controllers => {
    :registrations  =>  "registrations",
    :sessions       =>  "sessions",
    :passwords      =>  "passwords"
  }

  resource :search do
    collection do
      get :result
    end
  end
  root :to => 'searches#build'
end
