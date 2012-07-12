class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_admin!
  before_filter :authenticate_user!
  before_filter :content_totals
  before_filter :users
  before_filter :search_terms
  before_filter :assign_current_user

  private

  def assign_current_user
    User.current = current_user if current_user.present?
  end

  def search_terms
    @search_terms = {'popularity' => 100, 'preferences' => 100}.merge(params)
    @search_terms
  end

  def fetch_authors_and_categories
    @authors = Author.popular
    @categories = Category.popular
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
    @users = []
    #@users = User.all
  end

  def limit_endless_scroll
    if @items.nil? || @items.count == 0 && request.format == Mime::JS
      response.body = ""
      response.status = 416
    end
  end

end
