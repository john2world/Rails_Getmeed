class CommentsController < ApplicationController
  include CommentsManager
  include FeedItemsManager

  def show_comments

    unless logged_in?
      return
    end
    @position = params[:position]
    @feed_id = params[:feed_id]
    @type = params[:type]
    @comments = get_comments_for_feed(current_user, @feed_id)
    respond_to do |format|
      format.js
      return
    end

  end

  def delete
    unless logged_in?
      return
    end
    @comment_id = params[:comment_id]
    unless @comment_id.blank?
      remove_comment_by_id(@comment_id)
    end
    respond_to do |format|
      format.js
      format.json{
        return render json: {
          success: true,
          comment_id: @comment_id
        }
      }

    end

  end

  def create
    unless logged_in?
      return
    end
    @feed_id = params[:feed_id]
    @position = params[:position]
    @comment = create_comment(current_user.handle, params)
    unless @comment.blank?
      @comment[:user] = current_user
      @comment[:is_viewer_author] = true
    end
    respond_to do |format|
      format.js
      format.json{
        return render json: {
          success: true,
          comment: @comment
        }
      }
    end
  end

  def update
    return unless logged_in?

    @comment = Comment.find_by id: params[:id], poster_id: current_user.handle, poster_type: 'user'
    if @comment
      @comment.update_attributes description: scrub_input_text(params[:description])

      return render json: {
        success: true,
        comment: @comment
      }
    else
      return render json: {
        success: false,
        comment: "CommentNotFound"
      }
    end
  end
end