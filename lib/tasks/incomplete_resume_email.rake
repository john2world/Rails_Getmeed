namespace :incomplete_resume_email do
  task send_incomplete_resume_email: :environment do
    User.where(:active => true).to_a.each do |user|
      if user[:handle].blank?
        next
      end

      profile = get_user_profile_or_new(user.handle)
      if !profile.blank? and is_incomplete_profile(profile)
        EmailIncompleteResumeWorker.perform_async(user.id)
      end
    end
  end
end