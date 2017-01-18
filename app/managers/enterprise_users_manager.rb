module EnterpriseUsersManager
  include SchoolsManager
  include JobsManager
  include CommonHelper

  def get_enterpriser_by_email(email)
    EnterpriseUser.find(email)
  end

  # @param [String] handles
  def get_enterprisers_by_handles(handles)
    if handles.blank?
      return Array.[]
    end
    EnterpriseUser.where(:company_handle.in => handles)
  end

  def get_enterprise_by_id(id)
    if id.blank?
      return nil
    end
    EnterpriseUser.find(id)
  end

  def get_enterprisers_map(ids)
    users = EnterpriseUser.find(ids)
    user_map = Hash.new
    users.each do |user|
      user_map[user.id] = user
    end
    user_map
  end

  def get_or_create_enterprise_user(email, first_name, last_name)
    eu = get_enterpriser_by_email(email)
    if eu.blank?
      company_handle = get_company_handle_from_email(email)
      company = get_or_create_company(company_handle, nil)
      eu = EnterpriseUser.new
      eu.id = email
      eu.email = email
      eu.first_name = first_name
      eu.last_name = last_name
      eu.company_id = company.id
      eu.save!
    end
    return eu
  end

  def get_company_handle_from_email(email)
    unless email.blank?
      email_parts = email.split('@')
      company_prefix = email_parts[1]
      if company_prefix.blank?
        return ''
      end
      company_splits = company_prefix.split('.')
      return company_splits[company_splits.length - 2]
    end
    ''
  end

  def update_enterprise_user_linkedin_profile(eu, profile_hash_string)
    if profile_hash_string.blank?
      return nil
    end
    profile_hash = JSON.parse(profile_hash_string)
    # replace data from linkedIn
    unless profile_hash['firstName'].blank?
      eu.first_name = profile_hash['firstName']
    end
    unless profile_hash['lastName'].blank?
      eu.last_name = profile_hash['lastName']
    end
    unless profile_hash['headline'].blank?
      eu.title = profile_hash['headline']
    end
    unless profile_hash['emailAddress'].blank?
      eu.alternate_email = profile_hash['emailAddress']
    end
    unless profile_hash['publicProfileUrl'].blank?
      eu.linkedin_url = profile_hash['publicProfileUrl']
    end
    eu.save!
    return eu
  end

end