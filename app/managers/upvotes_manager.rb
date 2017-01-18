module UpvotesManager

  def add_handle_to_upvote_answer(answer_id, handle)
    upvotes = Upvotes.find(answer_id)
    if upvotes.blank?
      upvotes = Upvotes.new(:answer_id => answer_id)
    end
    upvotes.add_to_set(:handles, handle)
  end

  def pull_handle_from_upvote_answer (answer_id, handle)
    upvotes = Upvotes.find(answer_id)
    if upvotes.blank?
      return
    end
    upvotes.pull(:handles, handle)
  end

  def get_user_upvotes(handle)
    UserUpvotes.find(handle)
  end


end