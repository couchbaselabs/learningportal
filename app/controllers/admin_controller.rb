class AdminController < ApplicationController
  layout "admin"
  skip_before_filter :authenticate_user!
  skip_before_filter :users
end