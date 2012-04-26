LearningPortal::Application.routes.draw do

  resource :search
  root :to => 'search#show'
end
