module SidebarHelper

  # Determines whether to add .active class
  # to the filter content type tabs
  def active?(current=nil)
    if params[:type] == current || (params[:controller] == "searches" && current == "all")
      "active"
    else
      ""
    end
  end
end
