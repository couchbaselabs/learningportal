class Admin::DashboardsController < AdminController

  def show
    @content_view_totals = GlobalViewStats.views_by_type({}, true)

    @snapshots = Snapshot.all

  end

  def simulation
    if params[:times].nil?
      @times = 100
    else
      @times = params[:times].to_i
    end

    @times.times do
      Delayed::Job.enqueue UserLoadJob.new
    end

    redirect_to admin_dashboard_path, :notice => "#{@times} user interations now queued for processing"
  end

end