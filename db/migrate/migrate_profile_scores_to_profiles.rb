include ProfilesHelper
profiles = Profile.all()

profiles.each do |profile|
  update_score(profile)
  profile.save!
end