require 'sovren'
require 'logger'
begin
  Sovren.configure do |c|
    c.account_id = ENV['sovren_account_id']
    c.service_key = ENV['sovren_service_key']
  end
  Rails.logger.info "Finished Initializing Sovren"
rescue Exception => ex
  Rails.logger.error "Error initializing Sovren: #{ex}"
end
