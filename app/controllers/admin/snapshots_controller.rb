class Admin::SnapshotsController < ApplicationController

  layout "admin"
  skip_before_filter :authenticate_user!

  def create
    @snapshot = Snapshot.create!
    redirect_to admin_dashboard_path
  end

end