class NotificationsLoggerWorker
  include Sidekiq::Worker
  sidekiq_options retry: true, :queue => :low

  def perform(view_name, hash)
    if view_name.blank?
      return
    end
    ActiveSupport::Notifications.instrument(view_name, hash)
  end
end