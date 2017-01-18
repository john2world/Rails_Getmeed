# Be sure to restart your server when you modify this file.

# This initializer reads the model parameters for profile score
# the model parameters are initialized to a dictionary to be used later to compute score
require 'ostruct'
require 'logger'

begin
  job_tags_idf = $redis.get('job_tags_idf')
  if job_tags_idf.blank?
    # load immediately
    CacheJobKeywordsWorker.new().perform()
  else
    # else load from cache
    Futura::Application.config.job_tags_idf = eval(job_tags_idf)
  end

  # if the cache is outdated refresh in background
  if ($redis.get('job_tags_idf_time').blank? || (($redis.get('job_tags_idf_time').to_time - Time.now())/1.days > 7))
    # load in background
    CacheJobKeywordsWorker.perform_async()
  end
  Rails.logger.info "Finished loading job keywords"
rescue Exception => ex
  Rails.logger.error "Error loading job keywords: #{ex}"
end
