class CacheSkillsByMajorWorker
  include Sidekiq::Worker
  include UsersManager
  include CommonHelper
  require 'ostruct'

  sidekiq_options retry: true, :queue => :default

  def perform
    update_time = $redis.get("skills_by_major_time")
    if (update_time.blank? || (Time.now - Time.parse(update_time)) > 15.days)
      # Old data so update
      skills = skills_by_major
      Futura::Application.config.SkillsByMajor = skills
      $redis.set("skills_by_major", skills)
      $redis.set("skills_by_major_time", Time.now)
    end
  end
end