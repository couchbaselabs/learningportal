class SnapshotJob

  def initialize(snapshot_id)
    @snapshot_id = snapshot_id
  end

  def perform
    @snapshot = Snapshot.find(@snapshot_id)
    @snapshot.perform!
  end

end