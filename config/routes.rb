LearningPortal::Application.routes.draw do

  get "sidebar/all_tags"

  devise_for :users, :controllers => {
    :registrations  =>  "registrations",
    :sessions       =>  "sessions",
    :passwords      =>  "passwords"
  }

  resources :articles, :except => [:index]
  resources :authors
  resources :tags
  match '/tag' => 'tags#show', :as => :tag
  match '/author' => 'authors#show', :as => :author

  namespace :admin do
    root :to => 'dashboards#show'
    resource :dashboard
    resources :articles
    resources :users
    resources :snapshots
  end

  root :to => 'articles#popular'

  match '/tag_sidebar' => 'sidebar#all_tags', :as => :sidebar_tag
  match '/contributor_sidebar' => 'sidebar#all_contributors', :as => :sidebar_contributor
  match '/overview' => 'sidebar#overview', :as => :sidebar_overview
  match '/contributors/:letter' => 'authors#by_first_letter', :as => :authors_by_first_letter
  match '/tags/by_first_letter/:letter' => 'tags#by_first_letter', :as => :tags_by_first_letter
  match '/:type' => "articles#index", :constraints => { :type => /articles|images|videos/}, :as => :articles
  match 'admin/login_as/:user_id' => "admin/users#login_as", :as => :login_as
  match 'admin/login_as_random' => "admin/users#login_as_random", :as => :login_as_random
  match 'admin/simulation' => 'admin/dashboards#simulation', :as => :simulation

  match "/search" => "search#build", :as => :search

  match '/random' => 'articles#random', :as => :random_article

end