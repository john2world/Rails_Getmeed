class EmailEnterpriseWorker
  include Sidekiq::Worker
  include MessagesManager
  sidekiq_options retry: true, :queue => :default

  def perform(message_id)
    message = get_message_by_id(message_id)
    if message.blank?
      return
    end
    sender = get_user_by_email(message.from_email)
    if sender.blank?
      return
    end

    Notifier.email_enterprise_message(message, sender).deliver
  end

end