class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_admin!
  before_filter :authenticate_user!
  before_filter :content_totals
  before_filter :users

  private

  def fetch_authors_and_categories
    @authors = Author.popular(:limit => 8)
    @categories = Category.popular(:limit => 10)
    # @authors = []
    # @categories = []
  end

  def authenticate_admin!
    return true if Rails.env.development?
    authenticate_or_request_with_http_basic do |username, password|
      username == "couchbase" && password == ENV['HTTP_AUTH_PASSWORD']
    end
  end

  def content_totals
    @content_totals = Article.totals
  end

  def users
    @users = User.all
  end

end
