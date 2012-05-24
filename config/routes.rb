LearningPortal::Application.routes.draw do

  get "sidebar/all_tags"

  devise_for :users, :controllers => {
    :registrations  =>  "registrations",
    :sessions       =>  "sessions",
    :passwords      =>  "passwords"
  }

  resources :articles


  namespace :admin do
    root :to => 'dashboards#show'
    resource :dashboard
    resources :articles
    resources :users
  end

  resource :search do
    collection do
      get :result
    end
  end
  root :to => 'searches#build'

  match '/tag_sidebar' => 'sidebar#all_tags', :as => :sidebar_tag
  match '/contributor_sidebar' => 'sidebar#all_contributors', :as => :sidebar_contributor
  match '/overview' => 'sidebar#overview', :as => :sidebar_overview
  match '/authors/:letter' => 'authors#by_first_letter', :as => :authors_by_first_letter
  match '/tags/:letter' => 'tags#by_first_letter', :as => :tags_by_first_letter
end