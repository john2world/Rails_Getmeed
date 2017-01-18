Futura::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true
  config.serve_static_assets = true
  config.assets.enabled = true
  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = true

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = true
  Dir.glob("#{Rails.root}/app/assets/images/**/").each do |path|
    config.assets.paths << path
  end
  config.consider_all_requests_local = true
  # Generate digests for assets URLs
  config.assets.digest = true

  config.action_dispatch.rack_cache = {
      metastore:   'redis://localhost:6379/1/metastore',
      entitystore: 'redis://localhost:6379/1/entitystore'
  }

  # Defaults to nil and saved in location specified by config.assets.prefix
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.create_question(SyslogLogger.create_question)

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  config.action_controller.asset_host = 'cdn.getmeed.com'


  #Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  #config.assets.precompile += %w( application.js, bootstrap.js, bootstrap-fileupload.js)
  # config.assets.precompile += %w( *.js *.css *.scss *.woff *.eot *.svg *.ttf )

  config.assets.precompile = [
      Proc.new { |path|
        if path =~ /\.(css|js)\z/
          full_path = Rails.application.assets.resolve(path).to_path

          app_assets_path = Rails.root.join('app', 'assets').to_path

          whitelist = [
              Rails.root.join("app", "assets", "javascripts", "angular_app", "css", "manifest.css").to_path
          ]

          ignore_path = Rails.root.join("app", "assets", "javascripts", "angular_app", "css").to_path

          if whitelist.include?(full_path)
            true
          elsif full_path.starts_with?(ignore_path)
            false
          else
            true
          end
        else
          false
        end
      }
  ]


  # Disable delivery errors, bad email addresses will be ignored
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.raise_delivery_errors = true
  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5
  config.whiny_nils = true
  config.action_mailer.default_url_options = {:host => 'ec2-50-18-129-179.us-west-1.compute.amazonaws.com'}
  config.action_mailer.smtp_settings = {
      :user_name => ENV['sendgrid_username'],
      :password => ENV['sendgrid_password'],
      :domain => ENV['hostname'],
      :address => 'smtp.sendgrid.net',
      :port => 587,
      :authentication => :plain,
      :enable_starttls_auto => true
  }

  Rails.application.routes.default_url_options = {protocol: 'https', host: 'getmeed.com'}
end
