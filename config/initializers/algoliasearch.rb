require 'logger'

begin
  AlgoliaSearch.configuration = { application_id: 'HUQVU8F87J', api_key: '79a90629ebe2d747f207d77ed8b43bea', pagination_backend: :kaminari }
  Rails.logger.info("Finished Initializing Algolia")
rescue Exception => ex
  Rails.logger.error "Error initializing algolia search: #{ex}"
end
