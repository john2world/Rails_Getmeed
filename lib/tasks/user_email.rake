namespace :user_email do
  task send_meed_fair_invitation: :environment do
    include NotificationsManager
    YEARS_ORDER = ["2017", "2016", "2014", "2015"]
    index = $redis.get("meed_fair_job_invitations_year_index").to_i
    if (index < (YEARS_ORDER.count() - 1))
      year = YEARS_ORDER[index]
      users = User.where(active: true).where(year: year)
      users.each do |user|
        EmailMeedFairExistingUsers.perform_async(user[:_id])
      end
    else
      users = User.where(active: true).where(:year.nin => YEARS_ORDER)
      users.each do |user|
        # proceed only if the mail is not unsubscribed
        if check_email_unsubscribed(user.id.strip())
          EmailMeedFairExistingUsers.perform_async(user[:_id].strip())
        end
      end
    end
    $redis.set("meed_fair_job_invitations_year_index", index + 1)
  end

  task send_meed_fair_invitation_newuser: :environment do
    include NotificationsManager
    puts "executing task: send_meed_fair_invitation_newuser"
    Schools = ["berkeley", "brown", "caltech", "cmu", "columbia", "cornell", "duke", "gatech", "harvard", "illinois",
               "mit", "northwestern", "nyu", "princeton", "rice", "stanford", "uci", "ucla", "ucsd", "utexas", "ufl",
               "umass", "umich", "upenn", "usc", "washington", "yale"]
    users = User.where(active: false).select{|user| Schools.include? get_school_handle_from_email(user.email)};
    index = $redis.get("meed_fair_job_invitations_newusers_index").to_i
    puts "send_meed_fair_invitation_newuser: index: #{index}"
    case index
      when 0
        # get first half of ucla users
        users = User.where(active: false).select{|user| get_school_handle_from_email(user.email) == 'ucla'}
        count = users.count()
        users = users.take((count/2).round)
      when 1
        # get second half of ucla
        users = User.where(active: false).select{|user| get_school_handle_from_email(user.email) == 'ucla'}
        count = users.count()
        users = users.drop((count/2).round)
      when 2
        # get from gatech
        users = User.where(active: false).select{|user| get_school_handle_from_email(user.email) == 'gatech'}
      when 3
        # get from cmu and wash
        users = User.where(active: false).select{|user| ['cmu', 'washington'].include? get_school_handle_from_email(user.email)}
      when 4
        # get from everywhere else
        users = User.where(active: false).select{|user| !(['ucla', 'gatech', 'cmu', 'washington'].include? get_school_handle_from_email(user.email))}
    end
    puts "send_meed_fair_invitation_newuser: users: #{users.count()}"
    # send email to all these users
    users.each do |user|
      # proceed only if the mail is not unsubscribed
      if check_email_unsubscribed(user.id.strip())
        EmailMeedFairNewUsers.perform_async(user[:_id].strip())
      end
    end
    puts "send_meed_fair_invitation_newuser: Done"
    $redis.set("meed_fair_job_invitations_newusers_index", index + 1)
  end

  task email_verification_reminder: :environment do
    include NotificationsManager
    users = User.where(:create_dttm.gt => '2015-01-01', :create_dttm.lt => Date.today-1, active: false);
    users.each do |user|
      # proceed only if the mail is not unsubscribed
      if check_email_unsubscribed(user.id.strip())
        EmailVerifyReminderWorker.perform_async(user[:_id].strip())
      end
    end
  end

  task email_meed_fair_jobs_new_user: :environment do
    include NotificationsManager
    # we have year and major information for UW and CMU so sending the emails to them
    index = $redis.get("meed_fair_job_new_users_index").to_i
    users = []
    case index
      when 0
        # send emails to CMU
        users = User.where(active: false, :year.ne => nil, :major_id.ne => nil).select{|user| get_school_handle_from_email(user.email) == 'cmu'}
      when 1
        # send emails to UW
        users = User.where(active: false, :year.ne => nil, :major_id.ne => nil).select{|user| get_school_handle_from_email(user.email) == 'uw'}
    end
    # send job emails to users
    users.each do |user|
      # proceed only if the mail is not unsubscribed
      if check_email_unsubscribed(user.id.strip())
        EmailMeedFairExistingUsers.perform_async(user[:_id].strip())
      end
    end
    $redis.set("meed_fair_job_new_users_index", index + 1)
  end
end