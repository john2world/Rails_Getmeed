module ProfilesManager
  include UsersManager
  include UsersHelper
  include MeedPointsTransactionManager
  include KudosManager
  include CollectionsManager


  def is_incomplete_profile(profile)
    if profile.blank? or (profile[:objective].blank? and profile[:user_course_ids].blank?)
      return true
    elsif profile[:user_work_ids].blank? and profile[:user_course_ids].blank? and profile[:user_internship_ids].blank?
      return true
    end
    false
  end

  def is_influencer_incomplete_profile(user)
    if user.bio.blank? or user.company_id.blank? or user.company_ids.blank?
      return true
    end
    false
  end

  def profile_incomplete_reason(profile)
    if profile.blank?
      return "Profile doesn't exist"
    end
    if profile[:objective].blank?
      return "Objective is empty"
    end
    if profile[:user_course_ids].blank?
      return "Course work empty"
    end
  end

  def create_profile_from_resume(user, resume_hash)
    if resume_hash.blank? or user.blank?
      return nil
    end
    user_info = resume_hash[:user]
    profile = get_user_profile_or_new(user.handle)
    unless user_info.blank?
      unless user_info[:first_name].blank?
        user.first_name = user_info[:first_name]
      end
      unless user_info[:last_name].blank?
        user.last_name = user_info[:last_name]
      end
      unless user_info[:phone].blank?
        user.phone_number = user_info[:phone]
      end
      unless user_info[:email].blank?
        user.email = user_info[:email]
      end
      begin
        user.save!
      rescue Exception => ex
      end
    end

    education_info = resume_hash[:educations]
    unless education_info.blank?
      education_info.each do |edu|
        user_edu = UserEducation.new
        user_edu[:handle] = user.handle
        unless edu[:name].blank?
          user_edu.name = edu[:name]
        end

        unless edu[:degree].blank?
          user_edu.degree = get_meed_degree(edu[:degree])
        end

        unless edu[:major].blank?
          user_edu.major = edu[:major]
        end

        unless edu[:started_on].blank?
          user_edu.start_year = edu[:started_on].year.to_s
        end

        unless edu[:ended_on].blank?
          user_edu.end_year = edu[:ended_on].year.to_s
        end
        profile.push(:user_edu_ids, user_edu[:_id])
        user_edu.save
      end
    end

    intern_info = resume_hash[:internships]
    unless intern_info.blank?
      intern_info.each do |intern|
        user_intern = UserInternship.new
        user_intern[:handle] = user.handle
        unless intern[:company].blank?
          user_intern.company = intern[:company]
        end

        unless intern[:description].blank?
          user_intern.description = process_text(intern[:description])
        end

        unless intern[:title].blank?
          user_intern.title = process_text(intern[:title])
        end

        unless intern[:started_on].blank?
          user_intern.start_year = intern[:started_on].year.to_s
          user_intern.start_month = Date::MONTHNAMES[intern[:started_on].month]
        end

        unless intern[:ended_on].blank?
          user_intern.end_year = intern[:ended_on].year.to_s
          user_intern.end_month = Date::MONTHNAMES[intern[:ended_on].month]
        end
        profile.push(:user_internship_ids, user_intern[:_id])
        user_intern.save
      end
    end

    work_info = resume_hash[:employments]
    unless work_info.blank?
      work_info.each do |work|
        user_work = UserWork.new
        user_work[:handle] = user.handle
        unless work[:company].blank?
          user_work.company = work[:company]
        end

        unless work[:description].blank?
          user_work.description = process_text(work[:description])
        end

        unless work[:title].blank?
          user_work.title = process_text(work[:title])
        end

        unless work[:started_on].blank?
          user_work.start_year = work[:started_on].year.to_s
          user_work.start_month = Date::MONTHNAMES[work[:started_on].month]
        end

        unless work[:ended_on].blank?
          user_work.end_year = work[:ended_on].year.to_s
          user_work.end_month = Date::MONTHNAMES[work[:ended_on].month]
        end
        profile.push(:user_work_ids, user_work[:_id])
        user_work.save
      end
    end
  end

  def get_user_inbox_key(handle)
    user = get_active_user_by_handle(handle)
    if user.blank?
      return nil
    end

    school_handle = get_school_handle_from_email(user.id)
    (!school_handle.blank? and !current_user.major_id.blank?) ?
        "#{school_handle}_#{current_user.major_id}" :
        nil
  end

  def increment_profile_kudos(id, profile_type)
    case profile_type
      when UserFeedTypes::INTERNSHIP
        UserInternship.where(id: id).inc(:kudos_count, 1)
      when UserFeedTypes::USERWORK
        UserWork.where(id: id).inc(:kudos_count, 1)
      when UserFeedTypes::COURSEWORK
        UserCourse.where(id: id).inc(:kudos_count, 1)
      when UserFeedTypes::EDUCATION
        UserEducation.where(id: id).inc(:kudos_count, 1)
      when UserFeedTypes::PUBLICATION
        UserPublication.where(id: id).inc(:kudos_count, 1)
      else
        return
    end
  end

  def get_user_major_id_by_handle(handle)
    user = get_active_user_by_handle(handle);
    if user.blank?
      return nil;
    end
    return user[:major_id];
  end

  def get_user_internship(id)
    UserInternship.find(id)
  end

  def get_user_internships(viewer, profile)
    if profile.blank?
      return
    end
    internships = Array.new
    unless profile[:user_internship_ids].blank?
      internships = UserInternship.find(profile[:user_internship_ids])
    end
    unless viewer.blank?
      subject_ids = Array.new
      internships.each do |internship|
        subject_ids << internship.id
      end
      kudos_map = get_kudos_giver_map_subject_ids(viewer.handle, subject_ids)
      unless kudos_map.blank?
        internships.each do |internship|
          kudos = kudos_map[internship[:_id].to_s]
          internship[:viewer_gave_kudos] = (kudos.blank?) ? false : true
        end
      end
    end
    order_work_items(internships)
  end

  def get_user_course(id)
    return UserCourse.find(id)
  end

  def get_user_courses(viewer, profile)
    if profile.blank?
      return
    end
    courses = Array.new
    if !profile[:user_course_ids].blank?
      courses = UserCourse.find(profile[:user_course_ids])
      courses.each do |course|
        reviews = course.course_project_reference
        reviews.each do |review|
          review[:reviewer_user] = build_user_model(get_user_by_handle(review.reviewer_handle))
        end
        course[:reviews] = reviews
      end
    end
    unless viewer.blank?
      subject_ids = Array.new
      courses.each do |course|
        subject_ids << course.id
      end
      kudos_map = get_kudos_giver_map_subject_ids(viewer.handle, subject_ids)
      unless kudos_map.blank?
        courses.each do |course|
          kudos = kudos_map[course[:_id].to_s]
          reviews = course.course_project_reference
          course[:reviews] = reviews
          course[:viewer_gave_kudos] = (kudos.blank?) ? false : true
        end
      end
    end
    order_course_items(courses)
  end

  def get_user_unreviewed_courses(profile)
    course_ids = profile[:user_course_ids]
    if course_ids.blank?
      return
    end
    course_ids = course_ids.select{|id| CourseReview.where(course_id: id).blank?}
    if course_ids.blank?
      return
    end
    courses = UserCourse.find(course_ids)
    order_course_items(courses)
  end

  def get_user_reviewed_courses_count(profile)
    course_ids = profile[:user_course_ids]
    if course_ids.blank?
      return 0
    end
    CourseReview.where(:course_id.in => course_ids).count()
  end
  
  def get_user_work(id)
    UserWork.find(id)
  end

  def get_user_edu(id)
    UserEducation.find(id)
  end


  def get_user_edus(viewer, profile)
    if profile.blank?
      return
    end
    edus = Array.new
    unless profile[:user_edu_ids].blank?
      edus = UserEducation.find(profile[:user_edu_ids])
    end
    unless viewer.blank?
      subject_ids = Array.new
      edus.each do |edu|
        subject_ids << edu.id
      end
      kudos_map = get_kudos_giver_map_subject_ids(viewer.handle, subject_ids)
      unless kudos_map.blank?
        edus.each do |edu|
          kudos = kudos_map[edu[:_id].to_s]
          edu[:viewer_gave_kudos] = (kudos.blank?) ? false : true
        end
      end
    end
    edus

  end

  def get_user_works(viewer, profile)
    works = Array.new
    if profile.blank?
      return works
    end
    if !profile[:user_work_ids].blank?
      works = UserWork.find(profile[:user_work_ids])
    end
    unless viewer.blank?
      subject_ids = Array.new
      works.each do |work|
        subject_ids << work.id
      end
      kudos_map = get_kudos_giver_map_subject_ids(viewer.handle, subject_ids)
      unless kudos_map.blank?
        works.each do |work|
          kudos = kudos_map[work[:_id].to_s]
          work[:viewer_gave_kudos] = (kudos.blank?) ? false : true
        end
      end
    end
    order_work_items(works)
  end

  def get_user_publication(id)
    UserPublication.find(id)
  end

  def get_user_publications(viewer, profile)
    if profile.blank? || profile[:user_publication_ids].blank?
      return Array.new
    end
    publications = (UserPublication.find(profile[:user_publication_ids])).to_a
    unless viewer.blank?
      subject_ids = Array.new
      publications.each do |publication|
        subject_ids << publication.id
      end
      kudos_map = get_kudos_giver_map_subject_ids(viewer.handle, subject_ids)
      unless kudos_map.blank?
        publications.each do |publication|
          kudos = kudos_map[publication[:_id].to_s]
          publication[:viewer_gave_kudos] = (kudos.blank?) ? false : true
        end
      end
    end
    order_publication_items(publications)
  end

  def delete_user_profile_item(id, profile, type)
    if id.blank? || type.blank?
      return nil
    end

    if type == 'publication'
      pub = UserPublication.find(id)
      pub.delete
      profile.pull(:user_publication_ids, Moped::BSON::ObjectId(id));
    end

    if type == 'objective'
      profile.set(:objective, '')
      profile.save!
    end

    if type == 'internship'
      intern = UserInternship.find(id)
      intern.delete
      profile.pull(:user_internship_ids, Moped::BSON::ObjectId(id));
    end

    if type == 'course'
      course = UserCourse.find(id)
      course.delete
      profile.pull(:user_course_ids, Moped::BSON::ObjectId(id));
    end

    if type == 'work'
      work = UserWork.find(id)
      work.delete
      profile.pull(:user_work_ids, Moped::BSON::ObjectId(id));
    end
    if type == 'education'
      edu = UserEducation.find(id)
      edu.delete
      profile.pull(:user_edu_ids, Moped::BSON::ObjectId(id));
    end
    # tags have to be created
    GenerateProfileTagsWorker.perform_async(profile.id)
  end

  def get_school(school_handle)
    School.find(school_handle)
  end

  def get_school_map(school_handles)
    schools = School.find(school_handles)
    school_map = Hash.new
    schools.each do |school|
      school_map[school.handle] = school
    end
    school_map
  end

  def get_user_profile_or_new(handle)
    if handle.blank?
      return nil;
    end
    profile = Profile.find(handle);
    if profile.blank?
      profile = Profile.new(:handle => handle)
      profile.save
    end
    profile
  end

  def get_user_profile(handle)
    if handle.blank?
      return nil;
    end
    return Profile.find(handle)
  end

  def get_user_profiles(handles)
    handles = handles.compact
    Profile.find(handles)
  end

  def get_user_profile_map(handles)
    profiles = get_user_profiles(handles)
    profile_map = Hash.new
    profiles.each do |profile|
      profile_map[profile.handle] = profile
    end
    profile_map
  end

  def update_profile_invite_flag(handle)
    profile = get_user_profile_or_new(handle)
    if profile.blank?
      return
    end
    profile[:invited_friends] = true
    profile.save!
  end

  def get_profile_impressions(user)
    if user.blank?
      return nil
    end

    impression = ProfileImpressions.find(user[:handle])
    if impression.blank?
      impression = ProfileImpressions.new(:handle => user[:handle], :public_view_count => 0)
      impression.save
    end
    impression
  end

  def get_profile_viewers(user)
    if user.blank?
      return nil
    end
    impressions = ProfileImpressions.find(user[:handle])
    if impression.blank?
      impressions = ProfileImpressions.new(:handle => user[:handle], :public_view_count => 0)
      impressions.save
      return impressions
    end
    users = Array.[]
    #TODO- improve the db calls
    unless impressions[:viewers].blank?
      impressions[:viewers].each do |viewer|
        users << get_active_user_by_handle(viewer);
      end
    end
    users
  end

  def get_job_profile_viewers(user)
    if user.blank?
      return nil
    end
    impressions = ProfileImpressions.find(user[:handle])
    if impressions.blank?
      impression = ProfileImpressions.new(:handle => user[:handle], :public_view_count => 0)
      impression.save
      return impression
    end

    jobs = Array.[]
    #TODO- improve the db calls
    unless impressions[:job_ids].blank?
      return get_jobs_by_ids(impressions[:job_ids])
    end
    nil
  end

  def order_work_items(work_items)
    work_items.each do |profile_object|
      begin
        unless profile_object.start_year.blank?
          profile_object[:start_date] = Date.strptime("{#{profile_object.start_year} #{get_num_for_month(profile_object.start_month)}}", "{%Y %m}")
        end
      rescue Exception => ex
        profile_object[:start_date] = Time.now
        next
      end
    end
    begin
      work_items.sort_by!(&:start_date).reverse!
    rescue Exception => ex
      work_items
    end
  end

  def order_course_items(courses)
    courses.each do |profile_object|
      begin
        unless profile_object.year.blank?
          profile_object[:start_date] = Date.strptime("{#{profile_object.year} #{get_num_for_semester(profile_object.semester)}}", "{%Y %m}")
        end
      rescue Exception => ex
        profile_object[:start_date] = Time.now.to_date
        next
      end
    end
    begin
      courses.sort_by!(&:start_date).reverse!
    rescue Exception => ex
      courses
    end
  end

  def order_publication_items(publications)
    publications.each do |profile_object|
      begin
        unless profile_object.year.blank?
          profile_object[:start_date] = Date.strptime("{#{profile_object.year}}", "{%Y}")
        end
      rescue Exception => ex
        profile_object[:start_date] = Time.now.to_date
        next
      end
    end
    begin
      publications.sort_by!(&:start_date).reverse!
    rescue Exception => ex
      publications
    end
  end

  def get_users_applied(job)
    user_applied_jobs = JobApplicant.where(:job_id => job[:_id])
    if user_applied_jobs.blank?
      return Array.[]
    end
    handles = Array.[]
    user_applied_jobs.each do |job_app|
      handles << job_app.handle
    end
    handles
  end

  def create_linkedin_education(education_hash, user)
    resume_education = UserEducation.where(:handle => user.handle, :name => education_hash['schoolName']).to_a[0]
    unless resume_education.blank?
      return
    end

    resume_education = UserEducation.new
    resume_education.handle = user.handle
    unless education_hash['degree'].blank?
      resume_education.degree = education_hash['degree']
    end
    unless education_hash['startDate'].blank?
      resume_education.start_year = education_hash['startDate']['year']
    end

    unless education_hash['endDate'].blank?
      resume_education.end_year = education_hash['endDate']['year']
    end

    unless education_hash['fieldOfStudy'].blank?
      resume_education.major = education_hash['fieldOfStudy']
    end

    unless education_hash['schoolName'].blank?
      resume_education.name = education_hash['schoolName']
    end
    profile = get_user_profile_or_new(user.handle)
    profile.push(:user_edu_ids, resume_education[:_id])
    profile.save
    resume_education.save
  end

  def create_linkedin_publication(publication_hash, user)
    resume_publication = UserPublication.where(:handle => user.handle, :title => publication_hash['title']).to_a[0]
    unless resume_publication.blank?
      return
    end
    resume_publication = UserPublication.new
    resume_publication.handle = user.handle
    unless publication_hash['title'].blank?
      resume_publication.title = publication_hash['title']
    end
    unless publication_hash['date'].blank?
      resume_publication.year = publication_hash['date']['year']
    end
    profile = get_user_profile_or_new(user.handle)
    profile.push(:user_publication_ids, resume_publication[:_id])
    profile.save
    resume_publication.save
  end

  def create_linkedin_course(course_hash, user)
    course_title = ''
    if course_hash['number'].blank?
      course_title = course_hash['name']
    else
      course_title = "#{course_hash['name']} #{course_hash['number']}"
    end
    resume_course= UserCourse.where(:id => user.id, :title => course_title).to_a[0]
    unless resume_course.blank?
      return
    end
    resume_course = UserCourse.new
    resume_course.handle = user.handle
    unless course_hash['name'].blank?
      resume_course.title = course_title
      resume_course.semester = 'Fall'
      resume_course.year = Time.now.year
    end
    profile = get_user_profile_or_new(user.handle)
    profile.push(:user_course_ids, resume_course[:_id])
    profile.save
    resume_course.save
  end

  def create_linkedin_experience(experience, user)
    resume_work= UserWork.where(:id => user.id, :company => experience['company']['name'], :title => experience['title']).to_a[0]
    unless resume_work.blank?
      return
    end
    resume_work = UserWork.new
    resume_work.handle = user.handle
    unless experience['title'].blank?
      resume_work.title = experience['title']
    end
    unless experience['startDate'].blank?
      resume_work.start_year = experience['startDate']['year']
      resume_work.start_month = get_month(experience['startDate']['month'])
    end
    unless experience['endDate'].blank?
      resume_work.end_year = experience['endDate']['year']
      resume_work.end_month = get_month(experience['endDate']['month'])
    end

    unless experience['company'].blank?
      resume_work.company = experience['company']['name']
    end

    unless experience['summary'].blank?
      resume_work.description = experience['summary']
    end
    profile = get_user_profile_or_new(user.handle)
    profile.push(:user_work_ids, resume_work[:_id])
    profile.save
    resume_work.save
  end

  def create_linkedin_internship(internship, user)
    resume_intern = UserInternship.where(:id => user.id, :company => internship['company']['name'], :title => internship['title']).to_a[0]
    unless resume_intern.blank?
      return
    end
    resume_intern = UserInternship.new
    resume_intern.handle = user.handle
    unless internship['title'].blank?
      resume_intern.title = internship['title']
    end
    unless internship['startDate'].blank?
      resume_intern.start_year = internship['startDate']['year']
      resume_intern.start_month = get_month(internship['startDate']['month'])
    end
    unless internship['endDate'].blank?
      resume_intern.end_year = internship['endDate']['year']
      resume_intern.end_month = get_month(internship['endDate']['month'])
    end

    unless internship['company'].blank?
      resume_intern.company = internship['company']['name']
    end

    unless internship['summary'].blank?
      resume_intern.description = internship['summary']
    end
    profile = get_user_profile_or_new(user.handle)
    profile.push(:user_internship_ids, resume_intern[:_id])
    profile.save
    resume_intern.save
  end

  def create_linkedin_connection(connection_hash, current_user)
    if connection_hash.blank?
      return
    end
    linkedin_connection = SocialConnection.new

    begin
      linkedin_connection.connected_handle = current_user.handle
      linkedin_connection.first_name = connection_hash['first_name']
      linkedin_connection.last_name = connection_hash['last_name']
      linkedin_connection.headline = connection_hash['headline']
      linkedin_connection.industry = connection_hash['industry']
      linkedin_connection.picture_url = connection_hash['picture_url']
      unless connection_hash['location'].blank?
        linkedin_connection.location_name = connection_hash['location']['name']
        linkedin_connection.country = connection_hash['location']['country']['code']
      end
    rescue Exception => ex
      return
    end

    linkedin_connection.save
  end

  def recommendations_by_job(job, result_count=10)
    tags = job[:tags]
    # boosting works only for integer values so converting the probabilities into integers with precision = 10^-3
    precision = 100
    if tags.class() == Array
      tags = Hash[tags]
    end
    tags = tags.each { |k, v| tags[k] = (v * precision).round() }
    boost = tags.map { |k, v| {value: k, factor: v} }
    majors = job[:majors]
    schools = job[:schools]
    applied_users = get_users_applied(job)
    if applied_users.blank?
      applied_users = []
    end
    search_keywords = tags.map{|k,v| "\"#{k}\""}.join(' ')
    # filter results corresponding to what is available to the school.
    query = Profile.search search_keywords, operator: "or", explain: false, execute: false,
                           where: {school: schools, # in any one of the schools
                                   major: majors,
                                   handle: {not: applied_users}},
                       # matching skills and company name is most important. Then Title then location.
                       fields: %W(
                         tags^10
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

  def recommend_similar_profile(profile, limit = 5)
    # limiting profile to the same school as the user
    if profile.blank? || profile.handle.blank?
      return []
    end
    user = User.find_by(handle: profile.handle)
    if user.blank?
      return []
    end

    school = user.school.downcase
    recommended_profiles = profile.similar where: {school: school, public: true},
                                           boost_where: {
                                               major: {value: user.major_id, factor: 1},
                                               profile_picture_blank: {value: false, factor: 10}
                                           },
                                           limit: limit
    return recommended_profiles.to_a
  end

end