class TagsController < ApplicationController
  include TagsManager
  include CollectionsHelper

  def all_tags
    tags = get_all_tags
    respond_to do |format|
      format.html { return render layout: "angular_app", template: "angular_app/index" }
      format.json {
        return render json: {
                          success: true,
                          tags: tags,
                      }
      }
    end
  end

  def show_tag
    tag = get_tag(params[:id])
    if tag.blank?
      respond_to do |format|
        format.html { return render layout: "angular_app", template: "angular_app/index" }
        format.json {
          return render json: {
                            success: false
                        }
        }
      end
    end
    feed_items = get_feed_items_for_tag_id(tag.id)
    feed_page_size = params[:page_size].blank? ? FEEDS_BATCH_SIZE : params[:page_size]
    build_feed_models(current_user, feed_items)
    increment_tag_view_count(tag.id)
    @metadata = get_tag_metadata(tag)
    @feed_items = Kaminari.paginate_array(feed_items).page(params[:page]).per(feed_page_size)
    respond_to do |format|
      format.html { return render layout: "angular_app", template: "angular_app/index" }
      format.json {
        return render json: {
                          success: true,
                          tag: tag,
                          feed_items: @feed_items
                      }
      }
    end
  end

end