source 'https://rubygems.org'

gem 'rails', '3.2.2'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'
gem 'thin'

gem 'couchbase', '1.2.0.dp'

group :production do
  gem 'pg'
end
group :development, :test do
  gem 'mysql2'
  gem 'foreman'
  gem 'heroku'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'bootstrap-sass', '~> 2.0.3'
  gem 'compass-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer'

  gem 'uglifier', '>= 1.0.3'
end

gem "haml"
gem "haml-rails"
gem 'jquery-rails'
gem 'rails_exception_handler', :git => 'git://github.com/rumblelabs/rails_exception_handler.git'
gem 'tire'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'
group :development, :test do
  gem 'turn', '0.8.2', :require => false
  gem 'spork'

  gem 'autotest'
  gem 'autotest-rails-pure'
  gem 'autotest-fsevent'
  gem 'autotest-growl'

  gem 'rspec'
  gem 'rspec-rails', '>= 2.0.0.beta.22'
  gem 'ci_reporter'
  gem 'simplecov'
  gem 'simplecov-rcov'
  gem 'shoulda-matchers'
  gem "factory_girl_rails", "~> 1.2"
end