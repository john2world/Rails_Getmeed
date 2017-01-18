class ArticlesController < ApplicationController
  include ArticlesManager
  include FeedItemsManager
  include StoryHelper
  include UsersManager
  include SchoolsManager
  include CommonHelper

  def show_stories
    unless logged_in?
      return
    end
    @feed_items = FeedItems.where(:collection_id.exists => false, :poster_type => 'user', :type => 'story').to_a
    @public_collections = get_public_collections
  end

  def show_article
    @article = get_article(params[:id])
    rparams = params.except(:id)
    NotificationsLoggerWorker.perform_async('Consumer.Article.View',
                                            {handle: (current_user.blank?) ? 'public' : current_user[:handle],
                                             article_id: params[:id],
                                             params: rparams,
                                             ref: {referrer: params[:referrer],
                                                   referrer_id: params[:referrer_id],
                                                   referrer_type: params[:referrer_type],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('article-view', current_user[:_id].to_s, {
                                                           :article_id => params[:id],
                                                           :ref => {referrer: params[:referrer],
                                                                    referrer_id: params[:referrer_id],
                                                                    referrer_type: params[:referrer_type]}
                                                       })
    end
    if @article.blank?
      redirect_to root_path
    else
      update_article_views (@article.id)
      page_title(@article.title)
      @metadata = get_story_metadata(@article)
      unless @article[:company].blank? or current_user.blank?
        @article[:is_viewer_following] = is_user_following_company(current_user.handle, @article[:company].id)
      end
      respond_to do |format|
        format.html { return render layout: "angular_app", template: "angular_app/index" }
        format.json {
          return render json: {article: @article}
        }
      end
    end
  end

  def social_groups_track
    unless params[:id].blank?
      SocialChannels.where(_id: params[:id]).inc(:views, 1)
    end
  end

  def social_groups
    @school_channels = get_social_channels_for_school(get_school_handle_from_email(current_user.id))
    @fb_general_channels = Array.new
    @school_channels.each do |school_channel|
      if !school_channel.type.blank? and school_channel.type.eql? 'Facebook General Group'
        @fb_general_channels << school_channel
      end
    end
    @fb_general_channels.sort_by!(&:name)

    @fb_school_channels = Array.new
    @school_channels.each do |school_channel|
      if !school_channel.type.blank? and school_channel.type.eql? 'Facebook University Group'
        @fb_school_channels << school_channel
      end
    end
    @fb_school_channels.sort_by!(&:name)

    @linkedin_groups = Array.new
    @school_channels.each do |school_channel|
      if !school_channel.type.blank? and school_channel.type.downcase.eql? 'linkedin'
        @linkedin_groups << school_channel
      end
    end
    @linkedin_groups.sort_by!(&:name)

    @twitter_channels = Array.new
    @school_channels.each do |school_channel|
      if !school_channel.type.blank? and school_channel.type.downcase.eql? 'twitter'
        @twitter_channels << school_channel
      end
    end

    @twitter_channels.sort_by!(&:name)

  end

  def show_story
    article_id = params[:article_id]
    @article = ''
    if article_id.blank?
      return
    end
    @data = get_feed_item_for_subject_id(article_id, current_user)
    build_feed_models(current_user, [@data])[0]

    if @data.blank?
      return
    end
    @metadata = get_story_metadata(@data)
    page_title(@data.title)
    if cookies[article_id].blank?
      cookies[article_id] = true
      increment_feed_view_count(article_id)
    end
    rparams = params.except(:article_id)
    comments = get_comments_for_feed(current_user, @data.id)
    @data[:comments] = comments
    @data[:short_url] = get_short_url(@data.url)
    @related_content = get_feed_items_for_user_stories(current_user).take(3)
    NotificationsLoggerWorker.perform_async('Consumer.Article.Story',
                                            {handle: (current_user.blank?) ? 'public' : current_user[:handle],
                                             article_id: article_id,
                                             params: rparams,
                                             ref: {referrer: params[:referrer],
                                                   referrer_id: params[:referrer_id],
                                                   referrer_type: params[:referrer_type],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('story-view', current_user[:_id].to_s, {
                                                         :article_id => article_id,
                                                         :ref => {referrer: params[:referrer],
                                                                  referrer_id: params[:referrer_id],
                                                                  referrer_type: params[:referrer_type]},
                                                     })
    end


    respond_to do |format|
      format.html { return render layout: "angular_app", template: "angular_app/index" }
      format.json {
        return render json: {article: @data, related_content: @related_content, metadata: @metadata}
      }
    end


  end

  def create_article
    unless logged_in?
      return
    end
    @majors = admin_all_majors
    @feed_item = FeedItems.new
    cookies[:dont_show_meediorite_modal] = true

    respond_to do |format|
      format.html{
        return render layout: "angular_app", template: "angular_app/index"
      }
    end
  end

end
