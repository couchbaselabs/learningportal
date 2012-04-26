RailsExceptionHandler.configure do |config|
  config.environments = [:staging, :production]                             # Defaults to [:production]
  # config.storage_strategies = [:active_record, :rails_log, :remote_url => {:target => 'http://example.com'}] # Defaults to []
  config.storage_strategies = [:remote_url => {:target => 'http://guardian.rumblelabs.com/webhooks/errors'}]
  # config.fallback_layout = 'home'                                         # Defaults to 'application'
  # config.store_user_info = {:method => :current_user, :field => :login}   # Defaults to false
  # config.filters = [                                                      # No filters are  enabled by default
  #   :all_404s,
  #   :no_referer_404s,
  #   {:user_agent_regxp => /\b(ApptusBot|TurnitinBot|DotBot|SiteBot)\b/i},
  #   {:target_url_regxp => /\b(myphpadmin)\b/i}
  # ]
  # config.responses = {                                                    # There must be a default response. The rest is up to you.
  #   :default => "<h1>500</h1><p>Internal server error</p>",
  #   :custom => "<h1>404</h1><p>Page not found</p>"
  # }
  # config.response_mapping = {                                             # All errors are mapped to the :default response unless overridden here
  #  'ActiveRecord::RecordNotFound' => :custom,
  #  'ActionController::RoutingError' => :custom,
  #  'AbstractController::ActionNotFound' => :custom
  # }
  config.store_request_info do |storage,request|
    storage[:target_url] =  request.url
    storage[:referer_url] = request.referer
    storage[:params] =      request.params.to_json
    storage[:user_agent] =  request.user_agent
    storage[:http_method] = request.method
  end
  config.store_exception_info do |storage,exception|
    storage[:class_name] =   exception.class.to_s
    storage[:message] =      exception.to_s
    storage[:trace] =        exception.backtrace.join("\n")
  end
  config.store_environment_info do |storage,env|
    # Not in use in v1.0, leave it out if you want
  end
  config.store_global_info do |storage|
    storage[:app_name] =     Rails.application.class.parent_name
    #storage[:created_at] =   Time.now
  end
end
