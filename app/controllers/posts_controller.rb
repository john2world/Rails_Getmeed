class PostsController < ApplicationController
  include CommonHelper
  include LinkHelper


  def post_job
    unless logged_in?(root_path)
      return
    end
    enterprise_user = EnterpriseUser.find(current_user.id)
    if enterprise_user.blank?
      enterprise_user = EnterpriseUser.new
      enterprise_user.id = current_user.id
      enterprise_user.title = current_user.headline
      enterprise_user.first_name = current_user.first_name
      enterprise_user.last_name = current_user.last_name
      enterprise_user.password_hash = current_user.password_hash
      enterprise_user.create_dttm = current_user.create_dttm
      enterprise_user.short_bio = current_user.bio
      enterprise_user.active = true
      email_parts =  current_user.id.split('@')
      domain = email_parts[1]
      company = get_or_create_company(get_company_handle_from_email(current_user.id), "https://logo.clearbit.com/#{domain}")
      enterprise_user.company_id = company.id
      enterprise_user.save
    end
    redirect_to 'https://enterprise.getmeed.com/login'
  end

  def update_story
    unless logged_in?(root_path)
      return
    end

    if params[:scrape_id].blank? and params[:caption].blank?
      @error = 'scrapeIdBlank!'
    end

    unless params[:scrape_id].blank?
      scrape_data = get_scrape_by_id(params[:scrape_id])
      if scrape_data.blank?
        @error = 'scrapeBlank'
      end
      params[:poster_id] = current_user.handle
      params[:title] = scrape_data.title
      params[:description] = scrape_data.description
      params[:photo_url] = scrape_data.large_image_url
      params[:external_url] = scrape_data.url
      params[:tags] = scrape_data.tags
    end

    @feed_item = FeedItems.find params[:id]
    if @feed_item.blank?
      @error = 'empty_feed'
    end

    unless @error.blank?
      respond_to do |format|
        format.html { return redirect_to '/' }
        format.json { return render json: { success: false, redirect_url: '/', error: @error}}
      end
      return
    end

    if !current_user.is_moderator? and @feed_item.poster_id != current_user.handle
      @error = 'blank_id'
    end

    unless @error.blank?
      respond_to do |format|
        format.html { return redirect_to '/user/collections' }
        format.json { return render json: { success: false, redirect_url: '/user/collections', error: @error}}
      end
      return
    end

    tag_ids = nil
    # enforced collection_ids is not blank
    collection_ids = params[:collection_ids].blank? ? @feed_item.collection_ids : params[:collection_ids]
    if params[:tag_ids]
      tags = get_or_create_tags(params[:tag_ids])

      tag_ids = tags.map(&:_id)
      if tag_ids.any?{ |id| id.eql? PORTFOLIO_CID }
        @feed_item.portfolio = true
        collection_ids << "#{@feed_item.poster_id}_#{PORTFOLIO_CID}"
      end
    end

    begin
      @feed_item.update_attributes(
          caption: scrub_input_text(params[:caption]),
          collection_ids: collection_ids,
          tag_ids: tag_ids,
          last_updated: Time.now
      )
    rescue Exception => ex
    end


    user = User.where(handle: @feed_item.poster_id).first
    @data = build_feed_models(user, [@feed_item])

    redirect_url = '/'

    respond_to do |format|
      format.html { return redirect_to redirect_url }
      format.json { return render json: { success: true, data: @data, redirect_url: redirect_url}}
    end
  end

  def publish_story
    unless logged_in?(root_path)
      return
    end

    if params[:collection_ids].blank?
      @error = 'collectionIdsBlank'
    end

    if params[:scrape_id].blank? and params[:caption].blank?
      @error = 'scrapeIdBlank!'
    end

    unless params[:scrape_id].blank?
      scrape_data = get_scrape_by_id(params[:scrape_id])
      if scrape_data.blank?
        @error = 'scrapeBlank'
      end
      params[:poster_id] = current_user.handle
      params[:title] = scrape_data.title
      params[:description] = scrape_data.description
      params[:photo_url] = scrape_data.large_image_url
      params[:external_url] = scrape_data.url
      params[:tags] = scrape_data.tags
    end

    unless @error.blank?
      respond_to do |format|
        format.html { return redirect_to '/user/collections' }
        format.json { return render json: { success: false, redirect_url: '/user/collections', error: @error}}
      end
      return
    end
    params[:type] = UserFeedTypes::STORY.to_s
    @majors = admin_all_majors
    @data = publish_user_generated_content(current_user.handle, current_school_handle, params)
    unless @data.blank?
      reward_for_meed_submission(current_user.handle)
      current_user[:meed_points] += MEED_POINTS::SUBMIT_POST
    end
    NotificationsLoggerWorker.perform_async("Consumer.#{params[:type]}.Post",
                                            {user_id: current_user.id,
                                             school_id: current_school_handle,
                                             params: params,
                                             ref: {referrer: params[:referrer],
                                                   referrer_id: params[:referrer_id],
                                                   referrer_type: params[:referrer_type],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('publish-story', current_user[:_id].to_s, {
                                                            school_id: current_school_handle,
                                                            ref: {referrer: params[:referrer],
                                                                  referrer_id: params[:referrer_id],
                                                                  referrer_type: params[:referrer_type]}
                                                        })
    end

    redirect_url = '/'
    if params[:add_to_portfolio]
      redirect_url = get_story_path(@data.poster_id, @data.subject_id)
      reward_for_portfolio_create(current_user.handle)
    end

    respond_to do |format|
      format.html { return redirect_to redirect_url }
      format.json { return render json: { success: true, data: @data, redirect_url: redirect_url}}
    end
    # EmailMeedPostWorker.perform_async(@data.id)
  end

end
