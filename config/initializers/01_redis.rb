require 'logger'
begin
  $redis = Redis.new(:host => 'localhost', :port => 6379)
  Rails.logger.info "Finished initializing redis"
rescue Exception => ex
  Rails.logger.error "Error initializing redis: #{ex}"
end
