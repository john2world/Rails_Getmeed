module AnswersManager
  include HttpPartyManager
  include CommonHelper
  include JobsManager
  include CommentsManager
  include FeedItemsManager

  def get_answers_for_ids (answer_ids)
    answers = Answer.find(answer_ids)
    if !answers.blank?
      answers.sort { |a, b| compare(a[:date], b[:date]) }
      #answers.sort { |a, b| compare((a.upvote_count.blank? ? 0 : a.upvote_count), (b.upvote_count.blank? ? 0 : b.upvote_count)) }
      #answers.shuffle
    end
    answers
  end

  def get_user_answers(handle)
    user_answers = UserAnswers.find(handle)
    if user_answers.blank?
      return nil
    end
    get_answers_for_ids(user_answers.answer_ids)
  end

  def get_user_job_answers(job_id, handle)
    if job_id.blank?
      return
    end
    results = Array.[]
    job = get_job_by_id(job_id)
    if job.blank? or job.question_id.blank?
      return
    end

    answers = get_user_answers(handle)
    if answers.blank?
      return results
    end
    answers.each do |answer|
      if answer.question_id.eql? job.question_id
        results << answer
      end
    end
    results
  end

  def hide_answer_from_profile(answer_id)
    answer = Answer.find(answer_id)
    if answer.blank?
      return
    end

    answer.show_on_resume = false
    answer.save
  end

  def upvote_comment (comment_id, handle)
    add_handle_to_upvote_answer(comment_id, handle)
    increment_upvote_count (comment_id)
    push_answer_to_user_upvotes(handle, comment_id)
    if Rails.env.development?
      comment = get_comment_id(comment_id)
      if comment.blank?
        return
      end
      update_feed_update_date(comment.feed_id)
      create_notification(comment.poster_id, handle, comment.feed_id, MeedNotificationType::UPVOTE_COMMENT)
      user = get_user_by_handle(comment.poster_id)
      giver_user = get_user_by_handle(handle)
      Notifier.email_comment_upvote(giver_user, user, comment).deliver
    else
      UpvoteCommentsWorker.perform_async(comment_id, handle)
    end
  end


  def push_answer_to_user_upvotes(handle, comment_id)
    user_upvotes = UserUpvotes.find(handle)
    if user_upvotes.blank?
      user_upvotes = UserUpvotes.new(:handle => handle)
    end

    user_upvotes.add_to_set(:comment_ids, comment_id)
    user_upvotes.save
  end

  def pull_answer_from_user_upvotes (handle, answer_id)
    user_upvotes = UserUpvotes.find(handle)
    if user_upvotes.blank?
      return
    end

    user_upvotes.pull(:comment_ids, answer_id)
    user_upvotes.save
  end


  def increment_upvote_count (comment_id)
    Comment.where(_id: comment_id).inc(:upvote_count, 1)
  end

  def get_code_type(id)
    CodeType.find(id.downcase)
  end

  def get_code_type_by_extension (type)
    CodeType.find_by(:file_ext => type)
  end


  def create_answer(params, author_handle, question)
    if question.blank?
      return nil
    end
    answer = Answer.new
    description = process_text(params[:description][:text])
    description = hide_email_address(description)
    answer.description = description
    answer.question_id = params[:question_id]
    answer.code_description = params[:code_description][:text] if params[:code_description]
    answer.date = DateTime.now.to_date
    answer.job_id = params[:id]
    answer.user_handle = author_handle
    answer.lang_type = params[:lang_type]
    answer.show_on_resume = params[:add_to_profile]
    answer.upvote_count = 0
    push_answer_to_question(answer.id, question.id)
    push_answer_to_user(answer.id, author_handle)
    unless answer.code_description.blank?
      result = post_gist(answer)
    end
    answer.gist_id = result['id'] if result
    answer.save
    answer
  end

  def push_answer_to_user(answer_id, user_handle)
    user_answers = UserAnswers.find(user_handle)
    if (user_answers.blank?)
      user_answers = UserAnswers.new(:handle => user_handle)
    end

    user_answers.push(:comment_ids, answer_id)
    user_answers.save
  end

  def post_gist(answer)
    file_name = "#{answer.user_handle}_#{encode_id(answer.id)}#{answer.lang_type}"
    body_json = {:description => answer.description,
                 :public => true,
                 :files => {file_name => {
                     :content => answer.code_description
                 }}
    }.to_json
    post('https://api.github.com/gists', body_json)
  end


end