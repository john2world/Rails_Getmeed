class EmailBroadcastWorker
  include Sidekiq::Worker
  include UsersManager
  include CrmManager
  include QuestionsManager

  sidekiq_options retry: true, :queue => :default

  def perform(email)
  end

end