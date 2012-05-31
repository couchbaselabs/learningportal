SimpleNavigation::Configuration.run do |navigation|
  navigation.selected_class = 'active'
  navigation.items do |primary|
    primary.dom_class = 'nav'
    primary.item :articles, 'Content', admin_articles_path, :highlights_on => /admin\/articles/
    primary.item :users, 'Users', admin_users_path, :highlights_on => /admin\/users/
    # primary.item :contributors, 'Contributors', admin_authors_path, :highlights_on => /admin\/authors/
    primary.item :dashboard, 'Visit Learning Portal', root_path
  end
end
