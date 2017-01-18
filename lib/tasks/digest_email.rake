namespace :digest_email do
  task send_daily_digest_email: :environment do
    User.where(:active => true).to_a.each do |user|
      if user[:handle].blank?
        next
      end

      # send only if the user setting is daily
      setting = UserSettings.find(user[:handle]);
      if setting.blank? || setting.email_frequency != :DAILY
        next
      end

      if user.major.eql? 'Computer Science' or user.major.eql? 'Electrical Engineering' or user.major.eql? 'Computer Engineering'
        EmailMeedPostStatsWorker.perform_async(user.id)
      end
    end
  end
  # should go out once a week.
  task send_weekly_digest_email: :environment do
    User.where(:active => true).to_a.each do |user|
      if user[:handle].blank?
        next
      end

      # send only if the user setting is weekly
      setting = UserSettings.find(user[:handle]);
      if setting.blank? || setting.email_frequency != :WEEKLY
        next
      end

      if user.major.eql? 'Computer Science' or user.major.eql? 'Electrical Engineering' or user.major.eql? 'Computer Engineering'
        EmailWeeklyDigestWorker.perform_async(user.id)
      end
    end
  end

  # Weekly job digest email, sent once a week.
  task send_weekly_job_digest_email: :environment do
    User.where(:active => true).to_a.each do |user|
      if user[:handle].blank?
        next
      end

      # for now ignoring the user weekly settings for this
      EmailWeeklyJobDigestWorker.perform_async(user.id)
    end
  end
end