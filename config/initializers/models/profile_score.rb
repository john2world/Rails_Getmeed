# Be sure to restart your server when you modify this file.

# This initializer reads the model parameters for profile score
# the model parameters are initialized to a dictionary to be used later to compute score
require 'ostruct'
require 'logger'

begin
  profile_score_model = $redis.get('profile_score_model')
  if profile_score_model.blank?
    # load immediately
    CacheProfileScoreModelWorker.new().perform()
  else
    # else load from cache
    Futura::Application.config.profile_score_model = eval(profile_score_model)
  end

  # if the cache is outdated refresh in background
  if ($redis.get('profile_score_model_time').blank? || (($redis.get('profile_score_model_time').to_time - Time.now())/1.days > 7))
    # load in background
    CacheProfileScoreModelWorker.perform_async()
  end
  Rails.logger.info "Finished loading profile score"
rescue Exception => ex
  Rails.logger.error "Error loading profile score: #{ex}"
end