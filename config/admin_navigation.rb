SimpleNavigation::Configuration.run do |navigation|
  navigation.selected_class = 'active'
  navigation.items do |primary|
    primary.dom_class = 'nav'
    primary.item :dashboard, 'Dashboard', admin_dashboard_path
    primary.item :articles, 'Articles', admin_articles_path, :highlights_on => /admin\/articles/
    primary.item :users, 'Users', admin_users_path, :highlights_on => /admin\/users/
  end
end
