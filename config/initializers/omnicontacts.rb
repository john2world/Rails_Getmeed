require 'omnicontacts'
require 'logger'

begin
  Rails.application.middleware.use OmniContacts::Builder do
    importer :gmail, ENV['gmail_client_id'], ENV['gmail_client_secret'], {:redirect_path => '/contacts/gmail/callback', :max_results => 10000 }
    importer :facebook, 'client_id', 'client_secret'
  end
  Rails.logger.info "Finished initializing omni contacts"
rescue Exception => ex
  Rails.logger.error "Error initializing omni contacts: #{ex}"
end
