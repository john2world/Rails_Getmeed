module JobsManager
  include JobsHelper
  include UsersManager
  include CommonHelper
  include LinkHelper
  include PhotoManager
  include QuestionsManager
  $FEED_PAGE_SIZE = 24

  AllJobTypes = ['Full Time (Experienced)', 'Full Time (Entry Level)', 'Part Time (Hourly)',
                   'Mini Internship (Hourly)', 'Mini Internship (Fixed)', 'intern', 'Internship',
                   'full_time_entry_level', 'full_time_experienced' ]


  def get_recent_job_for_company(company_id)
    recent_job = Job.where(company_id: company_id, live: true).order_by([:create_dttm, -1]).first
    company = Company.find(company_id)
    stuff_company_job(recent_job, company)
    recent_job[:author] = EnterpriseUser.find(recent_job[:email])
    recent_job
  end

  def get_jobs_map(job_ids)
    Job.find(job_ids)
  end

  def get_top_jobs(limit = 50, school=nil, majortype=nil, year=nil, gigs=true, job_type = nil)
    jobs = Job.where(:live => true, :company_id.ne => 'testcorp')
    unless school.blank?
      jobs_filtered = jobs.where(:schools.in => [school, 'all'])
      unless jobs_filtered.blank?
        jobs = jobs_filtered
      end
    end
    unless majortype.blank?
      jobs = jobs.where(major_types: majortype)
    end
    unless year.blank?
      year = year.to_i
      if year > 0
        if (year - Date.today().year) < 1
          # student graduating in less than an year or already graduated. don't show internships
          jobs = jobs.where(:type.nin => %w(intern Internship))
        elsif (year - Date.today().year) >= 2
          # student graduating two years from now, don't show any full time jobs
          jobs = jobs.where(:type.nin => ['full_time_entry_level', 'Full Time (Experienced)', 'full_time_experienced', 'Full Time (Entry Level)'])
        end
      end
    end
    case job_type
      when 'internship'
        jobs = jobs.where(:type.in => %w(intern Internship))
      when 'full-time'
        jobs = jobs.where(:type.in => ['full_time_entry_level', 'Full Time (Experienced)', 'full_time_experienced', 'Full Time (Entry Level)'])
      when 'mini-internship'
        jobs = jobs.where(:type.in => ['Part Time (Hourly)', 'Mini Internship (Hourly)', 'Mini Internship (Fixed)' ])
    end
    jobs = jobs.order_by([:view_count, -1]).limit(limit).to_a

    if gigs
      gigs = Job.where(:live => true, type: /Mini Internship/).desc(:fixed_compensation)
      jobs = jobs.concat(gigs)
      jobs = jobs.shuffle
    end
    build_job_models(jobs)
  end

  def get_top_applied_jobs(major_type_id, year, gigs=false, live=false)
    year = year.to_i
    majors = MajorType.find(major_type_id).major_ids
    # get all user handles with these majors
    user_handles = User.where(:major_id.in => majors, active: true).pluck(:handle);
    # get all jobs applied by these users and create histogram
    job_ids_hist = get_histogram(JobApplicant.where(:handle.in => user_handles).pluck(:job_id)).map{|j| j[0]};
    jobs = Job.where(:id.in=> job_ids_hist, :company_id.ne => "resu.me");
    if (year - Date.today().year) < 1
      jobs = jobs.where(:type.nin => %w(intern Internship))
    elsif (year - Date.today().year) >= 2
      jobs = jobs.where(:type.nin => ['full_time_entry_level', 'Full Time (Experienced)', 'full_time_experienced', 'Full Time (Entry Level)']);
    end
    unless gigs
      jobs = jobs.where(:type => /[^(MiniInternship)]/)
    end

    if live
      jobs = jobs.where(live: true);
    end

    jobs.to_a
  end

  def get_top_gigs(limit = 50, school=nil, majortype=nil, year=nil)
    # get top gigs for both hourly and fixed sorted by compensation
    #hourly_jobs = Job.where(live: true, type: /Mini Internship \(Hourly\)/).desc(:hourly_compensation)
    fixed_jobs = Job.where(live: true, type: /Mini Internship \(Fixed\)/, :schools.in => [school, 'all'], major_types: majortype).desc(:fixed_compensation).take(limit)
    return fixed_jobs
  end

  def get_jobs_for_user(user, job_type = 'all')
    if user.blank?
      return get_top_jobs($FEED_PAGE_SIZE, nil, nil, nil, false)
    end

    school_handle = get_school_handle_from_email(user.id)
    jobs = []
    if job_type.eql? 'applied-jobs'
      return get_user_applied_jobs(user.handle)
    else
      profile = Profile.find(user[:handle])
      if profile.blank?
        return get_top_jobs($FEED_PAGE_SIZE, nil, nil, nil, false)
      else
        # use a very high no for results.
        jobs = recommendations_by_profile(profile, user, 500, job_type).to_a
        if jobs.count == 0
          # use regular method
          user_jobs = UserJobs.find("#{school_handle}_#{user.major_id}")
          unless user_jobs.blank?
            job_ids = decode_ids(user_jobs[:job_ids]).reverse
            jobs = get_jobs_live_by_ids(job_ids)
          end
        end
        jobs = build_job_models(jobs)
      end
    end
    jobs
  end

  def get_jobs_by_company_id(company_id)
    jobs = Job.where(:company_id => company_id).order_by([:_id, 1])
    company_ids = jobs.map { |job| job.company_id }
    results = Array.[]
    company_map = get_company_map(company_ids)
    jobs.each do |job|
      company = company_map[job.company_id]
      stuff_company_job(job, company)
      job[:hash] = encode_id(job.id)
      results << job
    end
    results
  end

  def get_jobs_for_school(school_handle)
    jobs = Job.where(:live => true).order_by([:create_dttm, -1]).in(:schools => [school_handle, 'all']).limit(50)
    company_ids = jobs.map { |job| job.company_id }
    results = Array.[]
    company_map = get_company_map(company_ids)
    jobs.each do |job|
      company = company_map[job.company_id]
      stuff_company_job(job, company)
      job[:hash] = encode_id(job.id)
      results << job
    end
    results
  end

  def get_live_jobs_by_company_id(company_id)
    jobs = Job.where(:company_id => company_id).order_by([:_id, 1])
    company_ids = jobs.map { |job| job.company_id }
    results = Array.[]
    company_map = get_company_map(company_ids)
    jobs.each do |job|
      if job.live
        company = company_map[job.company_id]
        stuff_company_job(job, company)
        job[:hash] = encode_id(job.id)
        results << job
      end
    end
    results
  end

  def stuff_company_job(job, company)
    unless company.blank?
      job.company = company.name.to_s
      unless company.company_logo.blank?
        job.company_logo = company.company_logo
      end

      unless company.culture_video_type.blank?
        job.culture_video_type = company.culture_video_type
      end

      unless company.culture_video_id.blank?
        job.culture_video_id = company.culture_video_id
      end

      unless company.description.blank?
        job.company_overview = company.description
      end
    end
  end

  def mark_live_job(job_id)
    job = Job.find(job_id)
    job[:live] = true
    job.save!
    job[:hash] = encode_id(job_id)
    job
  end

  def change_job_app_status(status, job_id, handle)
    if job_id.blank? or handle.blank?
      return false
    end

    unless JobStatusType.contains(status)
      return false
    end
    job_app_status_id = get_job_handle_id(handle, job_id)
    job_application_status = UserJobAppStats.find(job_app_status_id)
    if job_application_status.blank?
      job_application_status = UserJobAppStats.new
      job_application_status.id = job_app_status_id
      job_application_status.handle = handle
    end
    job_application_status.status = status
    job_application_status.save
    true
  end

  def get_default_jobs(num)
    jobs = Array.[]
    default_jobs = Job.order_by([:_id, -1]).limit(num)
    default_jobs.each do |job|
      if job[:live]
        job[:hash] = encode_id(job[:_id])
        jobs << job
      end

    end
    jobs
  end

  def get_job_by_hash(hash)
    get_job_by_id(decode_id(hash))
  end

  def update_job_views (id, handle)
    job = Job.find(id)
    unless job.blank?
      job.inc(:view_count, 1)
      job.save
    end
    unless handle.blank?
      view_id = get_job_handle_id(handle, id)
      job_view = JobView.find(view_id)
      if job_view.blank?
        job_view = JobView.new
        job_view.job_id = id
        job_view.id = view_id
        job_view.handle = handle
        job_view.create_dttm = Time.zone.now
        job_view.save
      end
    end

  end

  def is_applied_job_hash (handle, hash)
    id = decode_id(hash)
    job_app = JobApplicant.where(:job_id => id).find_by(handle: handle)
    if job_app.blank?
      return false
    end
    job_app.applied
  end

  def get_user_applied_jobs(handle)
    job_ids = get_user_applied_job_ids(handle)
    jobs = Job.find(job_ids)
    jobs.each do |job|
      job[:applied] = true
    end
     jobs
  end

  def get_user_applied_job_ids(handle)
    user_applied_jobs = JobApplicant.where(:handle => handle)
    if user_applied_jobs.blank?
      return Array.[]
    end
    job_ids = Array.[]
    user_applied_jobs.each do |job_app|
      job_ids << job_app.job_id
    end
    job_ids
  end

  def get_job_applicant_count(job_id)
    return JobApplicant.where(:job_id => job_id).count()
  end

  def get_user_job_status_map(job_id, handles)
    result_map = Hash.new
    ids = Array.new
    handles.each do |handle|
      ids << get_job_handle_id(handle, job_id)
    end
    app_stats = UserJobAppStats.find(ids)
    app_stats.each do |job_stats|
      result_map[job_stats.handle] = job_stats.status
    end
    result_map
  end

  def get_job_by_id(id)
    job = Job.find(id)
    build_job_models([job])[0]
  end

  def get_jobs_by_ids(ids)
    ids = ids.compact
    jobs = Job.order_by([:create_dttm, -1]).where(delete_dttm: nil).find(ids)
    build_job_models(jobs)
  end

  def build_job_models(jobs)
    company_ids = Array.[]
    poster_emails = Array.[]
    question_ids = Array.[]
    jobs.compact!
    jobs.each do |job|
      unless job[:question_id].blank?
        question_ids << job[:question_id]
      end
      company_ids << job.company_id
      poster_emails << job.email
    end
    company_map = get_company_map(company_ids)
    question_map = get_questions_map (question_ids)
    poster_map = get_job_poster_user_map(poster_emails)
    jobs.each do |job|
      job[:hash] = encode_id(job[:_id])
      unless job[:question_id].blank?
        job[:question] = question_map[job[:question_id]]
      end
      company = company_map[job.company_id]
      stuff_company_job(job, company)
      eu = poster_map[job.email]
      unless eu.blank?
        job[:poster_first_name] = eu.first_name
        job[:poster_last_name] = eu.last_name
      end
    end
    jobs
  end

  def get_jobs_live_by_ids(ids)
    ids = ids.compact
    jobs = Job.where(:live => true, :delete_dttm => nil).order_by([:create_dttm, -1]).find(ids)
    build_job_models(jobs)
  end

  def get_jobs_live_by_query_ids(query, ids)
    # searching for jobs query should be present
    if query.blank?
      return
    end
    jobs = Job.search(query).results
    if jobs.blank?
      return
    end
    #filtering and ordering the jobs
    jobs = jobs.select { |job| (!job.blank?) && job[:live] == true }.
        sort { |x, y| x <=> y }
    #jobs = Job.where(:live => true).order_by([:_id, -1]).find(ids)
    jobs = build_job_models(jobs)
    jobs
  end

  def get_jobs_by_hashes(hashes)
    get_jobs_by_ids(decode_ids(hashes))
  end

  def apply_job_update_app_stats(job_id, handle)
    # create a new record for each user in job app stats
    user_job_app_status = UserJobAppStats.new(
        _id: handle+"_"+job_id,
        job_id: job_id,
        handle: handle,
        status: "NEW"
    )
    user_job_app_status.save()
  end

  def apply_for_job(user, id, cover_note, answer_id = nil)
    if user.blank? or id.blank?
      return nil
    end
    handle = user.handle
    job = get_job_by_hash(id)
    if job.blank?
      job = get_job_by_id(id)
    end

    if job.blank?
      return nil
    end

    is_valid = is_job_valid_for_user(job, user)
    job_app = JobApplicant.find("#{handle}_#{job.id}")
    if job_app.blank?
      job_app = JobApplicant.new
      job_app.id = get_job_handle_id(handle, job.id)
      job_app.handle = handle
      job_app.job_id = job.id
      job_app.create_dttm = Time.zone.now
    end
    unless cover_note.blank?
      job_app.cover_note = params[:cover_description][:text]
    end

    if is_valid
      job_app.applied = true
    else
      job_app.pseudo_applied = true
    end
    unless answer_id.blank?
      job_app.answer_id = answer_id
    end
    job_app.save
    save_user_state(handle, UserStateTypes::APPLY_JOBS_DATE)
    apply_job_update_app_stats(job.id, handle)
    unless job[:emails].blank?
      # if Rails.env.development?
      #   Notifier.email_job_notification(job, job_app, User.find_by(handle: handle)).deliver
      # end
      if is_valid
        EmailJobNewApplicantWorker.perform_async(job.id.to_s, handle)
      end
    end
    EmailJobConfirmationWorker.perform_async(handle, job.id.to_s)
    job
  end

  def admin_all_jobs
    jobs = Job.all.desc(:create_dttm)
    Kaminari.paginate_array(get_jobs_by_ids(jobs.map { |job| job.id })).page(params[:page]).per($FEED_PAGE_SIZE)
  end

  def pause_job_by_id(job_id)
    job = Job.find(job_id)
    if job.blank?
      return
    end
    job[:live] = false
    job.save!
    job[:hash] = encode_id(job_id)
    job
  end

  def save_upwork_job(job_hash, major_type)
    # check if job exists
    job = Job.where(:'meta_info.external_url' => job_hash["url"])
    if job.count() > 0
      return job[0]
    end
    job = Job.new
    job[:title] = job_hash[:title]
    job[:description] = sanitize_description_text(job_hash[:description])
    job[:type] = job_hash[:job_type]
    meta_info = {}
    meta_info["external_url"] = job_hash[:url]
    meta_info["source"] = 'upwork'
    job[:meta_info] = meta_info
    unless job_hash[:fixed_price].blank?
      job[:fixed_compensation] = job_hash[:fixed_price].gsub(/[^\d]+/, '').to_i
    end
    unless job_hash[:hourly_hours].blank?
      job[:hourly_hours] = job_hash[:hourly_hours].gsub(/[^\d]+/, '').to_i
    end
    if job_hash[:start_date].blank?
      job[:start_date] = Date.today()
    else
      job[:start_date] = job_hash[:start_date]
    end
    job[:end_date] = job_hash[:end_date]
    job[:location] = "Remote"
    job[:company] = 'Meed Client'
    job[:company_id] = 'meed_client'
    job[:major_types] = [major_type]
    job[:majors] = MajorType.find(major_type).major_ids
    job[:schools] = Schools.keys()
    job[:email] = 'contact@getmeed.com'
    job[:emails] = %w(contact@getmeed.com vmk@getmeed.com)
    job.save
    return job
  end

  def update_removed_user_jobs(params, schools, majors)
    job = get_job_by_id(params[:hidden_id])
    if job.blank?
      return
    end

    removed_schools = Array.[]
    removed_majors = Array.[]
    job[:schools].each do |old_school|
      unless schools.include? old_school
        removed_schools << old_school
      end
    end
    job[:majors].each do |old_major|
      unless majors.include? old_major
        removed_majors << old_major
      end
    end

    if !removed_schools.blank? and removed_majors.blank?
      removed_schools.each do |school_handle|
        majors.each do |major|
          id = encode_id(job[:_id])
          remove_user_job(school_handle, major, id)
        end
      end

    end

    if !removed_majors.blank? and removed_schools.blank?
      schools.each do |school_handle|
        removed_majors.each do |major|
          id = encode_id(job[:_id])
          remove_user_job(school_handle, major, id)
        end
      end
    end

    removed_schools.each do |school_handle|
      removed_majors.each do |major|
        id = encode_id(job[:_id])
        remove_user_job(school_handle, major, id)
      end
    end

  end

  def remove_user_job (school_handle, major, id)
    if school_handle.blank? or major.blank? or id.blank?
      return
    end

    user_job_id = get_feed_key(school_handle, major)
    unless user_job_id.blank?
      user_job = UserJobs.find(user_job_id)
      unless user_job.blank?
        user_job.pull(:job_ids, id)
        user_job.save
      end
    end
  end

  def update_added_user_jobs(job, schools, majors)
    if !schools.blank? and !majors.blank?
      schools.each do |handle|
        majors.each do |major|
          user_job_id = get_feed_key(handle, major)
          unless user_job_id.blank?
            user_job = UserJobs.find(user_job_id)
            if user_job.blank?
              user_job = UserJobs.new(:user_job_id => user_job_id)
            end
            id = encode_id(job[:_id])
            user_job.add_to_set(:job_ids, id)
            user_job.save
          end
        end
      end
    end
  end

  def admin_all_prof_impressions
    ProfileImpressions.all
  end

  def recommendations_by_profile(profile, user, result_count=10, type = 'all')
    tags = profile[:tags]
    if tags.blank?
      tags = []
    end
    # boosting works only for integer values so converting the probabilities into integers with precision = 10^-3
    precision = 100
    if tags.class() == Array
      tags = Hash[tags]
    end
    tags = tags.each { |k, v| tags[k] = (v * precision) }
    boost = tags.map { |k, v| {value: k, factor: v} }
    major_key = user.major_id
    if major_key.blank?
      major_key = ''
    end
    major_type = ''
    unless major_key.blank?
      major_type = get_major_type_by_major_id(major_key)
    end
    if major_type.blank?
      major_type = ''
    end
    school_handle = get_school_handle_from_email(user.id)
    if school_handle.blank?
      school_handle = ''
    end
    search_keywords = tags.map{|k,v| "\"#{k}\""}.join(' ')
    if search_keywords.blank?
      search_keywords = "*"
    end

    include_types = []
    if type.eql? 'all'
      if user.year.blank? || user.year.to_i == 0
        # get everything
        include_types = AllJobTypes
      elsif (user.year.to_i - Date.today().year) < 1
        # no internships
        include_types = (AllJobTypes - %w(intern Internship))
      elsif (user.year.to_i - Date.today().year) >= 2
        # no full time
        include_types = (AllJobTypes - ['Full Time (Experienced)', 'Full Time (Entry Level)',
                                        'full_time_entry_level', 'full_time_experienced' ])
      else
        include_types = AllJobTypes
      end
    elsif type.eql? 'internship'
      include_types = %w(intern Internship)
    elsif type.eql? 'full-time'
      include_types = ['full_time_experienced', 'full_time_entry_level','Full Time (Experienced)', 'Full Time (Entry Level)']
    elsif type.eql? 'mini-internship'
      include_types = ['Part Time (Hourly)', 'Mini Internship (Hourly)', 'Mini Internship (Fixed)' ]
    end

    # filter results corresponding to what is available to the school.
    query = Job.search "*", operator: 'or', execute: false,
                       where: {live: true,
                               schools: [school_handle, 'all'],
                               major_types: {all: [major_type]},
                               type: include_types
                       },
                       # matching skills and company name is most important. Then Title then location.
                       fields: %W(
                        tags^10
                        skills^10
                        title^5
                        description^2
                        company_overview
                       ),
                       # boosting popular jobs
                       boost_where: {_all: boost, organic: [{value: true, factor: 20}, {value: false, factor: 1}] },
                       limit: result_count
    query.body[:query][:filtered][:query][:function_score][:functions].concat([{
                                                                                    exp: {
                                                                                        create_dttm: {
                                                                                            origin: Date.today(),
                                                                                            scale: '180d',
                                                                                            offset: '90d',
                                                                                            decay: 0.25
                                                                                        }
                                                                                    },
                                                                                    weight: 20
                                                                               },
                                                                               {
                                                                                   exp: {
                                                                                       application_count: {
                                                                                           origin: 30,
                                                                                           scale: 10,
                                                                                           offset: 20,
                                                                                           decay: 0.7
                                                                                       }
                                                                                   },
                                                                                   weight: 20
                                                                               }
                                                                              ])
    query.body[:query][:filtered][:query][:function_score][:score_mode] = "sum"
    # Using a decay function for the time when the feed item was posted. If the post was done within 7 days, there is
    # no decay in the score. In 30 days from then the score decays by half.
    # FUNCTION SCORE APPEARS TO OVERRIDE THE PREVIOUS SCORE SO DISABLING THE TIME OFFSET SCORING
    # query.body[:query][:filtered][:query][:function_score].merge!({
    #                                                functions: [
    #                                                    exp: {
    #                                                        create_dttm: {
    #                                                            origin: Date.today(),
    #                                                            scale: '180d',
    #                                                            offset: '90d',
    #                                                            decay: 0.25
    #                                                        }
    #                                                    }
    #                                                ],
    #                                                score_mode: "sum",
    #                                                boost_mode: "sum"
    #                                            })
    results = query.execute
    return results
  end

  def similar_jobs(job, user, limit=3, only_organic = false)
    if job.blank?
      return
    end
    where_conditions = {}
    if %w(intern Internship).include? job.type
      where_conditions["type"] = %w(intern Internship)
    elsif ['full_time_experienced', 'full_time_entry_level','Full Time (Experienced)', 'Full Time (Entry Level)'].include? job.type
      where_conditions["type"] = ['full_time_experienced', 'full_time_entry_level','Full Time (Experienced)', 'Full Time (Entry Level)']
    elsif ['Part Time (Hourly)', 'Mini Internship (Hourly)', 'Mini Internship (Fixed)' ].include? job.type
      where_conditions["type"] = ['Part Time (Hourly)', 'Mini Internship (Hourly)', 'Mini Internship (Fixed)' ]
    end

    unless user.blank?
      school_handle = get_school_handle_from_email(user.id)
      unless school_handle.blank?
        where_conditions["schools"] = [school_handle, 'any']
      end

      major_key = user.major_id
      unless major_key.blank?
        major_type = get_major_type_by_major_id(major_key)
        unless major_type.blank?
          where_conditions["major_types"] = {all: [major_type]}
        end
      end
      applied_job_ids = get_user_applied_job_ids(user.handle)
      unless applied_job_ids.blank?
        where_conditions["_id"] = {not: applied_job_ids}
      end
    end

    if only_organic
      where_conditions["organic"] = true
    end
    job.similar(where: where_conditions, limit: limit)
  end

  def sort_jobs_by_profile(profile, user, job_ids)
    # get lot of jobs and filter by job_ids
    jobs = recommendations_by_profile(profile, user, 500)
    jobs = jobs.select{|job| job_ids.include? job[:_id]}
    return jobs
  end

  def get_recommendation_count_by_filters(skills = [], majors = [], schools = [])
    precision = 100
    search_keywords = "*"
    unless skills.blank?
      search_keywords = skills.map {|t| "\"#{t}\""}.join(' ')
    end
    where_condition = {}
    unless schools.blank?
      where_condition[:school] = SchoolsStore.get_schools_from_select(schools)
    end
    unless majors.blank?
      where_condition[:major] = SchoolsStore.get_majors_from_select(majors)
    end
    query = Profile.search search_keywords, operator: "or", execute: false,
                           where: where_condition;
    response = query.execute;
    return response.response["hits"]["total"]
  end

  #company related apis
  def get_or_create_company(name, company_logo)
    id = generate_id_from_text(name.downcase)
    company = Company.find(id)
    if company.blank?
      company = Company.new
      company.name = name
      company.id = id
    end
    unless company_logo.blank?
      begin
        upload_hash = Cloudinary::Uploader.upload(company_logo,
                                                  :crop => :limit, :width => 75, :height => 75,
                                                  :eager => [
                                                      {:width => 75, :height => 75,
                                                       :crop => :thumb, :gravity => :face,
                                                       :radius => 20, :effect => :sepia},
                                                      {:width => 100, :height => 100,
                                                       :crop => :fit, :format => 'png'}
                                                  ], :secure => true,
                                                  :tags => ['job', name])
      rescue Exception => ex
        $log.error "Error in cloudinating images!: #{ex}"
      end

      unless upload_hash['secure_url'].blank?
        company.company_logo = upload_hash['secure_url']
      end
    end
    company.save
    company
  end

  def admin_create_company(name, company_logo)
    id = generate_id_from_text(name.downcase)
    company = Company.find(id)
    if company.blank?
      company = Company.new
      company.name = name
      company.id = id
      company.company_logo = company_logo;
      company.save
    end
    company
  end

  def get_company_map(company_ids)
    company_map = Hash.new
    if company_ids.blank?
      return company_map
    end
    companies = Company.find(company_ids.compact)
    companies.each do |company|
      company_map[company.id] = company
    end
    company_map
  end

  def get_job_poster_user_map(emails)
    users = EnterpriseUser.where(email: emails)
    users_map = Hash.new
    users.each do |user|
      user_map[user.email] = user
    end
    users_map
  end

  def get_companies(company_ids)
    companies = Company.find(company_ids)
    photo_ids = Array.[]
    companies.each do |company|
      photo_ids << company.culture_photo_ids
    end
    photos = get_photos_by_ids(photo_ids)
    photo_map = Hash.new
    photos.each do |photo|
      photo_map[photo.id] = photo
    end

    companies.each do |company|
      company_photos = Array.[]
      unless company.culture_photo_ids.blank?
        company.culture_photo_ids.each do |photo_id|
          company_photos << photo_map[photo_id]
        end
        company[:photos] = company_photos
      end

    end
  end

  def get_company_by_handle(company_handle)
    Company.find(company_handle)
  end

  def get_company_by_id(id)
    company = Company.find(id)
    unless company.blank?
      if !company.culture_video_id.blank? and company.culture_video_type.eql? 'youtube' and company.get_cover_image_url.blank?
        image_url = get_hd_youtube_image_url(company.culture_video_id)

        if image_url.blank?
          image_url = get_youtube_default_image_url(company.culture_video_id)
        end
        company.cover_image_url = image_url
        company.save
      end
      photos = get_photos_by_ids(company.culture_photo_ids)
      company[:photos] = photos
    end
    company
  end

  def get_poster_by_email(email)
    EnterpriseUser.find_by(email: email)
  end

  def update_company_view_count(company)
    if company.blank?
      nil
    end
    company = Company.find(company.id)
    company.inc(:view_count, 1)
    company.save
  end

  def get_job_map(job_ids)
    Hash[get_jobs_by_ids(job_ids).map { |j| ["#{j[:_id]}", j] }]
  end

  def follow_company(company_id, handle)
    id = "#{company_id}-#{handle}"
    company_follow = CompanyFollow.where(:_id => id)
    if company_follow.blank?
      company_follow = CompanyFollow.new
      company_follow.id = id
      company_follow.time = Time.zone.now
      company_follow.user_handle = handle
      company_follow.company_id = company_id
      company_follow.save
      Company.where(_id: company_id).inc(:follow_count, 1)
    end
    user_follow(company_id, handle)
    company_follow
  end

  def unfollow_company(company_id, handle)
    id = "#{company_id}-#{handle}"
    company_follow = CompanyFollow.where(:_id => id)
    unless company_follow.blank?
      company_follow.delete
      user_unfollow(company_id, handle)
    end
    company_follow
  end

  def is_user_following_company(user_handle, company_id)
    user_follows = get_user_follows(user_handle)
    return false if user_follows.blank?
    (!user_follows.company_ids.blank? and user_follows.company_ids.include? company_id)
  end

  end
