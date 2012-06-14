class Admin::SnapshotsController < AdminController

  def create
    @snapshot = Snapshot.create!
    redirect_to admin_dashboard_path
  end

end