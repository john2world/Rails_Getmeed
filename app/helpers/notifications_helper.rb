module NotificationsHelper

  def get_notification_type_for_feed(type)
    case UserFeedTypes.const_get(type.upcase)
      when UserFeedTypes::USER_COURSE_REVIEW
        return MeedNotificationType::UPVOTE_COURSE_REVIEW
      when UserFeedTypes::COURSEWORK
        return MeedNotificationType::UPVOTE_PROFILE_UPDATE
      when UserFeedTypes::QUESTION
        return MeedNotificationType::QUESTION_ASK
      when UserFeedTypes::STORY
        return MeedNotificationType::UPVOTE_STORY
      when UserFeedTypes::FOLLOW_COLLECTION
        return MeedNotificationType::FOLLOW_COLLECTION
      else
        return MeedNotificationType::UPVOTE_PROFILE_UPDATE
    end
  end



end