class EmailFollowCompanyWorker
  include Sidekiq::Worker
  include UsersManager
  include JobsManager
  def perform(company_id, handle)


  end

end