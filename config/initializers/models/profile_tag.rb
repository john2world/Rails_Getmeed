# Be sure to restart your server when you modify this file.

# This initializer reads the model parameters for profile score
# the model parameters are initialized to a dictionary to be used later to compute score
require 'ostruct'
require 'logger'

begin
  profile_tags_idf = $redis.get('profile_tags_idf')
  if profile_tags_idf.blank?
    # load immediately
    CacheProfileTagModelWorker.new().perform()
  else
    # else load from cache
    Futura::Application.config.profile_tags_idf = eval(profile_tags_idf)
  end

  # if the cache is outdated refresh in background
  if ($redis.get('profile_tags_idf_time').blank? || (($redis.get('profile_tags_idf_time').to_time - Time.now())/1.days > 7))
    # load in background
    CacheProfileTagModelWorker.perform_async()
  end
  Rails.logger.info "Finished loading profile tags"
rescue Exception => ex
  Rails.logger.error "Error loading profile tags: #{ex}"
end