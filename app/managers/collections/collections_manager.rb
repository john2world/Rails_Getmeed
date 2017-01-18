module CollectionsManager
  include SchoolsManager
  PORTFOLIO_CID = 'portfolio'
  PORTFOLIO_TITLE = "My Portfolio"

  LIBERAL_ARTS_COLLECTION_IMAGE = "https://res.cloudinary.com/resume/image/upload/c_fit,r_6,w_400/v1449193880/diqynberpeorf2llvuez.jpg"
  HARDWARE_ENG_COLLECTION_IMAGE = "https://res.cloudinary.com/resume/image/upload/c_fit,r_6,w_400/v1448916987/kor3eonal8zt2fl0ezad.jpg"
  SOFTWARE_ENG_COLLECTION_IMAGE = "https://res.cloudinary.com/resume/image/upload/c_fit,r_6,w_400/v1448916392/usqkbuejuya92ucbehbe.jpg"
  SCIENCES_COLLECTION_IMAGE = "https://res.cloudinary.com/resume/image/upload/c_fit,r_6,w_400/v1448918031/imbykm1korizmzseapqp.jpg"
  MARKETING_COLLECTION_IMAGE = "https://res.cloudinary.com/resume/image/upload/c_fit,r_6,w_400/v1448917537/ihjsbspwwkp5kdps23gq.jpg"
  OTHER_ENG_COLLECTION_IMAGE = "https://res.cloudinary.com/resume/image/upload/c_fit,r_6,w_400/v1448917201/w8ey9jre4huf7wurlnaw.jpg"

  PORTFOLIO_SMALL_IMAGE_URL = "https://res.cloudinary.com/resume/image/upload/c_scale,w_200/v1443755110/Portfolio-Development-Icon-300x300_famw7n.png"
  PORTFOLIO_MEDIUM_IMAGE_URL = "https://res.cloudinary.com/resume/image/upload/c_scale,w_400/v1443755110/Portfolio-Development-Icon-300x300_famw7n.png"
  PORTFOLIO_LARGE_IMAGE_URL = "https://res.cloudinary.com/resume/image/upload/c_scale,w_600/v1443755110/Portfolio-Development-Icon-300x300_famw7n.png"
  MEED_ANNOUNCEMENTS_CID = "product-meed-announcements-cid"
  ASK_MEED_COLLECTION_ID = "563bac68e2a07f38fa00000a"
  UNIVERSITY_NEWS_CID = "5604428678cb778f20000001"
  CAREER_ADVICE_CID = "560b42b7f03517678600000b"
  INTERVIEW_AND_JOB_TIPS_CID = "5604415078cb77bbf0000001"
  RESUME_AND_COVERLETTERS_CID = "560f061ce90e9d6caf000010"
  DEFAULT_PUBLIC_CIDS = %w(5602ffe178cb779fbb000002 5664bc5ce2a07f5831000036 5660f0b5e2a07f849f000003 568fdf1be2a07feedd000054 566232c4e2a07f4cf4000018 5660f262e2a07fd5f000000c 5660f15ae2a07fd5f0000008 5660f18ae2a07f849f000004 5660f19ae2a07fd5f000000a)
  PRIVATE_SCHOOL_GROUPS = %w(berkeley usc stanford)

  def create_collection(creator_id, params)
    Rails.cache.delete(REDIS_KEYS::CACHE_ALL_COLLECTIONS_ID)
    Rails.cache.delete("#{REDIS_KEYS::CACHE_USER_CREATED_COLLECTIONS}-#{creator_id}")
    Rails.cache.delete("#{REDIS_KEYS::CACHE_COLLECTIONS_FOR_USER}-#{creator_id}")
    Rails.cache.delete("#{REDIS_KEYS::CACHE_USER_FOLLOW_COLLECTIONS}-#{creator_id}")
    collection = Collection.new
    collection.handle = creator_id
    collection.title = params[:title]
    collection.slug_id = "#{generate_id_from_text(params[:title])}"
    collection.description = params[:description]
    begin
      upload_hash = Cloudinary::Uploader.upload(params[:image_url],
                                                :crop => :fit, :width => 800, :radius => 6,
                                                :eager => [
                                                    {:width => 400,
                                                     :crop => :fit,
                                                     :radius => 6},
                                                    {:width => 200,
                                                     :radius => 6,
                                                     :crop => :fit, :format => 'png'}
                                                ],
                                                :tags => ['blog', params[:title]], :secure => true)
      collection.large_image_url = upload_hash['secure_url']
      collection.small_image_url = upload_hash['eager'][0]['secure_url']
      collection.medium_image_url = upload_hash['eager'][1]['secure_url']
    rescue Exception => ex
      collection.large_image_url = params[:image_url]
      collection.small_image_url = params[:image_url]
      collection.medium_image_url =params[:image_url]
    end
    collection.category = params[:category_id]
    collection.private = params[:is_private].blank? ? false : true
    collection.major_types = params[:major_types]
    collection.view_count = 1
    collection.save
    create_follow_collection(collection.handle, collection)
    save_user_state(collection.handle, UserStateTypes::CREATE_COLLECTION_DATE)
    collection
  end

  def get_category_for_id(category_id)
    CollectionCategory.find(category_id)
  end

  def follow_collection(handle, collection_id)
    if collection_id.blank? or handle.blank?
      return
    end
    collection = get_collection(collection_id)
    if collection.blank?
      return
    end
    create_follow_collection(handle, collection)
  end

  def unfollow_collection(handle, collection_id)
    Rails.cache.delete("#{REDIS_KEYS::CACHE_USER_FOLLOW_COLLECTIONS}-#{handle}")
    Rails.cache.delete("#{REDIS_KEYS::CACHE_USER_CREATED_COLLECTIONS}-#{handle}")
    Rails.cache.delete("#{REDIS_KEYS::CACHE_FEED_ITEM_USER_STORIES}-#{handle}")
    Rails.cache.delete("#{REDIS_KEYS::CACHE_COLLECTIONS_FOR_USER}-#{handle}")

    collection = get_collection(collection_id)
    if collection.blank?
      return
    end
    follow_id = "#{handle}_#{collection.id}"
    follow_collection = UserFollowCollection.find(follow_id)
    unless follow_collection.blank?
      collection.inc(:follower_count, -1)
      follow_collection.delete
      collection.save
    end
  end

  def view_collection(collection_id)
    Collection.where(:collection_id => collection_id).inc(:view_count, 1)
  end

  def increment_collection_view_count(collection_id)
    Collection.where(_id: collection_id).inc(:view_count, 1)
  end

  def get_collection(collection_id)
    if collection_id.blank?
      return nil
    end
    Collection.find(collection_id)
  end

  def get_collection_map(collection_ids)
    collection_ids.uniq!
    collection_ids.compact!
    collections = Collection.find(collection_ids)
    ret_map = Hash.new
    collections.each do |collection|
      ret_map[collection.id.to_s] = collection
    end
    ret_map
  end

  def create_follow_collection(handle, collection)
    Rails.cache.delete("#{REDIS_KEYS::CACHE_USER_FOLLOW_COLLECTIONS}-#{handle}")
    Rails.cache.delete("#{REDIS_KEYS::CACHE_USER_CREATED_COLLECTIONS}-#{handle}")
    Rails.cache.delete("#{REDIS_KEYS::CACHE_FEED_ITEM_USER_STORIES}-#{handle}")
    Rails.cache.delete("#{REDIS_KEYS::CACHE_COLLECTIONS_FOR_USER}-#{handle}")

    follow_id = "#{handle}_#{collection.id}"
    follow_collection = UserFollowCollection.find(follow_id)
    if follow_collection.blank?
      follow_collection = UserFollowCollection.new
      follow_collection.id = follow_id
      follow_collection.follower_id = handle
      follow_collection.collection_id = collection.id
      follow_collection.save
      collection.inc(:follower_count, 1)
      collection.save
      unless DEFAULT_PUBLIC_CIDS.include? collection.id
        save_user_state(collection.handle, UserStateTypes::FOLLOW_COLLECTION_DATE)
        EmailFollowCollectionWorker.perform_async(handle, collection.id)
      end
    end
  end

  def get_collections(collection_ids)
    Collection.find(collection_ids)
  end

  def get_collections_for_category(category_id)
    Collection.where(:category => category_id).to_a
  end

  def get_recommended_collections(viewer)
    if viewer.blank?
      collections = get_recommended_collections_internal(viewer)
    else
      collections = get_recommended_collections_internal(viewer)
    end
    school_collections = get_school_collections(viewer)
    if school_collections.blank?
      return collections
    end
    collections[0..2].concat school_collections[0..2]
  end

  def get_top_collection_ids(limit = 5)
    ret = Rails.cache.fetch(REDIS_KEYS::CACHE_TOP_COLLECTIONS, expires_in: 48.hours) do
      Collection.all.order_by([:follower_count, -1]).limit(limit).to_a.map(&:id)
    end
    ret
  end

  def get_public_collections(viewer = nil, limit = 100)
    get_recommended_collections_internal(viewer)
  end

  def get_school_collections(viewer)
    if viewer.blank?
      return Array.[]
    end
    school = get_school(get_school_handle_from_email(viewer.id))
    if school.blank?
      return Array.[]
    end
    collection_ids_cache = Rails.cache.fetch("#{REDIS_KEYS::CACHE_SCHOOL_COLLECTIONS_ID}-#{school.id}", expires_in: 168.hours) do
      collection_ids = []
      unless school.blank?
        unless school.default_collection_ids.blank?
          collection_ids.concat school.default_collection_ids
        end

        unless school.major_collection_ids.blank?
          collection_ids.concat school.major_collection_ids
        end
      end
      collection_ids - get_user_follow_collection_ids(viewer.handle)
    end
    get_collections(collection_ids_cache)
  end

  def get_all_collections(viewer=nil)
    ret_2 = []
    ret = Rails.cache.fetch(REDIS_KEYS::CACHE_ALL_COLLECTIONS_ID, expires_in: 24.hours) do
      Collection.all.where(:portfolio => false, :private => false).to_a
    end

    unless viewer.blank?
      ret_2 = Rails.cache.fetch("#{REDIS_KEYS::CACHE_ALL_COLLECTIONS_ID}-#{viewer.handle}", expires_in: 48.hours) do
        Collection.all.where(:private => true, :category => get_school_handle_from_email(viewer.id))
      end
    end
    ret.concat ret_2
  end

  def get_collections_for_user(handle)
    ret = Rails.cache.fetch("#{REDIS_KEYS::CACHE_COLLECTIONS_FOR_USER}-#{handle}", expires_in: 48.hours) do
      user = get_user_by_handle(handle)
      unless user.blank?

        school_collections = Collection.where(:category => get_school_handle_from_email(user.id)).to_a
        following_collections = get_user_following_collections(handle, true)
        school_collections.concat following_collections
      end
    end
    ret
  end

  def get_user_generated_collections(handle)
    ret = Rails.cache.fetch("#{REDIS_KEYS::CACHE_USER_CREATED_COLLECTIONS}-#{handle}", expires_in: 48.hours) do
      Collection.all.where(:handle => handle, :portfolio => false).to_a
    end
    ret
  end

  def get_user_following_collections(handle, include_created=false)
    ret = Rails.cache.fetch("#{REDIS_KEYS::CACHE_USER_FOLLOW_COLLECTIONS}-#{handle}", expires_in: 48.hours) do
      ids = get_user_follow_collection_ids(handle)
      Collection.where(:_id.in => ids, :private => false).to_a
    end
    ret
  end

  def get_user_collection_ids(handle)
    Collection.where(:handle => handle).to_a.map(&:id)
  end

  def increment_collection_posts(collection_id)
    collection = Collection.find(collection_id)
    collection.inc(:submission_count, 1)
    collection.last_submission_dttm = Time.now
    collection.save
  end

  def build_collection_models(viewer, collections, include_contributors = false)
    unless viewer.blank?
      collection_ids = get_user_follow_collection_ids(viewer.handle)
    end
    user_ids = Array.new
    category_ids = Array.new
    collections.each do |collection|
      user_ids << collection.handle
      if include_contributors
        user_ids.concat collection.contributors
      end
      category_ids << collection.category
    end
    users_map = get_users_map_handles(user_ids.uniq)
    collections.each do |collection|
      if collection.portfolio
        next
      end
      unless viewer.blank?
        collection[:is_viewer_following] = collection_ids.include?(collection._id.to_s)
      end
      collection[:url] = get_collection_slug_url(collection._id, collection.handle, collection.slug_id)
      creator = users_map[collection.handle]
      if include_contributors
        users = Array.new
        collection[:contributors].each do |handle|
          users << users_map[handle]
        end
        collection[:contributor_users] = users
      end
      collection[:creator] = creator
      unless creator.blank?
        collection[:creator][:name] = creator.name
      end
    end
  end

  def create_school_collection_category(school_handle, school_name)
    collection_category = CollectionCategory.find(school_handle)
    if collection_category.blank?
      collection_category = CollectionCategory.new
      collection_category.id = school_handle
      collection_category.title = school_name
      collection_category.privacy = school_handle
      collection_category.save
    end
  end

  def get_school_major_collection_id(school_id, user_major_type)
    school = get_school(school_id)
    unless school.major_collection_ids.blank?
      school_collections = get_collections(school.major_collection_ids)
      school_collections.each do |collection|
        if collection.major_types.include? user_major_type
          return collection.id
        end
      end
    end
    nil
  end


  def get_public_major_collection_id(major_type_id)
    unless DEFAULT_PUBLIC_CIDS.blank?
      collections = get_collections(DEFAULT_PUBLIC_CIDS)
      collections.each do |collection|
        if collection.major_types.include? major_type_id
          return collection.id.to_s
        end
      end
    end
    nil
  end

  def seed_collections_for_user(user)
    handle = user.handle
    school = get_school(get_school_handle_from_email(user.id))
    user_portfolio_id = "#{handle}_#{PORTFOLIO_CID}"
    collection = Collection.find(user_portfolio_id)
    if collection.blank?
      collection = Collection.new
      collection.id = user_portfolio_id
      collection.title = PORTFOLIO_TITLE
      collection.small_image_url = PORTFOLIO_SMALL_IMAGE_URL
      collection.medium_image_url = PORTFOLIO_SMALL_IMAGE_URL
      collection.large_image_url = PORTFOLIO_SMALL_IMAGE_URL
      collection.privacies = Array(handle)
      collection.portfolio = true
      collection.save
    end
    major_type_id = get_major_type_by_major_id(user.major_id)

    #follow_school_collections
    unless school.blank?
      unless school.default_collection_ids.blank?
        school.default_collection_ids.each do |cid|
          follow_collection(handle, cid)
        end
      end
      major_type_cid = get_school_major_collection_id(school.handle, major_type_id)
      follow_collection(handle, major_type_cid)
    end

    #public_default_collections
    public_type_cid = get_public_major_collection_id(major_type_id)
    follow_collection(handle, public_type_cid)

  end

  def seed_collections_for_influencer(user)
    if user.blank?
      return
    end

    handle = user.handle
    unless user.school_id.blank? || user.major_types.blank?
      user_major_type = user.major_types[0]
      school = get_school(user.school_id)
      unless school.default_collection_ids.blank?
        school.default_collection_ids.each do |cid|
          follow_collection(handle, cid)
        end
      end
      major_type_cid = get_school_major_collection_id(school.handle, user_major_type)
      follow_collection(handle, major_type_cid)
    end

    unless user.major_types.blank?
      user.major_types.each do |major_type|
        public_type_cid = get_public_major_collection_id(major_type)
        follow_collection(handle, public_type_cid)
      end
    end

  end


  def get_user_follow_collection_ids(handle)
    UserFollowCollection.where(:follower_id => handle, :collection_id.nin => ["#{handle}_#{PORTFOLIO_CID}"]).pluck(:collection_id)
  end

  def get_collection_followers(collection_id)
    UserFollowCollection.where(collection_id: collection_id).pluck(:follower_id)
  end

  def get_recommended_collections_internal(viewer=nil)
    if viewer.blank?
      return Collection.all.order_by([:create_dttm, -1]).limit(6).to_a
    else
      coll_ids_cache = Rails.cache.fetch("#{REDIS_KEYS::CACHE_COLLECTION_RECOMMENDATIONS}-#{viewer.handle}", expires_in: 48.hours) do
        user_following_collection_cids = get_user_follow_collection_ids(viewer.handle)
        major_type_id = get_major_type_by_major_id(viewer.major_id)
        major_type_ids = [major_type_id]
        unless viewer.major_types.blank?
          major_type_ids << viewer.major_types
        end
        recent_collection_ids = Collection.where(:major_types.in => major_type_ids, :_id.nin => user_following_collection_cids, :portfolio => false, :private => false).order_by([:create_dttm, -1]).limit(6).pluck(:_id)
        popular_collection_ids = Collection.where(:major_types.in => major_type_ids, :_id.nin => user_following_collection_cids,:portfolio => false, :private => false).order_by([:follower_count, -1]).limit(6).pluck(:_id)
        coll_ids = ordered_random_merge(recent_collection_ids, popular_collection_ids)[0..5]
        if recent_collection_ids.blank? and popular_collection_ids.blank? and user_following_collection_cids.blank?
          coll_ids =  Collection.where(:portfolio => false, :private => false).order_by([:follower_count, -1]).limit(20).pluck(:_id)
        end
        coll_ids
      end
      collections = Collection.find(coll_ids_cache)
    end

  end

  def save_collection_tags(collection_id, tags=nil)
    collection = get_collection(collection_id)
    collection.tags = tags
    collection.save
  end

  def test_collection_follow_email(handle, collection_id)
    if handle.blank? or collection_id.blank?
      return
    end

    follower = get_user_by_handle(handle)
    save_user_after_checks(follower)
    follower.save
    collection = get_collection(collection_id)
    if follower.blank? or collection.blank?
      return
    end
    collection_owner = get_user_by_handle(collection.handle)
    collection_owner[:meed_points] = get_user_meed_points(collection.handle)
    Notifier.email_collection_owner_follow(collection_owner, follower, collection).deliver
    create_notification(collection_owner.handle, follower.handle, collection.id, get_notification_type_for_feed(UserFeedTypes::FOLLOW_COLLECTION))
    save_user_state(collection_owner.handle, UserStateTypes::FOLLOWER_RECEIVE_DATE)
    save_user_state(follower.handle, UserStateTypes::FOLLOW_COLLECTION_DATE)
  end
end
