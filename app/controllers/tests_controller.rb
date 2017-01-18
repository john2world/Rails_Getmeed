class TestsController < ApplicationController
  include CrmHelper

  def test_emails
    unless authenticate(current_user)
      return
    end
    if params[:id].blank?

    end
    email = params[:email]
    if email.blank?
      email = 'ravi@getmeed.com'
    end

    @email = email
    case EmailType.const_get(params[:id].upcase)
      when EmailType::WELCOME
        id = 'test1@tester.edu'
        user = get_user_by_email id
        Notifier.email_welcome(user).deliver
      when EmailType::MESSAGE_ENTERPRISER_TO_USER
        Notifier.email_user_message('test1@tester.edu', false).deliver
      when EmailType::MESSAGE_USER_TO_ENTERPRISER
        Notifier.email_user_message('test@testcorp.com', true).deliver
      when EmailType::INVITATION
        invitor_id = 'ravi'
        email_invitation = create_email_invitation_for_email(email, invitor_id)
        invitor = get_user_by_handle(invitor_id)
        schools = admin_all_schools
        email_variation = get_email_invitation_variation
        email_variation_id = "user_invitation_#{email_variation}"
        with_media = false
        feed_items = get_feed_items_for_user(invitor, false)
        user_ids = Hash.new
        filtered_feed_items = Array.[]
        feed_items.each do |feed_item|
          if user_ids[feed_item[:user].handle] == nil
            user_ids[feed_item[:user].handle] = feed_item[:user].handle
            filtered_feed_items << feed_item
          end
        end
        if filtered_feed_items.length > 5
          filtered_feed_items  = filtered_feed_items.each_slice(3).to_a[0]
        end
        subject = get_subject_for_variation(email_variation, 'USC')
        Notifier.email_user_invitation(invitor, email_invitation[:_id], subject, email_variation_id, email_variation, with_media, filtered_feed_items.shuffle!, schools).deliver
      when EmailType::NEW_JOB_APPLICATION
        id = 'test1@tester.edu'
        user = get_user_by_email id
        Notifier.email_job_notification('test@testcorp.com', 'tokenasdf', 'Snr Test Engineer', user).deliver
      when EmailType::VERIFICATION
        email = 'test1@tester.edu'
        email_invitation = create_email_invitation_for_email(email, nil)
        Notifier.email_verification(email, email_invitation[:_id]).deliver
      when EmailType::WEEKLY_DIGEST
        user = get_user_by_handle('ravi')
        email = 'ravi@getmeed.com'
        feed_items = get_feed_items_for_user(user, false)
        key = get_user_inbox_key(user.handle)
        user_jobs = get_jobs_for_user(key)
        jobs = nil
        companies = nil
        unless user_jobs.blank?
          jobs = get_jobs_live_by_ids(user_jobs.job_ids)
          company_ids = Array.new
          unless jobs.blank?
            jobs.each do | job|
              unless company_ids.include? job.company_id
                company_ids << job.company_id
              end
            end
            companies = get_companies(company_ids)
          end
        end

        unless jobs.blank? or feed_items.blank?
          Notifier.email_weekly_digest_feed(email, feed_items, companies).deliver
        end
      when EmailType::JOB_ALERTS
        jobs = get_default_jobs(10)
        Notifier.email_job_alerts(email, jobs).deliver
      when EmailType::JOB_ALERT
        job = get_job_by_hash(params[:job_id])
        user = get_user_by_email 'vadrevu@usc.edu'
        track_email_send("track_job_email_#{job.id}_2")
        Notifier.email_job_invitation(user, EmailInvitation.where(:activated => false).first.id, job, 2).deliver
      when EmailType::INCOMPLETE_RESUME
        user = get_user_by_handle('test1');
        Notifier.email_incomplete_resume(user).deliver
      when EmailType::KUDOS
        user = get_user_by_handle('test1')
        giver = get_user_by_handle('test2')
        Notifier.email_kudos(giver, user, 'userwork').deliver
      when EmailType::INVITE_USERS
        user = get_user_by_handle('test1')
        Notifier.email_user_invite_promotion(user).deliver
    end

  end

end