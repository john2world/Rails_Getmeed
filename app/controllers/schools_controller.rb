class SchoolsController < ApplicationController
  include ProfilesManager
  include UsersHelper

  def index
    @schools = School.where(:_id.nin => ['tester', 'metester'], :name.ne => nil).order_by([:name, 1]).to_a.compact
    respond_to do |format|
      format.json {
        render json: {schools: @schools}
      }
    end
  end

  def verify
    @show_top_bar = true
    if params[:email].blank?
      flash[:alert] = 'Please enter a valid email.'
      redirect_to root_path
      return
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
      redirect_to root_url
      return
    end
    @user = get_user_by_email(@email)
    if !@user.blank? && @user[:active] && !params[:forgot_email].present?
      flash[:alert] = 'User already exists! Please login.'
      redirect_to :controller => 'schools', :action => 'index', :email => @email
      return
    end

    @school_handle = get_school_handle_from_email(@email);
    @school = get_school(@school_handle)

    if @school.blank?
      put_in_wait_list(@school_handle, @email)
      session[:school_handle] = @school_handle
      render :template => 'users/waitlist'
      return
    end

    unless @user.blank?
      if @user.active
        flash[:alert] = 'You are already verified, please sign in.'
        redirect_to '/login'
        return
      end
    end
    @user = create_passive_user(@email, params[:ref])
    # create intercom contact
    IntercomCreateContactWorker.perform_async(@user.id, 'career_fair')
    ActiveSupport::Notifications.instrument('Consumer.User.Verify',
                                            {email: @email,
                                             ref: params[:ref]
                                            })
    unless send_email_invitation(@email)
      flash[:alert] = 'Something went wrong! Please try again.'
      redirect_to "/school/#{@school.id}"
    end
    unless cookies[:referrer].blank?
      reward_for_school_sign_up(cookies[:referrer], @school.id, 'career_fair', @user)
      # DONOT CLEAR THE REFERRAL AS WE NEED IT FOR JOB APPLICATION
    end
    redirect_to "/school/#{@school.id}"
  end

  def send_email_invitation(email)
    email_invitation = create_email_invitation_for_email(email, nil)
    ActiveSupport::Notifications.instrument('Consumer.User.EmailInvitation',
                                            {email: email
                                            })
    #Notifier.email_verification(email, email_invitation[:token]).deliver
    EmailVerifyWorker.perform_async(email)
    true
  end

  def lookup
    school = nil
    unless params[:email].blank?
      school_handle = get_school_handle_from_email(params[:email])
      unless school_handle.blank?
        school = get_school(school_handle)
      end
    end

    respond_to do |format|
      format.json{
        return render json: {school: school}
      }
    end
  end
end
