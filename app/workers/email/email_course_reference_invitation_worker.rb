class EmailCourseReferenceInvitationWorker
  include Sidekiq::Worker
  include CoursesManager
  sidekiq_options retry: true, :queue => :default

  def perform(invite_id, reminder = false)
    if invite_id.blank?
      return
    end

    invite = get_invite_by_id(invite_id)
    if invite.blank?
      return
    end

    course = invite.user_course
    if course.blank?
      return
    end

    if invite.reference_email.blank?
      return
    end

    reviewer = get_user_by_email(invite.reference_email)
    # Reviewer can be blank

    Notifier.email_course_reference(reviewer, invite, course, reminder).deliver
  end
end