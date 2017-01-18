module ReviewsHelper
  include LinkHelper
  def get_review_metadata(review)
    unless review.blank?
      metadata = Hash.new
      metadata[:title] = "Review of #{review.user_course.title} @ #{review.school_id.upcase}"
      metadata[:description] = ""
      metadata[:url] = url_for(controller: :reviews, action: :course_insights, course_code: review.course_code)
      metadata[:share_url] = metadata[:url]
      metadata[:image_url] = 'http://res.cloudinary.com/resume/image/upload/v1438210764/Facebook_Course_Share_Image-01_eokaoa.jpg'
      metadata[:email_share_body] = "Checkout review for #{review.user_course.title} @ #{review.school_id.upcase}"
      metadata[:share_url_short] = get_short_url(metadata[:url])
      metadata
    end
  end

  def get_review_dash_metadata(school_handle)
    description = "Check Out Course Insights for #{school_handle.upcase}"
    if school_handle.blank?
      description = 'Check Out Course Insights on Meed'
    end
    metadata = Hash.new
    metadata[:title] = description
    metadata[:description] = 'Write course reviews and help your fellow students'
    metadata[:url] = 'https://getmeed.com/insights/courses/dash'
    metadata[:share_url] = metadata[:url]
    metadata[:image_url] = 'http://res.cloudinary.com/resume/image/upload/v1438210764/Facebook_Course_Share_Image-01_eokaoa.jpg'
    metadata[:email_share_body] = description
    metadata[:share_url_short] = get_short_url(metadata[:url])
    metadata
  end

  def get_work_reviewer_company(work_reference)
    if work_reference.enterprise_user.blank?
      return nil
    end
    if work_reference.enterprise_user.company_id.blank?
      return nil
    end
    return Company.find(work_reference.enterprise_user.company_id)
  end

  def get_work_reviewer_company_name(work_reference)
    company = get_work_reviewer_company(work_reference)
    return company.name
  end

  def get_work_from_reference_invite(invite)
    work = nil
    if invite.work_type.blank?
      return nil
    end
    if invite.work_type == 'work'
      return UserWork.find(invite.work_id)
    elsif invite.work_type == 'internship'
      return UserInternship.find(invite.internship_id)
    else
      return nil
    end
  end

  def get_label_from_reference_status(status)
    case status
    when WorkReferenceInvitationStatus::INVITATION_SENT
      return 'default'
    when WorkReferenceInvitationStatus::INVITATION_VIEWED
      return 'primary'
    when WorkReferenceInvitationStatus::REFERENCE_RECEIVED
      return 'success'
    else
      return 'default'
    end
  end
end