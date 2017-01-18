module ReviewsManager
  include UsersManager
  include CommonHelper
  def course_reviews_count_by_profile(profile)
    course_ids = profile.user_course_ids
    if course_ids.blank?
      return 0
    end
    reviews = CourseReview.where(:course_id.in => course_ids)
    return reviews.count()
  end

  def get_course_review(id)
    if id.blank?
      return nil
    end
    return CourseReview.find(id)
  end

  def get_user_for_review(review)
    if review.blank? || review.user_course.blank|| review.user_course.handle.blank?
      return nil
    end
    return get_user_by_handle(review.user_course.handle)
  end

  def get_work_reference(id)
    if id.blank?
      return nil
    end
    return WorkReference.find(id)
  end

  def get_work_for_reference(reference)
    if reference.work_type == WorkReferenceType::WORK
      return reference.user_work
    elsif reference.work_type == WorkReferenceType::INTERNSHIP
      return reference.user_internship
    else
        return nil
    end
  end

  def create_user_work_reference(user_work, enterprise_user_id, review_text, type)
    review = WorkReference.new()
    if type == 'work'
      review.work_id = user_work.id
      review.work_type = WorkReferenceType::WORK
      review.user_work_id = user_work.id
    elsif type == 'internship'
      review.internship_id = user_work.id
      review.work_type = WorkReferenceType::INTERNSHIP
      review.user_internship_id = user_work.id
    else
      return nil
    end

    review.enterprise_user_id = enterprise_user_id
    review.review_text = review_text
    review.save!
    return review
  end

  def get_user_work_references()
    reviews = WorkReference.where(:enterprise_user.ne => nil).desc(:create_dttm).take(3)
    return reviews
  end

  def create_work_reference_invite(eu, message, type, encoded_work_id)
    invite = WorkReferenceInvitation.new
    invite.reference_email = eu.email
    invite.reference_first_name = eu.first_name
    invite.reference_last_name = eu.last_name
    invite.message = message
    if (type == 'work')
      invite.work_type = 'work'
      invite.work_id = decode_id(encoded_work_id)
    elsif (type == 'internship')
      invite.work_type = 'internship'
      invite.internship_id = decode_id(encoded_work_id)
    end

    invite.save!
    return invite
  end

  def get_work_reference_invite_by_id(encoded_id)
    if encoded_id.blank?
      return nil
    end
    invite = WorkReferenceInvitation.find(decode_id(encoded_id))
    return invite
  end
end