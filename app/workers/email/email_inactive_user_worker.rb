class EmailInactiveUserWorker
  include Sidekiq::Worker
  include UsersManager
  include CrmManager

  sidekiq_options retry: true, :queue => :default

  def perform(email)
    user = get_user_by_email email
    email_invitation = EmailInvitation.where(email: email)
    # if there is a email_invitation already then dont send email
    unless email_invitation.blank?
      return
    end
    # choosing one of three random variations
    #variation_id = rand(1..3)
    variation_id = 1
    # get coressponding subject
    subject = get_inactive_user_subject_variation(variation_id)

    school = get_school_handle_from_email(email)
    count = User.where(id: /#{school}/).count()
    count = ((count * 1.0/100).ceil)*100

    logger.info('Sending inactive user activation email to: ' + user.id)
    Notifier.email_inactive_user(user, variation_id, subject, school, count).deliver
  end

  def get_inactive_user_subject_variation(variation_id)
    case variation_id
      when 1
        "Reach Out to Employers and Stay Ahead of the Game on Meed"
      when 2
        "Want Recruiters To Contact You About Jobs & Internships? Try Meed"
      when 3
        "Nervous about the future? Try Meed — a career marketplace for students"
      else
        raise Exception "invalid variation id"
    end
  end

end