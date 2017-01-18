class EmailFriendInviteWorker
  include Sidekiq::Worker
  include UsersManager
  include ProfilesManager
  include LeadsManager
  include JobsManager
  def perform(invite_user_id, lead_email)
    if invite_user_id.blank? || lead_email.blank?
      return
    end
    invite_user = User.find(invite_user_id)
    if invite_user.blank?
      return
    end

    existing_user = User.find(lead_email)
    unless existing_user.blank?
      create_follow_user(existing_user.handle, invite_user.handle)
      return
    end

    profile = get_user_profile(invite_user.handle)
    lead = get_intercom_lead_by_email(lead_email)
    friend_handles = recommend_similar_profile(profile).map{|p| p.handle}
    friends = get_users_by_handles(friend_handles)
    school = invite_user.school.downcase
    friend_count = get_users_from_school(school).count()
    # fuzzy logic to make the count look good
    if friend_count < 100
      # choose a number based of
      friend_count = (44*Math.log10(friend_count+1) + 100).round
    end
    Notifier.email_friend_invite(lead, invite_user, friend_count, friends).deliver
  end
end