module LinkHelper
  Google::UrlShortener::Base.api_key = 'AIzaSyAhpoBPbnOy3X7_3mJuuAxZepBCCeWs4QA'
  $security = ENV['security']
  $environment_host = ENV['host']
  $recruiter_host_name = ENV['recruiter_hostname']
  $blog_root_name = ENV['blog_hostname']

  def get_perma_url(feed_id)
    "#{$security}#{$environment_host}/feed/perma/#{feed_id}"
  end

  def get_tag_url(tag_id)
    "#{$security}#{$environment_host}/tag/#{tag_id}"
  end

  def get_user_verification_url(invitation_token)
    if invitation_token.blank?
      return ''
    end
      $security + $environment_host + '/users/create' + '?token='+ invitation_token
  end

  def get_user_waitlist_verification_url(invitation_token)
    if invitation_token.blank?
      return ''
    end
    $security + $environment_host + '/waitlist/verify' + '?token='+ invitation_token
  end

  def get_waitlist_status_url(email)
    $security + $environment_host + "/?email=#{email}&action=waitlist_status"
  end

  def get_unsubscribe_link(job_type, email)
     $security + $environment_host + '/emails/unsubscribe' + '?email=' + email + '&type='+ job_type
  end

  def get_connections_url
    $security + $environment_host + '/connections'
  end

  def get_collection_slug_url(collection_id, handle, slug_id)
    $security + $environment_host + "/#{handle}/collection/#{slug_id}/#{collection_id}"
  end

  def get_collection_url(collection_id)
    $security + $environment_host + "/collection/#{collection_id}"
  end

  def get_question_url (question_id)
    $security + $environment_host + '/questions/'+ question_id
  end

  def get_user_password_new_url(invitation_token)
    if invitation_token.blank? then
      ''
    else
      $security + $environment_host + '/users/password' + '?token='+ invitation_token
    end
  end

  def get_user_invite_promo_url(invitor_handle)
    "#{$security}#{$environment_host}/promo?token=#{invitor_handle}"
  end

  def get_youtube_url(id)
    "https://www.youtube.com/watch?v=#{id}"
  end

  def get_youtube_default_image_url(id)
    "http://img.youtube.com/vi/#{id}/0.jpg"
  end

  def get_vimeo_url(id)
    "https://www.vimeo.com/#{id}"
  end

  def get_company_url(id)
    "#{$security}#{$environment_host}/company/#{id}"
  end

  def get_company_auth_profile_url(id)
    "#{$security}#{$environment_host}/company/#{id}/auth"
  end

  def get_dashboard_url
    "#{$security}#{$environment_host}/home"
  end

  def get_site_map_url
    $security + $environment_host + '/sitemap.xml'
  end

  def get_host_name_url
    $security + $environment_host
  end

  def get_meed_post_start_url
    $security + $environment_host + '/submit/post'

  end

  def get_root_url
  $security + $environment_host
  end

  def get_job_inbox_url
    $security + $environment_host + '/home'
  end

  def get_insights_url
    $security + $environment_host + '/insights'
  end

  def get_login_url
    $security + $environment_host + '/login'
  end

  def get_messages_url
    $security + $environment_host +  '/messages'
  end

  def get_enterprise_message_url
    $security + $recruiter_host_name +  '/messages'
  end

  def get_job_applicants_status_url(job_id, email)
    "#{$security}#{$recruiter_host_name}/job/#{job_id}/status?email=#{email}"
  end

  def get_job_url(job_hash)
    $security + $environment_host + '/job/'+ job_hash.to_s
  end

  def get_job_url_verification_link(job_hash, token)
    $security + $environment_host + '/job/'+ job_hash.to_s + '?verify_token=' + token
  end

  def get_job_url_id(job_hash)
    $security + $environment_host + '/job/'+ job_hash.to_s
  end

  def get_article_url(article_id)
    $security + $environment_host + '/articles/'+ article_id.to_s
  end

  def get_story_url(handle, article_id, time = Time.zone.now)
    if time.blank?
      time = Time.zone.now
    end
    "#{$security}#{$environment_host}#{get_story_path(handle, article_id, time)}"
  end

  def get_story_path(handle, article_id, time = Time.zone.now)
    "/#{handle}/#{time.year}/#{time.month}/#{time.day}/#{article_id.to_s}"
  end

  def get_user_profile_clean_url(handle)
    "#{$security}#{$environment_host}/#{handle}?showRajni=false"
  end

  def get_user_profiles_url(handle_string)
    $security + $environment_host + '/profiles/bundle?handles=' + handle_string  + '&showRajni=false'
  end

  def get_user_profile_download_url(handle, token)
    $security + $environment_host + '/' + handle + '/pdf?token=' + token
  end

  def get_user_profile_url(handle)
    if handle.blank?
      return
    end

    "#{$security}#{$environment_host}/#{handle}"
  end

  def get_user_portfolio_url(handle)
    if handle.blank?
      return
    end

    "#{$security}#{$environment_host}/#{handle}#portfolio"
  end

  def get_leaderboard_url
    "#{$security}#{$environment_host}/leaderboard/show"

  end

  def get_user_auth_profile_url(handle)
    if handle.blank?
      return
    end

    "#{$security}#{$environment_host}/#{handle}/auth"
  end

  def get_activity_feed_url
    "#{$security}#{$environment_host}/activity"
  end

  def get_thanksgiving_claim_url(handle)
    "#{$security}#{$environment_host}/thanksgiving/claim?handle=#{handle}"
  end

  def get_authed_contact_import_url
    "#{$security}#{$environment_host}/contacts/auth/gmail"
  end

  def get_marketplace_url
    "#{$security}#{$environment_host}/home#jobs"
  end

  def get_contact_us_url
    $security + $environment_host + '/contactus'
  end

  def get_non_absolute_content_url(article_type, id)
    if article_type.eql? 'article'
      return '/articles/' + id
    elsif article_type.eql? 'question'
      return '/questions/' + id
    end
    ''
  end

  def get_course_insights_url(course_code = nil, school_id = nil)
    $security + $environment_host + '/insights/courses' + "?school_id=#{school_id}&course_code=#{course_code}"
  end

  def get_short_url(url)
    if url.blank?
      return nil
    end
    if Rails.env.development?
      return "https://getmeed.com"
    end
    # adding retry logic
    retry_count = 3
    shortn_url = nil
    while retry_count > 0 and shortn_url.blank?
      shortn_url = Google::UrlShortener.shorten!(url)
    end
    return shortn_url
  end

  def get_short_redirect_url(url)
    short_url = get_short_url(url)
    if short_url.blank?
      return nil
    end
    code = URI.parse(short_url).path
    if code.blank?
      return nil
    end
    code = code.sub('/', '')
    return $security + $environment_host + "/r/#{code}"
  end

  def get_short_url_from_code(code)
    return "https://goo.gl/#{code}"
  end

  def pseudo_session_profile_edit_url(handle, auth_code)
    return $security + $environment_host + "/#{handle}?authorization_code=#{auth_code}"
  end

end
