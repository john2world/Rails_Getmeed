module CoursesManager
  include UsersManager

  def create_course_review(course_id, course_code, school_id, prof_name, rating, review_text, handle=nil)
    course_review = CourseReview.new()
    course = UserCourse.find(course_id)
    course_review.course_id = course_id
    course_review.id = course_id
    course_review.course_code = course_code
    course_review.school_id = school_id
    course_review.prof_name = prof_name
    course_review.rating = rating
    course_review.review = review_text
    course_review.reviewer_handle = handle
    course_review.user_course = course
    course_review.save!
    course.course_review_id = course_id
    course.save()
  end

  def get_course_reviews_by_school(school_id)
    reviews = CourseReview.where(school_id: school_id.downcase).order_by([:_id, -1]).to_a
    build_review_models(reviews)
  end

  def get_course_reviews_by_code(school_id, course_code)
    reviews = CourseReview.where(school_id: school_id.downcase).where(course_code: course_code.upcase).to_a
    build_review_models(reviews)
  end

  def build_review_models(reviews)
    reviews.each do |review|
      user = get_user_by_handle(review.reviewer_handle)
      review[:user] = user
      unless review.user_course.blank?
        feed = FeedItems.where(subject_id: review.user_course.id.to_s, type: UserFeedTypes::USER_COURSE_REVIEW.to_s).to_a
        if feed.blank? || feed.count == 0
          review[:feed] = nil
        else
          feed[0][:user] = user
          feed[0][:school] = get_school(feed[0][:poster_school])
          review[:feed] = feed[0]
          feed[0][:url] = get_course_insights_url(review.course_code, review.school_id)
        end
      end
    end
    reviews
  end

  def get_course_project_reference_invites(course_id)
    course = UserCourse.find(course_id)
    if course.blank?
      return nil
    end
    return course.course_project_reference_invitation
  end

  def get_course_project_references(course_id)
    course = UserCourse.find(course_id)
    if course.blank?
      return nil
    end
    return course.course_project_reference
  end

  def get_course_project_invites(course_id)
    course = UserCourse.find(course_id)
    if course.blank?
      return nil
    end
    return course.course_project_reference_invitation
  end

  def delete_course_project_reference_invite(reference_id)
    invite = CourseProjectReferenceInvitation.find(reference_id)
    unless invite.blank?
      invite.delete()
    end
  end

  def get_invite_by_id(invite_id)
    if invite_id.blank?
      return
    end
    CourseProjectReferenceInvitation.find(invite_id)
  end

  def get_course_reference_by_id(reference_id)
    if reference_id.blank?
      return
    end
    CourseProjectReference.find(reference_id)
  end

  def create_course_project_reference_invite(params)
    course = get_user_course(params[:course_id])
    if course.blank?
      return nil
    end
    invite = CourseProjectReferenceInvitation.new()
    invite.reference_first_name = params[:reference_first_name]
    invite.reference_last_name = params[:reference_last_name]
    invite.reference_email = params[:reference_email]
    invite.message = params[:message]
    invite.reference_type = params[:reviewType]
    invite.user_course = course
    invite.save
    invite
  end

  def get_course_project_invites_by_email(email)
    if email.blank?
      return nil
    end
    invites = CourseProjectReferenceInvitation.where(
        reference_email: email, skipped: false,
        :status.ne => CourseProjectReferenceInvitationStatus::REFERENCE_RECEIVED)
    invites
  end

  def skip_reference_invite_by_id(invite_id)
    invite = get_invite_by_id(invite_id)
    if invite.blank?
      return nil
    end
    invite.skipped = true
    invite.save
    return invite
  end

  def unskip_reference_invite_by_id(invite_id)
    invite = get_invite_by_id(invite_id)
    if invite.blank?
      return nil
    end
    invite.skipped = false
    invite.save
    invite
  end

  def create_reference_from_invite(invite_id, review_text)
    invite = get_invite_by_id(invite_id)
    course_reference = CourseProjectReference.new()
    course_reference.reviewer_handle = current_user.handle
    course_reference.reviewer_type = invite.reference_type
    course_reference.review_text = review_text
    course_reference.user_course = invite.user_course
    course_reference.save
    # updating the status of invite
    invite.status = CourseProjectReferenceInvitationStatus::REFERENCE_RECEIVED
    invite.save
    # create feed item
    CreateFeedItemWorker.perform_async(current_user.handle, course_reference._id.to_s,
                                       UserFeedTypes::USER_COURSE_REFERENCE.downcase, nil)
    course_reference
  end

end

