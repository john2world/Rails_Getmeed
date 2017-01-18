module JobsHelper
  include LinkHelper
  include CommonHelper

  NonRealEmails = %w(vmk@getmeed.com contact@getmeed.com ssravi@live.com ravi@getmeed.com ravi@resu.me
                   applications@resu.me vmk@resu.me Ssravi@live.com viswa_manikiran@yahoo.com)

  def get_job_type_code(type)
    if type.eql? 'Internship'
      return 'intern'
    end

    if type.eql? 'Full Time (Entry Level)' or type.eql? 'FullTime'
      return 'full_time_entry_level'
    end

    if type.eql? 'Full Time (Experienced)' or type.eql? 'FullTimeExperienced'
      return 'full_time_experienced'
    end
    nil
  end

  def get_job_handle_id(user_handle, job_id)
    "#{user_handle}_#{job_id}"
  end

  def get_job_type_from_code(code)
    if code.eql? 'intern'
      return 'Internship'
    end

    if code.eql? 'full_time_entry_level'
      return 'Full Time (Entry Level)'
    end

    if code.eql? 'full_time_experienced'
      return 'Full Time (Experienced)'
    end

    if code.eql? 'part_time'
      return 'Part Time'
    end
    code
  end

  def get_job_status_types
    JobStatusType
  end

  def get_job_metadata (job, company, poster)
    unless job.blank?
      metadata = Hash.new
      metadata[:title] = "#{job.title} @#{job.company}"
      metadata[:description] = "#{job.title}: #{job.description}"
      metadata[:image_url] = job.company_logo
      unless company.blank? || company[:photos].blank?
        metadata[:image_url] = company[:photos][0].large_image_url
      end
      metadata[:url] = get_job_url(encode_id(job.id))
      metadata[:share_url] = metadata[:url]
      unless @current_user.blank?
        metadata[:share_url] += "?referrer=#{@current_user.handle}&referrer_id=#{encode_id(job[:_id])}&referrer_type=job"
      end
      shortn_url = get_short_url(metadata[:share_url])
      if shortn_url.blank?
        shortn_url = metadata[:share_url]
      end
      metadata[:share_url_short] = shortn_url
      metadata[:email_share_body] = "Hi, \n #{job.company} is looking to hire students for #{job.title} role. \n Interested? Apply @"
      unless poster.blank?
        metadata[:poster_first_name] = poster.first_name
        metadata[:poster_last_name] = poster.last_name
        metadata[:poster_title] = poster.title
        metadata[:poster_short_bio] = poster.short_bio
      end
      metadata
    end
  end

  def get_company_metadata (company)
    unless company.blank?
      metadata = Hash.new
      metadata[:title] = "Come work for  #{company.name.upcase}"
      metadata[:description] = company.description
      metadata[:image_url] = company.get_cover_image_url
      unless company[:photos].blank?
        metadata[:image_url] = company[:photos][0].large_image_url
      end
      metadata[:video_url] = company.cover_video_url
      metadata[:url] = get_company_url(company.id)
      metadata
    end
  end

  def get_company_by_job_id(job_id)
    if job_id.blank?
      return nil;
    end
    job = Job.find(job_id);
    if job.blank? || job[:company_id].blank?
      return nil;
    end
    Company.find(job[:company_id]);
  end

  def get_job_stats(job, referrer)
    job_views = Instrumentation.where(:event_name=>'Consumer.Jobs.ViewJob', :"event_payload.job_id.$oid" => job.id.to_s)
    user_job_views = job_views.where(:"event_payload.ref.referrer" => referrer)
    job_applies = Instrumentation.where(:"event_name" => "Consumer.Jobs.Apply", :"event_payload.job_id" => job.id.to_s)
    user_job_applies = job_applies.where(:"event_payload.ref.referrer" => referrer)
    job[:view_count] = job_views.count()
    job[:user_view_count] = user_job_views.count()
    job[:user_job_count] = user_job_applies.count()
    job[:application_count] = job_applies.count()
    return job
  end

  def is_job_valid_for_user(job, user)
    result = (job[:majors].include? user[:major_id] or job[:majors].include? user[:minor_id]) and job[:schools].include? user.school.downcase()
    return result
  end

  def is_organic(job)
    return !(NonRealEmails.include? job.email)
  end

  def get_job_keywords(job)
    keywords = [];
    # appending keywords from each of them
    keywords = keywords.append(get_skills_in_text(job[:title]))
    keywords = keywords.append(get_skills_in_text(job[:description]))
    keywords = keywords.append(generate_skills(job[:skills]))
    return keywords.flatten.compact;
  end

  def get_job_tags(job)
    if job.blank?
      return nil
    end
    title_keywords = get_skills_in_text(job[:title]).flatten.compact
    desc_keywords = get_skills_in_text(job[:description]).flatten.compact
    # getting skills from job description and title
    skills = []
    skills = skills.concat(title_keywords)
    skills = skills.concat(desc_keywords)
    unless job[:skills].blank?
      skills = skills.concat(job[:skills])
    end
    # counting the title_keywords
    skills = skills.group_by{|x|x}.map{|key, value| {key=>value.count()}}.reduce(:merge);
    tags = Hash.new(0)
    unless skills.blank?
      max_value = skills.values().max()
      skills.each do |key, value|
        tf = 0.5 + (0.5 * value / max_value)
        if Futura::Application.config.job_tags_idf.has_key? key
          tags[key] = tf * Futura::Application.config.job_tags_idf[key]
        else
          tags[key] = tf
        end
      end
    end
    tags = tags.sort_by{|_key, value| -value}
    return tags;
  end

  def get_job_type_from_upwork(upwork_job_type)
    case upwork_job_type
      when 'Fixed Price'
        return JobType::MINIINTERN_FIXED
      when 'Hourly Job'
        return JobType::MINIINTERN_HOURLY
      else
        return nil
    end
  end
end