class CoursesController  < ApplicationController
  include CoursesManager

  def course_invites
    unless pseudo_logged_in?(root_path)
      return
    end

    if params[:course_id].blank?
      return error_render('Course Id is empty', '/')
    end

    invites = get_course_project_invites(params[:course_id])

    NotificationsLoggerWorker.perform_async('Consumer.Courses.viewInvites',
                                            {handle: current_user.blank? ? 'public' : current_user[:_id],
                                             course_id: params[:course_id],
                                             invites_count: invites.blank? ? 0 : invites.count(),
                                             ref: {referrer: params[:referrer],
                                                   referrer_id: params[:referrer_id],
                                                   referrer_type: params[:referrer_type],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    if invites.blank?
      respond_to do |format|
        format.js
        format.json {
          return render json: {success: false}
        }
      end
      return
    else
      respond_to do |format|
        format.js
        format.json {
          return render json: {success: true, invites: invites}
        }
      end
      return
    end
  end

  def invite_reminder
    unless pseudo_logged_in?(root_path)
      return
    end

    if params[:invite_id].blank?
      return error_render('Invite Id is empty', '/')
    end

    # removing skipped so it appears in reviewers feed
    invite = unskip_reference_invite_by_id(params[:invite_id])

    if invite.blank?
      return error_render("Invite doesn't exist", '/')
    end
    EmailCourseReferenceInvitationWorker.perform_async(invite.id.to_s, true)
    # TODO (VMK): Add notification
    NotificationsLoggerWorker.perform_async('Consumer.Courses.InviteReminder',
                                            {handle: current_user.blank? ? 'public' : current_user[:_id],
                                             invite_id: invite.id,
                                             ref: {referrer: params[:referrer],
                                                   referrer_id: params[:referrer_id],
                                                   referrer_type: params[:referrer_type],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('course-reference-invite-reminder', current_user[:_id].to_s, {
                                                                      :invite_id => invite.id
                                                                  })
    end

    respond_to do |format|
      format.js
      format.json {
        return render json: {success: true}
      }
    end

  end

  def create_invite
    unless pseudo_logged_in?(root_path)
      return
    end

    if params[:reference_first_name].blank?
      return error_render('First Name is blank', '/')
    end

    if params[:reference_last_name].blank?
      return error_render('First Name is blank', '/')
    end

    if params[:reference_email].blank?
      return error_render('First Name is blank', '/')
    end

    if params[:reviewType].blank?
      return error_render('Review Type is blank', '/')
    end

    if params[:message].blank?
      return error_render('Review Type is blank', '/')
    end

    invite = create_course_project_reference_invite(params)
    EmailCourseReferenceInvitationWorker.perform_async(invite.id.to_s)

    NotificationsLoggerWorker.perform_async('Consumer.Courses.CreateInvite',
                                            {handle: current_user.blank? ? 'public' : current_user[:_id],
                                             invite_id: invite.id,
                                             ref: {referrer: params[:referrer],
                                                   referrer_id: params[:referrer_id],
                                                   referrer_type: params[:referrer_type],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('course-reference-invite', current_user[:_id].to_s, {
                                                        :invite_id => invite.id
                                                    })
    end

    respond_to do |format|
      format.js
      format.json {
        return render json: {success: true, invite: invite}
      }
    end
  end

end