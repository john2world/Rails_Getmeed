class Notifier < ActionMailer::Base
  include SendGrid
  include LinkHelper
  include UsersHelper
  include CommonHelper
  include JobsManager
  include CrmHelper
  include CrmManager
  include NotifierHelper
  include ReviewsHelper
  include EnterpriseUsersManager
  include MeedPointsTransactionManager

  require 'socket'
  sendgrid_category :use_subject_lines
  sendgrid_enable :ganalytics, :opentrack, :clicktrack
  default :from => 'Meed <notification@getmeed.com>'
  DEFAULT_ADDRESS = 'Meed <notification@getmeed.com>'
  ACTIVITY_ADDRESS = 'Meed Activity <activity@getmeed.com>'
  JOE_ADDRESS = 'Joe Cussack <joe@getmeed.com>'
  DEFAULT_TALENT_ADDRESS = 'Meed Talent <notification@getmeed.com>'
  TEST_ADDRESS = 'ravi@getmeed.com'

  # send a signup email to the user, pass in the user object that contains the user's email address

  def email_influencer_question_submission(influencer, submittor, content)
    if influencer.blank? or submittor.blank? or content.blank?
      return
    end
    @commentor = submittor
    @feed_item = content
    @user = influencer
    sendgrid_category "meed_activity_ask_influencer"
    @url = get_story_url(content.poster_id, content.subject_id, content.create_time)
    subject = "#{submittor.first_name} asked you a question on Meed!"
    send_email(ACTIVITY_ADDRESS, influencer.email, subject)

  end

  def email_leaderboard_top_ten_position(user)
    @user = user
    if user.blank?
      return
    end
    @referrer_url = "#{get_root_url}?referrer=#{@user.handle}"
    @leaderboard_url = get_leaderboard_url
    subject = "[Meederboard Top 10] Your current position is #{user[:rank]}"
    # send_email(ACTIVITY_ADDRESS, user.email, subject)
  end

  def company_email_verification(email, token)
    sendgrid_category "enterprise_email_verification"
    @hostname = get_host_name_url
    @url = company_verified_url(token: token)
    @token = token
    @email = email
    # @late_verify = late_verify
    send_email(DEFAULT_ADDRESS, @email, 'Please verify your email')
  end

  def email_verification(email, token)
    sendgrid_category "email_verification"
    @hostname = get_host_name_url
    @url = get_user_verification_url(token)
    @token = token
    @email = email
    @name = get_handle_from_email(email)
    send_email(DEFAULT_ADDRESS, @email, 'Please verify your email')
  end

  def waitlist_email_verification(email, token)
    sendgrid_category "waitlist_email_verification"
    @hostname = get_host_name_url
    @url = get_user_waitlist_verification_url(token)
    @token = token
    @email = email
    @name = get_handle_from_email(email)
    send_email(DEFAULT_ADDRESS, @email, 'Please verify your email', 'email_verification')
  end


  # send a reminder email to users
  def email_verification_reminder(email, token)
    sendgrid_category 'email_verification_reminder'
    user = get_user_by_email(email)
    @hostname = get_host_name_url
    @url = get_user_verification_url(token)
    @token = token
    @email = email
    @name = get_handle_from_email(email)
    @unsubscribe_link = get_unsubscribe_link('signup', user.id)
    send_email(DEFAULT_ADDRESS, @email, 'Don\'t forget to complete your signup', 'email_verification')
  end

  def email_thanksgiving(user)
    unless check_email_notification_eligibility(user)
      return
    end
    @user = user
    @url = get_thanksgiving_claim_url(user.handle)
    email = user.id
    @unsubscribe_link = get_unsubscribe_link('thanks_giving_2014', user.id)
    unless user.primary_email.blank?
      email = user.primary_email
    end
    send_email(DEFAULT_ADDRESS, email, 'Happy Thanksgiving! - Your free personalized Tee')
  end

  def email_welcome(user)
    if user.blank?
      return
    end
    @user = user
    @referrer_url = "#{get_root_url}?referrer=#{@user.handle}"
    sendgrid_category "email_welcome"
    send_email(DEFAULT_ADDRESS, user.email, "Welcome to Meed Community, #{user.first_name}!")
  end

  def email_waitlist_welcome(user)
    if user.blank?
      return
    end
    @user = user
    @campaign_type=''
    unless @user.meta_data.blank?
      @campaign_type = @user.meta_data['campaign_type']
    end
    sendgrid_category "email_waitlist_welcome"
    @referral_url = get_need_meed_referral_url(@user.handle, @campaign_type)
    @pseudo_session_url = pseudo_session_profile_edit_url(@user.handle, get_pseduo_session_auth_code(@user))
    send_email(DEFAULT_ADDRESS, @user.email, "Welcome to Meed Community, #{@user.first_name}!")
  end

  def email_waitlist_friend_joined(user, joined_user)
    if user.blank? || joined_user.blank?
      return
    end
    @user = user
    @campaign_type=''
    unless @user.meta_data.blank?
      @campaign_type = @user.meta_data['campaign_type']
    end
    sendgrid_category "email_waitlist_friend_joined"
    @friend_name = joined_user.name
    @friend_count = get_friend_referral_count(user.handle)
    @left_count = MeedPointsTransactionManager::WaitlistFriendReferrerCount - @friend_count
    if @left_count <= 0
      return
    end
    @referral_url = get_need_meed_referral_url(@user.handle, @campaign_type)
    send_email(DEFAULT_ADDRESS, @user.email, "#{@user.first_name}, You Are One Step Closer to Meed!")
  end

  def email_waitlist_friend_activated(user, activated_user)
    if user.blank? || activated_user.blank?
      return
    end
    @activated_user = activated_user
    @user = user
    @campaign_type=''
    unless @user.meta_data.blank?
      @campaign_type = @user.meta_data['campaign_type']
    end
    sendgrid_category "email_waitlist_friend_activated"
    @friend_count = get_friend_referral_count(user.handle)
    @left_count = MeedPointsTransactionManager::WaitlistFriendReferrerCount - @friend_count
    if @left_count <= 0
      return
    end
    @referral_url = get_need_meed_referral_url(@user.handle, @campaign_type)
    send_email(DEFAULT_ADDRESS, @user.email, "#{@user.first_name}, #{@activated_user.first_name} just joined Meed!")
  end

  def email_waitlist_reminder(user, reminder_count = 0)
    if user.blank?
      return
    end
    @user = user
    @campaign_type=''
    unless @user.meta_data.blank?
      @campaign_type = @user.meta_data['campaign_type']
    end
    sendgrid_category "email_waitlist_reminder"
    @referral_url = get_need_meed_referral_url(@user.handle, @campaign_type)
    start_count = (reminder_count + 1)*1000
    offset = rand(1..100)
    @count = start_count + (offset * 10)
    @friend_count = get_friend_referral_count(user.handle)
    @left_count = (5 - @friend_count) > 0 ? (5 - @friend_count) : 0
    send_email(DEFAULT_ADDRESS, @user.email, "#{@user.first_name}, Get Instant Access to Meed Now!")
  end

  def email_waitlist_activation(user)
    if user.blank?
      return
    end
    @user = user
    @campaign_type=''
    unless @user.meta_data.blank?
      @campaign_type = @user.meta_data['campaign_type']
    end
    sendgrid_category "email_waitlist_activation"
    @friend_count = get_friend_referral_count(user.handle)
    @left_count = (5 - @friend_count) > 0 ? (5 - @friend_count) : 0
    invitation = get_email_invitation_for_email(user.id)
    if invitation.blank?
      return
    end
    @verification_url = get_user_verification_url(invitation.token)
    @referral_url = get_need_meed_referral_url(@user.handle, @campaign_type)
    send_email(DEFAULT_ADDRESS, @user.email, "#{@user.first_name}, The Wait For Meed is Over!")
  end

  def email_company_resume_view(user_handle, email, company)
    if company.blank?
      return
    end
    # check if user is subscribed to company updates
    user_settings = UserSettings.find(user_handle)
    if user_settings == nil || !user_settings.email_notification_subscription_enabled('company')
      return
    end
    @hostname = get_host_name_url
    @url = get_user_profile_url(user_handle)
    @company = company
    subject = "[Profile Views] #{company.name} has viewed your profile — Keep up to date!"
    logger.info('SENDING COMPANY VIEW EMAIL - ')
    send_email(DEFAULT_ADDRESS, email, subject)
  end

  def email_job_application_view(email, job, view_type)
    # check if user is subscribed to job updates
    user = User.find_by(email: email)
    unless check_email_notification_eligibility(user, 'job')
      return
    end

    @hostname = get_host_name_url
    @insights_url = get_insights_url
    if job.blank?
      company = 'Someone'
    else
      company = job.company
    end
    @subject = company
    if view_type.eql? 'pdf'
      subject = "[Resume Download] #{company} has downloaded your Meed — Check out new insights"
    else
      subject = "[Resume Views] #{company} has opened your application — Check out new insights"
    end
    logger.info('SENDING EMAIL - ')
    send_email(DEFAULT_ADDRESS, email, subject)
  end

  def email_job_confirmation(job, user)
    sendgrid_category "email_job_confirmation"
    @job = job
    @user = user
    # recommending only organic jobs
    @recommended_job = similar_jobs(job, user, 1, true).first
    @company = get_company_by_id(@job.company_id)
    subject = "Your application for #{@job.title}"
    send_email(DEFAULT_ADDRESS, user.email, subject)
  end

  def email_company_view(email, company)
    if email.blank? or company.blank?
      return
    end
    # check if user is subscribed to job updates
    user = User.find_by(email: email)
    unless check_email_notification_eligibility(user, 'company')
      return
    end
    @hostname = get_host_name_url
    @company = company
    @url = get_company_url(company.id)
    subject = "[Company View] #{company.name} just viewed your profile"
    send_email(DEFAULT_ADDRESS, email, subject)
  end

  def email_meed_post_stats(user, popular_feed_items, user_feed_items)

    total_views = 0
    user_feed_items.each do |feed_item|
      view_count = feed_item.view_count.blank? ? 0 : feed_item.view_count
      total_views = total_views + view_count
    end
    @user_feed_items = user_feed_items[0..2]
    @total_views = total_views

    @popular_feed_items = popular_feed_items[0..2]
    @user = user

    @url = get_meed_post_start_url

    subject = 'Your Weekly Meed Submission Stats'
    # send_email(ACTIVITY_ADDRESS, user.email, subject)
  end

  def email_weekly_digest_jobs(user, jobs)
    # check if user is subscribed to social updates
    unless check_email_notification_eligibility(user, 'job')
      return
    end
    @jobs = jobs
    subject = 'Recommended jobs for you this week'
    # There are two variations so choosing randomly.
    variation_id = Random.rand(1...3)
    sendgrid_category "job digest var #{variation_id}"
    template_name = "email_weekly_digest_job_var_#{variation_id}"
    send_email(DEFAULT_ADDRESS, user.email, subject, template_name)
  end

  def email_weekly_digest_feed(user, jobs, feed_items, collection_name='')
    if feed_items.blank? or jobs.blank?
      return
    end
    # check if user is subscribed to social updates
    if Rails.env.development?
      sendgrid_category 'test_meed_weekly_digest'
    else
      sendgrid_category 'meed_weekly_digest'
    end

    if feed_items[0].caption.blank?
      subject = "#{feed_items[0].caption.truncate(50, :omission => '..')}"
    else
      subject = "#{feed_items[0].title.truncate(50, :omission => '..')}"
    end

    @group_name = collection_name
    @user = user
    @feed_items = feed_items.take(3)
    @jobs = jobs.take(3)
    send_email(DEFAULT_ADDRESS, user.email, subject)
  end

  def email_alert_to_answer_question(user, job, question)
    # check if user is subscribed to social updates
    unless check_email_notification_eligibility(user, 'social')
      return
    end
    @user = user
    @question = question
    @landing_url = get_question_url(question.id)
    @job = job
    subject = "[Your application] #{job.company} is requesting you to answer a question"
    send_email(DEFAULT_ADDRESS, user.email, subject)
  end

  def email_password_reset(email, token)
    sendgrid_category "password_reset"
    @hostname = get_host_name_url
    @url = get_user_password_new_url(token)
    @token = token
    @email = email
    send_email(DEFAULT_ADDRESS, @email, 'Reset your password!')
  end

  def email_user_invite_promotion(user)
    @url = get_user_invite_promo_url(user.handle)
    @email = user.email
    @user = user
    @contacts_url = get_authed_contact_import_url
    @contacts_url = get_authed_contact_import_url
    send_email(DEFAULT_ADDRESS, @email, 'Care, Share & win a $250 gift card')
  end

  def email_user_message(to_email, to_enterpriser)
    # check if user is subscribed to message updates
    user = User.find_by(email: to_email)
    unless check_email_notification_eligibility(user, 'job')
      return
    end
    @hostname = get_host_name_url
    @url = get_messages_url
    if to_enterpriser
      @url = get_enterprise_message_url
      if to_email.split('@')[1].eql? 'testcorp.com'
        to_email = 'ravi@getmeed.com'
      end
    end
    @to_enterpriser = to_enterpriser
    send_email(to_enterpriser, to_email, 'You got a message from students on Meed!')
  end

  def email_enterprise_message(message, sender)
    if message.blank? or sender.blank?
      return
    end

    sendgrid_category "meed_message_enterprise"

    # check if user is subscribed to message update
    user = User.find_by(email: message.email)
    unless user.blank?
      user_settings = UserSettings.find(user.handle)
      if user_settings == nil || !user_settings.email_notification_subscription_enabled('message')
        return
      end
    end

    @message = message
    @user = sender
    @url = get_enterprise_message_url
    subject = "#{message.subject}"
    send_email(@user.id, message.email, subject)
  end

  def email_enterprise_invite_work_reference(invite, eu_user, user)
    sendgrid_category "Work Reference Invite"
    if invite.blank?
      return nil
    end

    @work = get_work_from_reference_invite(invite)
    if @work.blank?
      return nil
    end

    @invite = invite
    if invite.reference_email.blank?
      return nil
    end

    @enterprise_user = eu_user
    if @enterprise_user.blank?
      return nil
    end
    @user = user
    @url = url_for(:controller => 'reviews', :action => 'work_reference_invite_view',
                   :invite_id => encode_id(invite.id), :host => ENV['host'])

    subject = "Please write reference for #{@user.name}"
    email = send_email(@user.email, @enterprise_user.id, subject, 'email_enterprise_invite_work_reference')
    return email
  end

  def email_user_reference_notification(work, user, eu)
    sendgrid_category "Work Reference Notification"
    @work = work
    @user = user
    @eu = eu

    subject = "#{eu.first_name} wrote a reference for you"
    @url = url_for(:controller => 'reviews', :action => 'work_references', :host => ENV['host'])
    send_email(DEFAULT_ADDRESS, user.email, subject)
  end

  def email_user_message_public(sender_email, subject, email, body)
    # check if user is subscribed to message update
    user = User.find_by(email: email)
    unless check_email_notification_eligibility(user, 'message')
      return
    end
    if sender_email.blank?
      sender_email = DEFAULT_ADDRESS
    end
    @hostname = get_host_name_url
    @body = body
    @sender_email = sender_email
    send_email(sender_email, email, subject)
  end

  def email_custom(sender_email, subject, email, body, landing_url)
    if sender_email.blank?
      sender_email = DEFAULT_ADDRESS
    end

    if sender_email.eql? 'noreply@getmeed.com'
      sender_email = 'Meed Team <noreply@getmeed.com'
    end

    @hostname = get_host_name_url
    @body = body
    @landing_url = landing_url
    send_email(sender_email, email, subject)
  end

  def email_job_notification(job, job_app, user)
    # check if user is subscribed to job update
    sendgrid_category "job_notification"
    @user_title = "#{user.first_name} — #{user.major}"
    @hostname = get_host_name_url
    @job_title = job.title
    @job_app = job_app
    @short_listed = job_app.short_listed
    @user = user
    @url = get_user_profile_url(@user.handle)
    if @short_listed
      subject = "#{user.first_name} accepted your invitation for #{job.title}!"
    else
      subject = "#{user.first_name} interested in #{job.title} position"
    end
    from_address = DEFAULT_TALENT_ADDRESS
    send_email(from_address, job.email, subject)
    unless job.emails.blank?
      job.emails.each do |email|
        send_email(from_address, email, subject)
      end
    end
  end

  def email_job_invitation(user, token, job, variation_id)
    if job.blank? or user.blank?
      return
    end
    # check if user is subscribed to job update
    unless check_email_notification_eligibility(user, 'job')
      return
    end
    sendgrid_category "graphic_template"
    @job = job
    @user = user
    @test_variation = variation_id
    @school_handle = get_school_handle_from_email(user.id).upcase
    # subject = get_subject_for_job_variation(variation_id, job.company, job.title, job.location, @school_handle)
    subject = "#{job.company}"
    email_variation_id = "track_job_email_#{job.id}_graphic_template"
    @unsubscribe_link = get_unsubscribe_link(email_variation_id, user.id)
    job_url = get_job_url_id(encode_id(job.id))
    @url = "#{job_url}?ab_id=#{email_variation_id}&user_token=#{token}"
    @url_dry = "#{get_host_name_url}/#{job.company}/#{generate_id_from_text(job.title)}"
    address = 'Meed <joe@getmeed.com>'
    send_email(address, user.email, subject)
  end

  def email_job_forward(user, to_email, job)
    sendgrid_category "job_forward"
    if job.blank? or user.blank? or to_email.blank?
      return
    end
    # check if user is subscribed to job update
    unless check_email_notification_eligibility(user, 'job')
      return
    end
    @job = job;
    @job_type = @job[:type] == 'full_time_entry_level' ? 'Full Time' : 'Internship'
    @user = user;
    @unsubscribe_link = get_unsubscribe_link('user_job_forward', user.id)
    subject = "#{user[:first_name]} has recommended a job for you!"
    @job_url = "https://getmeed.com/job/#{encode_id(job[:_id])}"
    @company_url = "https://getmeed.com/company/#{job[:company_id]}"
    @user_url = "https://getmeed.com/#{user[:handle]}"
    send_email(user.email, to_email, subject)
  end

  def email_meed_fair_existing_users(user, jobs)
    # check if user is subscribed to job update
    unless check_email_notification_eligibility(user, 'job')
      return
    end
    @jobs = jobs.take(3)
    subject = "Meed Career Fair - Apply Now"
    @unsubscribe_link = get_unsubscribe_link('meed_fair_existing', user.id)
    send_email(JOE_ADDRESS,  user.email, subject)
  end

  def email_meed_fair_new_users(user)
    @user = user
    subject = '[Announcement] Meed Fair - Applications Open'
    attachments['flyer.png'] = File.read(Rails.root.join("app", "assets", "other", "meed_flyer.png"))
    @unsubscribe_link = get_unsubscribe_link('meed_fair_new', user.id)
    mail = send_email(JOE_ADDRESS, user.email, subject)
    return mail
  end

  def email_user_profile_invitation(email, token, invitor, profile_item, profile_type)
    if invitor.blank? or profile_item.blank? or profile_type.blank?
      return
    end
    # check if user is subscribed to social update
    user = User.find_by(email: email)
    unless check_email_notification_eligibility(user, 'social')
      return
    end
    @test_variation = 'email_invitation_5'
    @hostname = get_host_name_url
    @invitor = invitor
    @url = "#{get_user_verification_url(token)}&ab_id=#{@test_variation}"
    @token = token
    to_send = email
    invitor_name= "#{invitor[:first_name].capitalize} #{invitor[:last_name].capitalize}"
    @school_handle = get_school_handle_from_email(email).upcase
    address = "#{invitor_name} <#{invitor.id}>"
    subject = ''
    case UserFeedTypes.const_get(profile_type.upcase)
      when UserFeedTypes::COURSEWORK
        subject = "I took this course \"#{profile_item.title}\" in #{profile_item.semester}, #{profile_item.year}"
      when UserFeedTypes::USERWORK
        subject = "I worked as #{profile_item.title} at #{profile_item.company} in #{profile_item.start_year}"
      when UserFeedTypes::INTERNSHIP
        subject = "I interned at #{profile_item.company} in #{profile_item.start_year}"
      when UserFeedTypes::PUBLICATION
        subject = "I published #{profile_item.title}"
    end

    logger.info('sending invite to ' + to_send + ' from ' + address)
    send_email(address, to_send, subject)
  end

  def email_user_invitation(user, token, subject, variation_id, variation, with_media, feed_items, schools)
    @hostname = get_host_name_url
    @user = user
    @with_media = with_media
    @variation = variation
    @url = "#{get_user_verification_url(token)}&ab_id=#{variation_id}"
    @unsubscribe_link = get_unsubscribe_link(variation_id, user.id)
    @token = token
    @feed_items = feed_items
    @schools = schools[0..10]
    to_send = user.id
    @school_handle = get_school_handle_from_email(user.id).upcase
    address = DEFAULT_ADDRESS
    address = 'John Cussack<joe@getmeed.com>'
    logger.info('sending invite to ' + to_send + ' from ' + address)
    send_email(address, to_send, subject)
  end

  def email_broadcast_pdf (email, handle)
    @hostname = get_host_name_url
    @download_url = get_user_profile_download_url(handle, 'public')
    @profile_url = get_user_profile_url(handle)
    @contact_url= get_contact_us_url
    @handle = handle
    to_send = email
    subject = 'Introducing - Share your Meed, track views and download as PDF'
    address = DEFAULT_ADDRESS
    send_email(address, to_send, subject)
  end

  def email_inactive_user(user, variation_id, subject, school, school_user_count)
    sendgrid_category "Inactive User Var #{variation_id}"

    @school = school.upcase
    @school_user_count = school_user_count
    @user = user
    subject = subject
    template_name = "email_inactive_user_var_#{variation_id}"
    @unsubscribe_link = get_unsubscribe_link('email_inactive_user', user.id)

    send_email(DEFAULT_ADDRESS, user.email, subject, template_name)
  end

  def email_incomplete_resume(user)
    if user.blank?
      return
    end
    @hostname = get_host_name_url
    @handle = user.handle
    @major = user.major
    @landing_url = get_user_profile_url(user.handle)
    to_send = user.email
    unless user.primary_email.blank?
      to_send = user.primary_email
    end
    subject = 'Your Meed profile is incomplete!'
    address = DEFAULT_ADDRESS
    send_email(address, to_send, subject)
  end

  def email_collection_owner_follow(owner, follower, collection)
    if owner.blank? or follower.blank? or collection.blank?
      return
    end
    @follower = follower
    @collection = collection
    @user = owner
    collection_url = get_collection_slug_url(collection.id, collection.handle, collection.slug_id)
    @referrer_url = "#{collection_url}?referrer=#{@user.handle}"
    @url = collection_url
    subject = "[#{MEED_POINTS::COLLECTION_FOLLOWER} pts] A new follower for #{collection.title}!"
    send_email(ACTIVITY_ADDRESS, @user.email, subject)
  end

  def email_user_follow(user, follower)
    if user.blank? or follower.blank?
      return
    end
    @user = user
    @follower = follower
    sendgrid_category "activity_user_follow"
    subject = "#{follower.first_name} is now following you on Meed"
    send_email(ACTIVITY_ADDRESS, user.email, subject)
  end

  def email_ama_follow(user, ama, ama_author)
    if user.blank? or ama.blank? or ama_author.blank?
      return
    end
    sendgrid_category "activity_ama_follow"
    @user = user
    @ama = ama
    @ama_author = ama_author
    @time_string = @ama.start_dttm.in_time_zone("Pacific Time (US & Canada)").strftime("%B %d @ %I:%M %p %Z")
    subject = "Your are following AMA with #{ama_author.first_name}"
    send_email(ACTIVITY_ADDRESS, user.email, subject)
  end

  def email_collection_owner_submission(owner, submittor, collection, feed_item)
    if owner.blank? or submittor.blank? or collection.blank?
      return
    end
    @owner = owner
    @collection = collection
    @user = submittor
    @feed_item = feed_item
    collection_url = get_collection_slug_url(collection.id, collection.handle, collection.slug_id)
    @url = collection_url
    subject = "[#{MEED_POINTS::COLLECTION_SUBMISSION} pts] A new submission in #{collection.title}"
    send_email(ACTIVITY_ADDRESS, @user.email, subject)
  end

  def email_comment_content_owner(commentor, user, comment, content)
    if commentor.blank? or user.blank? or comment.blank?
      return
    end
    @commentor = commentor
    @comment = comment
    @user = user
    @feed_item = content
    sendgrid_category "meed_activity_comment_owner"
    @url = "#{get_story_url(content.poster_id, content.subject_id, content.create_time)}?action=signin"
    subject = "#{commentor.first_name} commented on your post!"
    send_email(ACTIVITY_ADDRESS, user.email, subject)
  end

  def email_comment_audience(commentor, user, comment, content)
    if commentor.blank? or user.blank? or comment.blank?
      return
    end
    @commentor = commentor
    @comment = comment
    @feed_item = content
    @user = user
    sendgrid_category "meed_activity_comment_threaded"
    @url = "#{get_story_url(content.poster_id, content.subject_id, content.create_time)}?action=signin"
    subject = "#{commentor.first_name} commented on a post you were following!"
    send_email(ACTIVITY_ADDRESS, user.email, subject)
  end

  def email_meed_post_success(poster, data)
    if poster.blank? or data.blank?
      return
    end
    @user = poster
    @data = data
    @url = "#{data.url}?referrer=#{@user.handle}"
    @referrer_url = "#{data.url}?referrer=#{@user.handle}"
    subject = "[#{MEED_POINTS::SUBMIT_POST} pts] Submission successful - few tips"
    send_email(ACTIVITY_ADDRESS, @user.email, subject)
  end

  def email_friend_joined(user, friend_user)
    if user.blank? or friend_user.blank?
      return
    end

    @user = user
    @friend_user = friend_user
    @leaderboard_url = get_leaderboard_url
    @referrer_url = "#{get_root_url}?referrer=#{@user.handle}"
    subject = "[#{MEED_POINTS::FRIEND_REFERRER} pts] Your friend #{friend_user.name} joined Meed!"
    send_email(ACTIVITY_ADDRESS, user.email, subject)
  end

  def email_meed_points_thanks(user, type)
    if user.blank?
      return
    end
    @user = user
    @url = get_leaderboard_url
    @leaderboard_url = get_leaderboard_url
    @meed_points_type = type
    @referrer_url = "#{get_root_url}?referrer=#{@user.handle}"
    case MEED_POINTS_REWARD_TYPE.const_get(type.upcase)
      when MEED_POINTS_REWARD_TYPE::COMPLETE_PROFILE
        subject = "[#{MEED_POINTS::COMPLETE_PROFILE} pts] Your profile is accepted!"
      when MEED_POINTS_REWARD_TYPE::FACEBOOK_LIKE
        subject = "[#{MEED_POINTS::FACEBOOK_LIKE} pts] Thanks for being our fan!"
      when MEED_POINTS_REWARD_TYPE::TWITTER_FOLLOW
        subject = "[#{MEED_POINTS::TWITTER_FOLLOW} pts] Thanks for following us!"
      else
        return
    end
    send_email(ACTIVITY_ADDRESS, user.email, subject)
  end

  def email_comment_upvote(giver_user, user, comment)
    if giver_user.blank? or user.blank?
      return
    end
    @comment = comment
    @user = user
    @giver_user = giver_user
    @url = get_perma_url(comment.feed_id)

    subject = "#{giver_user.first_name} upvoted your comment!"
    send_email(ACTIVITY_ADDRESS, user.email, subject)
  end


  def email_kudos(giver_user, user, subject_type, is_enterprise_content= false, story= nil)
    if giver_user.blank? or user.blank?
      return
    end
    @referrer_url = "#{get_root_url}?referrer=#{user.handle}"
    @subject_type = subject_type
    if subject_type.eql? 'userwork'
      @subject_type = 'experience'
    elsif subject_type.eql? 'user_course_review'
      @subject_type = 'Course Review'
    elsif subject_type.eql? 'comment'
      @subject_type = 'comment'
    elsif subject_type.eql? 'story'
      @subject_type = 'submission'
    end
    @feed_item = story
    @user = user
    @giver_user = giver_user
    @url = get_dashboard_url
    unless story.blank?
      if subject_type.eql? 'comment'
        @url = get_perma_url(story.feed_id)
      else
        @url = get_story_url(story.poster_id, story.subject_id, story.create_time)
      end
    end
    sendgrid_category "activity_kudos_given"
    @leaderboard_url = get_leaderboard_url
    @giver_url = get_user_profile_url(giver_user.handle)
    if is_enterprise_content
      @giver_url = get_user_profile_url(handle)
    end

    subject = "#{giver_user.first_name} upvoted your #{@subject_type}!"

    if is_enterprise_content
      subject = "A #{get_school_handle_from_email(giver_user.id).capitalize} student upvoted your #{@subject_type}"
    end

    send_email(ACTIVITY_ADDRESS, user.email, subject)
  end

  def email_course_review(user, course)
    if user.blank? or course.blank?
      return
    end
    unless check_email_notification_eligibility(user, 'tips')
      return
    end
    unless user.active
      return
    end
    sendgrid_category "course_review_invite"
    @user = user
    @course = course
    @school = get_school_handle_from_email(user.id).upcase
    subject = "Rate #{course[:title]} you took at #{get_school_handle_from_email(user.id).upcase}"
    send_email(DEFAULT_ADDRESS, user.email, subject, 'email_course_review')
  end

  def email_course_reference(reviewer, invite, course, reminder= false)
    if course.blank? or invite.blank?
      return
    end

    if reminder
      sendgrid_category "course_reference_invite_reminder"
    else
      sendgrid_category "course_reference_invite"
    end

    @reviewer = reviewer
    @invite = invite
    @course = course
    @user = get_user_by_handle(course.handle)
    subject = "Please write a reference for #{@user.first_name}"

    to_email = invite.reference_email
    unless reviewer.blank?
      to_email = @reviewer.email
    end

    if reminder
      subject = "Reminder - " + subject
      send_email(@user.id, to_email, subject, 'email_course_reference_reminder')
    else
      send_email(@user.id, to_email, subject, 'email_course_reference')
    end
  end

  def email_friend_invite(lead, invite_user, friend_count, friends_list=[])
    sendgrid_category "friend_invite"

    if lead.blank? || invite_user.blank?
      return
    end

    @invite_user = invite_user
    @lead = lead
    @friends = friends_list
    @friend_count = friend_count

    subject = "#{invite_user.first_name} has invited you to network together on Meed"
    send_email(DEFAULT_ADDRESS, lead[:email], subject)
  end

  def send_admin_message(subject, body)
    @body = body
    send_email(DEFAULT_ADDRESS, "contact@getmeed.com", subject)
  end

  def send_email(from_email, to_email, subject, template_name = nil)
    if to_email.split('@')[1].eql? 'tester.edu'
      to_email = TEST_ADDRESS
    end

    if to_email.split('@')[1].eql? 'testcorp.com'
      to_email = TEST_ADDRESS
    end

    if Rails.env.development?
      to_email = TEST_ADDRESS
    end

    begin
      if template_name.blank?
        mail(:to => to_email,
             :from => from_email,
             :subject => subject)
      else
        mail(:to => to_email,
             :from => from_email,
             :subject => subject) do |format|
          format.html { render template_name }
        end
      end

    rescue Exception => ex
      logger.info('ERROR SENDING EMAIL - ')
    end

  end

  def email_message_to_user(recipient, message, sender, job, message_type = 'invitation')
    @hostname = ''#get_root_host_name_url
    @job = job
    @url = ''#get_consumer_messages_url
    unless job.blank?
      @url = get_job_url(encode_id(job.id))
    end
    subject = "[Meed Invitation] #{message.subject}"
    if message_type.eql? 'email'
      subject = "#{message.subject}"
    elsif message_type.eql? 'invitation_reminder'
      subject = "[Important] #{message.subject}"
    end
    @message = message
    @sender = sender
    @recipient = recipient
    @message_type = message_type
    from_address = "#{sender.name} <contact@getmeed.com>"
    if message_type.eql? 'email'
      from_address = "#{sender.name} <#{sender.id}>"
    end

    if @job.blank?
      subject = "[Meed Message] #{message.subject}"
    end
    send_email(from_address, recipient.email, subject)
  end
end
