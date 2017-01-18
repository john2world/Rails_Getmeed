class EmailJobInvitationWorker
  include Sidekiq::Worker
  include UsersManager
  include JobsManager
  include CrmHelper
  include CrmManager

  sidekiq_options retry: true, :queue => :default

  #current active variations email_invitation_5, email_invitation_0
  #email_invitaiton_0 = job

  def perform(email, job_id)
    if email.blank? or job_id.blank?
      puts("Either of job or email is blank. Email: #{email}, Job: #{job_id}")
      return
    end

    email_invitations = EmailInvitation.where(:email => email)
    email_invitation = nil
    email_invitations.each do |invitation|
      unless invitation[:invitor_handle].blank?
        email_invitation = invitation
      end
    end

    if !email_invitations.blank? and email_invitation.blank?
      email_invitation = email_invitations[0]
    end

    if email_invitation.blank?
      email_invitation = create_email_invitation_for_email(email, nil)
    end

    if email_invitation.reminder_count >= 3
      puts("Reminder count exceeded for user: #{email}")
      return
    end

    job = get_job_by_id(job_id)
    if job.blank? or !job.live
      puts("Either Job is blank or not live. live? #{job.live}")
      return
    end

    email_variation_id = get_job_email_variation
    user = get_user_by_email(email)
    if user.blank?
      user = create_passive_user(email)
    elsif user[:active]
      puts("USER (#{user})is active returning from not sending invitation")
      return
    end
    begin
      Notifier.email_job_invitation(user, '', job, email_variation_id).deliver
    rescue Exception => ex
      puts "Exception: #{ex}"
    end

    email_invitation.last_variation_used = email_variation_id
    email_invitation.time = Time.now
    email_invitation.reminder_count = email_invitation.reminder_count + 1
    email_invitation.save
    track_email_send("track_job_email_#{job_id}_#{email_variation_id}")
  end
end