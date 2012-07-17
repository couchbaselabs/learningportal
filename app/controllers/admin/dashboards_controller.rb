class Admin::DashboardsController < AdminController

  def show
    @content_view_totals = PeriodViewStats.views_by_type
    @content_view_totals[:overall] = PeriodViewStats.views_by_type.sum{|t| t.last}

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