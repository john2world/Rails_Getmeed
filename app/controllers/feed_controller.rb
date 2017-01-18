class FeedController < ApplicationController
  include FeedItemsManager
  include CoursesManager

  def feed_track
    unless params[:id].blank?
      if cookies[params[:id]].blank?
        cookies[params[:id]] = true
        increment_feed_view_count(params[:id])
      end
    end

    respond_to do |format|
      format.json { render json: {success: true}  }
    end
  end

  def perma_link
    feed_item = get_feed_item_for_id(params[:id])
    build_feed_models(current_user, [feed_item])
    if feed_item.blank?
      redirect_url = '/'
    else
      redirect_url = get_story_url(feed_item.poster_id, feed_item.subject_id, feed_item.create_time)
    end
    redirect_to redirect_url
  end

  def collection_feed
    unless logged_in?
      return
    end

    feed_items = get_feed_items_for_collection_id(params[:collection_id])

    respond_to do |format|
      format.js
      format.json { render json: feed_items  }
    end

  end

  def collection_category_feed
    unless logged_in?
      return
    end
    feed_items = get_feed_items_for_category_id(params[:category_id])
    respond_to do |format|
      format.js
      format.json { render json: feed_items  }
    end
  end

  def activity
    unless logged_in?
      return
    end
    page_title ('Home')
    redirect_to '/home'
  end

  def company_load
    if params[:id].blank?
      @error = 'blank_id'
      return
    end
    position = params[:position]
    @company = get_company_by_id(params[:id])
    feed_items = get_feed_items_for_poster_id(nil, params[:id])
    @feed_items = Kaminari.paginate_array(feed_items).page(params[:page]).per($FEED_PAGE_SIZE)
    rparams = params.except(:id)

    NotificationsLoggerWorker.perform_async('Consumer.Feed.Company',
                                            {handle: current_user.blank? ? 'public' : current_user[:_id],
                                             company_id: @company.id,
                                             params: rparams,
                                             ref: {referrer: params[:referrer],
                                                   referrer_id: params[:referrer_id],
                                                   referrer_type: params[:referrer_type],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('view-company', current_user[:_id].to_s, {
                                                           :feeds_count => feed_items.blank? ? 0 : feed_items.count,
                                                           :page_index => params[:page],
                                                           :ref => params[:ref]
                                                       })
    end

    respond_to do |format|
      format.js
    end

  end

  def load
    position = params[:position]
    static_position = 0
    all_feed_items = Array.[]
    feed_page_size = params[:page_size].blank? ? FEEDS_BATCH_SIZE : params[:page_size]
    @user = current_user
    # feed will not have applied jobs
    if position.eql? 'university' and !@user.blank?
      school_handle = @user.school_id
      if school_handle.blank?
        school_handle = get_school_handle_from_email(current_user.id)
      end
      all_feed_items.concat get_feed_items_for_school(school_handle)
      static_feed_item = get_static_invite_cta_feed_item(current_user)
      unless static_feed_item.blank?
        static_position += 2
        all_feed_items.insert(static_position, static_feed_item)
      end
    else
      all_feed_items.concat get_feed_items_for_user(@user, false)
      static_feed_item = get_static_missing_cta_feed_item(current_user)
      unless static_feed_item.blank?
        static_position = 1
        all_feed_items.insert(static_position, static_feed_item)
      end

      recommended_job_item = get_static_recommended_jobs(current_user)
      unless recommended_job_item.blank?
        static_position += 2
        all_feed_items.insert(static_position, recommended_job_item)
      end

      recommended_collection_item = get_static_recommended_collections(current_user)
      unless recommended_collection_item.blank?
        static_position += 10
        all_feed_items.insert(static_position, recommended_collection_item)
      end
    end


    feed_items = Kaminari.paginate_array(all_feed_items).page(params[:page]).per(feed_page_size)
    @feed_items = build_feed_models(@user, feed_items)
    actions = []
    unless @user.blank?
      actions = get_course_project_invites_by_email(@user.id)
      actions = build_feed_action_models(actions)
    end

    rparams = params.except(:position, :page)

    NotificationsLoggerWorker.perform_async('Consumer.Feed.View',
                                            {handle: @user.blank? ? 'public' : @user[:_id],
                                             position: static_position,
                                             feed_items_count: @feed_items.count,
                                             params: rparams,
                                             ref: {referrer: params[:referrer],
                                                   referrer_id: params[:referrer_id],
                                                   referrer_type: params[:referrer_type],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('view-feed', current_user[:_id].to_s, {
                                                        :feeds_count => @feed_items.blank? ? 0 : @feed_items.count,
                                                        :page_index => params[:page],
                                                        :ref => params[:ref]
                                                    })
    end

    if params[:alert].eql? 'invite_success'
      flash[:alert] = 'Successfully included your contacts!'
    end

    respond_to do |format|
      format.js
      format.json { render json: {feed: @feed_items, actions: actions} }
    end
  end

  def feed
    redirect_to get_activity_feed_url
  end

  def delete
    unless logged_in?
      return
    end
    @feed_id = params[:feed_id]
    unless @feed_id.blank?
      remove_feed_item(@feed_id)
    end
    respond_to do |format|
      format.js
      format.json { render json: {success: true}  }
    end
  end

  def skip_action
    invite_id = params[:action_id]
    if invite_id.blank?
      return error_render('Action Id is empty', '/')
    end
    invite = skip_reference_invite_by_id(invite_id)
    success = true
    if invite.blank?
      success = false
    end
    respond_to do |format|
      format.js
      format.json { render json: {success: success} }
    end
  end

  def submit_action
    if params[:action_id].blank?
      return error_render('Invite Id is empty', '/')
    end
    if params[:review_text].blank?
      return error_render('Review text is empty', '/')
    end
    course_reference = create_reference_from_invite(params[:action_id], params[:review_text])
    success = true
    if course_reference.blank?
      success = false
    end
    respond_to do |format|
      format.js
      format.json { render json: {success: success} }
    end
  end
end
