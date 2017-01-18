class ProfilesController < ApplicationController
  include ProfilesHelper
  include SessionsHelper
  include SchoolsManager
  include UsersManager
  include UsersHelper
  include CommonHelper
  include LinkHelper
  include AnswersManager
  include PhotoHelper
  include QuestionsManager
  include MigrationsManager
  include CollectionsManager

  def view
    unless is_valid_handle(params[:id])
      redirect_to root_path
      return
    end
    create_pseudo_session = false
    if params[:authorization_code]
      @user = get_user_by_handle(params[:id])
      if @user.blank?
        redirect_to root_path
        return
      end
      if params[:authorization_code] != get_pseduo_session_auth_code(@user)
        redirect_to root_path
        return
      end
      create_pseudo_session = true
      update_session_with_user(@user)
      update_session_pseudo
    else
      @user = get_active_user_by_handle(params[:id])
    end
    if is_valid_handle(params[:id])
      # if the user has a pseduo session and its users profile, then show the profile
      if session_pseudo? && (session[:handle] == params[:id]) && @user.blank?
        @user = session[:user]
      end
      # if current user is null, then public profile matters
      @profile_is_public = true
      if current_user(false, create_pseudo_session).blank?
        @profile_is_public = UserSettings.find_or_create_by(handle: params[:id]).is_profile_public;
      end
      if @user.blank?
        #if user is blank, search for company
        @company = get_company_by_id(params[:id])
        if @company.blank?
          flash[:notice] = 'Meed profile not found.'
          redirect_to '/404?url='+request.url
          return
        else
          redirect_to "/company/#{params[:id]}"
          return
        end
      end
    else
      unless logged_in?
        return
      end
      @user = current_user
    end

    if params[:reg]
      page_heading('Please add skills to each section on your profile!')
    end

    if params[:incomplete]
      page_heading('Before claiming your tee, complete your profile!')
      page_sub_heading('(*Please finish your profile to claim your free Tee!)')
    end

    unless @user.equals?(current_user)
      record_user_profile_impressions(current_user, @user, params[:insightToken], params[:insightCompany])
    end

    @school_handle = get_school_handle_from_email(@user.id)
    @school = get_school(@school_handle)
    @profile = get_user_profile_or_new(@user[:handle])
    reset_is_profile_incomplete
    if @profile.blank?
      @profile = Profile.new(:handle => @user[:handle])
      @profile[:last_update_dttm] = Time.zone.now
      @profile.save
      # As profile is empty no need to trigger tag generation
    end

    if !@current_user.blank? && (@current_user[:_id].eql? @user[:_id])
      @incomplete_profile = is_incomplete_profile(@profile)
    end

    @degrees = Futura::Application.config.UserDegreesSmall
    @majors = admin_all_majors.sort_by! { |m| m[:major].downcase }
    @publications = get_user_publications(current_user, @profile)
    @internships = []
    get_user_internships(current_user, @profile).each do |internship|
      internship[:invites] = WorkReferenceInvitation.where(internship_id: internship.id)
      internship[:type] = 'internship'
      @internships.append(internship)
    end
    @courses = get_user_courses(current_user, @profile)
    @educations = get_user_edus(current_user, @profile)
    @experiences = get_user_works(current_user, @profile).map do |experience|
      experience[:invites] = WorkReferenceInvitation.where(work_id: experience.id)
      experience[:type] = 'work'
      experience.skills = experience.skills.split(", ") if experience.skills.is_a?(String)
      experience
    end

    @current_user = current_user
    @handle = params[:id].blank? ? @current_user[:handle] : params[:id]
    @answers = get_user_job_answers(params[:insightToken], @handle)
    question_ids = Array.[]
    unless @answers.blank?
      @answers.each do |answer|
        question_ids << answer.question_id
      end

      @question_map = get_questions_map(question_ids)
      @answer_question_map = Hash.new

      @answers.each do |answer|
        if @answer_question_map[answer.id].blank?
          @answer_question_map[answer.id] = @question_map[answer.question_id]
        end
      end
    end
    @is_viewer_profile = (!@current_user.blank? and @handle.eql? @current_user[:handle])
    @is_editable = (!@current_user.blank? and @handle.eql? @current_user[:handle] and !params[:edit].blank? and params[:edit])

    if !@current_user.blank? and @is_viewer_profile and !has_no_session?
      # insights
    end
    portfolio_feed_items = []
    activity_feed_items = []
    ama_id = "ama-#{@handle}"
    ama = get_ama_by_handle(@handle)
    is_event_happening = false
    unless ama.blank?
      unless ama.start_dttm.blank?
        is_event_happening = ama.start_dttm > Time.now
      end
      event_feed_items = get_feed_items_for_event(current_user, ama.id)
    end
    feed_items = get_feed_items_for_collection_id("#{@user.handle}_#{PORTFOLIO_CID}")
    build_feed_models(current_user, feed_items)
    @skills = get_autosuggest_skills_by_major(@user[:major_id]);
    if @skills.blank?
      @skills = []
    end
    @skills_as = @skills.collect { |s| "{skill: '#{s.sub("'", "")}'}" }.join(',');


    feed_items.each do |feed_item|
      if feed_item.portfolio
        portfolio_feed_items << feed_item
      else
        activity_feed_items << feed_item
      end
    end
    @collections = build_collection_models(current_user, get_user_generated_collections(@user.handle))
    @followed_collections = build_collection_models(current_user, get_user_following_collections(@user.handle))
    @is_viewer_following = current_user.blank? ? false : is_viewer_following(@user[:handle], current_user.handle)

    NotificationsLoggerWorker.perform_async('Consumer.Profile.ViewProfile',
                                            {handle: @user[:handle],
                                             token: params[:insightToken],
                                             viewer_handle: current_user.blank? ? nil : current_user.id,
                                             params: params,
                                             ref: {ref: params[:ref],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('view-profile', current_user[:_id].to_s, {
                                                           handle: @user[:handle],
                                                           token: params[:insightToken],
                                                           ref: params[:ref]
                                                       })
    end
    page_title ("#{@user.first_name} #{@user.last_name}")
    @metadata = get_profile_metadata(@user)
    respond_to do |format|
      format.html {
        return render layout: "angular_app", template: "angular_app/index"
      }
      format.json {
        # @user[:name] = @user.name
        ret = @profile.as_json.merge({
                                         answer_question_map: @answer_question_map,
                                         answers: @answers,
                                         company: @company,
                                         courses: !@courses.blank? ? @courses : nil,
                                         current_user: @current_user,
                                         educations: !@educations.blank? ? @educations : nil,
                                         experiences: !@experiences.blank? ? @experiences : nil,
                                         handle: @handle,
                                         portfolio_feed_items: portfolio_feed_items,
                                         activity_feed_items: activity_feed_items[0..4],
                                         event_feed_items: event_feed_items,
                                         is_event_happening: is_event_happening,
                                         event: ama,
                                         collections: @collections,
                                         followed_collections: @followed_collections,
                                         incomplete_profile: @incomplete_profile,
                                         internships: !@internships.blank? ? @internships : nil,
                                         is_editable: @is_editable,
                                         is_viewer_profile: @is_viewer_profile,
                                         metadata: @metadata,
                                         is_viewer_following: @is_viewer_following,
                                         # profile: @profile,
                                         profile_is_public: @profile_is_public,
                                         publications: !@publications.blank? ? @publications : nil,
                                         question_map: @question_map,
                                         redirect_url: @redirect_url,
                                         school: @school,
                                         school_handle: @school_handle,
                                         user: @user,
                                         contact_link: "/#/#{@user.handle}/contact",
                                         pdf_link: "/#{@user.handle}/pdf?token=#{@user.handle}"

                                     })

        if @is_viewer_profile
          ret = ret.merge({
                              degrees: @degrees,
                              majors: @majors.map { |x| {major: x.major, code: x.code} },
                              skills: @skills,
                              user: @user.attributes.except("password_hash")
                          })
        end

        if params[:showRajni]
          ret = ret.merge({
                              email: @user.email,
                              phone_number: @user.phone_number,
                          })
        end
        return render json: ret
      }

    end
  end

  def follow_user
    unless logged_in?
      return
    end
    create_follow_user(params[:id], current_user.handle)
    NotificationsLoggerWorker.perform_async('Consumer.Profile.Follow',
                                            {handle: current_user.handle,
                                             following_handle: params[:id],
                                             params: params,
                                             ref: {ref: params[:ref],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    respond_to do |format|
      format.json {
        return render json: {success: true}
      }
    end
  end

  def unfollow_user
    unless logged_in?
      return
    end
    delete_follow_user(params[:id], current_user.handle)
    NotificationsLoggerWorker.perform_async('Consumer.Profile.UnFollow',
                                            {handle: current_user.handle,
                                             following_handle: params[:id],
                                             params: params,
                                             ref: {ref: params[:ref],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    respond_to do |format|
      format.json {
        return render json: {success: true}
      }
    end
  end

  def profile
    unless logged_in?
      return
    end
    redirect_to "/#{current_user.handle}"
  end

  def auth_view
    unless logged_in?
      return
    end
    redirect_to get_user_profile_url params[:id]
  end

  def insights
    unless logged_in?
      return
    end

    @user = current_user

    # Creating a insights object
    user_insights = UserInsights(@user[:handle])
    @total_view_count = user_insights.get_total_profile_view_count;
    date_view_count_data = user_insights.get_profile_view_count_by_date
    date_view_count_data = date_view_count_data.map { |data|
      date = Date.strptime(data["_id"], "%d-%m-%Y");
      "[Date.UTC(#{date.year}, #{date.month}, #{date.day}), #{data["value"]}]"
    }

    @view_count_date_data_string = '['+date_view_count_data.join(',')+']'

    @impressions = get_profile_impressions(@user)
    # @total_view_count = 0;
    # unless @impressions.blank?
    #   @impressions[:public_view_count] = (@impressions[:public_view_count].blank?) ? 0 : @impressions[:public_view_count]
    #   @total_view_count = @impressions[:public_view_count]
    #   @people_view_count = 0
    #   @people_view_count = @impressions[:public_view_count]
    #   unless @impressions[:viewers].blank?
    #     @total_view_count += @impressions[:viewers].length
    #     @people_view_count += @impressions[:viewers].length
    #   end
    #   unless @impressions[:job_ids].blank?
    #     @total_view_count += @impressions[:job_ids].length
    #   end
    # end

    @school_prefix_handle = get_school_prefix_from_email(@user[:_id])
    @profile = get_user_profile_or_new(@user[:handle])
    NotificationsLoggerWorker.perform_async('Consumer.Profile.ViewInsights',
                                            {handle: @user[:handle],
                                             params: params,
                                             ref: {ref: params[:ref],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('view-insights', current_user[:_id].to_s, {
                                                            ref: params[:ref]
                                                        })
    end

  end

  def invite_user
    unless logged_in?
      return
    end
    NotificationsLoggerWorker.perform_async('Consumer.Profile.InviteFriend',
                                            {handle: current_user[:handle],
                                             params: params,
                                             ref: {ref: params[:ref],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    EmailFriendInviteWorker.perform_async(current_user.id, params[:id])
    respond_to do |format|
      format.json {
        return render json: {success: true}
      }
    end
  end

  def resume_upload
    if params[:resume_url].blank?
      respond_to do |format|
        format.json {
          return render json: {success: false}
        }
      end
      return
    end

    file = open(params[:resume_url], "r")
    begin
      resp = Sovren::Client.new(file)
      ret_hash = {}
      ret_hash[:success] = true
      ret_hash[:data] = resp.all
    rescue
      respond_to do |format|
        format.json {
          return render json: {success: false}
        }
      end
    end

    create_profile_from_resume(current_user, resp.all)
    respond_to do |format|
      format.json {
        return render json: ret_hash
      }
    end
  end

  def edit
    unless logged_in?
      return
    end
    save_redirect_url(params)
    @redirect_url=params[:redirect_url]
    @user = current_user
    @success = false;

    @school_handle = get_school_handle_from_email(@user.id)
    @school = get_school(@school_handle)
    @profile = get_user_profile_or_new(@user[:handle])
    if (@profile.blank?)
      @profile = Profile.new(:handle => @user[:handle])
      @profile[:last_update_dttm] = Time.zone.now
    end
    @skills_as = get_autosuggest_skills_by_major(current_user[:major_id]);
    @publications = get_user_publications(current_user, @profile)
    @internships = get_user_internships(current_user, @profile)
    @courses = get_user_courses(current_user, @profile)
    @experiences = get_user_works(current_user, @profile)

    NotificationsLoggerWorker.perform_async('Consumer.Profile.Edit',
                                            {handle: @user[:handle],
                                             params: params,
                                             ref: {ref: params[:ref],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('edit-profile', current_user[:_id].to_s, {
                                                           ref: params[:ref]
                                                       })
    end


    respond_to do |format|
      format.html # create_questionate_question.html.erb
    end
  end

  def contact_profile
    handle = params[:id]
    if handle.blank?
      return
    end

    @user = get_active_user_by_handle(handle)
    if @user.blank?
      redirect_to root_path
      return
    end
    NotificationsLoggerWorker.perform_async('Consumer.Profile.Contact',
                                            {handle: @user[:handle],
                                             params: params,
                                             ref: {ref: params[:ref],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
  end

  def send_email

    handle = params[:id]
    if handle.blank?
      return
    end

    @user = get_active_user_by_handle(handle)

    if @user.blank?
      return
    end

    if params[:email].blank?
      flash[:alert] = 'Please enter your email'
      redirect_to '/'+ handle + '/contact'
      return
    end

    if params[:subject].blank?
      flash[:alert] = 'Please enter a subject'
      redirect_to '/'+ handle + '/contact'
      return
    end

    if params[:description].blank?
      flash[:alert] = 'Please enter body'
      redirect_to '/'+ handle + '/contact'
      return
    end

    body = (params[:description])
    Notifier.email_user_message_public(params[:email], params[:subject], @user[:email], body).deliver
    rparams = params.except(:email, :subject, :description)

    NotificationsLoggerWorker.perform_async('Consumer.Profile.SendEmail',
                                            {handle: handle,
                                             email: params[:email],
                                             params: rparams,
                                             ref: {ref: params[:ref],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    save_message(params[:email], @user.id, @user[:handle], params[:subject], body)
    respond_to do |format|
      format.html # view.html.erb
    end

  end

  def save_objective
    unless pseudo_logged_in?(root_path)
      return
    end

    @success = false
    @delete = false
    @objective = (params[:objective][:text])
    @is_editable = true
    @user = current_user
    @profile = get_user_profile_or_new(@user[:handle])

    @is_new = false
    if @profile.blank?
      @profile = Profile.new(:handle => @user[:handle])
      @profile[:last_update_dttm] = Time.zone.now
      @is_new = true
    end

    if @profile[:objective].blank?
      @is_new = true
    end

    if params[:delete]
      @delete = true
      delete_user_profile_item(@profile[:handle], @profile, 'objective')
      respond_to do |format|
        format.js
        return
      end
    end

    @profile[:objective] = @objective;

    begin
      @profile[:last_update_dttm] = Time.zone.now
      # Everytime the profile is updated the coressponding score has to be updated
      update_score(@profile)
      # tags have to be created
      GenerateProfileTagsWorker.perform_async(@profile.id)
      @profile.save
    rescue Exception => ex
      $log.error "Error in saving profile for user_handle: #{@user[:handle]} - #{ex}"
      flash[:alert] = 'Something went wrong! Please try again.'
      redirect_to '/home'
      return
    end
    @success = true
    rparams = params.except(:objective, :delete)

    NotificationsLoggerWorker.perform_async('Consumer.Profile.SaveObjective',
                                            {handle: @profile[:handle],
                                             params: rparams,
                                             ref: {ref: params[:ref],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('save-objective', current_user[:_id].to_s, {
                                                             ref: params[:ref]
                                                         })
    end

    reset_is_profile_incomplete
    respond_to do |format|
      format.js
      format.json {
        return render json: {success: true}
      }
    end
  end

  def share
    unless logged_in?(root_path)
      return
    end

    @user = current_user
  end

  def download_pdf
    if params[:id].blank?
      redirect_to '/404?url='+request.url
      return
    end

    user = get_active_user_by_handle(params[:id])
    token = params[:token]
    if user.blank? or token.blank?
      redirect_to '/404?url='+request.url
      return
    end
    rparams = params.except(:id, :token)

    NotificationsLoggerWorker.perform_async('Consumer.Profile.DownloadPdf',
                                            {handle: user[:handle],
                                             token: token,
                                             user: params[:id],
                                             params: rparams,
                                             ref: {ref: params[:ref],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })

    generate_pdf(current_user, user, token)
  end

  def save_publication
    if !pseudo_logged_in?(root_path)
      return
    end

    @delete = false
    @success = false
    @id = params[:hidden_id]
    @is_editable = true
    @user = current_user
    @profile = get_user_profile_or_new(@user[:handle])

    if params[:delete]
      @delete = true
      delete_user_profile_item(@id, @profile, 'publication')
      respond_to do |format|
        format.js
        format.json {
          return render json: {success: true}
        }
      end
      return
    end

    if params[:publication][:text].blank? && params[:publication_title].blank?
      return
    end

    if params[:publication][:text].blank? && params[:publication_title].blank?
      return
    end


    if @profile.blank?
      @profile = Profile.new(:handle => @user[:handle])
      @profile[:last_update_dttm] = Time.zone.now
    end


    @is_new = false
    if @id.blank?
      @user_publication = UserPublication.new
      @user_publication[:handle] = @user[:handle]
      @id = @user_publication[:_id]
      @is_new = true
    else
      @user_publication = get_user_publication(@id)
    end

    @user_publication[:description] = sanitize_html(params[:publication][:text])
    @user_publication[:title] = params[:publication_title]
    unless params[:link].blank?
      @user_publication[:link] = process_links(params[:link])
    end
    unless params[:date][:year].blank?
      @user_publication[:year] = params[:date][:year]
    end

    begin
      if @is_new
        @user_publication.save
      else
        @user_publication.save!
      end
      @id = @user_publication[:_id]

    rescue Exception => ex
      $log.error "Error in saving publication for user_handle: #{@user[:handle]} - #{ex}"
      flash[:alert] = 'Something went wrong! Please try again.'
      redirect_to '/home'
      return
    end
    if @is_new
      @profile.push(:user_publication_ids, @user_publication[:_id])
    end
    @id = @user_publication[:_id]
    begin
      @profile[:last_update_dttm] = Time.zone.now
      update_score(@profile)
      # tags have to be created
      GenerateProfileTagsWorker.perform_async(@profile.id)
      @profile.save!
    rescue Exception => ex
      $log.error "Error in saving profile in 'save_publication' for user_handle: #{@user[:handle]} - #{ex}"
      flash[:alert] = 'Something went wrong! Please try again.'
      redirect_to '/home'
      return
    end
    @success = true
    reset_is_profile_incomplete
    rparams = params.except(:publication, :publication_title, :date, :link)

    NotificationsLoggerWorker.perform_async('Consumer.Profile.SavePublication',
                                            {handle: @user[:handle],
                                             delete: params[:delete],
                                             params: rparams,
                                             ref: {ref: params[:ref],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('save-publication', current_user[:_id].to_s, {
                                                               delete: params[:delete],
                                                               ref: params[:ref]
                                                           })
    end
    IntercomUpdateUserWorker.perform_async(current_user.id.to_s, nil)
    @message = 'Saved successfully!'
    respond_to do |format|
      format.js
      format.json {
        return render json: {
                          success: true,
                          _id: @id
                      }
      }
    end
  end

  def save_internship
    unless pseudo_logged_in?(root_path)
      return
    end
    @id = params[:hidden_id]
    @delete = false
    @success = false
    @user = current_user
    @profile = get_user_profile_or_new(@user[:handle])

    if (params[:delete])
      @delete = true
      delete_user_profile_item(@id, @profile, 'internship')
      respond_to do |format|
        format.js
        format.json {
          return render json: {
                            success: true
                        }
        }
      end
    end

    if params[:internship_description][:text].blank? or params[:internship_title].blank? && params[:internship_company].blank?
      @description_blank = true
      @skills_blank = true
      return
    end

    if params[:intern_skills].blank?
      @id = params[:hidden_id]
      @skills_blank = true
      return
    end

    if params[:internship_description][:text].blank? or params[:internship_title].blank? && params[:internship_company].blank?
      @id = params[:hidden_id]
      @description_blank = true
      @skills_blank = true
      return
    end

    @is_new = false
    @user_internship = nil
    if (@id.blank?)
      @user_internship = UserInternship.new
      @user_internship[:handle] = @user[:handle]
      @id = @user_internship[:_id]
      @is_new = true
    else
      @user_internship = get_user_internship(@id)
    end

    @user_internship[:description] = sanitize_html(params[:internship_description][:text])
    @user_internship[:title] = params[:internship_title]
    company = get_or_create_company_by_name(params[:internship_company])
    @user_internship[:company_id] = company.id
    @user_internship[:company] = company.name
    @user_internship[:link] = process_links(params[:link])
    @user_internship[:skills] = generate_skills(params[:intern_skills])
    update_new_skills(@user.major_id, @user_internship[:skills])
    @user_internship = load_dates(params, @user_internship)
    begin
      if (@is_new)
        @user_internship.save
      else
        @user_internship.save!
      end
      @id = @user_internship[:_id]
    rescue Exception => ex
      $log.error "Error in saving internship for user_handle: #{@user[:handle]} - #{ex}"
      flash[:alert] = 'Something went wrong! Please try again.'
      redirect_to '/home'
      return
    end

    if @is_new
      @profile.push(:user_internship_ids, @user_internship[:_id])
    end

    @id = @user_internship[:_id]
    begin
      @profile[:last_update_dttm] = Time.zone.now
      update_score(@profile)
      # tags have to be created
      GenerateProfileTagsWorker.perform_async(@profile.id)
      @profile.save!
    rescue Exception => ex
      $log.error "Error in saving profile in 'savenship' for user_handle: #{@user[:handle]} - #{ex}"
      flash[:alert] = 'Something went wrong! Please try again.'
      redirect_to '/home'
      return
    end
    @success = true
    reset_is_profile_incomplete
    rparams = params.except(:internship_description, :internship_title, :internship_company, :link, :intern_skills, :delete)
    @index = @profile.user_internship_ids.count() - 1
    NotificationsLoggerWorker.perform_async('Consumer.Profile.SaveInternship',
                                            {handle: @user[:handle],
                                             delete: params[:delete],
                                             params: rparams,
                                             ref: {ref: params[:ref],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('save-internship', current_user[:_id].to_s, {
                                                              delete: params[:delete],
                                                              ref: params[:ref]
                                                          })
    end
    IntercomUpdateUserWorker.perform_async(current_user.id.to_s, nil)
    @message = 'Saved successfully!'
    respond_to do |format|
      format.js
      format.json {
        return render json: {
                          success: true,
                          _id: @id
                      }
      }
    end

  end

  def save_course
    unless pseudo_logged_in?(root_path)
      return
    end
    @delete = false
    @success = false
    @id = params[:hidden_id]
    @user = current_user
    @profile = get_user_profile(@user[:handle])
    if params[:delete]
      @delete = true
      delete_user_profile_item(@id, @profile, 'course')
      respond_to do |format|
        format.js
        format.json {
          return render json: {success: true}
        }
      end
      return
    end

    @id = params[:hidden_id]
    if params[:course_skills].blank?
      @skills_blank = true
      return
    end

    @delete = false
    @success = false
    @id = params[:hidden_id]
    @user = current_user
    if params[:course_description][:text].blank? or params[:course_title].blank?
      @description_blank = true
      @skills_blank = true
      return
    end
    @is_editable = false
    @profile = get_user_profile_or_new(@user[:handle])
    @is_new = false
    @user_course = nil
    if @id.blank?
      @user_course = UserCourse.new
      @user_course[:handle] = @user[:handle]
      @id = @user_course[:_id]
      @is_new = true
    else
      @user_course = get_user_course(@id)
    end


    @user_course[:description] = sanitize_html(params[:course_description][:text])
    @user_course[:title] = params[:course_title]
    @user_course[:link] = process_links(params[:link])
    @user_course[:skills] = generate_skills(params[:course_skills])
    update_new_skills(@user.major_id, @user_course[:skills])
    @user_course[:year] = params[:date][:year]
    @user_course[:semester] = params[:semester]

    begin
      if @is_new
        @user_course.save
      else
        @user_course.save!
      end
      @id = @user_course[:_id]
    rescue Exception => ex
      Rails.logger.info "Error in saving course for user_handle: #{@user[:handle]} - #{ex}"
      Rails.logger.info @user_course.errors.inspect
      Rails.logger.info ex.backtrace.join("\n")
      flash[:alert] = 'Something went wrong! Please try again.'
      redirect_to '/home'
      return
    end
    if @is_new
      @profile.push(:user_course_ids, @user_course[:_id])
    end
    @id = @user_course[:_id]
    begin
      @profile[:last_update_dttm] = Time.zone.now
      update_score(@profile)
      # tags have to be created
      GenerateProfileTagsWorker.perform_async(@profile.id)
      @profile.save!
    rescue Exception => ex
      $log.error "Error in saving profile in 'save_course' for user_handle: #{@user[:handle]} - #{ex}"
      flash[:alert] = 'Something went wrong! Please try again.'
      return
    end
    @success = true
    reset_is_profile_incomplete
    rparams = params.except(:course_description, :course_title, :course_skills, :date, :link, :semester, :delete)

    NotificationsLoggerWorker.perform_async('Consumer.Profile.SaveCourse',
                                            {handle: @user[:handle],
                                             delete: params[:delete],
                                             params: rparams,
                                             ref: {ref: params[:ref],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('save-course', current_user[:_id].to_s, {
                                                          delete: params[:delete],
                                                          ref: params[:ref]
                                                      })
    end
    IntercomUpdateUserWorker.perform_async(current_user.id.to_s, nil)
    @message = 'Saved successfully!'

    respond_to do |format|
      format.js
      format.json {
        return render json: {
                          success: true,
                          _id: @id
                      }
      }
    end

  end

  def save_education
    if !pseudo_logged_in?(root_path)
      return
    end

    @delete = false
    @success = false
    @id = params[:hidden_id]
    @user = current_user

    @profile = get_user_profile_or_new(@user[:handle])

    if params[:delete]
      @delete = true
      delete_user_profile_item(@id, @profile, 'education')
      respond_to do |format|
        format.js
        format.json {
          return render json: {success: true}
        }
      end
      return
    end

    if params[:education_name].blank?
      return
    end
    @is_editable = true

    if @profile.blank?
      @profile = Profile.new(:handle => @user[:handle])
      @profile[:last_update_dttm] = Time.zone.now
    end


    if params[:education_name].blank?
      return
    end
    @is_editable = true

    if @profile.blank?
      @profile = Profile.new(:handle => @user[:handle])
      @profile[:last_update_dttm] = Time.zone.now
    end


    @is_new = false
    @user_education = nil
    if @id.blank?
      @user_education = UserEducation.new
      @user_education[:handle] = @user[:handle]
      @id = @user_education[:_id]
      @is_new = true
    else
      @user_education = get_user_edu(@id)
    end

    @user_education.name = params[:education_name]
    @user_education.degree = params[:education_degree]
    @user_education.major = params[:education_majors]
    @user_education = load_dates(params, @user_education)

    begin
      @user_education.save
    rescue Exception => ex
      $log.error "Error in saving work for user_handle: #{@user[:handle]} - #{ex}"
      flash[:alert] = 'Something went wrong! Please try again.'
      redirect_to '/home'
      return
    end

    if @is_new
      @profile.push(:user_edu_ids, @user_education.id)
    end

    @id = @user_education.id
    begin
      @profile[:last_update_dttm] = Time.zone.now
      update_score(@profile)
      # tags have to be created
      GenerateProfileTagsWorker.perform_async(@profile.id)
      @profile.save!
    rescue Exception => ex
      $log.error "Error in saving profile in 'save_work' for user_handle: #{@user[:handle]} - #{ex}"
      flash[:alert] = 'Something went wrong! Please try again.'
      Rails.logger.info ex.backtrace
      redirect_to '/home'
      return
    end
    @success = true
    reset_is_profile_incomplete
    rparams = params.except(:education_name, :education_degree, :education_majors, :delete)

    NotificationsLoggerWorker.perform_async('Consumer.Profile.SaveEducation',
                                            {handle: @user[:handle],
                                             delete: params[:delete],
                                             params: rparams,
                                             ref: {ref: params[:ref],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('save-education', current_user[:_id].to_s, {
                                                             delete: params[:delete],
                                                             ref: params[:ref]
                                                         })
    end
    IntercomUpdateUserWorker.perform_async(current_user.id.to_s, nil)
    @message = 'Saved successfully!'
    respond_to do |format|
      format.js
      format.json {
        return render json: {success: true, _id: @user_education._id}
      }
    end

  end

  def save_experience
    unless pseudo_logged_in?(root_path)
      return
    end
    @delete = false
    @success = false
    @id = params[:hidden_id]
    @user = current_user
    @id = params[:hidden_id]
    @skills_blank = false

    @profile = get_user_profile(@user[:handle])
    if params[:delete]
      @delete = true
      delete_user_profile_item(@id, @profile, 'work')
      respond_to do |format|
        format.js
        format.json {
          return render json: {success: true, _id: @id}
        }
      end
      return
    end

    if params[:work_skills].blank?
      @skills_blank = true
      return
    end
    @delete = false
    @success = false
    @user = current_user
    if params[:experience_description][:text].blank? or params[:experience_title].blank?
      @description_blank = true
      @skills_blank = true
      return
    end
    @degrees = Futura::Application.config.UserDegreesSmall
    @is_editable = true

    @is_new = false
    @user_experience = nil
    if @id.blank?
      @user_experience = UserWork.new
      @user_experience[:handle] = @user[:handle]
      @id = @user_experience[:_id]
      @is_new = true
    else
      @user_experience = get_user_work(@id)
    end

    @user_experience[:description] = sanitize_html(params[:experience_description][:text])
    @user_experience[:title] = params[:experience_title]
    company = get_or_create_company_by_name(params[:experience_company])
    if company.blank?
      @user_experience[:company] = params[:experience_company]
    else
      @user_experience[:company_id] = company.id
      @user_experience[:company] = company.name
    end

    @user_experience[:link] = process_links(params[:link])
    @user_experience[:skills] = generate_skills(params[:work_skills])
    update_new_skills(@user.major_id, @user_experience[:skills])
    @user_experience = load_dates(params, @user_experience)

    begin
      if (@is_new)
        @user_experience.save
      else
        @user_experience.save
      end

    rescue Exception => ex
      $log.error "Error in saving work for user_handle: #{@user[:handle]} - #{ex}"
      flash[:alert] = 'Something went wrong! Please try again.'
      redirect_to '/home'
      return
    end

    if (@is_new)
      @profile.push(:user_work_ids, @user_experience[:_id])
    end

    @id = @user_experience[:_id]
    begin
      @profile[:last_update_dttm] = Time.zone.now
      update_score(@profile)
      # tags have to be created
      GenerateProfileTagsWorker.perform_async(@profile.id)
      @profile.save!
    rescue Exception => ex
      $log.error "Error in saving profile in 'save_work' for user_handle: #{@user[:handle]} - #{ex}"
      flash[:alert] = 'Something went wrong! Please try again.'
      redirect_to '/home'
      return
    end
    rparams = params.except(:experience_company, :experience_description, :experience_title, :work_skills, :link, :delete)
    @index = @profile.user_work_ids.count() - 1
    NotificationsLoggerWorker.perform_async('Consumer.Profile.SaveExperience',
                                            {handle: @user[:handle],
                                             delete: params[:delete],
                                             params: rparams,
                                             ref: {ref: params[:ref],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('save-experience', current_user[:_id].to_s, {
                                                              delete: params[:delete],
                                                              ref: params[:ref]
                                                          })
    end
    # Update profile can lead to update to intercom user emails
    IntercomUpdateUserWorker.perform_async(current_user.id.to_s, nil)
    @success = true
    reset_is_profile_incomplete
    @message = 'Saved successfully!'
    respond_to do |format|
      format.js
      format.json {
        return render json: {
                          success: true,
                          _id: @id
                      }
      }
    end
  end

  def save_header
    unless pseudo_logged_in?(root_path)
      return
    end

    @delete = false
    @success = false
    @user = current_user
    @is_viewer_profile = (!@current_user.blank? and @handle.eql? @current_user[:handle])
    @is_editable = (!@current_user.blank? and @handle.eql? @current_user[:handle] and !params[:edit].blank? and params[:edit])
    if params[:delete_gpa]
      @user.gpa = nil
    else
      @user.gpa = params[:gpa]
    end

    @user.phone_number = params[:phone_number]
    unless params[:user_year].blank?
      @user.year = params[:user_year]
    end
    unless params[:email].blank?
      @user.email = params[:email]
    end
    unless params[:degree].blank?
      @user.degree = params[:degree]
    end
    unless params[:major].blank?
      @user.major_id = params[:major]
      @user.major = Major.find(params[:major]).major
    end

    if params[:minor].blank?
      # clear the minor
      @user.minor_id = nil
      @user.minor = nil
    else
      @user.minor_id = params[:minor]
      @user.minor = Major.find(params[:minor]).major
    end

    unless params[:first_name].blank?
      @user.first_name = params[:first_name]
    end

    unless params[:last_name].blank?
      @user.last_name = params[:last_name]
    end

    @user.save
    reset_is_profile_incomplete
    @school_handle = get_school_handle_from_email(@user.id)
    @school = get_school(@school_handle)
    rparams = params.except(:edit, :delete_gpa, :gpa, :phone_number, :email, :user_year, :degree, :major, :minor, :first_name, :last_name)

    NotificationsLoggerWorker.perform_async('Consumer.Profile.SaveHeader',
                                            {handle: @user[:handle],
                                             delete: params[:delete_gpa],
                                             params: rparams,
                                             ref: {ref: params[:ref],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('save-header', current_user[:_id].to_s, {
                                                          delete: params[:delete],
                                                          ref: params[:ref]
                                                      })
    end
    IntercomUpdateUserWorker.perform_async(current_user.id.to_s, nil)

    respond_to do |format|
      format.js
      format.json {
        return render json: {success: true}
      }
    end
  end

  def download_pdf_bundle
    handles = get_selects_from_params(params, 'handle')
    if params[:job_id].blank?
      flash[:alert] = 'Something went wrong.'
      @error = 'Please try again.'
      return
    end

    job = get_job_by_id(params[:job_id])

    if job.blank?
      flash[:alert] = 'Something went wrong.'
      @error = 'Please try again.'
      return
    end

    redirect_url = get_job_applicants_status_url(params[:job_id], job.email)
    rparams = params.except(:job_id)

    NotificationsLoggerWorker.perform_async('Consumer.Profile.DownloadBundle',
                                            {job_id: params[:job_id],
                                             handles: handles,
                                             params: rparams,
                                             ref: {ref: params[:ref],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    if handles.blank?
      @error = 'Please select at least one resume.'
      redirect_to redirect_url
      return
    end

    generate_pdfs(current_user, handles, params[:job_id])
  end

  def show_profile_bundle
    handle_string = params[:handles]
    if handle_string.blank?
      flash[:alert] = 'no_users'
      @success = false
      @error = 'no_handles'
      return
    end

    handles = decode_delimited_strings_char(handle_string, '_')
    users = get_users_by_handles(handles)
    @user_profile_map = Hash.new { |h, k| h[k] = Array.new }
    @user_map = Hash.new { |h, k| h[k] = Array.new }
    @user_course_map = Hash.new { |h, k| h[k] = Array.new }
    @user_work_map = Hash.new { |h, k| h[k] = Array.new }
    @user_edu_map = Hash.new { |h, k| h[k] = Array.new }
    @user_publication_map = Hash.new { |h, k| h[k] = Array.new }
    @user_internship_map = Hash.new { |h, k| h[k] = Array.new }
    @user_answer_map = Hash.new { |h, k| h[k] = Array.new }
    @user_school_map = Hash.new { |h, k| h[k] = Array.new }

    user_profiles = get_user_profiles(handles)

    users.each do |user|
      @user_map[user.handle] << user
    end

    user_profiles.each do |profile|
      @user_profile_map[profile.handle] << profile
      @user_course_map[profile.handle] = get_user_courses(current_user, profile)
      @user_work_map[profile.handle] = get_user_works(current_user, profile)
      @user_edu_map[profile.handle] = get_user_edus(current_user, profile)
      @user_internship_map[profile.handle] = get_user_internships(current_user, profile)
      @user_publication_map[profile.handle] = get_user_publications(current_user, profile)
      unless @user_map[profile.handle].blank?
        @user_school_map[profile.handle] = get_school(get_school_handle_from_email(@user_map[profile.handle][0].id))
      end
    end
    @success = true
  end

  def claim_offer_check
    unless logged_in?
      return
    end
    if is_profile_incomplete
      params[:incomplete] = true
      view
    else
      redirect_to '/thanksgiving/claim/complete'
    end
  end

  def add_user_details
    if params.has_key?('primary_email') and params[:primary_email].blank?
      flash[:alert] = 'Please enter your primary email!'
      claim_offer_check
      return
    end

    if params.has_key?('phone_number') and params[:phone_number].blank?
      flash[:alert] = 'Please enter your phone number!'
      claim_offer_check
      return
    end

    if params.has_key?('street_address') and params[:street_address].blank?
      flash[:alert] = 'Please enter your street address!'
      claim_offer_check
      return
    end

    if params.has_key?('city') and params[:city].blank?
      flash[:alert] = 'Please enter your city!'
      claim_offer_check
      return
    end

    if params.has_key?('state') and params[:state].blank?
      flash[:alert] = 'Please enter your State!'
      claim_offer_check
      return
    end

    if params.has_key?('zip_code') and params[:zip_code].blank?
      flash[:alert] = 'Please enter your zip code!'
      claim_offer_check
      return
    end

    if params.has_key?('t_size') and params[:zip_code].blank?
      flash[:alert] = 'Please enter your T shirt size!'
      claim_offer_check
      return
    end
    user = current_user
    unless params[:primary_email].blank?
      user.primary_email = params[:primary_email]
    end

    unless params[:street_address].blank?
      street_address = params[:street_address]
      unless params[:street_address_2].blank?
        street_address = "#{street_address}, #{params[:street_address_2]}"
      end

      unless params[:city].blank?
        street_address = "#{street_address}, #{params[:city]}"
      end

      unless params[:zip_code].blank?
        street_address = "#{street_address}, #{params[:zip_code]}"
      end
      user.street_address = street_address
    end

    unless params[:phone_number].blank?
      user.phone_number = params[:phone_number]
    end

    unless params[:t_size].blank?
      user.t_size = params[:t_size]
    end
    user.save!
  end

  def linkedin_failure
    redirect_to "/#{current_user.handle}"
  end

  def linkedin_oauth
    user = nil
    if current_user.blank?
      if session[:reg_email].blank?
        redirect_to '/auth/linkedin'
        return
      end
      user = get_user_by_email(session[:reg_email])
    else
      user = current_user
    end

    begin
      code = params[:code]
      linkedin_hash = request.env['omniauth.auth']['extra']['raw_info']
      unless linkedin_hash.blank?
        first_name = linkedin_hash['firstName']
        last_name = linkedin_hash['lastName']
        location = linkedin_hash['location']
        summary_hash = linkedin_hash['summary']
        email_address = linkedin_hash['emailAddress']
        picture_url = convert_to_cloudinary(linkedin_hash['pictureUrl'], 100, 100, user[:handle])
        user_handle = user.handle
        if user_handle.blank?
          user_handle = get_handle_from_email(user.id)
          user.handle = user_handle
        end

        profile = get_user_profile_or_new(user_handle)
        profile.linkedin_import = true
        unless summary_hash.blank?
          profile.summary = summary_hash
        end
        # tags have to be created
        GenerateProfileTagsWorker.perform_async(profile.id)
        profile.save

        unless email_address.blank?
          user.email = email_address
        end

        unless first_name.blank?
          user.first_name = first_name
        end

        unless last_name.blank?
          user.last_name = last_name
        end

        unless location.blank?
          user.location = location['name']
        end

        unless picture_url.blank?
          user.image_url = picture_url
        end


        user.active = true
        user.save
        education_hash = linkedin_hash['educations']
        unless education_hash.blank?
          educations = education_hash['values']
          unless educations.blank?
            educations.each do |education|
              create_linkedin_education(education, user)
            end
          end
        end

        publication_hash = linkedin_hash['publications']
        unless publication_hash.blank?
          publications = publication_hash['values']
          unless publications.blank?
            publications.each do |publication|
              create_linkedin_publication(publication, user)
            end
          end
        end

        courses_hash = linkedin_hash['courses']
        unless courses_hash.blank?
          courses = courses_hash['values']
          unless courses.blank?
            courses.each do |course|
              create_linkedin_course(course, user)
            end
          end
        end

        current_positions = linkedin_hash['threeCurrentPositions']
        unless current_positions.blank?
          positions = current_positions['values']
          unless positions.blank?
            positions.each do |position|
              if position['title'].include? 'intern' or position['title'].include? 'internship'
                create_linkedin_internship(position, user)
              else
                create_linkedin_experience(position, user)
              end
            end
          end
        end

        current_positions = linkedin_hash['threePastPositions']
        unless current_positions.blank?
          positions = current_positions['values']
          unless positions.blank?
            positions.each do |position|
              if position['title'].downcase.include? 'intern' or position['title'].downcase.include? 'internship'
                create_linkedin_internship(position, user)
              else
                create_linkedin_experience(position, user)
              end
            end
          end
        end

        connections_hash = linkedin_hash['connections']
        unless connections_hash.blank?
          connections = connections_hash['values']
          unless connections.blank?
            connections.each do |connection|
              create_linkedin_connection(connection, user)
            end
          end
        end
        #flush out staleness
        session[:user] = nil
        # tags have to be created
        GenerateProfileTagsWorker.perform_async(profile.id)
      end

    rescue Exception => ex
      $log.error "[LINKEDIN IMPORT] Error in import profile for user_handle: #{current_user.handle}: code = #{code}- #{ex}"
      redirect_to '/users/linkedin/create'
      return
    end
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('import-linkedin', current_user[:_id].to_s, {ref: params[:ref]})
    end

    reset_is_profile_incomplete
    if session[:linkedin_import_reg].blank?
      $log.error "[LINKEDIN REDIRECT]  linkedin_import_reg is: #{session[:linkedin_import_reg]}"
      redirect_to "/#{current_user.handle}"
    else
      $log.error "[LINKEDIN REDIRECT]  linkedin/create is: #{session[:linkedin_import_reg]}"
      redirect_to '/users/linkedin/create'
    end
  end

  def save_bio
    unless logged_in?
      return
    end

    @success = false
    @delete = false
    bio = (params[:bio][:text])
    @is_editable = true
    @user = current_user
    if @user[:bio].blank?
      @is_new = true
    end

    if params[:delete]
      @delete = true
      @user.bio = ''
      @user.save!
      respond_to do |format|
        format.js
        return
      end
    end

    @user[:bio] = bio
    @user.save!
    @success = true
    rparams = params.except(:bio, :delete)

    NotificationsLoggerWorker.perform_async('Consumer.Profile.SaveBio',
                                            {handle: @user[:handle],
                                             params: rparams,
                                             ref: {ref: params[:ref],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('save-bio', current_user[:_id].to_s, {
                                                       ref: params[:ref]
                                                   })
    end

    reset_is_profile_incomplete
    respond_to do |format|
      format.js
      format.json {
        return render json: {success: true}
      }
    end
  end

  def save_previous_company
    unless logged_in?
      return
    end

    companies = get_companies_by_names(params[:company_ids])
    user = get_user_by_handle(current_user.handle)
    user[:company_ids] = companies.map { |company| company.id }
    user.save!
    rparams = params.except(:current_company)
    NotificationsLoggerWorker.perform_async('Consumer.Profile.SavePreviousCompanies',
                                            {handle: user[:handle],
                                             params: rparams,
                                             ref: {ref: params[:ref],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('save-previous-companies', current_user[:_id].to_s, {
                                                                      ref: params[:ref]
                                                                  })
    end
    company_names = []
    companies.each do |company|
      company_names << company.name
    end
    reset_current_user
    respond_to do |format|
      format.js
      format.json {
        return render json: {success: true, company_names: company_names}
      }
    end
  end

  def save_current_company
    unless logged_in?
      return
    end
    name = 'Something went wrong!'
    company = get_or_create_company_by_name(params[:company_id])
    user = current_user
    unless company.blank?
      user[:company_id] = company.id
      user.save!
      name = company.name
      rparams = params.except(:current_company)
      reset_current_user
      NotificationsLoggerWorker.perform_async('Consumer.Profile.SaveCurrentCompany',
                                              {handle: user[:handle],
                                               params: rparams,
                                               ref: {ref: params[:ref],
                                                     meed_user_tracker: cookies[:meed_user_tracker]}
                                              })
      # Logging event in Intercom
      unless current_user.blank?
        IntercomLoggerWorker.perform_async('save-current-', current_user[:_id].to_s, {
                                                               ref: params[:ref]
                                                           })
      end
    end


    respond_to do |format|
      format.js
      format.json {
        return render json: {success: true, name: name}
      }
    end
  end

  def save_headline
    unless pseudo_logged_in?
      return
    end

    @success = false
    @delete = false
    @headline = (params[:headline][:text])
    @is_editable = true
    @user = current_user
    if @user[:headline].blank?
      @is_new = true
    end

    if params[:delete]
      @delete = true
      @user.headline = ''
      @user.save!
      respond_to do |format|
        format.js
        return
      end
    end

    @user[:headline] = @headline;
    @user.save!
    @success = true
    rparams = params.except(:headline, :delete)

    NotificationsLoggerWorker.perform_async('Consumer.Profile.SaveObjective',
                                            {handle: @user[:handle],
                                             params: rparams,
                                             ref: {ref: params[:ref],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('save-objective', current_user[:_id].to_s, {
                                                             ref: params[:ref]
                                                         })
    end

    reset_is_profile_incomplete
    respond_to do |format|
      format.js
      format.json {
        return render json: {success: true}
      }
    end
  end

  def sanitize_html t
    Sanitize.fragment(
        t,
        :elements => %w(ul li i b br u p ol),
    # :attributes => {
    #   "img" => ["class", "src"]
    # }
    )
  end
end
