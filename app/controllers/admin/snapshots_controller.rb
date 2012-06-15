class Admin::SnapshotsController < AdminController

  def create
    @snapshot = Snapshot.create!
    Delayed::Job.enqueue(SnapshotJob.new(@snapshot.id))
    redirect_to admin_dashboard_path, :notice => "Snapshot queued for processing"
  end

end