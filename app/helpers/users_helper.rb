require 'bcrypt'
require 'cgi'
module UsersHelper
  include BCrypt
  include CommonHelper
  include LinkHelper
  WHITE_LIST_EDUS = %w(uwaterloo.ca minerva.kgi.edu)
  WHITE_LIST_HANDLES = %w(sean-zhu rattanpriya)
  MODERATOR_HANDLES = %w(ravi peddinti jslo jsloman theexyw guptak007 greg torr allysorge giuseppe-petracca michaelwehar raj-thakker brianmo case-y)
  MEED_HANDLES = %w(ravi peddinti jsloman greg misbah terrell kkolla)

  def can_user_post(user)
    school_handle = get_school_handle_from_email(user.id)
    school_handle.eql? 'usc'
  end

  def get_meed_degree(degree)
    Futura::Application.config.UserDegreesSmall.each do |meed_degree|
      splits = degree.split(" ")
      splits.each do |split|
        if meed_degree.include? split
          return meed_degree
        end
      end

    end
    nil
  end


  def is_a_valid_edu_email(email)
    if email.blank?
      false
    end
    if is_valid_email(email)
      email_parts = email.split('@')
      school_prefix = email_parts[1]
      if WHITE_LIST_EDUS.include? school_prefix
        return true
      end

      if school_prefix.eql? 'getmeed.com'
        return true
      end

      edu_splits = school_prefix.split('.')
      (edu_splits[edu_splits.length - 1].eql? 'edu') or (edu_splits[edu_splits.length - 2].eql? 'ca')
    else
      false
    end
  end

  def get_next_handle(handle)
    return handle + '1'
  end

  def get_handle_from_email(email)
    if email.blank?
      return nil
    end
    id = email.strip.downcase.split("@").first
    if id.blank?
      return nil
    end
    # replace special characters in id with "."
    id.gsub(/[^a-z0-9\.\-]/, '.').gsub(/\.{2,}/, '.')
  end

  def get_school_handle_from_email(email)
    unless email.blank?
      email_parts = email.split('@')
      if email_parts.length > 1
        school_prefix = email_parts[1]
      else
        return ''
      end
      if school_prefix.blank? || school_prefix.nil?
        return ''
      end
      edu_splits = school_prefix.split('.')
      return school_safety_check(edu_splits[edu_splits.length - 2])
    end
    ''
  end

  def school_safety_check(school_id)
    return 'washington' if (school_id.eql? 'uw')
    return 'minerva' if (school_id.eql? 'kgi')
    school_id
  end


  #ravi@metester.fucker.edu
  def get_school_prefix_from_email(email)
    unless email.blank?
      email_parts = email.split('@')
      if email_parts.length > 1
        return email_parts[1]
      else
        return ''
      end
    end
    ''
  end

  def encrypt_password(password)
    Password.create(password)
  end

  def is_valid_handle(handle)
    if (handle.blank?) || (handle.eql? 'login') || (handle.eql? 'logout') || (handle.eql? 'edit') ||(handle.eql? 'view') || (handle.eql? 'settings')
      return false
    end
    return true
  end

  def get_signup_state(user, email_invitation, school)
    # if user is active, it must be a sign in
    if !user.blank? && user.active
      return :signin
    end
    if school.blank?
      return :waitlist_nosignup
    end
    if school.active
      # school currently open
      if user.blank?
        if email_invitation.blank?
          return :signup
        elsif !email_invitation.activated
          # if user object doesn't exist and email invitation also is not activated,
          # ignore the invitation and signup.
          return :signup
        else
          return :create_user
        end
      else
        if email_invitation.blank?
          return :verify_email
        elsif !email_invitation.activated
          return :verify_email
        else
          return :create_user
        end
      end
    else
      # school we are not open to but want to accept signups
      if user.blank? || user.password_hash.blank? || user.first_name.blank? || user.last_name.blank?
        return :waitlist_signup
      else
        return :waitlist_status
      end
    end
  end

  def get_params_from_url(referrer_url)
    if referrer_url.blank?
      return {}
    end
    uri = URI::parse(referrer_url)
    if uri.query.blank?
      return {}
    end
    params = CGI::parse(uri.query)
    params.each do |key, value|
      if value.class == Array
        params[key] = value[0]
      end
    end
    return params
  end

  def get_need_meed_referral_url(referrer, campaign_type)
    url = URI(url_for(controller: "home", action: "need_meed"))
    params = []
    unless referrer.blank?
      params.append(['referrer', referrer])
    end
    unless campaign_type.blank?
      params.append(['campaign_type', campaign_type])
    end
    url.query = URI.encode_www_form(params)
    shortn_url = get_short_redirect_url(url.to_s)
    if shortn_url.blank?
      shortn_url = url.to_s
    end
    return shortn_url
  end

  def get_pseduo_session_auth_code(user)
    return Digest::SHA1.hexdigest("#{user.handle}_#{user.id}")
  end

end
