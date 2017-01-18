class ApplicationController < ActionController::Base
  rescue_from Exception, :with => :server_error
  helper :all
  #before_filter :create, :only => [:users]
  before_filter :set_cache_buster
  before_filter :cookie_manager
  helper_method :current_user, :get_school_prefix, :logged_in?, :is_activity_page_default?, :current_school_handle,
                :is_profile_incomplete, :page_title, :get_school_logo_url, :has_invited_friends?,
                :current_badges, :has_no_session?, :sanitize_text, :current_school_name, :is_eligible_to_post
  protect_from_forgery
  include UsersManager
  include JobsManager
  include MessagesManager
  include UsersHelper
  include CompanyManager
  include CrmManager
  include ProfilesHelper
  include JobsHelper
  include QuestionsManager
  include UsersManager
  include AnswersManager
  include SchoolsManager
  include SyllabusManager
  include EnterpriseUsersManager
  include AdminsManager
  include UpvotesManager
  include FeedItemsManager
  include ProfilesManager
  include CommentsManager
  include FirstUserExperienceManager
  include MeedPointsTransactionManager
  include IntercomManager
  include SessionsHelper
  include CommonHelper

  $log = Logger.new('error_log.log', 'monthly')
  $SESSION_EXPIRY = 12000

  def set_cache_buster
    response.headers['Cache-Control'] = 'no-cache, no-store, max-age=0, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = 'Fri, 01 Jan 1990 00:00:00 GMT'
  end

  def cookie_manager
    # save request referrer as params
    unless request.referrer.blank?
      params[:request_referrer] = request.referrer
    end

    if cookies[:meed_user_tracker].blank?
      cookies[:meed_user_tracker] = Digest::SHA1.hexdigest(Time.now.to_s)
    end
  end

  def has_company? redirect_url = false, allow_pseudo_logged = false
    if current_user && current_user.company
      true
    else
      respond_to do |format|
        format.html { redirect_to root_path }
        format.json {
          data = {
            success: false,
            redirect_url: root_path,
            error: "You must be logged in to do that."
          }

          render(json: data, status: 403) and return false
        }
      end
      false
    end
  end

  def logged_in? redirect_url = false, allow_pseudo_logged = false
    if has_no_session? or current_user.blank? or (session_pseudo? && !allow_pseudo_logged)
      reset_session

      respond_to do |format|
        format.html { redirect_to get_loginurl_with_redirect(redirect_url) }
        format.json {
          data = {
              success: false,
              redirect_url: get_loginurl_with_redirect(redirect_url),
              error: "You must be logged in to do that."
          }

          render(json: data, status: 403) and return false
        }
      end
      return false
    end
    true
  end

  def pseudo_logged_in? redirect_url = false
    return logged_in? redirect_url, true
  end

  def logged_in_json?
    if has_no_session? or current_user.blank?
      reset_session
      unauth_hash = Hash.new
      unauth_hash[:success] = false
      unauth_hash[:reason] = 'un_auth'
      respond_to do |format|
        format.json { render json: unauth_hash.to_json }
      end
      return false
    end
    true
  end


  def is_eligible_to_post
    can_user_post(current_user)
  end

  def get_loginurl_with_redirect(redirect_url)
    redirect_url ||= request.url
    return "/login?redirect_url=#{redirect_url}"
  end

  def get_school_prefix
    if current_user.blank?
      return ''
    end
    get_school_prefix_from_email(current_user.id)
  end

  def set_activity_page_default
    session[:activity_page_default] = true
  end

  def unset_activity_page_default
    session[:activity_page_default] = false
  end

  def is_activity_page_default?
    session[:activity_page_default]
  end

  def current_school_handle
    if current_user.blank?
      return ''
    end
    get_school_handle_from_email(current_user.id)
  end

  def current_school_name
    if session[:school_name].blank?
      school = get_school(current_school_handle)
      unless school.blank?
        session[:school_name] = school.name
      end
    end
    session[:school_name]
  end

  def get_school_logo_url(handle)
    school = get_school(handle)
    unless school.blank? or school.logo.blank?
      return school.logo
    end
    ''
  end

  def has_no_session?
    return !session[:handle].present? || (session[:last_seen].present? && session[:last_seen] < $SESSION_EXPIRY.minutes.ago)
  end

  def public_view_session?
    if !session[:handle].present? || (session[:last_seen].present? && session[:last_seen] < $SESSION_EXPIRY.minutes.ago)
      reset_session
      if params[:verify_token].blank?
        redirect_to root_path + '?reg=true'
      else
        redirect_to "#{get_user_verification_url(params[:verify_token])}&ab_id=#{params[:ab_id]}"
      end
      return false
    end
    true
  end

  def reset_current_user
    session[:user] = nil
  end

  def current_user(force = false, pseudo_session = false)
    if session[:handle].blank?
      return nil
    end
    if session[:user].blank? || force
      if pseudo_session
        user = get_user_by_handle(session[:handle])
      else
        user = get_active_user_by_handle(session[:handle])
      end
      unless user.blank?
        if user[:handle].present? and user[:handle] == session[:handle]
          user[:name] = user.name
          user[:is_meediorite] = user.is_meediorite?
          if !user.company_id.blank? and user.verified_current_company
            user[:company] = get_company_by_id(user.company_id)
          end
          handle = user[:handle]
          profile = get_user_profile_or_new(handle)
          if user.badge.eql? 'influencer'
            is_incomplete = is_influencer_incomplete_profile(user)
          else
            is_incomplete = is_incomplete_profile(profile)
          end
          user[:is_profile_incomplete] = is_incomplete
          if is_incomplete
            user[:incomplete_reason] = profile_incomplete_reason(profile)
          end
          user[:pseudo_session] = pseudo_session
          session[:user] = user
          return user
        end
      end
    end
    if session[:user] && (session[:user].last_login_dttm.blank? or  session[:user].last_login_dttm > 1.minutes.ago)
      session[:user].last_login_dttm = Time.now
    end
    session[:user]
  end

  def current_inbox_key
    if session[:current_inbox_key].blank?
      session[:current_inbox_key] = get_user_inbox_key(current_user[:handle])
    end
    session[:current_inbox_key]
  end

  def current_major
    current_user.major
  end

  def current_major_code
    current_user.major_id
  end

  def require_user
    unless current_user
      store_location
      flash[:notice] = 'You must be logged in to view this page'
      redirect_to 'sessions/create_question'
      return false
    end
  end

  def set_inbox_count(count)
    session[:job_inbox_count] = count
  end

  def set_new_message_count(count)
    session[:message_new_count] = count
  end

  def current_badges
    if session[:current_badges].blank?
      badges_hash = Hash.new
      message_count = get_unread_message_count(current_user.id)

      if message_count.blank?
        badges_hash[:message_count] = 0
      else
        badges_hash[:message_count] = message_count
      end
      session[:current_badges] = badges_hash
    end
    session[:current_badges]
  end

  def update_message_count
    session[:current_badges][:message_count] = get_unread_message_count(current_user.id)
  end

  def dec_inbox_count
    if !session[:job_inbox_count].blank? and session[:job_inbox_count] > 0
      session[:job_inbox_count] = session[:job_inbox_count] - 1
    end
  end

  def is_profile_incomplete
    if session[:is_profile_incomplete].blank?
      unless current_user.blank?
        handle = current_user[:handle]
        profile = get_user_profile_or_new(handle)
        is_incomplete = is_incomplete_profile(profile)
        session[:is_profile_incomplete] = is_incomplete
        return is_incomplete
      end
    else
      return session[:is_profile_incomplete]
    end
    false
  end

  def has_invited_friends?
    if session[:has_invited_friends].blank?
      unless current_user.blank?
        profile = get_user_profile_or_new(current_user[:handle])
        session[:has_invited_friends] = profile[:invited_friends]
        return profile[:invited_friends]
      end
    end
    session[:has_invited_friends]
  end

  def reset_is_profile_incomplete(profile = nil)
    session[:is_profile_incomplete] = nil
    unless profile.blank?
      is_incomplete_profile(profile)
    end
  end

  def destroy_session_attributes
    session[:handle] = nil
    session[:is_profile_incomplete] = nil
    session[:show_diff_home_page] = nil
    session[:job_inbox_count] = nil
    session[:current_inbox_key] = nil
    session[:current_major] = nil
    session[:has_invited_friends] = nil
    session[:current_major_code] = nil
    session[:has_invited_friends] = nil
    session[:school_name] = nil
    session[:user] = nil
    session[:current_badges] = nil
    session[:activity_page_default] = nil
    cookies[:referrer] = ''
    cookies[:campaign_type] = ''
  end

  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def authenticate(user)
    unless logged_in?
      return false
    end

    unless user.is_admin?
      redirect_to '/'
      return false
    end
    true
  end

  def page_title(page_title)
    @page_title = page_title.to_s
  end

  def page_heading(page_heading)
    @page_heading = page_heading.to_s
  end

  def update_current_user(user)
    session[:user] = user
  end

  def page_sub_heading(heading)
    @page_sub_heading = heading.to_s
  end

  def filter_jobs_for_viewer(jobs)
    unless current_user.blank?
      jobs.delete_if { |job| (!job.schools.include? current_school_handle) or
          (!job.majors.include? current_user.major_id) }
    end
    jobs
  end

  def handle_show_question (question)
    @answers = Array.[]
    if !question.blank? and !question.majors.blank?
      majors = get_majors_for_ids (@question.majors)
      @major_string = build_major_separated_string(majors)
    end
    if !question.blank? and !question.answer_ids.blank?
      @answers = get_answers_for_ids(question.answer_ids)
    end
    @code_types = get_all_code_types
    user_handles = Array.[]
    @user_map = Hash.new
    @let_add_answer = true
    if !@answers.blank?
      @answers.each do |answer|
        if @let_add_answer and !current_user.blank? and answer.user_handle.eql? current_user.handle
          @let_add_answer = false
        end
        user_handles << answer.user_handle
      end
      @answer_count = @answers.length
    end
    unless current_user.blank?
      @is_following = false
      @user_upvotes = get_user_upvotes(current_user.handle)
      if !question.follow_handles.blank?
        @is_following = question.follow_handles.include? current_user.handle
      end
    end
    users = get_users_by_handles (user_handles)
    users.each do |user|
      @user_map[user.handle] = user
    end
    update_question_view_count(question.id)
    increment_feed_view_count(question.id)
  end

  def page_not_found
    @url = params[:url]
    render 'errors/not_found_error'
  end

  def server_error(exception)
    if !current_user.blank? and current_user.is_admin?
      raise exception
    else
      if Rails.env.development?
        raise exception
      else
        render 'errors/internal_error'
      end
    end
  end

  def require_moderator
    head :unauthorized unless current_user.is_moderator?
  end

  def render_angular_for_html_request
    if request.format == 'html'
      render layout: "angular_app", template: "angular_app/index"
      return
    end
  end
end

