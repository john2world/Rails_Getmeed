class SessionsController < ApplicationController
  include SessionsHelper
  include UsersManager
  include CommonHelper
  include CollectionsManager

  def new
    @redirect_url=params[:redirect_url]
    save_redirect_url(params)
    page_heading('Sign In')
    page_title('Sign In')
    @show_top_bar = true
    if has_no_session?
      render 'new'
    else
      redirect_to '/home'
    end
  end

  def demo
    params[:username] = 'ravi'
    params[:password] = 'software'
    params[:is_demo] = true
    create
  end


  def create
    username = params[:username].gsub(/\s+/, "")
    ret_hash = {}

    if username.blank?
      ret_hash[:error] = 'usernameBlank'
      ret_hash[:success] = false
    end

    page_heading('Sign In')

    if params[:password].blank?
      ret_hash[:error] = 'passwordBlank'
      ret_hash[:success] = false
    end
    username = username.downcase
    user = get_user_by_email(username)
    if user.blank?
      user = get_active_user_by_handle(username)
    end

    if user.blank?
      ret_hash[:error] = 'accountDoesntExistCreate'
      ret_hash[:success] = false
      ret_hash[:redirect_url] = '/'
    elsif !user[:active]
      waitlist_user = get_waitlist_user(user.id)
      if waitlist_user.blank?
        ret_hash[:error] = 'accountDoesntExistCreate'
        ret_hash[:redirect_url] = '/'
      else
        ret_hash[:error] = 'accountDoesntExistCreate'
        ret_hash[:redirect_url] = '/user/waitlist'
      end
      ret_hash[:success] = false
    end


    if ret_hash[:success] == false
      respond_to do |format|
        format.html {
          flash[:alert] = ret_hash[:error]
          return redirect_to ret_hash[:redirect_url]
        }
        format.json { return render json: ret_hash }
      end
      return
    end

    if user && user.authenticate(user.id, params[:password])
      update_session_with_user(user)
      user[:last_login_dttm] = Time.zone.now
      user.save!
      NotificationsLoggerWorker.perform_async('Consumer.Session.Login',
                                              {handle: user[:handle],
                                               params: params,
                                               ref: {referrer: params[:referrer],
                                                     referrer_id: params[:referrer_id],
                                                     referrer_type: params[:referrer_type],
                                                     meed_user_tracker: cookies[:meed_user_tracker]}
                                              })
      # Logging event in Intercom
      unless current_user.blank?
        IntercomLoggerWorker.perform_async('login', current_user[:_id].to_s, {
                                                      ref: {referrer: params[:referrer],
                                                            referrer_id: params[:referrer_id],
                                                            referrer_type: params[:referrer_type]}
                                                  })
      end

      cids = get_user_follow_collection_ids(user.handle)
      if cids.blank?
        redirect_url = '/?lb=1'
      end

      if request.referrer.blank?
        redirect_url = '/'
      else
        redirect_url = request.referrer
      end
      ret_hash[:redirect_url] = redirect_url
      ret_hash[:success] = true

    else
      ret_hash[:error] = 'invalidCredentials'
      ret_hash[:redirect_url] = '/login'
      ret_hash[:success] = false
    end
    respond_to do |format|
      format.html {
        flash[:alert] = ret_hash[:error]
        return redirect_to ret_hash[:redirect_url]
      }
      format.json { return render json: ret_hash }
    end
  end

  def social_sign_up
    ret_hash = {}

    unless current_user.blank?
      session[:omniauth_auth] = nil # clear out any auth that was there before
      ret_hash[:success] = false
      ret_hash[:reason] = 'Already signed in'
      ret_hash[:redirect_url] = "/"
      respond_to do |format|
        format.json { return render json: ret_hash }
      end
      return
    end

    oauth_token = params[:oauth_token]

    unless request.env['omniauth.auth'].blank?
      if request.env['omniauth.auth']['provider'].eql? 'facebook' or request.env['omniauth.auth']['provider'].eql? 'github'
        oauth_token = request.env['omniauth.auth']['credentials']['token']
      end
      Rails.cache.fetch("#{REDIS_KEYS::CACHE_OAUTH_TOKEN}-#{oauth_token}", :expires_in => 5.minutes) do
        oauth_data = request.env['omniauth.auth']
        session[:omniauth_auth] = nil
        session[:omniauth_auth] = {}
        if oauth_data['provider'].eql? 'facebook' or oauth_data['provider'].eql? 'github'
          oauth_token = oauth_data['credentials']['token']
        end
        ret_hash[:name] = oauth_data['info']['name']

        name = ret_hash[:name]

        first_name = name.split.count > 1 ? name.split.first : name
        last_name = name.split.count > 1 ? name.split.last : ""

        ret_hash[:first_name] = first_name
        ret_hash[:last_name] = last_name
        ret_hash[:handle] = generate_id_from_text(oauth_data['info']['nickname'])
        ret_hash[:image_url] = oauth_data['info']['image']
        ret_hash[:headline] = oauth_data['info']['description']
        ret_hash[:urls] = oauth_data['info']['urls']
        ret_hash[:source] = oauth_data['provider']
        ret_hash[:primary_email] = oauth_data['info']['email']
        ret_hash[:summary] = oauth_data['extra']['raw_info']['summary']
        session[:omniauth_auth][oauth_token] = ret_hash
        ret_hash
      end
    end

    respond_to do |format|
      format.html {

        return redirect_to root_path(oauth_token: oauth_token )
      }
      format.json {
        ret_hash = Rails.cache.fetch("#{REDIS_KEYS::CACHE_OAUTH_TOKEN}-#{oauth_token}")
        if ret_hash.blank?
          return render json: {success: false, redirect_url: "/"}
        else
          ret_hash = ret_hash
          ret_hash[:success] = true
          return render json: ret_hash
        end
      }
    end
  end

  def social_sign_up_dummy
    ret_hash = {}
    unless current_user.blank?
      ret_hash[:success] = false
      ret_hash[:reason] = 'Already signed in'
      ret_hash[:redirect_url] = "/"
      respond_to do |format|
        format.json { return render json: ret_hash }
      end
      return
    end

    ret_hash[:name]           = 'Ravi Vadrevu'
    ret_hash[:first_name]     = 'Ravi'
    ret_hash[:last_name]      = 'Vadrevu'
    ret_hash[:handle]         = 'ravi'
    ret_hash[:image_url]      = 'https://graph.facebook.com/10153418161890589/picture'
    ret_hash[:headline]       = 'Cool headline yo!'
    ret_hash[:urls]           = { :twitter => 'twitter.com/raviformative' , :google   => 'google.com/ravi'}
    ret_hash[:source]         = 'twitter'
    ret_hash[:primary_email]  = 'vadrevu@outlook.com'
    ret_hash[:summary]        = 'This is a very long dummy summary and sometimes this could be blank....'
    respond_to do |format|
      format.json { return render json: ret_hash }
    end
  end

  def destroy
    NotificationsLoggerWorker.perform_async('Consumer.Session.Logout',
                                            {handle: session[:handle],
                                             params: params,
                                             ref: {referrer: params[:referrer],
                                                   referrer_id: params[:referrer_id],
                                                   referrer_type: params[:referrer_type],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('logout', current_user[:_id].to_s, {
                                                     ref: {referrer: params[:referrer],
                                                           referrer_id: params[:referrer_id],
                                                           referrer_type: params[:referrer_type]}
                                                 })
    end

    destroy_session_attributes
    flash[:notice] = 'Logged out succesfully.'
    page_heading('Sign In')
    # no redirection as this is log out.
    next_url = '/login'

    respond_to do |format|
      format.html {
        return redirect_to next_url
      }
      format.json {
        return render json: {success: true, redirect_url: next_url}
      }
    end


    return
  end
end
