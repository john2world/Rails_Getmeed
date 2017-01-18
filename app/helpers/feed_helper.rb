module FeedHelper

  def get_possible_privacies(key)
    privacies = Array.new
    privacies << key
    if key.eql? 'sci_comp'
      privacies << 'eng_electrical'
      privacies << 'eng_comp'

    elsif key.eql? 'eng_electrical'
      privacies << 'eng_comp'
      privacies << 'sci_comp'
    elsif key.eql? 'eng_comp'
      privacies << 'eng_electrical'
      privacies << 'sci_comp'
    else
      majors = Major.all
      majors.each do |major|
        if !major.id.eql? 'sci_comp' and !major.id.eql? 'eng_electrical' and !major.id.eql? 'eng_comp'
          privacies << major.id
        end
      end
    end
    privacies
  end


  def is_user_generated_content(model)
    if model[:privacy].eql? 'everyone' or (model[:type].eql? 'question' or model[:type].eql? 'requirement' or model[:type].eql? 'story')
      return true
    end
    false
  end

  def is_popular_content(model)
    if model[:kudos_count].blank? and model[:comment_count].blank?
      return false
    end
    true
  end

  def is_feed_media_type(feed_type)
    ContentType.constants.each do |constant|
      if feed_type.eql? constant.to_s
        return true
      end
    end
    false
  end


end