source 'http://rubygems.org'

gem 'rails', '3.2.13'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass', '~> 3.3.10'
  gem 'sass-rails', '~> 3.2.5'
  gem 'coffee-rails', '~> 3.2.2'
  gem 'turbo-sprockets-rails3'
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'twitter-bootstrap-rails'
  gem 'uglifier', '>= 1.0.3'
  gem 'therubyracer'
  gem 'less-rails' #Sprockets (what Rails 3.1 uses for its asset pipeline) supports LESS
end
gem 'filepreviews'
gem 'rails-dev-tweaks'
gem 'redis-rack-cache'
gem 'sovren-ruby', '~> 0.1.0'
gem 'omniauth'
gem 'omniauth-linkedin'
gem 'omniauth-twitter'
gem 'omniauth-github'
gem 'koala', '~> 2.2'
gem 'filepicker_client', git: 'git://github.com/infowrap/filepicker_client.git'
gem 'clearbit'
gem 'algoliasearch-rails'
gem 'jquery-rails'
gem 'omnicontacts'
gem 'bcrypt-ruby'
gem 'bson_ext'
gem 'mongoid'
gem 'sendgrid'
gem 'gelf'
gem 'base62'
gem 'httparty'
gem 'chronic'
gem 'chronic_duration'
gem 'cloudinary'
gem 'sanitize'
gem 'mongoid-autoinc'
# for thread pooling
gem 'thread'
gem 'kaminari'
gem 'pdfkit'
gem 'wkhtmltopdf-binary-edge', '~> 0.12.2.1'
gem 'htmlentities'
gem 'sentry-raven'
gem 'embedly'
gem 'redis-rails'
gem 'less-rails-bootstrap'
gem 'shareable'
gem 'redis'
gem 'bootstrap-wysihtml5-rails'
# for shorting url
gem 'google_url_shortener'

# for models
gem 'distribution'
gem 'descriptive_statistics'
group :test do
  gem 'rspec'
  gem 'rspec-rails'
  gem 'turn', :require => false
end

# Deploy with Capistrano

gem 'capistrano'
gem  'rvm-capistrano',  require: false
gem 'passenger'
gem 'filepicker-rails'



#sidekiq
gem 'sidekiq', '~> 2.11.2'
gem 'capistrano-sidekiq'
gem 'kiqstand'
gem 'sinatra', require: false
gem 'slim'

gem 'searchkick'
gem 'remotipart'
gem 'ress'
gem 'whenever', :require => false

gem 'parallel'
gem 'public_suffix'
gem 'ruby-progressbar'
# intercom for user analytics
gem 'intercom', '~> 3.0.6'



# Gem wrapper of angular to guarantee we are using latest stable version
gem "angularjs-rails"

# Compiles Angular templates as part of asset pipeline:
# https://github.com/pitr/angular-rails-templates

gem 'angular-rails-templates', github: 'keenahn/angular-rails-templates'
gem "test-unit"
gem 'rabl'
gem 'oj'
gem 'jbuilder'
gem 'stripe'
gem 'mongoid-slug'

group :development, :test do
  gem "thin"
  # gem "unicorn"
  gem "pry-rails"
  gem 'spring'
end

