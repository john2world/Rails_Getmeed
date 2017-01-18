class ReviewsController < ApplicationController
  include CoursesManager
  include ProfilesManager
  include ReviewsManager
  include ProfilesHelper
  include ReviewsHelper
  include EnterpriseUsersManager
  include ReviewsHelper


  def course_review
    unless logged_in?
      return
    end
    page_heading('Please Review At Least One Course!')
    @user = current_user
    # get courses for that user that are not yet reviewed
    profile = Profile.find(current_user.handle)
    if profile.blank?
      flash[:alert] = 'Invalid User'
      return
    end

    if is_incomplete_profile(profile)
      redirect_to "/#{current_user.handle}?show_complete=true"
      return
    end

    @courses = get_user_unreviewed_courses(profile)
    @reviewed_course_count = get_user_reviewed_courses_count(profile)
    @course = nil
    if @courses.blank?
      @courses = []
    else
      @course = @courses[0]
    end
    if @course.blank?
      redirect_to '/insights/courses'
      return
    end
    NotificationsLoggerWorker.perform_async('Consumer.Review.ViewReviews',
                                            {handle: current_user[:handle],
                                             params: params,
                                             ref: {meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
  end

  def course_review_submit
    unless logged_in?
      return
    end

    user = current_user
    @course_id = params[:course_id]
    if params[:course_id].blank?
      @message = 'Unknown error occured.'
      @result = false
      respond_to do |format|
        format.js
        return
      end
    end
    if params[:course_code].blank?
      @message = 'Course code empty.'
      @result = false
      respond_to do |format|
        format.js
        return
      end
    end
    if params[:prof_name].blank?
      @message = 'Professor name is empty'
      @result = false
      respond_to do |format|
        format.js
        return
      end
    end
    if params[:rating].blank? || params[:rating] == '0'
      @message = 'Rating not valid!'
      @result = false
      respond_to do |format|
        format.js
        return
      end
    end
    if params[:review].blank?
      @message = 'Review is blank.'
      @result = false
      respond_to do |format|
        format.js
        return
      end
    end
    if (params.has_key? 'anonymous') && (params[:anonymous].has_key? 'true') && params[:anonymous][:true] == 'true'
      handle = nil
    else
      handle = user.handle
    end
    school_id = get_school_handle_from_email(user.id)
    course_review = CourseReview.find_by(course_id: params[:course_id])
    if course_review.blank?
      create_course_review(params[:course_id], params[:course_code].upcase, school_id, params[:prof_name], params[:rating],
                           params[:review][:text], handle)
      course = get_user_course(params[:course_id])
      @message = "Review Successful for #{course[:title]}.. Please wait.."
      @message_color = 'green'
      @result = true
    else
      @message = "Course already reviewed"
      @result = false
    end
    # removing used params
    rparams = params.except(:course_id, :course_code, :prof_name, :rating, :review, :anonymous)

    NotificationsLoggerWorker.perform_async('Consumer.Review.SubmitReview',
                                            {handle: user[:handle],
                                             params: rparams,
                                             ref: {meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    profile = Profile.find(current_user.handle)
    courses = get_user_unreviewed_courses(profile)
    @courses_count = 0
    unless courses.blank?
      @courses_count = courses.count
    end
    respond_to do |format|
      format.js
      return
    end
  end

  def course_insights_dash
    unless current_user.blank?
      redirect_to '/insights/courses'
    end
    @show_top_bar = true
    @metadata = get_review_dash_metadata(current_school_handle)
    NotificationsLoggerWorker.perform_async('Consumer.Review.CourseInsightsDash',
                                            {handle: current_user[:handle],
                                             params: params,
                                             ref: {meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
  end

  def course_insights
    unless logged_in?
      return
    end
    page_heading("#{current_school_handle.upcase} Course Reviews")
    @course_pairs = []

    # check if user profile is incomplete
    profile = get_user_profile_or_new(current_user.handle)
    rparams = params.except(:id)

    @profile_incomplete = is_incomplete_profile(profile)
    if @profile_incomplete
      page_heading('Incomplete Profile!')
      NotificationsLoggerWorker.perform_async('Consumerre.Reviews.CourseInsights',
                                              {handle: current_user[:_id],
                                               params: rparams,
                                               ref: {referrer: params[:referrer],
                                                     referrer_id: params[:referrer_id],
                                                     referrer_type: params[:referrer_type],
                                                     meed_user_tracker: cookies[:meed_user_tracker]},
                                               profile_incomplete: @profile_incomplete
                                              })
      return
    end

    # check if user reviewed atleast one course
    @reviews_count = course_reviews_count_by_profile(profile)
    if @reviews_count == 0 and !@profile_incomplete
      redirect_to '/reviews/course'
      return
    end

    @school_id = current_user.school.downcase
    @course_code = params[:course_code]
    @reviews = get_course_reviews_by_school(@school_id)
    if @reviews.count > 0
      @metadata = get_review_metadata(@reviews[0])
    end

    unless @course_code.blank?
      @reviews = get_course_reviews_by_code(@school_id, @course_code)
    end

    # get list of all course_ids and titles
    @course_pairs = CourseReview.where(school_id: current_user.school.downcase).group_by { |r| r.course_code.upcase }.map { |k, v| ["#{v[0].user_course.title} (#{k})", k] }
    rparams = params.except(:course_code)

    NotificationsLoggerWorker.perform_async('Consumer.Reviews.CourseInsights',
                                            {handle: current_user[:_id],
                                             params: rparams,
                                             ref: {referrer: params[:referrer],
                                                   referrer_id: params[:referrer_id],
                                                   referrer_type: params[:referrer_type],
                                                   meed_user_tracker: cookies[:meed_user_tracker]},
                                             course_pairs_count: @course_pairs.count(),

                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('view-course-insights', current_user[:_id].to_s, {
                                                                   :course_pair_count => @course_pairs.count()
                                                               })
    end
  end

  def course_insights_search
    @results = []
    unless logged_in?
      respond_to do |format|
        format.js
      end
    end

    school_id = params[:school_id]
    course_code = params[:course_search].upcase

    @reviews = get_course_reviews_by_code(school_id, course_code)
    if @reviews.count() > 0
      @metadata = get_review_metadata(@reviews[0])
    end
    @result_count = @results.count()

    rparams = params.except(:school_id, :course_search)
    NotificationsLoggerWorker.perform_async('Consumer.Reviews.CourseInsightsSearch',
                                            {handle: current_user[:_id],
                                             params: rparams,
                                             ref: {referrer: params[:referrer],
                                                   referrer_id: params[:referrer_id],
                                                   referrer_type: params[:referrer_type],
                                                   meed_user_tracker: cookies[:meed_user_tracker]},
                                             school_id: school_id,
                                             course_code: course_code,
                                             result_count: @result_count
                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('view-course-insights-search', current_user[:_id].to_s, {
                                                                          :school_id => school_id,
                                                                          :course_code => course_code,
                                                                          :result_count => @result_count
                                                                      })
    end
    respond_to do |format|
      format.js
    end
  end

  def work_references_dash
    @show_top_bar = true
    reviews_data = get_user_work_references
    # get user for reviews
    @reviews = []
    reviews_data.each do |review|
      work = get_work_for_reference(review)
      unless work.blank?
        review[:user] = User.find_by(handle: work.handle)
        @reviews.append(review)
      end
    end
    NotificationsLoggerWorker.perform_async('Consumer.Review.WorkReferencesDash',
                                            {handle: current_user.blank?? 'public' : current_user[:handle],
                                             params: params,
                                             ref: {meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('view-work-references-dash', current_user[:_id].to_s, {})
    end
  end

  def work_references
    unless logged_in?
      return
    end
    @user = current_user
    # Get list of all user works and internship
    @works = []
    profile = get_user_profile_or_new(current_user.handle)
    profile.user_work_ids.uniq.each do |user_work_id|
      work = UserWork.find(user_work_id)
      work[:invites] = WorkReferenceInvitation.where(work_id: work.id)
      work[:type] = 'work'
      @works.append(work)
    end

    profile.user_internship_ids.each do |user_internship_id|
      work = UserInternship.find(user_internship_id)
      work[:invites] = WorkReferenceInvitation.where(internship_id: work.id)
      work[:type] = 'internship'
      @works.append(work)
    end
    NotificationsLoggerWorker.perform_async('Consumer.Review.WorkReferences',
                                            {handle: current_user[:handle],
                                             params: params,
                                             ref: {meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('view-work-references', current_user[:_id].to_s, {count: @works.count()})
    end
  end

  def work_reference_email_invite
    @user = current_user
    eu = get_or_create_enterprise_user(params[:email], params[:first_name], params[:last_name])
    @invite = create_work_reference_invite(eu, params[:message], params[:work_type], params[:work_id])
    @parent_id = params[:parent_id]

    mail = Notifier.email_enterprise_invite_work_reference(@invite, eu, @user)
    if mail.blank?
      @result = false
    else
      mail.deliver
      @result = true
    end

    rparams = params.except(:email, :first_name, :last_name, :message, :work_type, :work_id)
    NotificationsLoggerWorker.perform_async('Consumer.Review.WorkReferences.EmailInvite',
                                            {handle: current_user[:handle],
                                             params: rparams,
                                             eu_id: eu.id,
                                             invite_id: @invite.id,
                                             ref: {meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('work-references-invite', current_user[:_id].to_s, {
                                                                          eu_id: eu.id,
                                                                          invite_id: @invite.id
                                                                      })
    end

    respond_to do |format|
      format.js
      return
    end
  end

  def work_reference_invite_view
    @show_top_bar = true
    if params[:invite_id].blank?
      @result = false
      @message = 'Invalid Invite Id!'
      respond_to do |format|
        format.html
        return
      end
    end
    @invite = get_work_reference_invite_by_id(params[:invite_id])
    if @invite.blank?
      @result = false
      @message = 'Invalid Invite!'
      logger.error("Invalid Invite Id: #{params[:invite_id]}")
      respond_to do |format|
        format.html
        return
      end
    end
    if @invite.status == WorkReferenceInvitationStatus::REFERENCE_RECEIVED
      @result = false
      @invite_fulfilled = true
      @message = 'Review Completed'
      respond_to do |format|
        format.html
        return
      end
    end
    @work = get_work_from_reference_invite(@invite)
    if @work.blank?
      @result = false
      @message = 'Oops Something is wrong!'
      logger.error("Missing Work. Invite id: #{params[:invite_id]}")
      respond_to do |format|
        format.html
        return
      end
    end
    if @work.handle.blank?
      @result = false
      @message = 'Error Finding user!'
      logger.error("User missing. Invite id: #{params[:invite_id]}")
      respond_to do |format|
        format.html
        return
      end
    end
    @user = get_user_by_handle(@work.handle)
    if @user.blank?
      @result = false
      @message = 'Can\'t find user!'
      logger.error("Missing User. Invite id: #{params[:invite_id]}")
      respond_to do |format|
        format.html
        return
      end
    end
    # mark invite as viewed
    @invite.update_status(WorkReferenceInvitationStatus::INVITATION_VIEWED)
    @result = true
    NotificationsLoggerWorker.perform_async('Consumer.Review.WorkReferences.InviteView',
                                            {handle: @user[:handle],
                                             params: params,
                                             work_id: @work.id,
                                             invite_id: @invite.id,
                                             ref: {meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    respond_to do |format|
      format.html
    end
  end

  def work_reference_submit
    @result = false
    if params[:review].blank?
      @result = false
      respond_to do |format|
        format.js
        return
      end
    end
    review = params[:review]['text']
    invite = get_work_reference_invite_by_id(params['invite_id'])
    if invite.blank?
      @result = false
      respond_to do |format|
        format.js
      end
    end
    eu = get_or_create_enterprise_user(invite.reference_email, nil, nil)
    if eu.blank?
      @result = false
      respond_to do |format|
        format.js
      end
    end
    eu = update_enterprise_user_linkedin_profile(eu, params['profile_text'])
    @company = get_company_by_id(eu.company_id).name
    work = get_work_from_reference_invite(invite)
    if work.blank?
      @result = false
      respond_to do |format|
        format.js
      end
    end
    @user = get_user_by_handle(work.handle)
    review = create_user_work_reference(work, eu.id, review, invite.work_type)
    if review.blank?
      @result = false
      respond_to do |format|
        format.js
      end
    end
    @result = true
    invite.update_status(WorkReferenceInvitationStatus::REFERENCE_RECEIVED)
    # sent notification to user
    mail = Notifier.email_user_reference_notification(work, @user, eu)
    mail.deliver
    NotificationsLoggerWorker.perform_async('Consumer.Review.WorkReferences.Submit',
                                            {handle: @user[:handle],
                                             eu_id: eu.id,
                                             work_id: work.id,
                                             invite_id: invite.id,
                                             review_id: review.id
                                            })
    unless @user.blank?
      IntercomLoggerWorker.perform_async('recieved-work-reference', @user[:_id].to_s, {
                                                                          eu_id: eu.id,
                                                                          invite_id: invite.id,
                                                                          reference_id: review.id
                                                                      })
    end
    respond_to do |format|
      format.js
    end
  end
end

