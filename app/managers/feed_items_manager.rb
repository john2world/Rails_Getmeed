module FeedItemsManager
  include CommonHelper
  include LinkHelper
  include JobsManager
  include ProfilesManager
  include ProfilesHelper
  include TagsManager
  include SchoolsManager
  include KudosManager
  include UsersHelper
  include UsersManager
  include FeedHelper
  include EventsManager
  include CollectionsManager
  include ReviewsHelper
  include ReviewsManager
  include PhotoManager
  include CommentsManager
  include CoursesManager
  include MeedPointsTransactionManager

  FEEDS_BATCH_SIZE= 10
  TOTAL_FEED_SIZE = 350
  TOP_FEEDS_BATCH_SIZE = 10
  Schools = Hash[School.all().map { |s| [s.handle, s] }]

  def publish_user_generated_content(handle, school_handle, params)
    if handle.blank? or params.blank? or school_handle.blank?
      return
    end
    create_feed_item(handle, params[:scrape_id], params[:type], params[:privacy], params)
  end

  def create_feed_item(handle, subject_id, type, privacy, params = {})
    if handle.blank? or type.blank?
      return
    end
    if params.blank?
      params = {}
    end
    user = get_active_user_by_handle(handle)
    if privacy.blank?
      if user.blank?
        return
      end
      if user.major_id.blank?
        privacy = 'everyone'
      else
        privacy = user.major_id
      end
    end
    major_types = []
    user_major_id = get_major_type_by_major_id(user.major_id)
    unless user.major_id.blank?
      major_types << user_major_id
    end

    unless params[:major_types].blank?
      major_types.concat params[:major_types]
    end
    school_handle = get_school_handle_from_email(user.id)
    feed_item = FeedItems.new
    feed_item.poster_id = handle
    feed_item.major_types = major_types
    feed_item.privacy = privacy
    feed_item.poster_type = 'user'
    feed_item.create_time = Time.zone.now
    feed_item.poster_school = school_handle
    feed_item.privacy_text = get_privacy_text(privacy)
    user_generated_content = nil

    case UserFeedTypes.const_get(type.upcase)

      when UserFeedTypes::STORY
        feed_item.title = params[:title]
        feed_item.url = get_story_url(params[:poster_id], generate_id_from_text(params[:title]))
        feed_item[:path] = get_story_path(params[:poster_id], generate_id_from_text(params[:title]))
        feed_item.large_image_url = params[:photo_url]
        collection_ids = Array.new
        unless params[:collection_ids].blank?
          collection_ids.concat params[:collection_ids]
        end
        unless params[:tag_ids].blank?
          tags = get_or_create_tags(params[:tag_ids])
          tag_ids = []
          tags.each do |tag|
            if tag._id.eql? PORTFOLIO_CID
              params[:add_to_portfolio] = true
            end
            tag_ids << tag._id
          end
          feed_item.tag_ids = tag_ids
        end
        unless params[:event_id].blank?
          feed_item.event_id = params[:event_id]
        end
        if params[:add_to_portfolio]
          feed_item.portfolio = true
          collection_ids << "#{user.handle}_#{PORTFOLIO_CID}"
        end
        feed_item.collection_id = params[:collection_id]
        feed_item.collection_ids = collection_ids.compact
        stuff_feed_image_sizes(feed_item)
        feed_item.photo_id = params[:photo_id]
        feed_item.description = process_text(params[:description])
        if subject_id.blank?
          unless params[:caption].blank?
            subject_id = "#{generate_id_from_text(params[:caption].split(' ')[0..5].join(' '))}"
          end
        end
        feed_item.subject_id = subject_id
        feed_item.poster_id = user.handle
        unless params[:tags].blank?
          feed_item.tags = params[:tags]
        end
        unless params[:collections].blank?
          feed_item.collections = params[:collections]
        end
        unless params[:skills].blank?
          feed_item.skills = params[:skills]
        end
        unless params[:caption].blank?
          feed_item.caption = scrub_input_text(params[:caption])
        end
        unless params[:external_url].blank?
          feed_item.external_url = params[:external_url]
        end
        unless params[:embed_code].blank?
          feed_item.embed_code = params[:embed_code]
        end
        feed_item.photo_id = params[:photo_id]
        feed_item.is_anonymous = params[:is_anonymous]
        feed_item.type = UserFeedTypes::STORY.downcase
        if Rails.env.development?
          unless feed_item.event_id.blank?
            event = get_events(feed_item.event_id)
            unless event.blank?
              influencer = get_user_by_handle(event.author_id)
              unless influencer.blank?
                Notifier.email_influencer_question_submission(influencer, user, feed_item).deliver
              end
            end
          end
        end
      when UserFeedTypes::INTERNSHIP
        internship = get_user_internship(subject_id)
        if internship.blank?
          return
        end
        feed_item.title = internship.company
        feed_item.tag_line = "#{internship.title} - #{internship.end_year}"
        feed_item.subject_id = internship.id
        description = "#{internship.description}"
        unless internship.skills.blank?
          skills_string = internship.skills.kind_of?(Array) ? internship.skills.join(', ') : internship.skills
          description = "#{internship.description}  <br/>Skills —  #{skills_string}"
        end
        unless internship.link.blank?
          description = "#{description} <br/>#{anchorify_link(internship.link)}"
        end
        school_major_cid = get_school_major_collection_id(school_handle, user_major_id)
        unless school_major_cid.blank?
          feed_item.collection_ids << school_major_cid
        end
        feed_item.description = sanitize_text(description)
        feed_item.type = UserFeedTypes::INTERNSHIP.downcase
      when UserFeedTypes::USERWORK
        user_work = get_user_work(subject_id)
        unless user_work.blank?
          feed_item.title = "#{user_work.company}"
          feed_item.tag_line = "#{user_work.title} - #{user_work.end_year}"
          feed_item.subject_id = user_work.id
          description = "#{(user_work.description)}"
          unless user_work.skills.blank?
            skills_string = user_work.skills.kind_of?(Array) ? user_work.skills.join(', ') : user_work.skills
            description = "#{user_work.description} <br/> Skills — #{skills_string}"
          end
          unless user_work.link.blank?
            description = "#{description} <br/>#{anchorify_link(user_work.link)}"
          end
          school_major_cid = get_school_major_collection_id(school_handle, user_major_id)
          unless school_major_cid.blank?
            feed_item.collection_ids << school_major_cid
          end
          feed_item.description = sanitize_text(description)
          feed_item.type = UserFeedTypes::USERWORK.downcase
        end
      when UserFeedTypes::COURSEWORK
        user_course = get_user_course(subject_id)

        if user_course.blank? or user_course.description.blank?
          return
        end

        feed_item.title = user_course.title
        feed_item.tag_line = "#{user_course.semester} - #{user_course.year}"
        feed_item.subject_id = user_course.id
        description = "#{(user_course.description)}"
        unless user_course.skills.blank?
          skills_string = user_course.skills.kind_of?(Array) ? user_course.skills.join(', ') : user_course.skills
          description = "#{user_course.description} <br/>Skills — #{skills_string}"
        end
        unless user_course.link.blank?
          description = "#{description} <br/>#{anchorify_link(user_course.link)}"
        end
        school_major_cid = get_school_major_collection_id(school_handle, user_major_id)
        unless school_major_cid.blank?
          feed_item.collection_ids << school_major_cid
        end
        feed_item.description = sanitize_text(description)
        feed_item.type = UserFeedTypes::COURSEWORK.downcase
      when UserFeedTypes::PUBLICATION
        user_publication = get_user_publication(subject_id)
        unless user_publication.blank?
          feed_item.title = user_publication.title
          feed_item.subject_id = user_publication.id
          description = "#{process_text(user_publication.description)}"
          unless user_publication.link.blank?
            description = "#{description} <br/>#{anchorify_link(user_publication.link)}"
          end
          feed_item.description = description
          feed_item.type = UserFeedTypes::PUBLICATION.downcase
        end

      when UserFeedTypes::USER_COURSE_REVIEW
        review = get_course_review(subject_id)
        if review.blank? or review.review.blank? or review.user_course.blank?
          return
        end
        feed_item.title = "#{review.user_course.title} - Review"
        feed_item.tag_line = "#{review.course_code} by Prof.#{review.prof_name}"
        feed_item.subject_id = subject_id
        feed_item.description = "#{process_text(review.review)}"
        feed_item.caption = "Rating: #{review.rating}"
        feed_item.type = UserFeedTypes::USER_COURSE_REVIEW.downcase
        feed_item.is_anonymous = review.reviewer_handle.blank?
        feed_item.poster_id = review.reviewer_handle
        feed_item.poster_school = review.school_id
        feed_item.privacy = user.major_id
        feed_item.privacy_text = get_privacy_text(feed_item.privacy)
        feed_item.url = get_course_insights_url(review.course_code, review.school_id)
        school_major_cid = get_school_major_collection_id(school_handle, user_major_id)
        unless school_major_cid.blank?
          feed_item.collection_ids << school_major_cid
        end
      when UserFeedTypes::USER_COURSE_REFERENCE
        reference = get_course_reference_by_id(subject_id)
        reviewer = get_user_by_handle(reference.reviewer_handle)
        if reference.blank?
          return
        end
        feed_item.title = "#{reference.user_course.title}"
        feed_item.tag_line = "Reference from <a href='/#{reference.reviewer_handle}'>#{reviewer.name}</a>"
        feed_item.subject_id = subject_id
        feed_item.description = reference.review_text
        feed_item.type = UserFeedTypes::USER_COURSE_REFERENCE.downcase
        feed_item.poster_id = reference.reviewer_handle
        # Hardcoding the collection id to Resume and cover letters collection
        feed_item.collection_ids << get_public_major_collection_id(user_major_id)
        feed_item.tag_ids = ['course-reference']
      when UserFeedTypes::NATIVE_STORY
        feed_item.title = params[:title]
        feed_item.url = get_story_url(params[:poster_id], generate_id_from_text(params[:title]))
        feed_item[:path] = get_story_path(params[:poster_id], generate_id_from_text(params[:title]))
        feed_item.large_image_url = params[:photo_url]
        collection_ids = Array.new
        unless params[:collection_ids].blank?
          collection_ids.concat params[:collection_ids]
        end
        unless params[:tag_ids].blank?
          tags = get_or_create_tags(params[:tag_ids])
          tag_ids = []
          tags.each do |tag|
            if tag._id.eql? PORTFOLIO_CID
              params[:add_to_portfolio] = true
            end
            tag_ids << tag._id
          end
          feed_item.tag_ids = tag_ids
        end
        unless params[:event_id].blank?
          feed_item.event_id = params[:event_id]
        end
        if params[:add_to_portfolio]
          feed_item.portfolio = true
          collection_ids << "#{user.handle}_#{PORTFOLIO_CID}"
        end
        feed_item.collection_id = params[:collection_id]
        feed_item.collection_ids = collection_ids.compact
        stuff_feed_image_sizes(feed_item)
        feed_item.photo_id = params[:photo_id]
        feed_item.description = process_text(params[:description])
        if subject_id.blank?
          unless params[:caption].blank?
            subject_id = "#{generate_id_from_text(params[:caption].split(' ')[0..5].join(' '))}"
          end
        end
        feed_item.subject_id = subject_id
        feed_item.poster_id = user.handle
        unless params[:tags].blank?
          feed_item.tags = params[:tags]
        end
        unless params[:collections].blank?
          feed_item.collections = params[:collections]
        end
        unless params[:skills].blank?
          feed_item.skills = params[:skills]
        end
        unless params[:caption].blank?
          feed_item.caption = scrub_input_text(params[:caption])
        end
        unless params[:external_url].blank?
          feed_item.external_url = params[:external_url]
        end
        unless params[:embed_code].blank?
          feed_item.embed_code = params[:embed_code]
        end
        feed_item.photo_id = params[:photo_id]
        feed_item.is_anonymous = params[:is_anonymous]
        feed_item.type = UserFeedTypes::NATIVE_STORY.downcase
        if Rails.env.development?
          unless feed_item.event_id.blank?
            event = get_events(feed_item.event_id)
            unless event.blank?
              influencer = get_user_by_handle(event.author_id)
              unless influencer.blank?
                Notifier.email_influencer_question_submission(influencer, user, feed_item).deliver
              end
            end
          end
        end
    end

    unless params[:scrape_id].blank?
      feed_item.scrape_id = params[:scrape_id]
    end
    feed_item.poster_school = school_handle
    begin
      feed_item.save
    rescue Exception => ex
    end

    if UserFeedTypes.const_get(type.upcase).eql? UserFeedTypes::STORY
      feed_item.collection_ids.each do |cid|
        NewSubmissionToCollectionWorker.perform_async(feed_item.id, cid)
      end
    end
    unless params[:scrape_id].blank?
      put_scrape_into_feed(feed_item, params[:scrape_id])
    end
    feed_item[:user] = user
    if feed_item[:user]
      feed_item[:user][:name] = user.name
    end
    build_feed_models(nil, [feed_item])[0]
  end

  def put_scrape_into_feed(feed_item, scrape_id)
    if feed_item.blank?
      return
    end
    content = ScrapeData.find(scrape_id)
    if content.blank?
      return
    end
    feed_item[:scrape_data] = content
  end

  def get_feed_item_model_for_id(viewer, id)
    feed_item = FeedItems.find(id)
    unless feed_item.blank?
      feed_items = Array.new
      feed_items << feed_item
      feed_item_models = build_feed_models(viewer, feed_items)
      if feed_item_models.count == 0
        return nil
      end
      feed_item_models[0]
    end
  end

  def get_feed_item_for_id(id)
    FeedItems.find(id)
  end

  def get_feed_item_for_ids(ids, order_by_last_update=false)
    return order_by_last_update ?
        FeedItems.where(:_id.in => ids).order_by([:last_updated,-1]).to_a :
        FeedItems.find(ids)

  end

  def get_feed_item_for_subject_id(id, viewer = nil)
    FeedItems.where(subject_id: id).to_a[0]
  end

  def get_popular_meed_posts(time, limit= 5)
    feed_items = FeedItems.where(:create_time.gt => time, :poster_type => 'user', :type => 'story').order_by([:view_count, -1]).limit(limit)
    feed_item_models = build_feed_models(nil, feed_items)
    feed_item_models
  end

  def get_user_meed_posts(handle, time= 7.days.ago)
    feed_items = FeedItems.where(:create_time.gt => time, :poster_id => handle, :poster_type => 'user', :type => 'story').order_by([:view_count, -1])
    feed_item_models = build_feed_models(nil, feed_items)
    feed_item_models
  end

  def get_feed_items_for_poster_id(viewer, poster_id, page_size = 100)
    feed_items = FeedItems.where(:poster_id => poster_id).order_by([:create_time, -1])
    feed_item_models = build_feed_models(viewer, feed_items)
    feed_item_models
  end

  def increment_feed_kudos_count(id, handle)
    feed_item = FeedItems.find(id)
    unless feed_item.blank?
      feed_item.kudos_count += 1
      feed_item.last_updated = Time.now
      begin
        feed_item.save
      rescue Exception => ex
      end
      reward_for_upvote_received(feed_item.poster_id, id, handle)
    end
  end

  def update_feed_update_date(feed_id)
    feed_item = FeedItems.find(feed_id)
    unless feed_item.blank?
      feed_item.last_updated = Time.now
      begin
        feed_item.save
      rescue Exception => ex
      end
    end
  end

  def increment_comment_count(id, handle)
    feed_item = FeedItems.find(id)
    unless feed_item.blank?
      feed_item.comment_count += 1
      feed_item.last_updated = Time.now
      begin
        feed_item.save
      rescue Exception => ex
      end
      reward_for_comment_received(feed_item.poster_id, id, handle)
    end
  end

  def decrement_comment_count(id)
    FeedItems.where(id: id).inc(:comment_count, -1)
  end

  def increment_feed_view_count(subject_id)
    feed_item = FeedItems.where(subject_id: subject_id).first
    unless feed_item.blank?
      feed_item.view_count += 1
      if feed_item.view_count % 50 == 0
        feed_item.last_updated = Time.now
        reward_for_views_received(feed_item.poster_id, feed_item.id)
      end
      begin
        feed_item.save
      rescue Exception => ex
      end
    end
  end

  def remove_feed_item(id)
    feed_item = FeedItems.find(id)
    unless feed_item.blank?
      feed_item.delete
    end
  end

  def get_feed_item_map(feed_ids)
    feed_items = FeedItems.find(feed_ids)
    feed_map = Hash.new
    feed_items.each do |feed_item|
      feed_map[feed_item.id] = feed_item
    end
    feed_map
  end

  def get_feed_item_subject_map(subject_ids)
    feed_items = FeedItems.where(:subject_id.in => subject_ids)
    build_feed_models(nil, feed_items)
    feed_map = Hash.new
    feed_items.each do |feed_item|
      feed_map[feed_item.subject_id] = feed_item
    end
    feed_map
  end

  def get_public_feed_items(viewer)
    FeedItems.where(privacy: 'everyone').order_by([:create_time, -1]).limit(FEEDS_BATCH_SIZE).to_a
  end

  def get_feed_items_for_school(school_id)
    feed_items_cache = Rails.cache.fetch("#{REDIS_KEYS::CACHE_FEED_ITEM_UNIVERSITY}-#{school_id}", expires_in: 24.hours) do
       FeedItems.where(:poster_school => school_id, :type => 'story').pluck(:_id).to_a
    end
    feed_items = get_feed_item_for_ids(feed_items_cache)
    feed_items = feed_items.sort_by(&:last_updated)
    feed_items = feed_items.reverse
    feed_items.compact
  end

  def get_feed_items_company_type
    query = FeedItems.search "*", limit: FEEDS_BATCH_SIZE, execute: false
    query.body[:query] = {function_score: {random_score: {seed: DateTime.now.to_i},
                                           :query => {:filtered => {:filter => {:and => [{:term => {:type => "story"}}, {:term => {:poster_type => "company"}}]}}}}}
    (query.execute).results;
  end

  def get_feed_items_for_event(viewer, event_id)
    feed_items = FeedItems.where(:event_id => event_id)
    build_feed_models(viewer, feed_items)
  end

  def get_all_feed_items(cid=nil)
    if cid.blank? or cid.eql? 'feed'
      return FeedItems.where(:type => 'story', :poster_type => 'user').order_by([:create_time, -1]).to_a
    end
    FeedItems.where(:type => 'story', :poster_type => 'user', :collection_ids => cid).order_by([:create_time, -1]).to_a
  end

  def get_feed_items_course_reviews
    query = FeedItems.search "*", limit: FEEDS_BATCH_SIZE, execute: false
    query.body[:query] = {function_score: {random_score: {seed: DateTime.now.to_i},
                                           :query => {:filtered => {:filter => {:and => [{:term => {:type => "user_course_review"}}]}}}}}
    feed_items = (query.execute).results;
    feed_items
  end

  def get_feed_items_for_user_stories(viewer)
    handle = viewer.blank? ? 'public' : viewer.handle
    collection_feed_cache = Rails.cache.fetch("#{REDIS_KEYS::CACHE_FEED_ITEM_USER_STORIES}-#{handle}", expires_in: 24.hours) do
      collection_ids = get_user_follow_collection_ids(handle)
      FeedItems.where(:collection_ids.in => collection_ids, :type => 'story').limit(TOTAL_FEED_SIZE).pluck(:_id).to_a
    end

    followee_feed_cache = Rails.cache.fetch("#{REDIS_KEYS::CACHE_FEED_ITEM_FOLLOWEE_STORIES}-#{handle}", expires_in: 24.hours) do
      user_follow_ids = get_user_followee_ids(handle)
      FeedItems.where(:poster_id.in => user_follow_ids, :type => 'story').limit(TOTAL_FEED_SIZE).pluck(:_id).to_a
    end

    feed_ids = ordered_random_merge(collection_feed_cache, followee_feed_cache)
    feed_ids.uniq!
    feed_ids.compact!
    get_feed_item_for_ids(feed_ids, true)
  end

  def get_related_user_stories(feed_item, result_count=3)
    query = feed_item.similar explain: false, execute: false,
                              where: {title: {not: feed_item.title},
                                      type: 'story',
                                      poster_type: 'user',
                                      large_image_url: {not: nil}
                              },
                              field: %W(
            collections^15
            tags^10
            title^6
            description^4
            caption^4
        ),
                              boost_by: [:view_count],
                              limit: result_count

    related_content = query.execute
    results = related_content.to_a
    if results.size() < result_count
      # append results queries by tags
      precision = 100
      tags = Hash[feed_item.tags]
      tags = tags.each { |k, v| tags[k] = (v * precision).round() }
      boost = tags.map { |k, v| {value: k, factor: v} }
      search_keywords = tags.map { |k, v| "\"#{k}\"" }.join(' ')
      exclude_titles = results.map { |result| result.title }
      query = FeedItems.search search_keywords, explain: false, execute: false,
                               where: {title: {not: exclude_titles},
                                       type: 'story',
                                       poster_type: 'user',
                                       large_image_url: {not: nil}
                               },
                               field: %W(
                                    collections^15
                                    tags^10
                                    title^6
                                    description^4
                                    caption^4
                                ),
                               boost_where: {_all: boost},
                               limit: (result_count - results.size());
      search_results = query.execute.to_a;
      results = results + search_results
    end
    if results.size() < result_count
      exclude_titles = results.map { |result| result.title }
      results = results + FeedItems.where(:title.nin => exclude_titles, type: 'story', poster_type: 'user',
                                          :large_image_url.ne => nil).desc(:view_count).take(3).to_a;
    end
    return results
  end

  def get_feed_items_for_user(user, include_company = false)
    if user.blank?
      return get_weekly_top_feed_items
    end
    get_feed_items_for_user_stories(user)
  end

  def get_weekly_top_feed_items
    feed_items_cache = Rails.cache.fetch(REDIS_KEYS::CACHE_WEEKLY_TOP_FEED, expires_in: 24.hours) do
      FeedItems.where(:type => 'story').order_by([:last_updated, -1]).limit($FEED_PAGE_SIZE).pluck(:_id).to_a
    end
    feed_items = get_feed_item_for_ids(feed_items_cache)
    feed_items = feed_items.sort_by(&:last_updated)
    feed_items = feed_items.reverse
    feed_items.compact
  end

  def get_feed_items_for_tag_id(tag_id)
    FeedItems.where(:tag_ids => tag_id, :type.in => %w(native_story story)).order_by([:last_updated, -1]).to_a
  end

  def get_feed_items_for_collection_id(collection_id)
    if collection_id.include? PORTFOLIO_CID
      feed_items = FeedItems.where(:poster_id => collection_id.split(PORTFOLIO_CID)[0].chomp('_'), :type.in => ['native_story', 'story']).order_by([:last_updated, -1]).to_a
    else
      feed_items = FeedItems.where(:collection_ids => collection_id, :type.in => %w(native_story story)).order_by([:last_updated, -1]).to_a
    end
    feed_items
  end

  def get_feed_items_for_category_id(category_id)
    collection_ids = Collection.where(category: category_id).map { |x| x._id }
    feed_items = FeedItems.any_in(:collection_ids => collection_ids).order_by("last_updated DESC").to_a
    build_feed_models(nil, feed_items)
    feed_items
  end


  def get_static_item_sign_up
    static_feed_item = FeedItems.find('product-signup-banner')
    if static_feed_item.blank?
      static_feed_item = FeedItems.new
      static_feed_item.id = 'product-signup-banner'
      static_feed_item.title = 'Sign Up now to join Meed\'s professional community!'
      static_feed_item.type = 'product'
      static_feed_item.poster_type = 'product'
      static_feed_item.url = '/?lb=1'
      begin
        static_feed_item.save
      rescue Exception => ex
      end
    end
    static_feed_item
  end

  def get_static_item_submit_meed_post
    static_feed_item = FeedItems.find('product-collection-submission-points')
    if static_feed_item.blank?
      static_feed_item = FeedItems.new
      static_feed_item.id = 'product-collection-submission-points'
      static_feed_item.title = "Submit to your interested collections earn #{MEED_POINTS::COLLECTION_CREATE} pts"
      static_feed_item.type = 'product'
      static_feed_item.poster_type = 'product'
      static_feed_item.tag_line = ''
      static_feed_item.url = '/collections/new'
      begin
        static_feed_item.save
      rescue Exception => ex
      end
    end
    static_feed_item
  end


  def get_static_recommended_users(viewer)
    if viewer.blank?
      return nil
    end
    feed_item = FeedItems.new
    feed_item.id = 'recommended_users'
    feed_item.type = 'recommended_users'
    feed_item.poster_type = 'product'
    recommended_users = []
    if viewer.badge.eql? 'influencer'
      recommended_users =  get_recommended_influencers_for_user(viewer.handle)[0..5]
    else
      recommended_users =  get_recommended_influencers_for_user(viewer.handle)[0..5]
      recommended_users.concat get_recommended_school_users(viewer.handle)[0..5]
      recommended_users.shuffle!
    end

    if recommended_users.count > 0
      build_user_models(current_user, recommended_users)
      feed_item[:recommended_users] = recommended_users[0..5]
      feed_item
    end
  end

  def get_static_recommended_collections(viewer, all_recommendations = false)
    feed_item = FeedItems.new
    feed_item.id = 'recommended-collections'
    feed_item.type = 'recommended_collections'
    feed_item.poster_type = 'product'
    recommended_collections = get_recommended_collections(viewer)
    if recommended_collections.count > 0
      build_collection_models(current_user, recommended_collections)
      feed_item[:collections] = recommended_collections
      feed_item
    else
      nil
    end
  end

  def get_static_recommended_jobs(viewer)
    if viewer.blank? or viewer.badge.eql? UserBadgeTypes::INFLUENCER
      return nil
    end
    feed_item = FeedItems.find('recommended_jobs')
    if feed_item.blank?
      feed_item = FeedItems.new
      feed_item.id = 'recommended-jobs'
      feed_item.type = 'jobs'
      feed_item.poster_type = 'product'
      begin
        feed_item.save
      rescue Exception => ex
      end
    end
    type = 'all'
    jobs = get_jobs_for_user(viewer, type)
    if jobs.count > 0
      feed_item[:jobs] = jobs.take(30).shuffle().take(3)
      feed_item
    else
      nil
    end
  end



  def get_static_influencer_checklist_feed_item(feed_item, user_state)
    incomplete_items = 0
    if user_state.create_collection_date.blank?
      incomplete_items +=1
    end

    if user_state.last_submission_date.blank?
      incomplete_items +=1
    end

    if incomplete_items > 1
      feed_item[:user_state] = user_state
      return feed_item
    end
    nil
  end

  def get_static_invite_cta_feed_item(viewer)
    feed_item = FeedItems.find('product-check-list-single')
    feed_item.title = "Hey #{viewer.first_name.split(' ')[0].capitalize}, grow your network by inviting classmates!"
    feed_item.url = '/?lb=1&cp=1'
    feed_item
  end

  def get_static_missing_cta_feed_item(viewer)
    if viewer.blank?
      return get_static_item_sign_up
    end
    user_state_type = ''
    feed_item = nil
    unless viewer.badge.eql? 'influencer'
      feed_items = FeedItems.where(:poster_id => viewer.handle, :type => 'story').to_a
      if feed_items.blank?
        feed_item = FeedItems.find('product-check-list-single')
        feed_item.title = 'Hey, your portfolio is empty! Click here to start building your timeline :) '
        feed_item.url = "/#{viewer.handle}#portfolio"
      end
    end

    if viewer.image_url.include? 'dummyimage'
      feed_item = FeedItems.find('product-check-list-single')
      feed_item.title = 'Hey, You are missing a profile picture! Click here to change it :)'
      feed_item.url = "/#{viewer.handle}"
    end
    feed_item
  end


  def build_feed_models(viewer, feed_items)
    feed_item_models = Array.new
    feed_items = feed_items.compact

    if feed_items.blank?
      return feed_item_models
    end
    company_ids = Array.new
    user_ids = Array.new
    school_ids = Array.new
    feed_ids = Array.new
    job_ids = Array.new
    scrape_ids = Array.new
    tag_ids = []
    collection_ids = Array.new
    event_ids = Array.new
    viewer_followee_ids = []
    unless viewer.blank?
      viewer_followee_ids = get_user_followee_ids(viewer.handle)
    end
    downvoted_feed_items_ids = UserDownvote.from_user(viewer).feed_item_ids

    feed_items.each do |feed_item|
      unless feed_item.scrape_id.blank?
        scrape_ids << feed_item.scrape_id
      end
      unless feed_item.tag_ids.blank?
        tag_ids.concat feed_item.tag_ids.compact
      end
      unless feed_item.collection_ids.blank?
        collection_ids.concat feed_item.collection_ids.compact
      end

      unless feed_item.event_id.blank?
        event_ids << feed_item.event_id
      end

      unless viewer.blank?
        if viewer.handle.eql? feed_item.poster_id and !feed_item.type.in? %w(story native_story)
          next
        end
        feed_item[:is_viewer_following] = viewer_followee_ids.include? feed_item.poster_id
        if viewer.handle.eql? feed_item.poster_id
          feed_item[:is_viewer_author] = true
          feed_item[:is_viewer_following] = true
        elsif viewer.is_moderator?
          feed_item[:is_viewer_author] = true
        end
        feed_item[:can_downvote] = viewer.handle != feed_item.poster_id && viewer.is_moderator?
        feed_item[:downvoted] = feed_item.id.in? downvoted_feed_items_ids
      end

      if !feed_item.poster_type.blank? and feed_item.poster_type.eql? 'company' and !feed_item.poster_id.eql? 'testcorp'
        company_ids << feed_item.poster_id
        begin
          unless feed_item.job_ids.blank?
            job_ids.concat feed_item.job_ids
          end
        rescue Exception => ex
        end
      elsif !feed_item.poster_type.blank? and feed_item.poster_type.eql? 'user' and feed_item[:type] == UserFeedTypes::JOB
        user_ids << feed_item.poster_id
        job_ids << feed_item[:subject_id]
      elsif !feed_item.poster_type.blank? and (feed_item.poster_type.eql? 'user' or feed_item.poster_type.eql? 'product')
        user_ids << feed_item.poster_id
      end

      feed_item_models << feed_item
      feed_ids << feed_item.id
    end

    comments_map = get_comments_map_for_feed_ids(viewer, feed_ids)
    events = get_events(event_ids)
    event_map = Hash.new
    events.each do |event|
      if event.type.eql? 'ama'
        event[:url] = get_user_profile_url(event.author_id)
      end
      user_ids << event.author_id
      event_map[event.id] = event
    end
    user_ids.compact!
    tag_ids.compact!
    tags_map = get_tag_map(tag_ids)
    user_map = get_users_map_handles(user_ids)
    profile_map = get_user_profile_map(user_ids)
    collection_map = get_collection_map(collection_ids)
    user_ids.each do |user_id|
      user = user_map[user_id]
      unless user.blank?
        school_ids << get_school_handle_from_email(user.id)
      end
    end

    unless viewer.blank?
      kudos_map = get_kudos_giver_map_feed_ids(viewer.handle, feed_ids)
    end

    feed_item_models.each do |feed_item|
      unless feed_item.collection_ids.blank?
        mini_collections = []
        feed_item.collection_ids.each do |cid|
          if cid.eql? "#{feed_item.poster_id}_portfolio"
            next
          end
          collection = collection_map[cid.to_s]
          unless collection.blank?
            mini_collection = {}
            mini_collection[:_id] = collection._id
            mini_collection[:title] = collection.title
            mini_collection[:private] = collection.private
            mini_collection[:url] = get_collection_slug_url(collection.id, collection.handle, collection.slug_id)
            mini_collections << mini_collection
          end
        end
        unless feed_item.tag_ids.blank?
          tags = []
          feed_item.tag_ids.each do |tag_id|
            tag = tags_map[tag_id]
            unless tag.blank?
              tags << tag
            end
          end
          feed_item[:tag_objects] = tags
        end
        unless feed_item.event_id.blank?
          event = event_map[feed_item.event_id]
          unless event.blank?
            user = user_map[event.author_id]
            unless user.blank?
              event[:user] = user
              event[:user][:name] = event[:user].name
              feed_item[:event] = event
            end
          end
        end
        unless mini_collections.blank?
          feed_item[:collections] = mini_collections
          feed_item[:collection] = mini_collections[0]
        end
      end
      if !feed_item.scrape_id.blank? and (feed_item.large_image_url.blank?)
        feed_item[:large_image_url] = 'https://res.cloudinary.com/resume/image/upload/v1451955244/latest_gkfrrs.png'
        feed_item[:medium_image_url] = 'https://res.cloudinary.com/resume/image/upload/c_scale,w_100/v1451955244/latest_gkfrrs.png'
        feed_item[:small_image_url] = 'https://res.cloudinary.com/resume/image/upload/c_scale,w_50/v1451955244/latest_gkfrrs.png'

      end
      if !feed_item.poster_type.blank? and feed_item.poster_type.eql? 'user'
        user = user_map[feed_item.poster_id]
        profile = profile_map[feed_item.poster_id]
        if feed_item[:type] == UserFeedTypes::STORY or feed_item[:type] == UserFeedTypes::NATIVE_STORY
          feed_item.url = get_story_url(feed_item.poster_id, feed_item.subject_id, feed_item.create_time)
          if feed_item.type == UserFeedTypes::NATIVE_STORY
            feed_item.url = feed_item.external_url
          end
          feed_item[:path] = get_story_path(feed_item.poster_id, feed_item.subject_id)

          if comments_map.blank?
            feed_item[:comments] = []
          else
            comments = comments_map[feed_item.id.to_s]
            feed_item[:comments] = comments
          end
        end

        unless profile.blank?
          if is_user_generated_content(feed_item) or is_popular_content(feed_item)
            feed_item[:feed_rank] = 100
          else
            feed_item[:feed_rank] = profile.score
          end
        end

        unless user.blank?
          user_hash = {}

          user_hash[:name] = user.name
          user_hash[:badge] = user.badge
          user_hash[:handle] = user.handle
          user_hash[:headline] = user.headline
          user_hash[:small_image_url] = user.small_image_url
          user_hash[:image_url] = user.image_url
          user_hash[:large_image_url] = user.large_image_url
          user_hash[:school] = get_school_handle_from_email(user.id)
          feed_item[:user] = user_hash
        end

        if feed_item.url.blank?
          feed_item.url = get_user_auth_profile_url feed_item.poster_id
        end

        unless kudos_map.blank? or viewer.blank?
          kudos = kudos_map[feed_item[:_id].to_s]
          feed_item[:viewer_gave_kudos] = (kudos.blank?) ? false : true
        end
      end
    end
    feed_item_models
  end

  def build_feed_action_models(actions)
    action_models = Array.new
    # currently supporting only course invites
    actions.each do |invite|
      invite[:course] = invite.user_course
      unless invite.user_course.blank?
        invite[:user] = build_user_model(get_user_by_handle(invite.user_course.handle))
        action_models << invite
      end
    end
    action_models
  end

  def get_privacy_text(privacy_code)
    if privacy_code.eql? 'everyone'
      return 'Everyone'
    end
    majors = get_major_by_code(privacy_code)
    unless majors.blank?
      if majors.code.eql? 'sci_comp' or majors.code.eql? 'eng_electrical' or majors.code.eql? 'eng_comp'
        return 'Computer Science, Electrical Engineering'
      else
        return majors.major
      end
    end
    school = get_school(privacy_code)
    if school.blank?
      return 'Everyone'
    end
    school.name
  end

  # adds information that is not available in feed object but required to render ux
  def add_feed_metadata(user, profile, feeditems)
    # getting user kudos
    kudos = get_kudos_by_handle(profile.handle)
    # create a hash
    kudos = Hash[kudos.map { |k| [k.feed_id, k] }]
    # create a user hash
    user_ids = feeditems.select { |f| f.poster_type == 'user' }.map { |f| f.poster_id }.uniq
    users = get_users_map_handles(user_ids)
    feeditems.each do |item|
      if item[:description].blank?
        # remove item if it has no description
        feeditems.delete(item)
      end
      if profile.handle.eql? item.poster_id
        item[:is_viewer_author] = true
      end
      # if feeditem is of type company fill company information
      case item.poster_type
        when 'company'
          unless item.poster_id.blank?
            company = Company.find(item.poster_id)
            unless company.blank?
              item[:company] = company
            end
          end
        when 'user'
          if item.url.blank?
            item.url = get_user_auth_profile_url item.poster_id
          end
          item[:user] = users[item.poster_id]
      end
      # create url if user is absent
      if item.url.blank?
        item.url = get_story_url(item.poster_id, item.subject_id, item.create_time)
      end
      unless profile.blank?
        item[:is_user_following_company] = is_user_following_company(profile.handle, item.poster_id)
      end
      item[:viewer_gave_kudos] = kudos.has_key? item[:_id] ? true : false

      item[:school] = Schools[get_school_handle_from_email(user.id)]
    end
    return feeditems
  end

  # Returns the feed items for a user. If filter is specified it will return results from that filter
  def get_user_feed(user, filter = nil)
    feeditems = []
    if user.blank?
      return feeditems
    end
    profile = Profile.find(user[:handle])
    if profile.blank?
      return items
    end

    case filter
      when "students"
        # searching only where poster_type is user
        feeditems = search_by_profile(user, profile, FEEDS_BATCH_SIZE, ["user"]).results
      when "company"
        # searching only where poster type is company
        feeditems = search_by_profile(user, profile, FEEDS_BATCH_SIZE, ["company"]).results
      else
        # searching for both user and company
        feeditems = search_by_profile(user, profile, FEEDS_BATCH_SIZE).results
    end
    # add required metadata before returning the feeditems
    return add_feed_metadata(user, profile, feeditems)
  end

  # Gets the feed items for a provided profile from the FeedItems Index
  # poster_filters allows filtering by poster_type
  def search_by_profile(user, profile, result_count=10, poster_filters = ["user", "company"])
    tags = profile[:tags]
    if tags.blank?
      tags = []
    end
    # boosting works only for integer values so converting the probabilities into integers with precision = 10^-3
    precision = 100
    if tags.class() == Array
      tags = Hash[tags]
    end
    tags = tags.each { |k, v| tags[k] = (v * precision).round() }
    boost = tags.map { |k, v| {value: k, factor: v} }
    major_key = user.major_id
    if major_key.blank?
      major_key = ''
    end
    school_handle = get_school_handle_from_email(user.id)
    if school_handle.blank?
      school_handle = ''
    end
    privacies = get_possible_privacies(major_key)
    privacies << school_handle
    privacies << "everyone"
    search_keywords = tags.map { |k, v| "\"#{k}\"" }.join(' ')
    query = FeedItems.search search_keywords, operator: 'or', execute: false,
                             where: {poster_type: poster_filters,
                                     # removing posts by user himself
                                     poster_id: {not: profile.handle}
                             },
                             fields: %W(
                              title^10,
                              caption^5,
                              tag_line^5,
                              description^1
                             ),
                             boost_where: {_all: boost,
                                           poster_school: {value: school_handle, factor: 500},
                                           privacy: {value: privacies, factor: 500},
                                           poster_type: [{value: "company", factor: 100}],
                             },
                             limit: result_count
    # Using a decay function for the time when the feed item was posted. If the post was done within 7 days, there is
    # no decay in the score. In 30 days from then the score decays by half.
    query.body[:query][:function_score].merge!({
                                                   functions: [
                                                       exp: {
                                                           create_time: {
                                                               scale: '60',
                                                               offset: '30d',
                                                               decay: 0.5
                                                           }
                                                       }
                                                   ]
                                               })
    results = query.execute
    return results
  end

  def test_new_submission_to_collection_email(feed_id, collection_id)
    if collection_id.blank?
      return
    end
    collection = get_collection(collection_id)
    if collection.blank?
      return
    end
    feed_item = get_feed_item_for_id(feed_id)
    if feed_item.blank?
      return
    end
    collection.inc(:submission_count, 1)
    collection.last_submission_dttm = Time.now
    unless collection.handle.eql? feed_item.poster_id
      collection.add_to_set(:contributors, feed_item.poster_id)
    end
    collection.save

    submittor = get_user_by_handle(feed_item.poster_id)
    save_user_state(submittor, UserStateTypes::LAST_SUBMISSION_DATE)

    if submittor.handle.eql? collection.handle
      return
    end
    collection_owner = get_user_by_handle(collection.handle)
    if collection_owner.blank? or submittor.blank? or feed_item.blank?
      return
    end
    Notifier.email_collection_owner_submission(collection_owner, submittor, collection, feed_item).deliver
  end

  def migrate_feed_item_old_to_new(feed_item)
    if feed_item.blank?
      return
    end
    poster = get_user_by_handle(feed_item.poster_id)
    if poster.blank?
      return
    end
    major_type_id = get_major_type_by_major_id(poster.major_id)
    cid = get_public_major_collection_id(major_type_id)

    new_cids = [cid.to_s]
    unless feed_item.collection_ids.blank?
      feed_item.collection_ids.each do |id|
        if !id.blank? and id.to_s.include? 'portfolio'
          new_cids << id
        end
      end
    end

    feed_item.collection_ids = new_cids
    begin
      feed_item.save
    rescue Exception => ex
    end
    get_collection(cid)
  end


end
