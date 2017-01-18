class MigrationsController < ApplicationController
  include ProfilesHelper
  include JobsManager
  include SchoolsManager
  include UsersManager
  include FeedItemsManager

  def migrate_primary_emails
    unless authenticate(current_user)
      @un_auth = true
      return
    end
    users = admin_all_users
    users.each do |user|
      unless user[:primary_email].blank?
        user.email = user[:primary_email]
        user.save
      end
    end
  end


  def migrate_resume_score
    unless authenticate(current_user)
      @un_auth = true
      return
    end
    profiles = Profile.all
    @count = 0
    profiles.each do |profile|
      update_score(profile)
      profile.save!
      @count = @count + 1
    end
  end

  def migrate_seed_activity_feed
    unless authenticate(current_user)
      @un_auth = true
      return
    end
    courses_group_one= UserCourse.all.order_by([:_id, -1]).limit(500)


    works_group_one = UserWork.all.order_by([:_id, -1]).limit(500)


    publications_group_one = UserPublication.all.order_by([:_id, -1]).limit(500)


    internships_group_one = UserInternship.all.order_by([:_id, -1]).limit(500)


    edus_group_one = UserEducation.all.order_by([:_id, -1]).limit(500)

    all_groups = (courses_group_one << works_group_one << publications_group_one << internships_group_one << edus_group_one).flatten

    @count = 0
    all_groups.each do |profile_item|
      case profile_item.class.name
        when 'UserCourse'
          migrate_create_feed_item_user(profile_item.handle, profile_item.id, UserFeedTypes::COURSEWORK)
        when 'UserWork'
          migrate_create_feed_item_user(profile_item.handle, profile_item.id, UserFeedTypes::USERWORK)
        when 'UserInternship'
                  migrate_create_feed_item_user(profile_item.handle, profile_item.id, UserFeedTypes::INTERNSHIP)
        when 'UserPublication'
                  migrate_create_feed_item_user(profile_item.handle, profile_item.id, UserFeedTypes::PUBLICATION)
        when 'UserEdu'
                  migrate_create_feed_item_user(profile_item.handle, profile_item.id, UserFeedTypes::EDUCATION)
      end
    end
  end

  def migrate_public_feed_create_time
    unless authenticate(current_user)
      @un_auth = true
      return
    end

    public_feed_items = FeedItems.where(privacy: 'everyone')
    @count = 0
    public_feed_items.each do |feed|
      feed[:create_time] = Time.now
      feed.save
      @count = @count + 1
    end

    render :template => 'migrations/migrate_seed_activity_feed'
  end

  def migrate_create_feed_item_user(handle, subject_id, type)
    feed_item = FeedItems.where(poster_id: handle, subject_id: subject_id, type: UserFeedTypes.const_get(type.upcase).downcase)
    if feed_item.blank?
      @count = @count + 1
    else
      return
    end
    if handle.blank? or subject_id.blank? or type.blank?
         return
       end

       user = get_user_by_handle(handle)
       if user.blank? or user.major_id.blank?
         return
       end
       feed_item = FeedItems.new
       feed_item.poster_id = handle
       feed_item.privacy = user.major_id
       feed_item.poster_type = 'user'
       feed_item.create_time = Moped::BSON::ObjectId(subject_id).generation_time
       feed_item.poster_school = get_school_handle_from_email(user.id)
       case UserFeedTypes.const_get(type.upcase)
         when UserFeedTypes::INTERNSHIP
           internship = get_user_internship(subject_id)
           unless internship.blank?
             feed_item.title = internship.company
             feed_item.subject_id = internship.id
             description = "#{internship.description}"
             unless internship.skills.blank?
               description = "#{internship.description} <br/> <strong>Skills —  #{internship.skills} </strong>"
             end
             unless internship.link.blank?
               description = "#{description} <br/>#{anchorify_link(internship.link)}"
             end
             feed_item.description = description
             feed_item.type = UserFeedTypes::INTERNSHIP.downcase
           end
         when UserFeedTypes::USERWORK
           user_work = get_user_work(subject_id)
           unless user_work.blank?
             feed_item.title = "#{user_work.company}, #{user_work.title}"
             feed_item.subject_id = user_work.id
             description = "#{user_work.description}"
             unless user_work.skills.blank?
               description = "#{user_work.description} <br/> <strong>Skills —  #{user_work.skills} </strong>"
             end
             unless user_work.link.blank?
               description = "#{description} <br/>#{anchorify_link(user_work.link)}"
             end
             feed_item.description = description
             feed_item.type = UserFeedTypes::USERWORK.downcase
           end
         when UserFeedTypes::COURSEWORK
           user_course = get_user_course(subject_id)
           unless user_course.blank?
             feed_item.title = user_course.title
             feed_item.subject_id = user_course.id
             description = "#{user_course.description}"
             unless user_course.skills.blank?
               description = "#{user_course.description} <br/> <strong>Skills —  #{user_course.skills} </strong>"
             end
             unless user_course.link.blank?
               description = "#{description} <br/>#{anchorify_link(user_course.link)}"
             end
             feed_item.description = description
             feed_item.type = UserFeedTypes::COURSEWORK.downcase
           end

         when UserFeedTypes::EDUCATION
           user_edu = get_user_edu(subject_id)
           unless user_edu.blank?
             feed_item.title = user_edu.name
             feed_item.subject_id = user_edu.id
             feed_item.description = user_edu.major
             feed_item.type = UserFeedTypes::EDUCATION.downcase
           end

         when UserFeedTypes::PUBLICATION
           user_publication = get_user_publication(subject_id)
           unless user_publication.blank?
             feed_item.title = user_publication.title
             feed_item.subject_id = user_publication.id
             description = "#{user_publication.description}"
             unless user_publication.link.blank?
               description = "#{description} <br/>#{anchorify_link(user_publication.link)}"
             end
             feed_item.description = description
             feed_item.type = UserFeedTypes::PUBLICATION.downcase
           end
       end
       feed_item.save
       feed_item
  end


  def migrate_jobs_allschools
    unless authenticate(current_user)
      @un_auth = true
      return
    end

    schools = admin_all_schools
    majors = admin_all_majors
    user_jobs = Array.[]
    UserJobs.each do |db_user_job|
      user_jobs << db_user_job.user_job_id
    end

    @count = 0
    schools.each do |school|
      majors.each do |major|
        user_job = get_feed_key(school.handle, major.id)
        unless user_jobs.include? user_job
          mother_user_job = UserJobs.find("usc_#{major.id}")

          unless mother_user_job.blank?
            new_user_job = UserJobs.new(:user_job_id => user_job)
            new_user_job.job_ids = mother_user_job.job_ids
            new_user_job.save
            @count = @count + 1
          end
        end
      end
    end
  end

  def migrate_job_applications
    unless authenticate(current_user)
      @un_auth = true
      return
    end

    job_apps = JobApplicant.order_by([:create_dttm, -1]).limit(100).to_a
    @count = 1
    job_apps.each do |jobs_app|
      if @count > 100
        return
      end
      job = get_job_by_hash(jobs_app.job_id)
      if job.blank?
        job = get_job_by_id(jobs_app.job_id)
      end
      @count = @count + 1
      if job.blank?
        next
      end
      if job[:email_notifications].blank? or job[:email_notifications]
        # EmailJobNewApplicantWorker.perform_async(job.id.to_s, job[:email], job[:title], jobs_app.handle)
      end
    end
  end

end