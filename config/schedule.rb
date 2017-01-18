require 'active_support/all'
set :environment, 'production'
set :output, 'log/cron_log.log'
# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron
Time.zone = 'US/Pacific'
# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

# updating the insights data
#every 1.days do
#  rake 'generate_insights:update_profile_view_counts'
#end

# every :day, :at => Time.zone.parse('8:00 am').localtime do
#   rake 'inactive_user_job_email:send_daily_job_invitation_major_known'
# end

# sending the email verification reminder email only once
# every '* 9 1 6 *' do
#   rake 'user_email:email_verification_reminder'
# end

# running for two days at 10:00 AM
# every '* 10 1,2 6 *' do
#   rake 'user_email:email_meed_fair_jobs_new_user'
#end

# sending weekly job digest email on sundays
# every :sunday, :at => '10am' do
#   rake 'digest_email:send_weekly_digest_email'
# end

# sending user_course_reviews job once
# every '0 10 20 7 *' do
#   rake 'user_activity:send_course_review_invitation'
# end

# # #9 am PST
# every 1.day, :at => Time.zone.parse('9:00 am').localtime do
#   rake 'user_email:send_inactive_user_email[0,2,0,cmu,sci_comp]'
#   rake 'user_email:send_inactive_user_email[0,2,0,cmu,eng_electrical]'
#   rake 'user_email:send_inactive_user_email[0,2,0,gatech,sci_comp]'
#   rake 'user_email:send_inactive_user_email[0,2,0,gatech,eng_electrical]'
#   rake 'user_email:send_inactive_user_email[0,2,0,gatech,eng_comp]'
#   rake 'user_email:send_inactive_user_email[0,2,0,cmu,eng_comp]'
#   rake 'user_email:send_inactive_user_email[0,2,0,gatech,eng_computer_software]'
#   rake 'user_email:send_inactive_user_email[0,2,0,cmu,eng_computer_software]'
# end
#
# # #2 pm PST
# every 1.day, :at => Time.zone.parse('2:00 pm').localtime do
#   rake 'user_email:send_inactive_user_email[0,2,0,cmu,sci_comp]'
#   rake 'user_email:send_inactive_user_email[0,2,0,cmu,eng_electrical]'
#   rake 'user_email:send_inactive_user_email[0,2,0,gatech,sci_comp]'
#   rake 'user_email:send_inactive_user_email[0,2,0,gatech,eng_electrical]'
#   rake 'user_email:send_inactive_user_email[0,2,0,gatech,eng_comp]'
#   rake 'user_email:send_inactive_user_email[0,2,0,cmu,eng_comp]'
#   rake 'user_email:send_inactive_user_email[0,2,0,gatech,eng_computer_software]'
#   rake 'user_email:send_inactive_user_email[0,2,0,cmu,eng_computer_software]'
# end
#
# # #2 pm PST
# every 1.day, :at => Time.zone.parse('2:00 pm').localtime do
#   rake 'user_email:send_inactive_user_email[0,2,0,cmu,sci_comp]'
#   rake 'user_email:send_inactive_user_email[0,2,0,cmu,eng_electrical]'
#   rake 'user_email:send_inactive_user_email[0,2,0,gatech,sci_comp]'
#   rake 'user_email:send_inactive_user_email[0,2,0,gatech,eng_electrical]'
#   rake 'user_email:send_inactive_user_email[0,2,0,gatech,eng_comp]'
#   rake 'user_email:send_inactive_user_email[0,2,0,cmu,eng_comp]'
#   rake 'user_email:send_inactive_user_email[0,2,0,gatech,eng_computer_software]'
#   rake 'user_email:send_inactive_user_email[0,2,0,cmu,eng_computer_software]'
# end
# #
# # #6 pm PST
# every 1.day, :at => Time.zone.parse('6:00 pm').localtime do
#   rake 'user_email:send_inactive_user_email[0,2,0,cmu,sci_comp]'
#   rake 'user_email:send_inactive_user_email[0,2,0,cmu,eng_electrical]'
#   rake 'user_email:send_inactive_user_email[0,2,0,gatech,sci_comp]'
#   rake 'user_email:send_inactive_user_email[0,2,0,gatech,eng_electrical]'
#   rake 'user_email:send_inactive_user_email[0,2,0,gatech,eng_comp]'
#   rake 'user_email:send_inactive_user_email[0,2,0,cmu,eng_comp]'
#   rake 'user_email:send_inactive_user_email[0,2,0,gatech,eng_computer_software]'
#   rake 'user_email:send_inactive_user_email[0,2,0,cmu,eng_computer_software]'
# end
# #
# # #7 pm PST
# every 1.day, :at => Time.zone.parse('7:00 pm').localtime do
#   rake 'user_email:send_inactive_user_email[0,2,0,cmu,sci_comp]'
#   rake 'user_email:send_inactive_user_email[0,2,0,cmu,eng_electrical]'
#   rake 'user_email:send_inactive_user_email[0,2,0,gatech,sci_comp]'
#   rake 'user_email:send_inactive_user_email[0,2,0,gatech,eng_electrical]'
#   rake 'user_email:send_inactive_user_email[0,2,0,gatech,eng_comp]'
#   rake 'user_email:send_inactive_user_email[0,2,0,cmu,eng_comp]'
#   rake 'user_email:send_inactive_user_email[0,2,0,gatech,eng_computer_software]'
#   rake 'user_email:send_inactive_user_email[0,2,0,cmu,eng_computer_software]'
# end
# #
# # #11 am PST
# every 1.day, :at => Time.zone.parse('11:20 am').localtime do
#   rake 'user_email:send_inactive_user_email[0,2,0,washington,sci_comp]'
#   rake 'user_email:send_inactive_user_email[0,2,0,washington,eng_electrical]'
#   rake 'user_email:send_inactive_user_email[0,2,0,ucla,sci_comp]'
#   rake 'user_email:send_inactive_user_email[0,2,0,washington,eng_comp]'
#   rake 'user_email:send_inactive_user_email[0,2,0,ucla,sci_comp]'
#   rake 'user_email:send_inactive_user_email[0,2,0,washington,eng_computer_software]'
# end
# #
# # #6 pm PST
# every 1.day, :at => Time.zone.parse('6:00 pm').localtime do
#   rake 'user_email:send_inactive_user_email[0,2,0,washington,sci_comp]'
#   rake 'user_email:send_inactive_user_email[0,2,0,washington,eng_electrical]'
#   rake 'user_email:send_inactive_user_email[0,2,0,ucla,sci_comp]'
#   rake 'user_email:send_inactive_user_email[0,2,0,washington,eng_comp]'
#   rake 'user_email:send_inactive_user_email[0,2,0,ucla,sci_comp]'
#   rake 'user_email:send_inactive_user_email[0,2,0,washington,eng_computer_software]'
# end
# #
# # #7 pm PST
# every 1.day, :at => Time.zone.parse('7:00 pm').localtime do
#   rake 'user_email:send_inactive_user_email[0,2,0,washington,sci_comp]'
#   rake 'user_email:send_inactive_user_email[0,2,0,washington,eng_electrical]'
#   rake 'user_email:send_inactive_user_email[0,2,0,ucla,sci_comp]'
#   rake 'user_email:send_inactive_user_email[0,2,0,washington,eng_comp]'
#   rake 'user_email:send_inactive_user_email[0,2,0,ucla,sci_comp]'
#   rake 'user_email:send_inactive_user_email[0,2,0,washington,eng_computer_software]'
# end
# #
# # #8 pm PST
# every 1.day, :at => Time.zone.parse('8:00 pm').localtime do
#   rake 'user_email:send_inactive_user_email[0,2,0,washington,sci_comp]'
#   rake 'user_email:send_inactive_user_email[0,2,0,washington,eng_electrical]'
#   rake 'user_email:send_inactive_user_email[0,2,0,ucla,sci_comp]'
#   rake 'user_email:send_inactive_user_email[0,2,0,washington,eng_comp]'
#   rake 'user_email:send_inactive_user_email[0,2,0,ucla,sci_comp]'
#   rake 'user_email:send_inactive_user_email[0,2,0,washington,eng_computer_software]'
# end
# #
# # #2 pm PST
# every 1.day, :at => Time.zone.parse('2:00 pm').localtime do
#   rake 'user_email:send_inactive_user_email[0,2,0,washington,sci_comp]'
#   rake 'user_email:send_inactive_user_email[0,2,0,washington,eng_electrical]'
#   rake 'user_email:send_inactive_user_email[0,2,0,ucla,sci_comp]'
#   rake 'user_email:send_inactive_user_email[0,2,0,washington,eng_comp]'
#   rake 'user_email:send_inactive_user_email[0,2,0,ucla,sci_comp]'
#   rake 'user_email:send_inactive_user_email[0,2,0,washington,eng_computer_software]'
# end

# send daily digest email
#every 1.day, :at => Time.zone.parse('7:00 pm').localtime do
#  rake 'digest_email:send_daily_digest_email'
#end

# will send on 1,2 of every month and year
# every "0 0 2 ? * *" do
#   # Sending weekly digest email every 2 weeks on wednesday
#   rake "digest_email:send_weekly_digest_email"
# end
#
# every 2.days do
#   # sending email to incomplete users every 2 weeks
#   rake "incomplete_resume_email:send_incomplete_resume_email"
# end
#
# every 2.days do
#   rake "model_updates::update_profile_score_model"
#   rake "model_updates::update_profile_score"
# end
