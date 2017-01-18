# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Futura::Application.initialize!

ActionMailer::Base.smtp_settings = {
    :user_name => ENV['sendgrid_username'],
    :password => ENV['sendgrid_password'],
    :domain => 'resu.me',
    :address => 'smtp.sendgrid.net',
    :port => 587,
    :authentication => :plain,
    :enable_starttls_auto => true
}


# Initializing Intercom
IntercomClient = Intercom::Client.new(app_id: ENV['intercom_app_id'], api_key: ENV['intercom_secret'])