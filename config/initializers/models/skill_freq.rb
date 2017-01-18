# Be sure to restart your server when you modify this file.

# This initializer reads the model parameters for profile score
# the model parameters are initialized to a dictionary to be used later to compute score
require 'logger'

begin
  skill_hist = $redis.get('skill_hist')
  if skill_hist.blank?
    # load immediately
    CacheSkillFreqWorker.new().perform()
  else
    # else load from cache
    Futura::Application.config.skill_hist = eval(skill_hist)
  end

  # if the cache is outdated refresh in background
  if ($redis.get('skill_hist_time').blank? || (($redis.get('skill_hist_time').to_time - Time.now())/1.days > 7))
    # load in background
    CacheSkillFreqWorker.perform_async()
  end
  Rails.logger.info "Finished loading skills frequency"
rescue Exception => ex
  Rails.logger.error "Error loading skills frequency: #{ex}"
end