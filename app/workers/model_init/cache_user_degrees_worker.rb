class CacheUserDegreesWorker
  include Sidekiq::Worker
  include UsersManager
  require 'ostruct'

  sidekiq_options retry: true, :queue => :default

  def perform
    update_time = $redis.get("user_degrees_time")
    if (update_time.blank? || (Time.now - Time.parse(update_time)) > 15.days)
      # Old data so update
      degrees = get_user_degress
      Futura::Application.config.UserDegrees = degrees
          $redis.set("user_degrees", degrees)
      $redis.set("user_degrees_time", Time.now)
    end
  end
end