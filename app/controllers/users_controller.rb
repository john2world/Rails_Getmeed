require 'logger'
class UsersController < ApplicationController
  include UsersManager
  include SchoolsManager
  include CrmManager
  include SessionsHelper
  include UsersHelper
  include CommonHelper
  include EventsManager
  include EventsHelper
  include LeadsManager
  include IntercomManager

  def recommended_users
    users = []
    if current_user.blank?
      users = get_recommended_influencers_for_user(nil)
    else
      users = get_recommended_influencers_for_user(current_user.handle)[0..10]
      users.concat get_recommended_school_users(current_user.handle)[0..10]
      users = users.sort_by(&:meed_points).reverse
    end
    build_user_models(current_user, users[0..19])
    respond_to do |format|
      format.json {
        render json: {recommended_users: users}
      }
    end
  end

  def recommended_lead_users
    if current_user.blank?
      users = []
    else
      users = search_leads(current_user, params[:query], 9)
      #users = search_lead_user_by_name(current_user, params[:query])
    end
    #build_intercom_user_lead_models(users)
    build_user_lead_models(users)
    respond_to do |format|
      format.json {
        render json: {lead_users: users}
      }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @user }
    end
  end

  # GET /users/create_question
  # GET /users/create_question.json
  def new
    unless logged_in?
      return
    end

    respond_to do |format|
      format.html # create_question.html.erbion.html.erb
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  def influencer_expertise_save
    influencer_account
  end

  def influencer_account
    error_template = 'users/create'
    ret_hash = {}
    if request.format == :json
      params.merge!(get_params_from_url(request.referrer))
    end
    if params[:primary_email].blank?
      return error_render('Primary email can\'t be blank', error_template)
    end

    if params[:first_name].blank?
      return error_render('Please enter a first name', error_template)
    end
    if params[:last_name].blank?
      return error_render('Please enter a last name', error_template)
    end
    if params[:password].blank?
      return error_render('Password can\'t be blank.', error_template)
    end
    params[:handle] = get_next_handle_from_name(params[:first_name], params[:last_name])
    # determine the user signup state
    @user = get_user_by_email(params[:primary_email])
    params[:active] = true
    params[:badge] = UserBadgeTypes::INFLUENCER
    @user = create_influencer(params)
    IntercomConvertContactWorker.perform_async(@user.id.to_s, params[:referrer])
    respond_to do |format|
      format.json {
        return render json: {success: true, verify_email: false, redirect_url: '/?lb=1'}
      }
    end

  end

  # POST /users/account
  def account
    error_template = 'users/create'
    ret_hash = {}
    if request.format == :json
      params.merge!(get_params_from_url(request.referrer))
    end
    @majors = admin_all_majors.sort_by! { |m| m[:major].downcase }
    if params[:primary_email].blank?
      return error_render('Primary email can\'t be blank', error_template)
    end

    @majors = admin_all_majors.sort_by! { |m| m[:major].downcase }
    @degrees = Futura::Application.config.UserDegrees
    @selected_major = params[:major]
    @selected_minor = params[:minor]
    @selected_degree = params[:degree]
    if params[:first_name].blank?
      return error_render('Please enter a first name', error_template)
    end
    if params[:last_name].blank?
      return error_render('Please enter a last name', error_template)
    end
    if params[:university_email].blank?
      ret_hash[:error] = 'schoolEmailBlank'
      ret_hash[:success] = false
    end

    if params[:degree].blank?
      return error_render('Please enter a degree', error_template)
    end
    if params[:major].blank?
      return error_render('Please select a major', error_template)
    end
    if params[:phone_field].blank?
      return error_render('Phone Number can\'t be blank.', error_template)
    end
    if params[:year].blank?
      return error_render('Please enter year of graduation', error_template)
    end
    if params[:password].blank?
      return error_render('Password can\'t be blank.', error_template)
    end
    params[:handle] = get_handle_from_email(params[:university_email])
    unless is_handle_available(params[:handle])
      params[:handle] = get_next_handle_from_name(params[:first_name], params[:last_name])
    end
    # determine the user signup state
    @user = get_user_by_email(params[:university_email])

    email_invitation = get_email_invitation_for_email(params[:university_email])
    school_handle = get_school_handle_from_email(params[:university_email])
    school = get_school(school_handle)
    if school.blank?
      school = create_school(school_handle, nil)
    end
    if school.name.blank? and !params[:school_field].blank?
      update_school_name(school, params[:school_field])
    end
    referrer_url = ''
    unless request.referrer.blank?
      path = URI.parse(request.referrer).path
      unless path == "/" || path.blank?
        referrer_url = request.referrer
      end
    end

    state = get_signup_state(@user, email_invitation, school)

    case state
      when :signin
        msg = 'You are already verified, please sign in.'
        return error_redirect(msg, nil, {:action => "signin"})
      when :verify_email
        send_email_invitation(@user.id)
        # take user to the verification state.
        respond_to do |format|
          format.json {
            return render json: {success: true, verify_email: true, referrer_url: referrer_url, campaign_type: params[:campaign_type]}
          }
        end
      when :create_user
        # everything is fine but user object needs to be updated and user must be activated
        params[:active] = true
        @user = create_user(params, nil)
        IntercomConvertContactWorker.perform_async(@user.id.to_s, params[:referrer])
        session[:reg_email] = @user.email
        respond_to do |format|
          format.json {
            return render json: {success: true, verify_email: false, redirect_url: '/?lb=1', referrer_url: referrer_url, campaign_type: params[:campaign_type]}
          }
        end
      when :waitlist_status
        # redirect user to the place where he can get the status
        msg = "You are already in Waitling list."
        redirect_url = url_for(:controller => "home", :action => "need_meed", :email => params[:university_email])
        return error_redirect(msg, redirect_url)
      when :waitlist_nosignup
        # not supported university
        put_in_wait_list(school_handle, params[:university_email], params)
        respond_to do |format|
          format.html {
            return render :template => 'users/waitlist'
          }
          format.json {
            return render json: {success: false, school_handle: school_handle, waitlist: true, referrer_url: referrer_url, campaign_type: params[:campaign_type]}
          }
        end
      when :signup
        params[:active] = false
        @user = create_user(params, nil)
        if @user.blank?
          msg = 'Something went wrong! Please try again.'
          redirect_url = root_path
          return error_redirect(msg, redirect_url)
        end
        session[:reg_email] = @user.email
        send_email_invitation(@user.id)
        rparams = params.except(:token, :primary_email, :major, :minor, :degree, :first_name, :last_name, :phone_field, :year, :password, :handle)
        NotificationsLoggerWorker.perform_async('Consumer.User.Account',
                                                {handle: @user.handle,
                                                 token: params[:token],
                                                 params: rparams,
                                                 ref: {ref: params[:referrer],
                                                       meed_user_tracker: cookies[:meed_user_tracker]}
                                                })
        IntercomLoggerWorker.perform_async('signup-account', @user[:_id].to_s, {
                                                               token: params[:token],
                                                               ref: params[:referrer]
                                                           })
        respond_to do |format|
          format.json {
            return render json: {success: true, verify_email: true, referrer_url: referrer_url, campaign_type: params[:campaign_type]}
          }
        end
      when :waitlist_signup
        params[:active] = false
        @user = create_user(params, nil)
        # incrementing the waitlist no
        @user.add_waitlist_no()
        meta_data = @user.meta_data
        unless meta_data.blank?
          meta_data["campaign_type"] = params[:campaign_type]
          @user.meta_data = meta_data
        end
        @user.save
        if @user.blank?
          msg = 'Something went wrong! Please try again.'
          redirect_url = root_path
          return error_redirect(msg, redirect_url)
        end
        session[:reg_email] = @user.email
        send_waitlist_email_invitation(@user.id)
        # For waitlist there is no redirect url
        referrer_url = nil
        # send waitlist email
        WelcomeWaitlistUserWorker.perform_async(@user.handle)
        # create a reminder in 3 days
        WaitlistReminderWorker.perform_at(3.days.from_now, @user.handle, 0)
        rparams = params.except(:token, :primary_email, :major, :minor, :degree, :first_name, :last_name, :phone_field, :year, :password, :handle)
        NotificationsLoggerWorker.perform_async('Consumer.User.Account.Waitlist',
                                                {handle: @user.handle,
                                                 token: params[:token],
                                                 params: rparams,
                                                 ref: {ref: params[:ref],
                                                       meed_user_tracker: cookies[:meed_user_tracker]}
                                                })
        IntercomLoggerWorker.perform_async('waitlist-signup-account', @user[:_id].to_s, {
                                                                        token: params[:token],
                                                                        ref: params[:ref]
                                                                    })
        # check if this is coming from ama. if yes add to ama page
        ama_id = get_ama_id_from_url(request.referrer)
        unless ama_id.blank?
          user_follow_ama(ama_id, @user.handle)
        end
        respond_to do |format|
          format.json {
            return render json: {success: true, verify_email: true, waitlist: true,
                                 email: @user.id, handle: @user.handle, referrer_url: referrer_url,
                                 invite_url: get_need_meed_referral_url(@user.handle, params[:campaign_type]),
                                 campaign_type: params[:campaign_type]}
          }
        end
    end
  end


  def incomplete
    unless logged_in?
      return
    end
    @degrees = Futura::Application.config.UserDegrees
    @majors = admin_all_majors
    @user = current_user
    respond_to do |format|
      format.html # view.html.erb
    end
  end

  def promotion
    leader_board_users = get_users_by_handles(MODERATOR_HANDLES)[0..4]
    leader_board_users << current_user
    result = {}
    result[:users] = leader_board_users
    result[:first_prize] = 'Bose QC Comfort'
    result[:first_prize_url] = 'getmeed.com'
    result[:second_prize] = 'Bose QC Comfort 2'
    result[:second_prize_url] = 'getmeed.com'
    result[:third_prize] = 'Bose QC Comfort 3'
    result[:third_prize_url] = 'getmeed.com'
    result[:current_position] = 25
    respond_to do |format|
      format.json { render json: result }
    end
  end

  def leader_board
    leader_board_users = get_leaderboard_users(4).to_a
    leader_board_users = build_user_models(leader_board_users)
    add_current_user = true
    leader_board_users.each do |user|
      if !current_user.blank? and (user.handle.eql? current_user.handle or MEED_HANDLES.include? current_user.handle)
        add_current_user = false
      end

    end
    if add_current_user and !current_user.blank?
      leader_board_users << current_user
    end

    leader_board_users.sort_by!(&:meed_points).reverse!
    leader_board_users.each_with_index do |user, index|
      if add_current_user and !current_user.blank? and user.handle.eql? current_user.handle
        user[:rank] = get_leaderboard_rank(user.meed_points)
      else
        user[:rank] = index + 1
      end
    end


    result = {}
    result[:users] = leader_board_users
    result[:prizes] = [
        {name: "Bose Bluetooth headset", image_url: "https://res.cloudinary.com/resume/image/upload/c_scale,w_120/v1442028384/bose_714675_0020_soundlink_on_ear_blue_1078141_whsn53.jpg"},
        {name: "One year Spotify Premium", image_url: "https://res.cloudinary.com/resume/image/upload/c_scale,w_120/v1442028091/spotify-logo-horizontal-black_lekwu4.jpg"},
        {name: "Chipotle $100 credit", image_url: "https://res.cloudinary.com/resume/image/upload/c_scale,w_120/v1442028302/logo-chipotle_awjyni.png"},
    ]
    respond_to do |format|
      format.html { redirect_to "/" }
      format.json { render json: result }
    end

  end

  def leader_board_show
    unless logged_in?(root_path)
      return
    end
    return redirect_to(root_path(lb: 1))
  end

  def earn_meed_points
    return redirect_to(root_path(lb: 1, mp: 1))
    @show_top_bar = true
    @dont_show_header = true
  end

  def linkedin_create
    if session[:reg_email].blank? && current_user.email.blank?
      flash[:alert] = 'Something went wrong, please verify your email!'
      redirect_to root_path
      return
    end

    if current_user.blank?
      @user = User.find(session[:reg_email])
    else
      @user = current_user
    end

    if @user.blank?
      flash[:alert] = 'Can\'t find user, please verify again'
      redirect_to root_path
      return
    end
    @handle = get_handle_from_email(@user.id)
    @majors = admin_all_majors.sort_by! { |m| m[:major].downcase }
    @degrees = Futura::Application.config.UserDegrees
    # Logging event in Intercom
    respond_to do |format|
      format.html # view.html.erb
    end
  end

  def linkedin_complete
  end

  # POST /users/create
  # POST /users.json
  # Scenario when a user with a valid token tries to create an account.
  # Even with a valid token, the user must
  def create
    # if there is a redirect uri, store in cookies before any further redirection
    save_redirect_url(params)
    ret_hash = {}

    if params[:token] == nil
      return error_redirect('Please signup/signin to continue', root_path)
    end
    if params[:token].blank?
      return error_redirect('Invalid verification code!', root_path)
    end

    email_invitation = get_email_invitation_by_id(params[:token])
    unless params[:ab_id].blank?
      session[:ab_id] = params[:ab_id]
      track_email_click(params[:ab_id])
    end
    if email_invitation.blank?
      return error_redirect('Your invitation has expired. Please verify your email again', root_path)
    end
    email = email_invitation[:email]
    @reg_email = email
    session[:reg_email] = email
    session[:current_email] = email
    unless email_invitation[:invitor_handle].blank?
      friend_user = get_active_user_by_handle(email_invitation[:invitor_handle])
      unless friend_user.blank?
        @friend_name = friend_user[:first_name]
      end
    end

    @school_handle = get_school_handle_from_email(email).upcase
    @majors = admin_all_majors.sort_by! { |m| m[:major].downcase }
    @degrees = Futura::Application.config.UserDegrees

    email_invitation[:activated] = true
    @user = get_user_by_email(email)
    if @user.blank?
      return error_redirect('Can\'t find user, please verify again', root_path)
    end
    @handle = @user.handle
    if @user.active
      return error_redirect('You are already verified, please sign in.', root_path)
    end

    if @user.handle
      # if user in wait list, don't active, just return the
      activate_user_live(@user.handle)
      update_session_with_user(@user)
      NotificationsLoggerWorker.perform_async('Consumer.User.Create',
                                              {handle: @handle,
                                               token: params[:token],
                                               params: params,
                                               ref: {ref: params[:ref],
                                                     meed_user_tracker: cookies[:meed_user_tracker]}
                                              })
      ret_hash[:success] = true
      ret_hash[:redirect_url] = '/?lb=1'
      IntercomConvertContactWorker.perform_async(@user.id.to_s, cookies[:referrer])
      # WelcomeNewUserWorker.perform_async(@user.handle)
      redirect_url = '/'
    else
      # the user has no information so
      ret_hash[:success] = false
      ret_hash[:redirect_url] = '/'
      ret_hash[:error] = "Account not created."
      redirect_url = "/?email=#{email}"
    end
    email_invitation.save
    # moving this to synchronous to be able to track the conversions from intercom

    respond_to do |format|
      format.json {
        return render json: ret_hash
      }
      format.html {
        return redirect_to redirect_url
      }
    end
  end

  def password
    @invitation_id = params[:token]
    @invitation = get_email_invitation_by_id(@invitation_id)
    if @invitation.blank?
      flash[:alert] = "Can't verify account"
      render '/login'
    end
    @invitation[:activated] = true

    @invitation.save!
    respond_to do |format|
      format.html # create_question.html.erbion.html.erb
    end
  end

  def passwordsubmit
    @password = params[:password]
    @token = params[:token]
    @confirm_password = params[:confirm_password]
    if !@password.eql? @confirm_password
      flash[:alert] = 'Passwords don\'t match.'
      render '/users/password'
      return
    end
    @invitation = get_email_invitation_by_id(@token)

    if @invitation.nil?
      flash[:alert] = 'Passwords don\'t match.'
      redirect_to '/users/login'
      return
    end

    @user = User.find(@invitation[:email])
    @user[:password_hash] = encrypt_password(params[:password])
    @user.save!
    update_session_with_user(@user)
    rparams = params.except(:password, :token, :confirm_password)

    NotificationsLoggerWorker.perform_async('Consumer.User.PasswordReset',
                                            {handle: @user[:handle],
                                             token: params[:token],
                                             params: rparams,
                                             ref: {ref: params[:ref],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    # Logging event in Intercom
    unless @user.blank?
      IntercomLoggerWorker.perform_async('password-reset', @user.id.to_s, {
                                                             token: params[:token],
                                                             ref: params[:ref]
                                                         })
    end

    flash[:notice] = 'Logged in successfully.'
    redirect_to '/home'
    return
  end

  def forgot
    @show_top_bar = true
  end

  def forgotme
    @show_top_bar = true
    @email = params[:email]
    if @email.blank?
      redirect_to '/users/forgot'
      flash[:alert] = 'Please enter an email.'
      return
    end
    @school_handle = get_school_handle_from_email @email
    user = get_user_by_email(@email)

    if user.blank?
      flash[:alert] = 'No user registered with that email.'
      redirect_to action: "forgot"
      return
    end
    unless user.primary_email.blank?
      @email = user.primary_email
    end

    unless send_email_password_reset(@email)
      flash[:alert] = 'Something went wrong! Please try again.'
      redirect_to action: "forgot"
      return
    end
    rparams = params.except(:email)

    NotificationsLoggerWorker.perform_async('Consumer.User.ForgetMe',
                                            {email: @email,
                                             params: rparams,
                                            })
    # Logging event in Intercom
    unless user.blank?
      IntercomLoggerWorker.perform_async('forgetme', user[:_id].to_s, {ref: params[:ref]})
    end
  end

  def check_handle
    handle = params[:handle]
    result = is_handle_available(handle)
    respond_to do |format|
      format.json { render json: result }
    end
  end

  def verify
    @show_top_bar = true
    if params[:email].blank?
      msg = 'Please enter a valid \'.edu\' email'
      redirect_url = root_path
      return error_redirect(msg, redirect_url)
    end
    @email = params[:email].gsub(/\s+/, '')
    @email = @email.downcase
    session[:verify_email] = @email
    session[:reg_email] = @email
    unless is_a_valid_edu_email(@email)
      flash[:alert] = 'Please enter a valid \'.edu\' email'
      @error = 'not_student'
      domain = get_handle_from_email(@email)
      put_in_wait_list(domain, @email)

      msg = 'Please enter a valid \'.edu\' email'
      redirect_url = root_path
      return error_redirect(msg, redirect_url)

    end
    @user = get_user_by_email(@email)
    if !@user.blank? && @user[:active] && !params[:forgot_email].present?
      msg = 'User already exists! Please login.'
      redirect_url = root_path
      return error_redirect(msg, redirect_url)
    end

    @school_handle = get_school_handle_from_email(@email);
    @school = get_school(@school_handle)

    if @school.blank? || !@school.active
      put_in_wait_list(@school_handle, @email)
      session[:school_handle] = @school_handle
      respond_to do |format|
        format.html {
          return render :template => 'users/waitlist'
        }
        format.json {
          return render json: {success: true, school_handle: @school_handle, waitlist: true}
        }
      end
    end

    unless @user.blank?
      if @user.active
        msg = 'You are already verified, please sign in.'
        redirect_url = root_path
        return error_redirect(msg, redirect_url)
      else
        unless send_email_invitation(@email)
          msg = 'Something went wrong! Please try again.'
          redirect_url = root_path
          return error_redirect(msg, redirect_url)
        end
        respond_to do |format|
          format.html { return render }
          format.json {
            return render json: {success: true, verify_email: true}
          }
        end
      end
    end
    @user = create_passive_user(@email, params[:ref])
    rparams = params.except(:email, :forgot_email)

    NotificationsLoggerWorker.perform_async('Consumer.User.Verify',
                                            {email: @email,
                                             params: rparams,
                                             ref: {ref: params[:ref],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    unless send_email_invitation(@email)
      msg = 'Something went wrong! Please try again.'
      redirect_url = root_path
      return error_redirect(msg, redirect_url)
    end
    respond_to do |format|
      format.html
      format.json {
        return render json: {success: true, verify_email: true}
      }
    end
  end

  def waitlist_verify
    if params[:token] == nil
      return error_redirect('Please signup/signin to continue', root_path)
    end
    if params[:token].blank?
      return error_redirect('Invalid verification code!', root_path)
    end

    referrer_url = ''
    unless request.referrer.blank?
      path = URI.parse(request.referrer).path
      unless path == "/" || path.blank?
        referrer_url = request.referrer
      end
    end

    email_invitation = get_email_invitation_by_id(params[:token])
    if email_invitation.blank?
      return error_redirect('Your invitation has expired. Please verify your email again', root_path)
    end
    email = email_invitation[:email]
    @handle = get_handle_from_email(email)
    @reg_email = email
    session[:reg_email] = email
    session[:current_email] = email
    email_invitation[:activated] = true
    @user = get_user_by_email(email)
    if @user.blank?
      return error_redirect('Can\'t find user, please verify again', root_path)
    end

    if @user.active
      return error_redirect('You are already verified, please sign in.', root_path)
    end

    campaign_type = nil
    unless params[:campaign_type].blank?
      campaign_type = params[:campaign_type]
    end

    if campaign_type.blank?
      unless @user.meta_data.blank?
        campaign_type = @user.meta_data['campaign_type']
      end
    end

    respond_to do |format|
      format.html {
        redirect_to get_waitlist_status_url(@reg_email)
      }
      format.json {
        return render json: {success: true, verify_email: false, action: "waitlist", waitlist_no: @user.waitlist_no,
                             email: @user.id, handle: @user.handle, referrer_url: referrer_url,
                             invite_url: get_need_meed_referral_url(@user.handle, params[:campaign_type]),
                             campaign_type: params[:campaign_type]}
      }
    end
  end

  def send_email_invitation(email)
    rparams = params.except(:password)
    NotificationsLoggerWorker.perform_async('Consumer.User.EmailInvitation',
                                            {email: email,
                                             params: rparams,
                                             ref: {meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    email_invitation = create_email_invitation_for_email(email, nil)
    if email_invitation.blank?
      return
    end
    #Notifier.email_verification(email, email_invitation[:token]).deliver
    EmailVerifyWorker.perform_async(email)
    true
  end

  def send_waitlist_email_invitation(email)
    email_invitation = create_email_invitation_for_email(email, nil)
    NotificationsLoggerWorker.perform_async('Consumer.User.WaitlistEmailInvitation',
                                            {email: email,
                                             params: params,
                                             ref: {meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    Notifier.waitlist_email_verification(email, email_invitation[:token]).deliver
  end

  def send_email_password_reset(email)
    @email_invitation = create_email_invitation_for_email(email, nil)
    Notifier.email_password_reset(email, @email_invitation[:_id]).deliver
    true
  end

  def invite

  end

  def incomplete_submit
    user = current_user
    unless params[:primary_email].blank?
      user.primary_email = params[:primary_email]
    end

    unless params[:first_name].blank?
      user.first_name = params[:first_name]
    end

    unless params[:last_name].blank?
      user.last_name = params[:last_name]
    end

    unless params[:degree].blank?
      user.degree = params[:degree]
    end


    unless params[:phone_field].blank?
      user.phone_number = params[:phone_field]
    end

    unless params[:major].blank?
      major = get_majors_for_ids(params[:major])
      user[:major] = major[:major]
      user[:major_id] = major[:_id]
    end

    unless params[:year].blank?
      user[:year] = params[:year]
    end

    user.save!

    redirect_to '/home'

  end

  # Simple API endpoint for getting the current user as a JSON object
  def get_current_user
    return render(json: {success: false}) unless current_user
    if params[:force] == 'true'
      ret = current_user(true)
    else
      ret = current_user
    end
    ret[:success] = true
    school_handle = current_user.school_id
    if school_handle.blank?
      school_handle = get_school_handle_from_email(current_user.id)
    end
    school = get_school(school_handle)
    unless school.blank?
      ret[:school_handle] = if school.name.length < 10 then
                              school.name.capitalize
                            else
                              school.handle.length < 5 ? school.handle.upcase : school.handle.capitalize
                            end
      ret[:school_name] = school.name
    end
    ret[:show_invite] = true
    ret[:notifications_count] = get_notification_count_for_user(current_user.handle)
    ret[:verified_current_company] = current_user.verified_current_company if current_user.verified_current_company
    ret = ret.to_json
    respond_to do |format|
      format.json { return render json: ret }
    end
  end


end
