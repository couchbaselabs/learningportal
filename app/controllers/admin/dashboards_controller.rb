class Admin::DashboardsController < ApplicationController

  layout "admin"

  def show
    @content_view_totals = ViewStats.views_by_type
    @content_view_totals[:overall] = ViewStats.views_by_type.sum{|t| t.last}

    @snapshots = Snapshot.all

  end

end