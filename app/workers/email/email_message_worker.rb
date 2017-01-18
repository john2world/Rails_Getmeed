class EmailMessageWorker
  include Sidekiq::Worker
  sidekiq_options retry: true, :queue => :default

  def perform(email, to_enterpriser)
    Notifier.email_user_message(email, to_enterpriser).deliver
  end

end