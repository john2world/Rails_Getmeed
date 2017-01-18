namespace :inactive_user_job_email do
  task :send_inactive_user_email, [:skip, :limit, :company_id, :school_id, :major_id, :with_media] => :environment do |t, args|
    email_unsub_emails = Array.[]
    email_unsubs = EmailUnsubscribe.all
    email_unsubs.each do |email_unsub|
      email_unsub_emails << email_unsub.id
    end

    last_skip_num = $redis.get("#{args.school_id}_#{args.major_id}_skip")
    last_limit_num = $redis.get("#{args.school_id}_#{args.major_id}_limit")
    if last_skip_num.blank?
      $redis.set("#{args.school_id}_#{args.major_id}_skip", args.skip)
      last_skip_num = args.skip.to_i
    else
      last_skip_num = last_skip_num.to_i
    end


    if last_limit_num.blank?
      $redis.set("#{args.school_id}_limit", args.limit)
      last_limit_num = args.limit.to_i
    else
      last_limit_num = last_limit_num.to_i
    end

    batch_users = User.where(_id: /#{args.school_id}.edu/i, active: false, :major_id => args.major_id).order_by([:create_dttm, -1]).skip(last_skip_num).limit(last_limit_num).to_a
    if batch_users.blank?
      batch_users = User.where(_id: /#{args.school_id}.edu/i, active: false).order_by([:create_dttm, -1]).skip(last_skip_num).limit(last_limit_num).to_a
    end

    batch_users.each do |user|
      if user.blank?
        next
      end
      if email_unsub_emails.include? user.id
        next
      end
      # if Rails.env.development?
      #   test_code(args.company_id, user, (args.with_media.eql? 'true'))
      # else
      #   EmailJobInvitationWorker.perform_async(user.id, args.company_id, (args.with_media.eql? 'true'))

      # end
    end
    last_skip_num = last_skip_num + last_limit_num
    $redis.set("#{args.school_id}_#{args.major_id}_skip", last_skip_num.to_s)
  end
  TargetSchools = ["usc", "ucla", "uw", "utexas", "berkeley", "cornell", "rice", "gatech", "nyu", "cmu"]
  task send_daily_job_invitation_major_known: :environment do
    include UsersHelper
    target_count = 200
    # selecting users where we know the majors
    users = User.where(active: false).where(:major_id.ne => nil).select{|user| TargetSchools.include? get_school_handle_from_email(user[:email])};

    job_histogram = get_popular_job_histogram()
    job_histogram = get_boost_job_histogram.merge(job_histogram){|k, v1, v2| v1.concat(v2)}
    sampled_users = users.sample(target_count)
    sampled_users.each do |user|
      # get the best job for that school and major
      key = [get_school_handle_from_email(user[:email]), user[:major_id]]
      if job_histogram.has_key? key
        # take the sample from one 20 of the top jobs
        selected_job = job_histogram[key].take(20).sample()[0]
        puts "Sending job: #{selected_job} to user: #{user[:_id]}"
        EmailJobInvitationWorker.new.perform(user[:email], selected_job)
      end
    end
  end

  def test_code(company_id, user, with_media)
    recent_job = Job.where(company_id: company_id, live: true).order_by([:create_dttm, -1]).first
    company = Company.find(company_id)
    stuff_company_job(recent_job, company)
    recent_job[:author] = EnterpriseUser.find(recent_job[:email])
    Notifier.email_job_invitation(user, 'testtoken', recent_job, with_media).deliver
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

  def get_popular_job_histogram()
    # first get counts per job id
    job_id_counts = JobApplicant.all().to_a.group_by{|a| a[:job_id]}.map{|k,v| [k, v.count()]}.sort_by{|k, v| -v};
    school_major_job_counts = []
    job_id_counts.each do |job_count|
      job = Job.find(job_count[0])
      if job.blank? || !job[:live] || (job[:schools] & TargetSchools).count() == 0
        next
      end
      school_major_pair = job[:schools].product(job[:majors])
      # adding the pair as key and job_id and count as value
      school_major_job_counts.concat(school_major_pair.map{|school_major_pair| [school_major_pair, job_count]})
    end
    # group by school_major_pair
    t = school_major_job_counts.group_by{|c| c[0]}
    t.each{|k,v| t[k] = v.map{|_,subv| subv}}
    return t
  end

  def get_boost_job_histogram()
    hash = {}
    jobs = Job.where(:manual_boost.gt => 0).desc(:create_dttm);
    jobs.each do |job|
      unless job[:schools].blank? || job[:majors].blank?
        job[:schools].product(job[:majors]).each do |key|
          if TargetSchools.include? key[0]
            unless hash.has_key? key
              hash[key] = []
            end
            hash[key].push([job[:_id], job[:manual_boost]])
          end
        end
      end
    end
    return hash
  end
end