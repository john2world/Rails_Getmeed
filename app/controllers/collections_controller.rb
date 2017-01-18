class CollectionsController < ApplicationController
  include CollectionsManager
  include FeedItemsManager
  include CommonHelper
  include UsersManager
  include CollectionsHelper
  include TagsManager

  def user_following_collections
    unless logged_in_json?
      return
    end
    collections = get_user_following_collections(current_user.handle, true)
    trending_tags = get_current_trending_tags(6)
    build_collection_models(current_user, collections, false)
    respond_to do |format|
      format.html { return render layout: "angular_app", template: "angular_app/index" }
      format.json {
        return render json: {
                          success: true,
                          collections: collections,
                          trending_tags: trending_tags
                      }
      }
    end
  end


  def user_collections
    if current_user.blank?
      all_collections = get_all_collections
    else
      all_collections = get_user_following_collections(current_user.handle, true)
    end
    tags = get_all_tags
    respond_to do |format|
      format.html { return render layout: "angular_app", template: "angular_app/index" }
      format.json {
        return render json: {
                          success: true,
                          public_collections: all_collections,
                          tags: tags
                      }
      }
    end
  end

  def all_categories
    all_collections = get_all_collections(current_user)
    private_collections = []
    category = nil
    public_collections = []
    if params[:category_id].eql? 'all' or params[:category_id].blank?
      all_collections.each do |coll|
        if coll.private
          private_collections << coll
        else
          public_collections << coll
        end
      end
      unless current_user.blank?
        category = get_category_for_id(current_user.school_handle)
      end
    else
      public_collections = all_collections
      category = get_category_for_id(params[:category_id])
      private_collections = get_collections_for_category(params[:category_id])
      all_collections.concat private_collections
    end
    build_collection_models(current_user, all_collections)
    respond_to do |format|
      format.html { return render layout: "angular_app", template: "angular_app/index" }
      format.json {
        return render json: {
                          success: true,
                          category: category,
                          public_collections: public_collections,
                          private_collections: private_collections
                      }
      }
    end
  end


  def show_category
    category_id = params[:category_id]
    category = nil
    public_collections = []
    private_collections = []
    all_collections = get_all_collections(current_user)
    if category_id.eql? 'all'
      all_collections.each do |coll|
        if coll.private
          private_collections << coll
        else
          public_collections << coll
        end
      end
    else
      category = get_category_for_id(category_id)
      public_collections = all_collections
      private_collections = get_collections_for_category(category_id)
      all_collections.concat private_collections
    end
    unless current_user.blank?
      category = get_category_for_id(get_school_handle_from_email(current_user.id))
    end
    build_collection_models(current_user, all_collections)
    respond_to do |format|
      format.html { return render layout: "angular_app", template: "angular_app/index" }
      format.json {
        return render json: {
                          success: true,
                          category: category,
                          public_collections: public_collections,
                          private_collections: private_collections
                      }
      }
    end
  end


  def collections_by_category
    collections = get_collections_for_category(params[:category_id])
    collections.compact
    build_collection_models(current_user, collections)
    respond_to do |format|
      format.json { render json: collections }
    end
  end

  def public_collections
    collections = get_public_collections
    build_collection_models(current_user, collections)
    respond_to do |format|
      format.json { render json: collections }
    end
  end

  def recommended_collections
    following_collections = []
    recommended_collections = []
    if current_user.blank?
      collections = get_public_collections
    else
      collections = get_public_collections(current_user, 7)
      collections.concat get_school_collections(current_user)
      following_collections = get_user_following_collections(current_user.handle)
      map = Hash.new
      following_collections.each do |c|
        map[c.id] = c
      end
      collections.each do |c|
        if map[c.id].blank?
          recommended_collections << c
        end
      end
    end
    all_collections = recommended_collections.concat following_collections
    build_collection_models(current_user, all_collections)
    respond_to do |format|
      format.json { render json: {
                               recommended_collections: recommended_collections[0..2],
                               following_collections: following_collections
                           }
      }
    end
  end


  def new
    respond_to do |format|
      format.html { return render layout: "angular_app", template: "angular_app/index" }
      format.json {
        ret = get_all_major_types
        return render json: ret
      }
    end

  end


  def create
    unless logged_in?(root_path)
      return
    end
    if params[:is_private]
      params[:category_id] = get_school_handle_from_email(current_user.id)
    end
    collection = create_collection(current_user.handle, params)
    build_collection_models(current_user, [collection])
    ret_hash = {}
    ret_hash[:collection] = collection
    ret_hash[:success] = true
    ret_hash[:redirect_url] = get_collection_url(collection._id)
    respond_to do |format|
      format.json { render json: ret_hash }
    end

  end


  def collection_follow
    unless logged_in?(root_path)
      return
    end
    follow_collection(current_user.handle, params[:collection_id])
    respond_to do |format|
      format.json { render json: {success: true} }
    end
  end

  def collection_unfollow
    unless logged_in?(root_path)
      return
    end
    unfollow_collection(current_user.handle, params[:collection_id])
    respond_to do |format|
      format.json { render json: {success: true} }
    end
  end

  def show_collection_full
    collection = get_collection(params[:collection_id])
    feed_page_size = params[:page_size].blank? ? FEEDS_BATCH_SIZE : params[:page_size]
    if collection.blank?
      respond_to do |format|
        format.html { return render layout: "angular_app", template: "angular_app/index" }
        format.json {
          return render json: {
                            success: false
                        }
        }
      end
    end
    if params[:slug_id].blank?
      redirect_to get_collection_slug_url(params[:collection_id], collection.handle, collection.slug_id)
      return
    end
    feed_items = get_feed_items_for_collection_id(params[:collection_id])
    build_feed_models(current_user, feed_items)
    @feed_items = Kaminari.paginate_array(feed_items).page(params[:page]).per(feed_page_size)
    increment_collection_view_count(params[:collection_id])
    build_collection_models(current_user, [collection], true)
    author = get_user_by_handle(collection.handle)
    @metadata = get_collection_metadata(collection, author)
    respond_to do |format|
      format.html { return render layout: 'angular_app', template: 'angular_app/index' }
      format.json {
        return render json: {
                          success: true,
                          collection: collection,
                          feed_items: @feed_items
                      }
      }
    end

  end

  def show_collection

    collection = get_collection(params[:collection_id])
    redirect_url = '/'
    if collection.blank?
      redirect_url = get_collection_slug_url(collection._id, collection.handle, collection.slug_id)
    end

    respond_to do |format|
      format.html {
        return redirect_url
      }
      format.json {
        return render json: {
                          success: true,
                          collection: collection
                      }
      }
    end
  end
end
