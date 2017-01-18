class QuestionsController < ApplicationController
  include QuestionsManager
  include AnswersManager
  include UsersManager
  include SchoolsManager
  include SyllabusManager
  include ProfilesHelper
  include AdminsManager
  include QuestionsHelper
  include UpvotesManager
  include CommonHelper

  def handle_create_question
    unless authenticate(current_user)
      return
    end
    @user = current_user
    @majors = admin_all_majors.sort_by! { |m| m[:major].downcase }
    @syllabus = admin_all_syllabus_chapters
  end

  def dash
    unless logged_in?
      return
    end

    @question = get_current_question (get_user_major_by_handle(current_user.handle))
    @blogs = get_today_blogs
    if @question.blank?
      flash[:alert] = 'Question is deleted or flagged.'
      redirect_to '/404?url='+request.url
      return
    end

    handle_show_question (@question)
    @metadata = get_question_metadata(@question)
    page_title (@question.title)

  end

  def show_question
    if params[:id].blank?
      flash[:alert] = 'Question is deleted or flagged.'
      redirect_to '/404?url='+request.url
      return
    end

    @question = get_question_for_id (params[:id])

    if @question.blank?
      flash[:alert] = 'Question is deleted or flagged.'
      redirect_to '/404?url='+request.url
      return
    end

    NotificationsLoggerWorker.perform_async('Consumer.Question.View',
                                            {question_id: params[:id],
                                             params: params,
                                             ref: {referrer: params[:referrer],
                                                   referrer_id: params[:referrer_id],
                                                   referrer_type: params[:referrer_type],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })

    handle_show_question (@question)
    @metadata = get_question_metadata(@question)
    page_title (@question.title)

  end

  def publish_question
    unless authenticate(current_user)
      return
    end

    if params[:title].blank?
      flash[:alert] = 'Title can\'t be blank.'
      redirect_to '/questions/create'
      return
    end

    if params[:syllabus_id].blank?
      flash[:alert] = 'Please select syllabus type.'
      redirect_to '/questions/create'
      return
    end

    @major_list = get_selected_items_from_params(params, 'major');
    if @major_list.blank?
      flash[:alert] = 'Please select at least one major.'
      redirect_to '/questions/create'
      return
    end

    @question = create_question(params, @major_list)
    rparams = params.except(:title, :syllabus_id)

    NotificationsLoggerWorker.perform_async('Consumer.Question.Publish',
                                            {handle: current_user[:_id],
                                             params: rparams,
                                             ref: {ref: params[:ref],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    create_feed_item(@question, 'question')
    majors = get_majors_for_ids(@major_list)
    @major_string = build_major_separated_string (majors)
    render :template => 'questions/show_question'
  end

  def show

  end

  def follow_question
    unless logged_in?
      return
    end

    question_id = params[:id]
    if question_id.blank?
      question_id = params[:question_id]
    end

    if question_id.blank? or current_user.blank?
      render :json => { :success => false }
    end


    follow_question_user(question_id, current_user.handle)
    NotificationsLoggerWorker.perform_async('Consumer.Question.Follow',
                                            {handle: current_user[:_id],
                                             question_id: question_id,
                                             params: params,
                                             ref: {referrer: params[:referrer],
                                                   referrer_id: params[:referrer_id],
                                                   referrer_type: params[:referrer_type],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('follow-question', current_user[:_id].to_s, {
                                            question_id: question_id,
                                            ref: {referrer: params[:referrer],
                                                  referrer_id: params[:referrer_id],
                                                  referrer_type: params[:referrer_type]}
                                        })
    end

    render :json => { :success => true }
  end



  def unfollow_question
    unless logged_in?
      return
    end

    question_id = params[:id]
    if question_id.blank?
      question_id = params[:question_id]
    end

    if question_id.blank? or current_user.blank?
      render :json => { :success => false }
    end


    unfollow_question_user(question_id, current_user.handle)
    rparams = params.except(:question_id)

    NotificationsLoggerWorker.perform_async('Consumer.Question.UnFollow',
                                            {handle: current_user[:_id],
                                             question_id: question_id,
                                             params: rparams,
                                             ref: {referrer: params[:referrer],
                                                   referrer_id: params[:referrer_id],
                                                   referrer_type: params[:referrer_type],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('unfollow-question', current_user[:_id].to_s, {
                                              question_id: question_id,
                                              ref: {referrer: params[:referrer],
                                                    referrer_id: params[:referrer_id],
                                                    referrer_type: params[:referrer_type]}
                                          })
    end

    render :json => { :success => true }
  end
end