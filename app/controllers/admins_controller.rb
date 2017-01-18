class AdminsController < ApplicationController
  include AdminsManager
  include AdminsHelper
  include ArticlesManager
  include CrmManager
  include UsersManager
  include JobsManager
  include UsersHelper
  include FeedItemsManager
  include JobsHelper
  include CommonHelper
  include LinkHelper
  include PhotoHelper
  include PhotoManager
  include CollectionsManager
  include NotifierHelper
  include MigrationsManager

  def view
    unless authenticate(current_user)
      return
    end

    respond_to do |format|
      format.html # view.html.erb
    end
  end

  def influencers
    @influencers = User.where(:badge => 'influencer').order_by([:create_dttm, -1]).to_a
  end

  def weekly_digest
    unless authenticate(current_user)
      return
    end
  end


  def weekly_digest_generate
    unless authenticate(current_user)
      return
    end

    if params[:feed_ids].blank?
      weekly_digest
      return
    end

    if params[:job_ids].blank?
      weekly_digest
      return
    end

    feed_ids = params[:feed_ids].gsub(/\s+/, "").split(',')
    job_ids = params[:job_ids].gsub(/\s+/, "").split(',')
    feed_items = FeedItems.where(:subject_id.in => feed_ids).to_a
    build_feed_models(nil, feed_items)
    jobs = get_jobs_by_ids(job_ids)
    if jobs.blank?
      jobs = get_jobs_by_hashes(job_ids)
    end
    collection = Collection.find(params[:collection_id])
    if feed_items[0].caption.blank?
      @subject = "#{feed_items[0].title.truncate(50, :omission => '..')}"
    else
      @subject = "#{feed_items[0].caption.truncate(50, :omission => '..')}"
    end

    @group_name = collection.title
    @feed_items = feed_items.take(3)
    @jobs = jobs.take(2)

    erb_file = "#{Rails.root}/app/views/notifier/email_weekly_digest_feed.html.erb"
    erb_str = File.read(erb_file)
    @result = ERB.new(erb_str).result(binding)
  end


  def admin_collection
    unless authenticate(current_user)
      return
    end
    @categories = get_all_categories
    @business_major_types = get_business_major_types
    @engineering_major_types = get_engineering_major_types
    @other_major_types = get_other_major_types
  end

  def admin_submissions
    unless authenticate(current_user)
      return
    end
    feed_items = FeedItems.where(:collection_id.exists => false, :poster_type => 'user', :type => 'story').to_a
    @feed_items = build_feed_models(current_user, feed_items)
    @public_collections = get_public_collections

  end

  def admin_map_submission_collection
    feed_id = params[:feed_id]
    feed_item = FeedItems.find(feed_id)
    @feed_id = feed_id
    feed_item.collection_id = params[:collection_id]
    increment_collection_posts(params[:collection_id])
    feed_item.save
  end

  def admin_create_collection
    unless logged_in?(root_path)
      return
    end
    params[:is_public] = true
    collection = create_collection(current_user.handle, params)
    if collection.blank?
      flash[:alert] = "Something went wrong, please create again"
    else
      flash[:alert] = "Collection creation successful"
    end
    build_collection_models(current_user, [collection])
    redirect_to '/admin/collection'
  end

  def update_intercom_contacts
    unless authenticate(current_user)
      return
    end

    inactive_users = User.where(:active => false)
    inactive_users.each do |inactive_user|
      update_intercom_contact(inactive_user)
    end

    respond_to do |format|
      format.html # view.html.erb
      format.json { render json: @user }
    end
  end

  def create_intercom_contacts
    unless authenticate(current_user)
      return
    end

    inactive_users = User.where(:active => false)
    inactive_users.each do |inactive_user|
      create_intercom_contact(inactive_user)
    end

    respond_to do |format|
      format.html # view.html.erb
      format.json { render json: @user }
    end
  end

  def add_group_submit
    @schools = admin_all_schools
    channel = SocialChannels.where(:link => params[:link])
    if channel.blank?
      channel = SocialChannels.new
      channel.link = params[:link]
      channel.school_handle = params[:school].blank? ? 'everyone' : params[:school]
      channel.name = params[:name]
      channel.source = params[:source]
      channel.type = params[:type]
      channel.save
    end

    flash[:alert] = 'Successful! Add another group source'
    render 'admins/add_group'
  end

  def add_group
    @schools = admin_all_schools
  end

  def gecko_stats
    json_hash = Hash.new
    if params[:token].eql? 'gecko_master'
      case params[:metric]
        when 'user_growth'
          json_hash = get_user_growth_gecko_stats(params[:days].to_i)
        when 'user_signup_referer'
          json_hash = get_user_signup_referer_gecko_stats(params[:days].to_i)
        when 'user_work_references'
          json_hash = get_user_work_references_gecko_stats(params[:days].to_i)
        when 'user_signup_source'
          json_hash = get_user_signup_source_gecko_stats(params[:days].to_i)
        else
          success = false
          reason = 'invalid_metric'
          json_hash[:success] = success
          json_hash[:reason] = reason
      end
    else
      success = false
      reason = 'unauth'
      json_hash[:success] = success
      json_hash[:reason] = reason
    end

    respond_to do |format|
      format.json { render json: json_hash }
    end
  end

  def search_index
    unless authenticate(current_user)
      return
    end

    jobs = Job.where(:live => true).to_a
    users = User.where(:active => true).to_a
    companies = Company.all

    users.each do |user|
      if user.id.include? 'test'
        next
      end
      profile = get_user_profile_or_new(user.handle)
      school = get_school(get_school_handle_from_email(user.id))
      if Rails.env.development?
        search_record = DevSearch.new
      else
        search_record = Search.new
      end
      search_record.id = user.handle
      search_record.handle = user.handle
      search_record.name = "#{user.first_name} #{user.last_name}".upcase
      search_record.type = 'user'
      search_record.degree = user.degree
      search_record.major = user.major
      search_record.score = profile.score
      unless user.image_url.blank?
        search_record.picture = user.image_url
      end

      unless school.blank?
        search_record.university = school.name
      end
      skills = Array.new
      unless profile[:user_work_ids].blank?
        user_works = UserWork.find(profile[:user_work_ids])
        experience_titles = Array.new
        user_works.each do |user_work|
          experience_titles << "#{user_work.title}, #{user_work.company}"
          unless user_work.skills.blank?
            skills.concat user_work.skills.split(',');
          end
        end
        search_record.experience = experience_titles
      end

      unless profile[:user_internship_ids].blank?
        user_internships = UserInternship.find(profile[:user_internship_ids])
        experience_titles = Array.new
        user_internships.each do |user_internship|
          experience_titles << "#{user_internship.title}, #{user_internship.company}"
          unless user_internship.skills.blank?
            skills.concat user_internship.skills.split(',');
          end
        end
        search_record.internships = experience_titles
      end


      unless profile[:user_course_ids].blank?
        user_courses = UserCourse.find(profile[:user_course_ids])
        course_titles = Array.new
        user_courses.each do |user_course|
          course_titles << "#{user_course.title}, #{user_course.semester}-#{user_course.year}"
          unless user_course.skills.blank?
            skills.concat user_course.skills.split(',');
          end
        end
        search_record.coursework = course_titles
      end

      unless skills.blank?
        search_record.skills = skills.uniq
      end
      search_record.save
    end

    jobs.each do |job|

      if Rails.env.development?
        search_record = DevSearch.new
      else
        search_record = Search.new
      end
      search_record.id = job.id
      search_record.handle = encode_id(job.id)
      search_record.name = "#{job.title} #{job.company}, #{job.location}"
      search_record.type = 'job'
      search_record.picture = job.company_logo
      search_record.score = job.view_count
      search_record.save
    end

    companies.each do |company|
      if Rails.env.development?
        search_record = DevSearch.new
      else
        search_record = Search.new
      end
      search_record.id = company.id
      search_record.handle = company.id
      search_record.name = company.name
      search_record.type = 'company'
      search_record.picture = company.company_logo
      search_record.score = company.view_count
      search_record.save
    end


    if Rails.env.development?
      DevSearch.reindex!
    else
      Search.reindex!
    end
  end

  def lost_users
    unless authenticate(current_user)
      return
    end

    lost_users = UserLost.all
    lost_users.each do |lost_user|
      user = User.find(lost_user.id)
      if user.blank?
        user = User.new
        user.id = lost_user.id.downcase
        user.email = lost_user.email
        user.first_name = lost_user.first_name
        user.last_name = lost_user.last_name
        user.degree = lost_user.degree
        user.major_id = lost_user.major_id
        user.active = true
        user.create_dttm = Time.now
        unless lost_user.gpa.blank?
          user.gpa = lost_user.gpa
        end
        user.image_url = lost_user.image_url
        user.handle = lost_user.handle
        user.save
      end
    end

  end

  def email
    unless authenticate(current_user)
      return
    end
    respond_to do |format|
      format.html # view.html.erb
      format.json { render json: @user }
    end
  end

  def sitemap_initialize
    unless authenticate(current_user)
      return
    end
  end

  def email_send
    unless authenticate(current_user)
      return
    end
    if params[:subject].blank?
      flash[:alert] = 'Please enter a subject'
      render :template => 'admins/email'
      return
    end

    if params[:body][:text].blank?
      flash[:alert] = 'Please enter body'
      render :template => 'admins/email'
      return
    end

    if params[:email].blank?
      flash[:alert] = 'Please enter landing url'
      render :template => 'admins/email'
      return
    end

    if params[:landing_url].blank?
      flash[:alert] = 'Please enter landing url'
      render :template => 'admins/email'
      return
    end

    emails = decode_delimited_strings_char(params[:email], ',')

    emails.each do |email|
      each_email = email.gsub(/\s|"|'/, '')
      Notifier.email_custom(params[:sender_email], params[:subject], each_email, scrub_input_text(params[:body][:text]), params[:landing_url]).deliver
    end

    respond_to do |format|
      format.html # view.html.erb
      format.json { render json: @user }
    end
  end

  def waitlist
    unless authenticate(current_user)
      return
    end
    @waitlists = WaitListInvitation.all
    respond_to do |format|
      format.html # view.html.erb
      format.json { render json: @user }
    end
  end

  def invitations
    unless authenticate(current_user)
      return
    end
    @invitations = EmailInvitation.all
    respond_to do |format|
      format.html
    end
  end

  def blogs
    unless authenticate(current_user)
      return
    end
    @blogs = admin_recent_n_blogs(15)
    respond_to do |format|
      format.html
    end
  end

  def contact_us
    unless authenticate(current_user)
      return
    end
    if params[:subject].blank?
      flash[:alert] = 'Please enter a subject'
      render :template => 'admins/email'
      return
    end

    if params[:body][:text].blank?
      flash[:alert] = 'Please enter body'
      render :template => 'admins/email'
      return
    end

    if params[:email].blank?
      flash[:alert] = 'Please enter landing url'
      render :template => 'admins/email'
      return
    end

    if params[:landing_url].blank?
      flash[:alert] = 'Please enter landing url'
      render :template => 'admins/email'
      return
    end

    Notifier.email_custom('ravi@getmeed.com', params[:subject], params[:email], process_text(params[:body][:text]), params[:landing_url]).deliver

    respond_to do |format|
      format.html # view.html.erb
      format.json { render json: @user }
    end
  end

  def new_blog
    unless authenticate(current_user)
      return
    end
    if params[:title].blank? or params[:description].blank? or params[:url].blank? or params[:img_url].blank?
      flash[:notice] = '*One or more fields blank!'
      redirect_to '/admin/blogs'
      return
    end
    @blog = admin_create_blog(params)
    @blogs = admin_recent_n_blogs(3)
    flash[:notice] = 'Blog saved successfully.'

    render 'admins/blogs'

  end

  def delete_blog
    @blog_id = params[:id]
    if (@blog_id.blank?)
      flash[:alert] = 'Error deleting blog.'
      render 'admins/blogs'
      return
    end

    @blog = FeedItems.find(@blog_id)
    if (@blog.blank?)
      flash[:alert] = 'Error deleting blog.'
      render 'admins/blogs'
      return

    end
    @blog.delete
    @blogs = FeedItems.order_by([:_id, -1]).limit(3)
    flash[:alert] = 'Deleted successfully'
    render 'admins/blogs'
  end

  def show_jobs
    unless authenticate(current_user)
      return
    end
    @jobs = admin_all_jobs
    @live_jobs = Array.[]
    @pause_jobs = Array.[]
    @jobs.each do |job|
      get_job_stats(job, current_user.handle)
      if job[:live]
        @live_jobs << job
      else
        @pause_jobs << job
      end

    end
    render 'admins/show_jobs'
  end

  def show_bdi_jobs
    unless logged_in?
      return
    end
    if params[:days].blank?
      params[:days] = 14
    end
    key = "admin_bdi_jobs_#{current_user.handle}_#{params[:days]}"
    @jobs_metadata = $redis.get(key)
    if @jobs_metadata.blank?
      @jobs = Job.where(:live => true).desc(:create_dttm).limit(50)
      metadata = []
      @jobs.each do |job|
        job = get_job_stats(job, current_user.handle)
        metadata.push(job)
      end
      @jobs_metadata = metadata.map { |job| {:_id => job.id, :company_id => job[:company_id], :title => job[:title],
                                             :company => job[:company], :view_count => job[:view_count],
                                             :application_count => job[:application_count],
                                             :user_view_count => job[:user_view_count],
                                             :user_job_count => job[:user_job_count]} }
      $redis.set(key, @jobs_metadata)
      # expire after 3 hrs
      $redis.expire(key, 3600 * 3)
    else
      @jobs_metadata = eval(@jobs_metadata)
    end

    render 'admins/show_bdi_jobs'
  end

  def show_bdi_status
    unless logged_in?
      return
    end
    if params[:days].blank?
      params[:days] = 14
    end
    key = "admin_bdi_status_#{params[:days]}"
    @results = $redis.get(key)
    if @results.blank?
      job_views = Instrumentation.where(:event_name => 'Consumer.Jobs.ViewJob', :"event_payload.ref.referrer".in => MODERATOR_HANDLES, :event_start.gt => (Time.now() - params[:days].to_i.days))
      jobs_count = Hash[job_views.map { |v| [v.event_payload['ref']['referrer'], v.event_payload['job_id']] }.group_by { |v| v[0] }.map { |k, v| [k, v.uniq.count()] }]
      bdi_views = Hash[job_views.group_by { |v| v.event_payload['ref']['referrer'] }.map { |key, value| [key, value.count()] }]
      job_applies = Instrumentation.where(:event_name => 'Consumer.Jobs.Apply', :"event_payload.ref.referrer".in => MODERATOR_HANDLES, :event_start.gt => (Time.now() - params[:days].to_i.days))
      bdi_applies = Hash[job_applies.group_by { |v| v.event_payload['ref']['referrer'] }.map { |key, value| [key, value.count()] }]
      @results = MODERATOR_HANDLES.map { |handle| {:handle => handle, :jobs_count => jobs_count.has_key?(handle) ? jobs_count[handle] : 0, :view_count => bdi_views.has_key?(handle) ? bdi_views[handle] : 0, :apply_count => bdi_applies.has_key?(handle) ? bdi_applies[handle] : 0} }
      $redis.set(key, @results)
      # expire after 3 hrs
      $redis.expire(key, 3600 * 3)
    else
      @results = eval(@results)
    end
  end

  def show_bdi_job_status
    unless logged_in?
      return
    end
    if params[:handle].blank?
      return
    end

    if params[:days].blank?
      params[:days] = 14
    end

    if params[:limit].blank?
      params[:limit] = 50
    end
    key = "admin_bdi_job_status_#{params[:handle]}_#{params[:days]}_#{params[:limit]}"
    @jobs_metadata = $redis.get(key)
    if @jobs_metadata.blank?
      job_views = Instrumentation.where(:event_name => 'Consumer.Jobs.ViewJob', :"event_payload.ref.referrer" => params[:handle], :event_start.gt => (Time.now() - params[:days].to_i.days))
      job_applies = Instrumentation.where(:event_name => 'Consumer.Jobs.Apply', :"event_payload.ref.referrer" => params[:handle], :event_start.gt => (Time.now() - params[:days].to_i.days))
      job_ids = job_views.map { |view| view[:event_payload]['job_id']["$oid"] }
      job_ids = job_ids.concat(job_applies.map { |view| view[:event_payload]['job_id']['$oid'] })
      job_ids = job_ids.uniq().compact
      # get view counts for each job
      view_counts = job_views.group_by { |view| view[:event_payload]['job_id']['$oid'] }.map { |key, value| [key, value.count()] }.select { |t| !t[0].blank? }.to_h
      apply_counts = job_applies.group_by { |view| view[:event_payload]['job_id']['$oid'] }.map { |key, value| [key, value.count()] }.select { |t| !t[0].blank? }.to_h
      if job_ids.blank?
        job_ids = []
      end
      jobs = Job.find(job_ids)
      jobs_dict = jobs.map { |job| [job[:_id].to_s, job] }.to_h
      @jobs_metadata = []
      job_ids.each do |job_id|
        meta = {}
        meta[:job_id] = job_id
        meta[:title] = jobs_dict[job_id].title
        meta[:company] = jobs_dict[job_id].company
        meta[:company_id] = jobs_dict[job_id].company_id
        if view_counts.has_key? job_id
          meta[:view_count] = view_counts[job_id]
        else
          meta[:view_count] = 0
        end
        if apply_counts.has_key? job_id
          meta[:apply_count] = apply_counts[job_id]
        else
          meta[:apply_count] = 0
        end
        @jobs_metadata.append(meta)
      end
      $redis.set(key, @jobs_metadata.to_s)
    else
      @jobs_metadata = eval(@jobs_metadata)
    end
  end

  def pause_job
    unless authenticate(current_user)
      return
    end
    @job = pause_job_by_id(params[:id])
    @jobs = admin_all_jobs
    @live_jobs = Array.[]
    @pause_jobs = Array.[]
    @jobs.each do |job|
      if (job[:live])
        @live_jobs << job
      else
        @pause_jobs << job
      end
    end
    render 'admins/show_jobs'

  end

  def live_job
    unless authenticate(current_user)
      return
    end
    job_id = params[:id]
    @job = mark_live_job(job_id)
    @jobs = admin_all_jobs
    @live_jobs = Array.[]
    @pause_jobs = Array.[]
    @jobs.each do |job|
      if (job[:live])
        @live_jobs << job
      else
        @pause_jobs << job
      end
    end
    render 'admins/show_jobs'

  end

  def remind_incomplete_resume
    if !current_user.blank? and !current_user.handle.eql? 'ravi'
      @un_auth = true
      return
    end
    users = admin_all_users
    @count = 0
    users.each do |user|
      if user.active
        profile = get_user_profile_or_new(user.handle)
        if !profile.blank? and is_incomplete_profile(profile)
          EmailIncompleteResumeWorker.perform_async(user.id)
          @count = @count + 1
        end
      end
    end
  end

  def broadcast_new_feature
    if !current_user.blank? and !current_user.handle.eql? 'ravi'
      @un_auth = true
      return
    end
    users = User.where({:last_login_dttm => {'$gte' => (Date.today - 50.day)}})
    @count = 0
    users.each do |user|
      feed_items = get_feed_items_for_user(user, false)
      unless feed_items.blank?
        @count = @count + 1
        Notifier.email_activity_feed(user, feed_items).deliver
      end
    end
    render :template => 'admins/remind_incomplete_resume'
  end

#inactive users emails
  def send_emails
  end

  def add_major_type
    @majors = Major.where(:major_type_id.exists => false)
    @major_types = MajorType.all
  end

  def add_major_type_submit
    flash[:alert] = 'Successful! Link other majors'
    add_major_type

    if params[:major].blank? or params[:major_type].blank?
      render 'add_major_type'
      return
    end

    major = get_major_by_code(params[:major])
    major.major_type_id = params[:major_type]
    major.save

    redirect_to '/admin/add_major_type'
  end

  def dashboard
    unless authenticate(current_user)
      return
    end
    # check cache and get metric
    if params[:force] == 'true'
      $redis.del("admin_dashboard_key_metrics")
      $redis.del("admin_dashboard_key_metrics_timestamp")
    end
    key_metrics = $redis.get("admin_dashboard_key_metrics")
    total_users_time_stamp = $redis.get("admin_dashboard_key_metrics_timestamp")
    if key_metrics.blank?
      @key_metrics = get_dashboard_keymetrics
      $redis.set("admin_dashboard_key_metrics", @key_metrics)
      $redis.set("admin_dashboard_key_metrics_timestamp", Time.now())
    elsif $redis.get("admin_dashboard_key_metrics_timestamp").to_time < 6.hours.ago
      # time to refresh
      GenerateAdminMetricsWorker.perform_async("key_metrics")
      # meanwhile use existing data
      @key_metrics = eval(key_metrics)
    else
      @key_metrics = eval(key_metrics)
    end
  end

  def migrate_static_image_sizes
    feed_items = FeedItems.where(:type => 'story', :poster_type => 'user').to_a
    image_ids = %w(Screen_Shot_2015-09-04_at_12.30.49_AM_najre6 Screen_Shot_2015-09-04_at_12.31.43_AM_onyo9n Screen_Shot_2015-09-04_at_12.42.11_AM_rxygpe PSD_eruyyd.png Screen_Shot_2015-09-04_at_12.22.53_AM_aginiy.png Screen_Shot_2015-09-04_at_12.28.08_AM_shdjua.png Screen_Shot_2015-09-04_at_12.26.34_AM_yvzezq.png post-it-icon_zqtdxo.png)
    feed_items.each do|feed_item|
      image_ids.each do |image_id|
        if !feed_item.small_image_url.blank? and feed_item.small_image_url.include? image_id
          feed_item.small_image_url = feed_item.small_image_url.gsub 'w_150', 'w_50'
          feed_item.save
        end
      end
    end
  end

  def migrate_user_state
    users = User.where(:small_image_url.ne => User::DEFAULT_SMALL_IMAGE, :active => true).to_a
    users.each do |user|
      save_user_state(user.handle, UserStateTypes::PROFILE_PICTURE_BLANK, true, 'false')
    end
  end

  def migrate_industry_major_type
    text = File.open('major_industry.csv').read
    text.gsub!(/\r\n?/, "\n")
    text.each_line do |line|
      splits = line.split('","')
      splits.each do|split|
        split.gsub!(", ", '-')
      end
      splits.each do|split|
        split.gsub!('"', '')
      end

      refined_line = splits.join(',')
      splits = refined_line.split(',')
      major_type_ids = []
      industry_id = generate_id_from_text(splits[0].downcase)
      splits.each do |split|
        split.gsub!("-", ', ')
        major_type = MajorType.where(:name => split).first
        unless major_type.blank?
          major_type_ids << major_type.id
          if major_type.industry_ids.blank?
            major_type.industry_ids = []
          end
          unless major_type.industry_ids.include? industry_id
            major_type.industry_ids << industry_id
          end
          major_type.save
        end
      end
      industry = Industry.new
      industry.name = splits[0]
      industry.major_type_ids = major_type_ids
      industry._id = industry_id
      industry.save

    end

  end

end
