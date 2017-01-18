class ApplicantsStore
  def self.load type, job_ids
    case type
    when 'applications'
      self.applications(job_ids)
    when 'recommendations'
      self.recommendations(job_ids)
    when 'shortlisted'
      self.shortlisted(job_ids)
    else
      []
    end
  end

  def self.get_profile_summary(profile)
    unless profile.summary.blank?
      return profile.summary
    end

    summary = ''
    unless profile.user_internship_ids.blank?
      interns = UserInternship.find(profile.user_internship_ids)
      summary = "Interned at #{interns.map { |p| p.company }.join(', ')}"
    end

    if summary.blank?
      unless profile.user_work_ids.blank?
        works = UserWork.find(profile.user_work_ids)
        unless profile.user_work_ids.blank?
          summary = "#{summary.blank? ? '' : "#{summary}. " }Worked at #{works.map { |p| p.company }.join(', ')}"
        end
      end
    end

    unless profile.user_course_ids.blank?
      courses = UserCourse.find(profile.user_course_ids)
      if courses.length > 4
        courses = courses[0..3]
      end

      unless courses.blank?
        summary = "#{summary.blank? ? '' : "#{summary}. " }Took courses like - #{courses.map { |p| p.title }.join(', ')}"
      end
    end
    # profile.update_attributes summary: summary
    summary
  end

  def self.get_jobs_map(job_ids)
    jobs_map = Hash.new
    jobs = Job.order_by([:create_dttm, -1]).where(delete_dttm: nil).find(job_ids).to_a
    jobs.each do |job|
      job[:hash] = encode_id(job.id)
      jobs_map[job.id.to_s] = job

    end
    jobs_map
  end

  def self.shortlisted(ids)
    job_ids = Array(ids)
    job_applications = JobApplicant.where(:job_id.in => job_ids, :short_listed => true, :applied => true).to_a
    job_applications.concat JobApplicant.where(:job_id.in => job_ids, :bought => true).to_a

    job_applications.uniq { |e| [e.id] }

    handles = Array.[]
    handle_timemap = Hash.new
    job_app_stats_map = Hash.new
    user_school_handles = Array.[]
    job_notes_map = Hash.new
    job_applications_map = Hash.new
    user_job_id_map = Hash.new
    user_answer_id_map = Hash.new
    answer_ids = Array.[]
    job_ids = Array.[]
    job_applications.each do |job_application|
      job_applications_map[job_application.handle] = job_application
      handles << job_application.handle
      handle_timemap[job_application.handle] = job_application.create_dttm.strftime("%B %d")
      job_notes_map[job_application.handle] = job_application.notes
      user_job_id_map[job_application.handle] = job_application.job_id
      unless job_application.answer_id.blank?
        user_answer_id_map[job_application.handle] = job_application.answer_id
        answer_ids << job_application.answer_id
      end
      job_ids << job_application.job_id
    end

    jobs_map = get_jobs_map(job_ids)
    question_ids = Array.[]
    jobs_map.each do |key, job|
      unless job.question_id.blank?
        question_ids << job.question_id
      end
    end
    profile_map = get_user_profile_map(handles)
    answers = Answer.find(answer_ids)
    user_answer_map = Hash.new
    answers.each do |answer|
      user_answer_map[answer.user_handle] = answer
    end
    #status
    users = get_users_by_handles(handles)
    users = users.sort { |a, b| compare(job_applications_map[a.handle].create_dttm, job_applications_map[b.handle].create_dttm) }
    results = Array.new

    users.each do |user|
      user_school_handles << get_school_handle_from_email(user.id)
    end
    school_map = get_school_map(user_school_handles.compact)

    users.each do |user|
      user[:applied_time] = handle_timemap[user.handle]
      user[:app_status] = job_app_stats_map[user.handle]
      user[:school] = school_map[get_school_handle_from_email(user.id)]
      user[:profile] = profile_map[user.handle]
      user[:handle_url] = get_user_profile_url(user.handle)
      user[:cover_note] = job_applications_map[user.handle][:cover_note]
      user[:summary] = get_profile_summary(profile_map[user.handle])
      user[:notes] = job_notes_map[user.handle]
      user[:job] = jobs_map[user_job_id_map[user.handle]]
      user[:answer] = user_answer_map[user.handle]
      user[:opened] = job_applications_map[user.handle].opened
      results << user
    end
    results
  end

  def self.recommendations(job_ids, recommendations_count = 50, major_filter = nil, year_filter = nil, school_filter = nil)
    ids = Array(job_ids)
    applied_handles = JobApplicant.where(:job_id.in => ids).any_of({applied: true}, {archived: true}).pluck(:handle)
    invited_handles = JobApplicant.where(:job_id.in => ids).where(short_listed: true).where(applied: false).pluck(:handle)

    recommendation_profiles = Array.[]
    jobs_map = get_jobs_map(ids)
    if ids.length < 2
      recommendations_count = recommendations_count * 4
    end
    ids.each do |job_id|
      cache_key = "#{job_id}_recommended_#{recommendations_count}_#{major_filter}_#{year_filter}_#{school_filter}"
      cached_recos = JSON.load($redis.get(cache_key))
      if cached_recos.blank?
        cached_recos = recommendations_by_job(jobs_map[job_id.to_s], applied_handles, recommendations_count, major_filter, year_filter, school_filter)
        if cached_recos.blank?
          next
        end
        cached_recos.each do |profile|
          profile[:job_id] = job_id.to_s
        end
        $redis.set(cache_key, cached_recos.to_json)
        $redis.expire cache_key, 604800 # seconds = 7 days.
      end
      recommendation_profiles.concat cached_recos.blank? ? [] : cached_recos
    end

    handles = recommendation_profiles.map { |p| p['handle'] }
    users_map = Hash[get_users_by_handles(handles).map { |u| [u[:handle], u] }]
    recommendations = []
    recommendation_profiles.each do |rec_profile|
      job_id = rec_profile['job_id']
      #marshal data
      unless rec_profile.is_a?(Profile)
        rec_profile = Profile.new(rec_profile)
      end
      if invited_handles.include? rec_profile.handle
        next
      end
      recommendation = users_map[rec_profile.handle]
      if recommendation.blank?
        next
      end
      recommendation[:job] = jobs_map[job_id]
      recommendation[:profile] = rec_profile
      if recommendation[:profile].summary.blank?
        recommendation[:summary] = get_profile_summary(recommendation[:profile])
      else
        recommendation[:summary] = recommendation[:profile].summary
      end
      schools = Hash[School.all().map { |s| [s.handle, s] }]
      schools['washington'] = School.find('uw')
      recommendation[:school] = schools[recommendation.school.downcase]
      # recommendations are always pending
      recommendations << recommendation
    end
    recommendations
  end

  def self.applications(ids, label_filter = "")
    job_ids = Array(ids)
    job_applications = JobApplicant.where(:job_id.in => job_ids, :applied => true, :archived => false).to_a
    #invitation pending
    job_applications.concat JobApplicant.where(:job_id.in => job_ids, :short_listed => false, :archived => false, :applied => false, :bought => false).to_a

    handles = Array.[]
    handle_timemap = Hash.new
    job_app_stats_map = Hash.new
    user_school_handles = Array.[]
    job_notes_map = Hash.new
    job_applications_map = Hash.new
    user_job_id_map = Hash.new
    user_answer_id_map = Hash.new
    answer_ids = Array.[]
    job_ids = Array.[]
    job_applications.each do |job_application|
      job_applications_map[job_application.handle] = job_application
      handles << job_application.handle
      handle_timemap[job_application.handle] = job_application.create_dttm.strftime("%B %d")
      job_notes_map[job_application.handle] = job_application.notes
      user_job_id_map[job_application.handle] = job_application.job_id
      unless job_application.answer_id.blank?
        user_answer_id_map[job_application.handle] = job_application.answer_id
        answer_ids << job_application.answer_id
      end
      job_ids << job_application.job_id
    end

    jobs_map = get_jobs_map(job_ids)
    question_ids = Array.[]
    jobs_map.each do |key, job|
      unless job.question_id.blank?
        question_ids << job.question_id
      end
    end
    profile_map = get_user_profile_map(handles)
    answers = Answer.find(answer_ids)
    user_answer_map = Hash.new
    answers.each do |answer|
      user_answer_map[answer.user_handle] = answer
    end
    #status
    users = get_users_by_handles(handles)
    users = users.sort { |a, b| compare(job_applications_map[a.handle].create_dttm, job_applications_map[b.handle].create_dttm) }
    results = Array.new

    users.each do |user|
      user_school_handles << get_school_handle_from_email(user.id)
    end
    school_map = get_school_map(user_school_handles.compact)

    users.each do |user|
      user[:applied_time] = handle_timemap[user.handle]
      user[:app_status] = job_app_stats_map[user.handle]
      user[:school] = school_map[get_school_handle_from_email(user.id)]
      user[:profile] = profile_map[user.handle]
      user[:handle_url] = get_user_profile_url(user.handle)
      user[:cover_note] = job_applications_map[user.handle][:cover_note]
      user[:summary] = get_profile_summary(profile_map[user.handle])
      user[:notes] = job_notes_map[user.handle]
      user[:job] = jobs_map[user_job_id_map[user.handle]]
      user[:answer] = user_answer_map[user.handle]
      user[:pending] = job_applications_map[user.handle].invited
      user[:opened] = job_applications_map[user.handle].opened
      results << user
    end
    results.sort_by! { |a| a[:pending] ? 1 : 0 }
    results
  end

  def self.recommendations_by_job(job, applied_handles = [], result_count=10, major_filter = nil, year_filter = nil, school_filter = nil)
    if job.blank?
      return nil
    end
    tags = job[:tags]
    if tags.blank?
      #creates tags
      job.save
      return Array.new
    end
    # boosting works only for integer values so converting the probabilities into integers with precision = 10^-3
    precision = 100
    if tags.class() == Array
      tags = Hash[tags]
    end
    if tags.blank?
      tags = Hash.new
    end

    tags = tags.each { |k, v| tags[k] = (v * precision).round() }
    boost = tags.map { |k, v| {value: k, factor: v} }
    where_conditions = {}
    if major_filter.blank?
      where_conditions[:major] = SchoolsStore.get_majors_from_select(job[:majors])
    else
      where_conditions[:major] = SchoolsStore.get_majors_from_select(major_filter)
    end
    if school_filter.blank?
      where_conditions[:school] = SchoolsStore.get_schools_from_select(job[:schools])
    else
      where_conditions[:school] = SchoolsStore.get_schools_from_select(school_filter)
    end
    if year_filter.blank?
      where_conditions[:year] = year_filter
    end
    where_conditions[:handle] = {not: applied_handles}
    search_keywords = tags.map{|k,v| "\"#{k}\""}.join(' ')
    # filter results corresponding to what is available to the school.
    query = Profile.search search_keywords, operator: "or", explain: false, execute: false,
                           where: where_conditions,
                           # matching skills and company name is most important. Then Title then location.
                           fields: %W(
                         tags^50
                         summary^10
                         objective^6
                         user_work_titles^5
                         user_internships_titles^5
                         user_publication_titles^3
                         user_course_titles^3
                         user_edu_titles^3
                         user_work_desc^2
                         user_internships_desc^2
                         user_publication_desc^1
                         user_course_desc^1
                         user_edu_desc^1
                       ),
                           # boosting by resume score has adverse effects as ppl from low match but high score are coming on top
                           # the matching is more if profile is complete so resume score is not required.
                           #boost_by: {score: {factor: 0.1}},
                           boost_where: {_all: boost},
                           limit: result_count;
    results = query.execute;
    return results
  end

  def self.job_shortlist_application(id, job_id, invitation = true)
    application = JobApplicant.where(id: id).first_or_create(
      job_id: job_id,
      applied: false,
      handle: id.split('_').last,
    )

    if !application.applied and !invitation
      application.bought = true
      application.short_listed = true
    end

    if invitation
      application.invited = true
    else
      application.short_listed = true
    end

    application.create_dttm = Time.now
    application.save!
    application
  end

end
