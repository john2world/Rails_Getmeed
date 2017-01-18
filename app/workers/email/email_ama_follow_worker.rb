class EmailAmaFollowWorker
  include Sidekiq::Worker
  include UsersManager
  include CrmManager
  include EventsManager

  sidekiq_options :retry => 5, :queue => :default

  def perform(ama_author_id, handle)
    ama = get_ama_by_handle(ama_author_id)
    ama_author = get_user_by_handle(ama_author)
    user = get_user_by_handle(handle)
    if ama.blank? || user.blank?
      return
    end
    Notifier.email_ama_follow(user, ama, ama_author).deliver
  end
end