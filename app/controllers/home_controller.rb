class HomeController < ApplicationController
  include ProfilesHelper
  include JobsManager
  include JobsHelper
  include UsersManager
  include QuestionsManager
  include PromotionsManager
  include CommonHelper
  include AnswersManager
  include ArticlesManager
  include UserInsightsHelper
  include UsersHelper
  include CompanyInsightsHelper
  include CommonHelper
  include LinkHelper
  include SessionsHelper

  caches_page :sitemap

  def tos
    page_title ('Meed Terms And Conditions')
    page_heading('Meed Terms And Condition')
    respond_to do |format|
      format.html { return render layout: "angular_app", template: "angular_app/index" }
    end
  end

  def contact
    @user = current_user
    page_title ('Contact Us')
    page_heading('Contact Us')
    @show_top_bar = true
    respond_to do |format|
      format.html { return render layout: "angular_app", template: "angular_app/index" }
    end
  end

  def careerfair
    @metadata = get_career_fair_metadata
    @schools = admin_all_schools
    @show_top_bar = true
    respond_to do |format|
      format.html
    end

  end

  def about_product
    page_title ('About Resume')
  end

  def dash
    unless logged_in?
      return
    end
    # follow_redirect_url

    page_title ('Home')
    @user = current_user
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('view-dash', current_user[:_id].to_s, {
                                                        :ref => params[:ref]
                                                    })
    end

    return redirect_to root_path

  end

  def enterprise_pointer
    redirect_to 'https://enterprise.getmeed.com'
  end

  def competition
    unless logged_in?
      return
    end

    @school_prefix = get_school_prefix
    @school_prefix_handle = get_school_prefix_from_email(current_user.id)
    @promo_url = get_user_invite_promo_url(current_user.handle)
    respond_to do |format|
      format.html
    end
  end

  def competition_leaderboard

  end

  def contact_us
    if params[:subject].blank?
      flash[:alert] = 'Please enter a subject'
      @show_top_bar = true
      redirect_to action: 'contact'
      return
    end

    if params[:body][:text].blank?
      flash[:alert] = 'Please enter body'
      @show_top_bar = true
      redirect_to action: 'contact'
      return
    end

    if params[:email].blank?
      flash[:alert] = 'Please enter landing url'
      redirect_to action: 'contact'
      return
    end

    Notifier.email_custom('contact@getmeed.com', params[:subject], 'contact@getmeed.com', process_text(params[:body][:text]), params[:email]).deliver
    rparams = params.except(:subject, :body, :email)

    NotificationsLoggerWorker.perform_async('Consumer.Home.ContactUs',
                                            {email: params[:email],
                                             params: rparams,
                                             ref: {referrer: params[:referrer],
                                                   referrer_id: params[:referrer_id],
                                                   referrer_type: params[:referrer_type],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    respond_to do |format|
      format.html # view.html.erb
      format.json {
        return render json: {success: true}

      }
    end
  end

  def insights
    unless logged_in?
      return
    end
    page_heading('Profile Insights')
    page_title('Insights')
    @user = current_user
    user_insights = InsightsForUser.new(@user[:handle])
    @total_view_count = user_insights.get_total_profile_view_count;
    date_view_count_data = user_insights.get_profile_view_count_by_date
    if (!date_view_count_data.blank?)
      date_view_count_data = date_view_count_data.map { |data|
        data_date = Date.strptime(data['date'], "%Y-%m-%d")
        "[Date.UTC(#{data_date.year}, #{data_date.month}, #{data_date.day}), #{data['count']}]"
      }
      @view_count_date_data_string = '['+date_view_count_data.join(',')+']'
    end

    company_view_count_data = user_insights.get_profile_view_count_by_company;
    if (!company_view_count_data.blank?)
      @company_view_count_data_string = company_view_count_data.map { |data|
        "[\"#{data['company']}\", #{data['count']}]"
      }.join(',');
      @company_view_count_data_string = '['+@company_view_count_data_string+']';
    end
    @resume_score = user_insights.get_resume_score
    resume_score_raw = user_insights.get_resume_score_raw
    resume_score_contributions = user_insights.get_resume_contributors
    if (!resume_score_contributions.blank?)
      resume_score_contributions = resume_score_contributions.map { |data|
        "[\"#{data['type'].capitalize}\", #{data['value'].round(5)}]"
      }
      @resume_score_contributions_data_string ='['+resume_score_contributions.join(',')+']'
    end

    # @impressions = get_profile_impressions(@user)
    # @total_view_count = 0;
    NotificationsLoggerWorker.perform_async('Consumer.Home.Insights',
                                            {handle: @user[:handle],
                                             params: params,
                                             ref: {referrer: params[:referrer],
                                                   referrer_id: params[:referrer_id],
                                                   referrer_type: params[:referrer_type],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('view-insights', current_user[:_id].to_s, {
                                                            :ref => {referrer: params[:referrer],
                                                                     referrer_id: params[:referrer_id],
                                                                     referrer_type: params[:referrer_type]}
                                                        })
    end

    @school_prefix = get_school_handle_from_email(current_user.id).upcase
    @school_prefix_handle = get_school_prefix_from_email(@user[:_id])
    @profile = get_user_profile_or_new(@user[:handle])
  end

  def settings
    unless logged_in?(root_path)
      return
    end

    respond_to do |format|
      format.html{
        return render layout: "angular_app", template: "angular_app/index"
      }

      format.json{
        settings = UserSettings.find_or_create_by(handle: current_user[:handle])
        @profile_public = settings.is_profile_public
        @email_frequency = settings.email_frequency
        @email_subscriptions = settings.notification_email_subscriptions
        return render json: {
          profile_public: @profile_public,
          email_frequency: @email_frequency,
          email_subscriptions: @email_subscriptions
        }
      }
    end
  end

  def deactivate_survey
    unless logged_in?(root_path)
      return
    end


    NotificationsLoggerWorker.perform_async('Consumer.Home.Deactivate',
                                            {handle: current_user.handle,
                                             job: params[:job],
                                             graduated: params[:graduated],
                                             testing: params[:testing],
                                             other: params[:other],
                                             meed_user_tracker: cookies[:meed_user_tracker]})
    respond_to do |format|
      format.js
      format.json{
        return render json: {success: true, redirect_url: "/logout"}
      }
    end
  end

  def update_settings
    unless logged_in?(root_path)
      return
    end
    handle = params[:id]

    if handle != current_user.handle
      return error_redirect("You cannot change the settings for that user", root_path)
    end

    setting = UserSettings.find_or_create_by(handle: handle)
    setting.set_profile_public(params[:profile_public])
    setting.set_email_frequency(params[:email_frequency])

    params[:email_subscriptions].each{|k, v|
      setting.email_notification_update_subscription(k, v)
    }

    redirect_url = nil
    msg = "Settings saved"

    if params[:deactivate]
      current_user[:active] = false;
      current_user.save();
      IntercomUpdateUserWorker.perform_async(current_user.id)
      redirect_url = "/logout"
      msg = "User deleted"
      message = "User with handle #{handle} has deleted his profile on: #{Time.now}. Email: #{current_user[:email]} ."
      Notifier.email_custom('contact@getmeed.com', 'Profile Deactivated', 'contact@getmeed.com', message, 'contact@getmeed.com').deliver
    end

    return render json: {success: true, redirect_url: redirect_url, message: msg}
  end

  def redeem_meeds
    unless current_user.blank?

    end
  end

  def promotion
    unless params[:token].blank?
      @inviter_handle = params[:token]
      inviter = get_active_user_by_handle(params[:token])
      unless inviter.blank?
        @metadata = get_promo_metadata("#{inviter.first_name} #{inviter.last_name}")
      end
      @metadata = get_promo_metadata(nil)
    end

    unless params[:referrer].blank?
      cookies[:referrer] = params[:referrer]
    end
    unless params[:referrer_id].blank?
      cookies[:referrer_id] = params[:referrer_id]
    end
    unless params[:referrer_type].blank?
      cookies[:referrer_type] = params[:referrer_type]
    end

    unless params[:campaign_type].blank?
      cookies[:campaign_type] = params[:campaign_type]
    end

    @schools = admin_all_schools
    @dont_show_header = true
    @show_top_bar = true
    rparams = params.except(:test)
    NotificationsLoggerWorker.perform_async('Consumer.Home.Index',
                                            {params: rparams,
                                             ref: {referrer: params[:referrer],
                                                   referrer_id: params[:referrer_id],
                                                   referrer_type: params[:referrer_type],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    respond_to do |format|
      format.html
    end
  end

  def index
    unless current_user.blank?
      # if there is a redirect url we will follow else go to home
      save_redirect_url(params)

      # if session is pseudo, we clear it
      if session_pseudo?
        reset_session
      end
      # New for angular app
      return render layout: "angular_app", template: "angular_app/index"

      # Uncomment to go back to old dashboard
      # redirect_to '/home'
      # return
    end
    save_redirect_url(params)
    campaign_type = nil
    if !params[:campaign_type].blank?
      campaign_type = params[:campaign_type]
    else
      campaign_type = params[:referrer]
    end
    unless params[:referrer].blank?
      @referrer_user = get_user_by_handle(params[:referrer])
      @metadata = get_promotion_metadata(campaign_type, @referrer_user)
    end

    cookies_record_required_params(params)
    @schools = admin_all_schools
    @show_top_bar = true
    rparams = params.except(:test)
    NotificationsLoggerWorker.perform_async('Consumer.Home.Index',
                                            {params: rparams,
                                             ref: {referrer: params[:referrer],
                                                   referrer_id: params[:referrer_id],
                                                   referrer_type: params[:referrer_type],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    respond_to do |format|
      format.html{
        return render layout: "angular_app", template: "angular_app/index"
      }
    end
  end

  def invite_users
    @user = current_user

    invitee_emails = Array.[]
    unless params[:invite_id_1].blank?
      invitee_emails << params[:invite_id_1].split('@')[0]
    end
    unless params[:invite_id_2].blank?
      invitee_emails << params[:invite_id_2].split('@')[0]
    end
    unless params[:invite_id_3].blank?
      invitee_emails << params[:invite_id_3].split('@')[0]
    end
    if invitee_emails.length < 3
      flash[:alert] = 'Fill all emails'
      if params[:show_easter].blank?
        redirect_to '/home'
      else
        redirect_to '/home?showEaster=true'
      end
      return
    end
    @school_prefix_handle = get_school_prefix_from_email(@user[:_id])
    update_profile_invite_flag(@user[:handle])
    invitee_emails.each do |email_handle|
      email = email_handle + '@' + @school_prefix_handle
      logger.info('Triggering emails - ' + email)
      unless is_registered_user(email)
        EmailInvitationWorker.perform_async(email, @user[:_id], rand(1..2).to_s)
      end
    end
    NotificationsLoggerWorker.perform_async('Consumer.Home.EmailInvite',
                                            {handle: @user[:handle],
                                             params: params,
                                             ref: {referrer: params[:referrer],
                                                   referrer_id: params[:referrer_id],
                                                   referrer_type: params[:referrer_type],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    redirect_to '/home'
  end

  def viewers
    unless logged_in?
      return
    end

    @user = current_user
    unless params[:id].eql? @user[:handle]
      redirect_to '/' + @user[:handle] + '/viewers'
    end

    @viewers = get_profile_viewers(@user)
    respond_to do |format|
      format.html
    end
  end

  def job_views
    unless logged_in?
      return
    end

    @user = current_user
    unless params[:id].eql? @user[:handle]
      redirect_to root_path
      return
    end

    @jobs = get_job_profile_viewers(@user)
    respond_to do |format|
      format.html
    end
  end

  def show_version

  end

  def unsubscribe
    email = params[:email]
    email_type = params[:type]
    email_unsub = EmailUnsubscribe.new
    email_unsub.email = email
    email_unsub.id = email
    email_unsub.type = email_type
    email_unsub.save
    NotificationsLoggerWorker.perform_async('Consumer.Home.Unsubscribe',
                                            {email: params[:email],
                                             params: params,
                                             ref: {referrer: params[:referrer],
                                                   referrer_id: params[:referrer_id],
                                                   referrer_type: params[:referrer_type],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('update-settings', current_user[:_id].to_s, {
                                                              :action => params[:key],
                                                              :value => params[:value],
                                                              :ref => {referrer: params[:referrer],
                                                                       referrer_id: params[:referrer_id],
                                                                       referrer_type: params[:referrer_type]}
                                                          })
    end

  end

  def subscribe
    email = params[:email]
    email_type = params[:type]
    email_unsubscribe = EmailUnsubscribe.where(:_id => email, :type => email_type)
    email_unsubscribe.delete
    NotificationsLoggerWorker.perform_async('Consumer.Home.Subscribe',
                                            {email: params[:email],
                                             params: params,
                                             ref: {referrer: params[:referrer],
                                                   referrer_id: params[:referrer_id],
                                                   referrer_type: params[:referrer_type],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
  end

  def sitemap

    if !SEARCH_ENGINE_BOTS.include? request.user_agent.downcase
      users = User.all
      @users = Array.[]
      settings_map = Hash[UserSettings.all.map { |u| [u.id, u] }]
      users.each do |user|
        settings = settings_map[user.handle]
        unless settings.public_profile
          @users << user
        end
      end
      @companies = Company.all
      @articles = Article.all
      feed_items = FeedItems.where(privacy: 'everyone').order_by([:create_time, -1])
      @posts = build_feed_models(nil, feed_items)
    end
  end

  def sitemap_all
    if !SEARCH_ENGINE_BOTS.include? request.user_agent.downcase
      users = User.where(:active => true).to_a
      @users = Array.[]
      settings_map = Hash[UserSettings.all.map { |u| [u.id, u] }]
      users.each do |user|
        settings = settings_map[user.handle]
        if !settings.blank? and settings.is_profile_public
          @users << user
        end
      end
      @companies = Company.all
      @articles = FeedItems.where(:type => 'story', :poster_type => 'user').order_by([:last_updated, -1]).to_a
      @articles.each do |article|
        article.url = get_story_url(article.poster_id, article.subject_id, article.create_time)
        article.save
      end
      feed_items = FeedItems.where(:poster_type => 'user').order_by([:create_time, -1])
      @posts = build_feed_models(nil, feed_items)
    end
  end

  def robots
  end

  def add_waitlist_users

    invitee_emails = Array.[]
    if invitee_emails.blank?
      @school_handle = session[:school_handle]
      flash[:alert] = 'Please enter at least one email'
      render 'users/waitlist'
      return
    end

    unless params[:invite_id_1].blank?
      invitee_emails << params[:invite_id_1]
    end
    unless params[:invite_id_2].blank?
      invitee_emails << params[:invite_id_2]
    end
    unless params[:invite_id_3].blank?
      invitee_emails << params[:invite_id_3]
    end

    unless invitee_emails.blank?
      invitee_emails.each do |email|
        put_in_wait_list(session[:school_handle], email)
      end
    end
    render 'connections/gmail_import_callback'
  end

  def need_meed
    @show_top_bar = true
    @school = nil
    success = false
    unless params[:school_id].blank?
      @school = get_school(params[:school_id])
      if !(@school.blank? or !@school.active)
        success = true
      end
    end
    unless params[:email].blank?
      @email = params[:email]
    end
    @user = nil
    unless @email.blank?
      @user = get_user_by_email(@email)
    end
    show_status = false
    unless @user.blank?
      show_status = true
    end
    if params[:campaign_type].blank?
      params[:campaign_type] = 'needmeed'
    end
    @metadata = get_promotion_metadata(params[:campaign_type], nil)
    cookies_record_required_params(params)
    ActiveSupport::Notifications.instrument('Consumer.Home.NeedMeed',
                                            {email: @email,
                                             referrer: params[:referrer],
                                             params: params,
                                            })
    respond_to do |format|
      format.html {
        if @email.blank?
          return render layout: "angular_app", template: "angular_app/index"
        else
          return redirect_to url_for(controller: "home", action: "index", email: @email, referrer: params[:referrer], campaign_type: params[:campaign_type])
        end
      }
      format.json{
        return render json: {school: @school.blank?? nil : @school.as_json, success: success, show_status: show_status}
      }
    end

  end

  def need_meed_status
    email = params[:email]
    if email.blank?
      respond_to do |format|
        format.json{
          return render json: {success: false, redirect_url: "/"}
        }
      end
    end
    user = get_user_by_email(email)
    if user.blank?
      respond_to do |format|
        format.json{
          return render json: {success: false, redirect_url: "/?email=#{email}"}
        }
      end
    end
    campaign_type = ''
    unless user.meta_data.blank?
      campaign_type = user.meta_data["campaign_type"]
    end
    respond_to do |format|
      format.json{
        return render json: {success: true, verify_email: false, action: "waitlist",
                             waitlist_no: user.waitlist_no, email: user.id, handle: user.handle,
                             invite_url: get_need_meed_referral_url(user.handle, campaign_type)}
      }
    end
  end

  def redirect
    if params[:code].blank?
      redirect_to root_path
    else
      redirect_to get_short_url_from_code(params[:code])
    end
  end

  # Landing page
  def recruiting
    unless current_user.blank?
      redirect_to '/'
      return
    end

    respond_to do |format|
      format.html {
        return render layout: "angular_app", template: "angular_app/index"
      }
      format.json {
        return render json: {
                          success: true
                      }
      }
    end
  end
end
