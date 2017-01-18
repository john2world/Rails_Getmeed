class EmailUserPromoWorker
  include Sidekiq::Worker
  include UsersManager

  sidekiq_options retry: true, :queue => :default

  def perform(id)
    user = get_user_by_email(id)
    if user.blank?
      return
    end
    Notifier.email_user_invite_promotion(user).deliver
  end

end