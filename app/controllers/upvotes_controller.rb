class UpvotesController < ApplicationController
  include AnswersManager
  include CommentsManager
  include MeedPointsTransactionManager

  def upvote
    comment_id = params[:id]
    if comment_id.blank? or current_user.blank?
      respond_to do |format|
        format.js
        return
      end
    end
    upvote_comment(comment_id, current_user.handle)
    comments = get_comments(current_user, comment_id)
    unless comments.blank?
      @comment = comments[0]
    end
    respond_to do |format|
      format.js
      format.json{
        return render json: {
          success: true,
          upvote_count: @comment.upvote_count

        }
      }

    end
  end

end