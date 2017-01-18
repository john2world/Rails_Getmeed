class AnswersController < ApplicationController
  include QuestionsManager
  include AnswersManager

  def handle_create_answer
    unless logged_in?
      return
    end

    if params[:question_id].blank?
      flash[:alert] = 'Question is deleted or flagged.'
      render :template => 'answers/handle_create_answer'
      return
    end
    @question = get_question_for_id (params[:question_id])
    if @question.blank?
      flash[:alert] = 'Question is deleted!'
      render :template => 'answers/handle_create_answer'
      return
    end
    @answers = Array.[]
    if !@question.answer_ids.blank?
      @answers = get_answers_for_ids (@question.answer_ids)
    end
    @major_string = build_comma_separated_string(@question.majors)
  end

  def delete_user_answer
    id = params[:answer_id]
    if id.blank?
      return
    end
    @answer_id = id
    hide_answer_from_profile(id)
    respond_to do |format|
      format.js
      return
    end


  end

  def publish_answer
    unless logged_in?
      return
    end

    @user = current_user

    if params[:question_id].blank?
      flash[:alert] = 'Something went wrong.'
      redirect_to '/questions'
      return
    end

    @question = get_question_for_id (params[:question_id])
    if @question.blank?
      flash[:alert] = 'Question is deleted!'
      redirect_to '/questions'
      return
    end


    if params[:description][:text].blank?
      flash[:alert] = 'Description can\'t be blank.'
      redirect_to '/questions'
      return
    end

    if params[:lang_type].blank?
      flash[:alert] = 'Code Language can\'t be blank.'
      redirect_to '/questions'
      return
    end

    invite_users_for_upvotes
    @code_type =  get_code_type_by_extension (params[:lang_type])
    if @code_type.blank?
      flash[:alert] = 'Invalid/Unsupported language.'
      redirect_to '/questions'
      return
    end

    @answer = create_answer(params, @user.handle, @question)
    redirect_to '/questions'

  end


  def invite_users_for_upvotes
    invitee_emails = Array.[]
    unless params[:invite_id_1].blank?
      invitee_emails << params[:invite_id_1].split('@')[0]
    end

    unless params[:invite_id_2].blank?
      invitee_emails << params[:invite_id_2].split('@')[0]
    end

    unless params[:invite_id_3].blank?
      invitee_emails << params[:invite_id_3].split('@')[0]
    end

    @school_prefix_handle = get_school_prefix_from_email(@user[:_id])
    # invitee_emails.each do |email_handle|
    #   email = email_handle + '@' + @school_prefix_handle
    #   unless is_registered_user(email)
    #     EmailInvitationWorker.perform_async(email, @user[:_id], true)
      # end
    # end
  end
end