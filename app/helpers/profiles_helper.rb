module ProfilesHelper
  include UsersHelper
  include LinkHelper
  include CommonHelper
  include Models::ModelsHelper


  def generate_pdf(viewer, user, token)
    if user.blank?
      return
    end
    PDFKit.configure do |config|
      config.default_options = {
          :encoding => 'UTF-8',
          :margin_top => '0.5in',
          :margin_right => '0.5in',
          :margin_bottom => '0.5in',
          :margin_left => '0.5in'
      }
    end
    begin
      kit = PDFKit.new(get_user_profile_clean_url(user.handle), layout: false, print_media_type: true, :page_size => 'Letter')
    rescue
      # Do nothing
    end


    pdf = kit.to_pdf


    if viewer.blank?
      ProfileViewWorker.perform_async(user.handle, token, false)
    end
    send_data pdf, :filename => "#{user.first_name} #{user.last_name}.pdf"
  end

  def generate_pdfs(viewer, handles, token)
    handle_string= encode_delimited_strings_char(handles, '_')
    PDFKit.configure do |config|
      config.default_options = {
          :encoding => 'UTF-8',
          :margin_top => '0.5in',
          :margin_right => '0.5in',
          :margin_bottom => '0.5in',
          :margin_left => '0.5in'
      }
    end
    pdf = PDFKit.new(get_user_profiles_url(handle_string), layout: false).to_pdf
    if viewer.blank?
      handles.each do |handle|
        ProfileViewWorker.perform_async(handle, token, false)
      end
    end
    # send the generated PDF
    send_data pdf, :filename => "#{handle_string}.pdf"
  end

  def load_dates(params, profile_item)
    if profile_item.blank?
      return profile_item
    end

    unless params[:date][:start_year].blank?
      profile_item[:start_year] = params[:date][:start_year]
    end


    unless params[:date][:start_month].blank?
      profile_item[:start_month] = get_month(params[:date][:start_month])
    end

    if is_present(params[:date][:end_year], params[:date][:end_month])
      #no op
    else
      unless params[:date][:end_month].blank?
        profile_item[:end_month] = get_month(params[:date][:end_month])
      end
      unless params[:date][:end_year].blank?
        profile_item[:end_year] = params[:date][:end_year]
      end
    end
    profile_item

  end

  def get_profile_metadata(user)

    unless user.blank?
      metadata = Hash.new
      metadata[:title] = "#{user.first_name}'s Portfolio — Meed"
      metadata[:description] = "#{user.degree} in #{user.major} at #{get_school_handle_from_email(user.id).upcase}"
      metadata[:url] = get_user_profile_url(user.handle)
      metadata[:image_url] = "#{user.large_image_url}"
      metadata
    end

  end

  def record_user_profile_impressions (viewer, user, job_id, company_id)

    if user.blank? and job_id.blank? and company_id.blank?
      return
    end

    if !viewer.blank? and viewer.is_admin?
      return
    end

    impression = ProfileImpressions.find(user[:handle])
    if impression.blank?
      impression = ProfileImpressions.new(:handle => user[:handle], :public_view_count => 0)
    end

    if !viewer.blank?
      impression.pull(:viewers, viewer[:handle])
      impression.add_to_set(:viewers, viewer[:handle])
    elsif cookies[:recorded_public_view].blank?
      cookies[:recorded_public_view] = true
      impression.inc(:public_view_count, 1)
    end
    impression[:last_view_dttm] = Date.today
    impression.save
  end

  def is_present(year, month)
    if Time.zone.now.month <= month.to_i && Time.zone.now.year <= year.to_i
      return true
    end
    false
  end

  def get_num_for_semester(semester)
    case semester.downcase
      when 'fall'
        return 8
      when 'spring'
        return 1
      when 'summer'
        return 5
      else
        return 1
    end
  end

  def get_month(num)
    case num.to_s
      when '1'
        return 'January'
      when '2'
        return 'February'
      when '3'
        return 'March'
      when '4'
        return 'April'
      when '5'
        return 'May'
      when '6'
        return 'June'
      when '7'
        return 'July'
      when '8'
        return 'August'
      when '9'
        return 'September'
      when '10'
        return 'October'
      when '11'
        return 'November'
      when '12'
        return 'December'
      else
        # type code here
    end
    ''
  end

  def get_num_for_month(month)
    case month
      when 'January'
        return '1'
      when 'February'
        return '2'
      when 'March'
        return '3'
      when 'April'
        return '4'
      when 'May'
        return '5'
      when 'June'
        return '6'
      when 'July'
        return '7'
      when 'August'
        return '8'
      when 'September'
        return '9'
      when 'October'
        return '10'
      when 'November'
        return '11'
      when 'December'
        return '12'
      else
        return '12'
    end
    ''
  end

  def build_major_separated_string (majors)
    if (!majors.blank?)
      return_string = ''
      count = 0
      majors.each do |major|
        return_string << major.major
        count += 1
        if majors.length != count
          return_string << ', '
        end
      end
    end

    return_string
  end

  def get_date(year, month)
    if year == nil || month == nil
      return Date.today
    end
    Date.new(year.to_i, get_num_for_month(month).to_i, 1)
  end

  def get_year(year)
    Date.new(year.to_i)
  end

  def update_score(profile)
    score_contributions = profile_contributions(profile)
      begin
      score = score_contributions.values.sum()
      score = (score*100).floor
      rescue Exception => ex
        profile[:score] = 0
        return
      end

    # update the insights
    user_insights = UserInsights.find_or_create(profile[:handle])
    user_insights[:resume_score][:score] = score
    user_insights[:resume_score][:contributions] = score_contributions.
        map{|key, value| {:type => key.to_s, :value => value}}
    user_insights.save()
    # update profile
    profile[:score] = score
  end

  def get_profile_tags(profile)
    if profile.blank?
      return nil
    end
    # final keywords and counts
    keywords = get_profile_keywords(profile);
    if keywords.blank?
      keywords = []
    end
    # counting the keywords
    keywords = keywords.group_by{|x|x}.map{|key, value| {key=>value.count()}}.reduce(:merge);
    if keywords.blank?
      keywords = []
    end
    tags = {}
    unless keywords.blank?
      max_value = keywords.values().max()
      keywords.each do |key, value|
        if Futura::Application.config.profile_tags_idf.has_key? key
          tf = 0.5 + (0.5 * value / max_value)
          tags[key] = tf * Futura::Application.config.profile_tags_idf[key]
        end
      end
    end
    # adding skills from these as tags too.
    internships = get_user_internships(nil, profile);
    courses = get_user_courses(nil, profile);
    works = get_user_works(nil, profile);
    pubs = get_user_publications(nil, profile);
    skills = []

    skills = skills.append(internships.map{|doc| generate_skills(doc[:skills])})
    skills = skills.append(courses.map{|doc| generate_skills(doc[:skills])})
    skills = skills.append(works.map{|doc| generate_skills(doc[:skills])})
    skills = skills.append(pubs.map{|doc| generate_skills(doc[:skills])})
    skills = skills.flatten.compact;
    skills = skills.group_by{|x|x}.map{|key, value| {key=>value.count()}}.reduce(:merge);
    unless skills.blank?
      max_value = skills.values().max();
      skills.each do |skill, count|
        if skill.blank?
          next
        end
        unless tags.has_key? skill
          tags[skill] = count * 1.0 / max_value
        end
      end
    end
    tags = tags.sort_by{|_key, value| -value}
    # taking the top 50 sorted ones
    tags = tags.take(50)
    return tags;
  end

  def get_consolidated_profile_tags(profiles)
    tags_set = profiles.map{|profile| profile.tags}.compact
    merged_tags = {}
    tags_set.each do |tags|
      if tags.class == Array
        tags = Hash[tags]
      end
      merged_tags = tags.merge(merged_tags){|key, first, second| first+second}
    end
    # normalizing
    sum = merged_tags.values().sum()
    merged_tags.each do |key, value|
      merged_tags[key] = value/sum
    end
    return merged_tags
  end

  def get_autosuggest_skills_by_major(major_id)
    if Futura::Application.config.SkillsByMajor.has_key? major_id
      return Futura::Application.config.SkillsByMajor[major_id].to_a
    else
      return nil
    end
  end

  def get_profile_keywords(profile)
    if profile.blank?
      return nil
    end
    internships = get_user_internships(nil, profile);
    courses = get_user_courses(nil, profile);
    works = get_user_works(nil, profile);
    pubs = get_user_publications(nil, profile);
    keywords = [];
    # appending keywords from each of them
    keywords = keywords.append(get_skills_in_text(profile[:objective]))
    keywords = keywords.append(internships.map{|doc| get_skills_in_text(doc[:title])});
    keywords = keywords.append(internships.map{|doc| get_skills_in_text(doc[:description])});
    keywords = keywords.append(courses.map{|doc| get_skills_in_text(doc[:title])});
    keywords = keywords.append(courses.map{|doc| get_skills_in_text(doc[:description])});
    keywords = keywords.append(works.map{|doc| get_skills_in_text(doc[:title])});
    keywords = keywords.append(works.map{|doc| get_skills_in_text(doc[:description])});
    keywords = keywords.append(pubs.map{|doc| get_skills_in_text(doc[:title])});
    keywords = keywords.append(pubs.map{|doc| get_skills_in_text(doc[:description])});
    return keywords.flatten.compact.uniq;
    #return filter_keywords_by_skills(keywords.flatten.compact);
  end

  # updates the global skills variable if there is a new skill
  def update_new_skills(major_id, skills)
    if Futura::Application.config.SkillsByMajor.has_key? major_id
      Futura::Application.config.SkillsByMajor[major_id] = (Futura::Application.config.SkillsByMajor[major_id].to_set + skills.to_set).to_a
    else
      Futura::Application.config.SkillsByMajor[major_id] = Set.new(skills).to_a
    end
  end
end
