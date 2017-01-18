namespace :thanks_giving_email do
  task :send_thanksgiving_email, [:skip, :limit] => :environment do |t, args|

    email_unsub_emails = Array.[]
    email_unsubs = EmailUnsubscribe.all
    email_unsubs.each do |email_unsub|
      email_unsub_emails << email_unsub.id
    end

    batch_users = User.where(active: true).order_by([:create_dttm, -1]).skip(args.skip).limit(args.limit).to_a
    batch_users.each do |user|
      if user.blank?
        next
      end

      if email_unsub_emails.include? user.id
        next
      end
      # test_thanksgiving
      EmailThanksGivingWorker.perform_async(user.id)
      sleep(5.seconds)
    end
  end
end

def test_thanksgiving
  user = User.find('vadrevu@usc.edu')
  Notifier.email_thanksgiving(user).deliver
end