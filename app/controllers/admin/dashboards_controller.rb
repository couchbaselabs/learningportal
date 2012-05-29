class Admin::DashboardsController < ApplicationController

  layout "admin"

  def show
    @content_view_totals = Article.view_stats_type
    @content_view_totals[:overall] = Article.view_stats_type.sum{|t| t.last}
  end

end