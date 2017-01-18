class GenerateProfileTagsWorker
  include Sidekiq::Worker
  include ProfilesHelper
  sidekiq_options retry: true, :queue => :critical

  def perform(handle)
    profile = get_user_profile_or_new(handle)
    tags = get_profile_tags(profile)
    unless tags.blank?
      profile[:tags] = tags
      profile.save()
    end
  end
end