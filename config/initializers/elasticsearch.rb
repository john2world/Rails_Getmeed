require 'logger'

begin
  Searchkick.client = Elasticsearch::Client.new(hosts: [ENV['elastic_search_url']], retry_on_failure: true, transport_options: {request: {timeout: 250}})
  Rails.logger.info "Finished Initializing Elasticsearch"
rescue Exception => ex
  Rails.logger.error "Error initializing elastic search: #{ex}"
end
