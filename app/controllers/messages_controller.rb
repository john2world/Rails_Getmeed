class MessagesController < ApplicationController
  include UsersManager
  include MessagesManager
  include MessagesHelper
  include CommonHelper
  
  def messages
    unless logged_in?
      return
    end

    page_title('Messages')
    page_heading('Message Inbox')
    @user = current_user
    messages = get_messages(@user[:handle])
    
    # getting metadata for messages
    messages.each do |message|
      build_message_model(message)
    end
    rparams = params.except(:page, :position)

    NotificationsLoggerWorker.perform_async('Consumer.Message.View',
                                            {handle: @user[:handle],
                                             message_count: messages.count(),
                                             page_index: params[:page],
                                             params: rparams,
                                             ref: {referrer: params[:referrer],
                                                   referrer_id: params[:referrer_id],
                                                   referrer_type: params[:referrer_type],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('view-inbox', current_user[:_id].to_s, {
                                       message_count: messages.count(),
                                       page_index: params[:page],
                                       ref: {referrer: params[:referrer],
                                             referrer_id: params[:referrer_id],
                                             referrer_type: params[:referrer_type]}
                                   })
    end

    if messages.blank?
      return
    end

    @messages = Kaminari.paginate_array(messages).page(params[:page]).per($FEED_PAGE_SIZE)
    update_message_count
    page_title ('Messages')
    respond_to do |format|
      format.html
    end
  end
  
  def show_message
    unless logged_in?
      return
    end
    @user = current_user
    message = get_message_by_hash(params[:id])
    rparams = params.except(:id)

    NotificationsLoggerWorker.perform_async('Consumer.Message.View',
                                            {handle: @user[:handle],
                                             message_id: params[:id],
                                             params: rparams,
                                             ref: {referrer: params[:referrer],
                                                   referrer_id: params[:referrer_id],
                                                   referrer_type: params[:referrer_type],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('view-message', current_user[:_id].to_s, {
                                         message_id: params[:id],
                                         ref: {referrer: params[:referrer],
                                               referrer_id: params[:referrer_id],
                                               referrer_type: params[:referrer_type]}
                                     })
    end

    if message.blank?
      redirect_to '/404?url='+request.url
      return
    end
    unless authenticate_message(@user[:handle], message)
      flash[:alert] = 'This message is not for you.'
      redirect_to '/messages'
    end
    page_title (message[:subject])

    # has to be saved before getting the metadata
    update_message_status(message.id, 'viewed')
    @message = build_message_model(message)
    update_message_count
    # mark the message status as viewed
  end

  def initiate_message
    if params[:insightToken].blank? and !logged_in?
      redirect_to get_loginurl_with_redirect
      return
    end

    handle = params[:id]
    if handle.blank?
      redirect_to '/404?url='+request.url
      return
    end

    sender_user = current_user
    from_enterpriser = false
    if sender_user.blank?
      job = get_job_by_id(params[:insightToken])
      if job.blank?
        redirect_to get_loginurl_with_redirect
        return
      end
      sender_user = get_enterpriser_by_email(job.email)
      from_enterpriser = true
      if sender_user.blank?
        redirect_to get_loginurl_with_redirect
        return
      end
    end

    if params[:subject].blank?
      flash[:alert] = 'Please enter a subject'
      redirect_to url_for(:controller => 'profiles', :action => 'contact_profile', :id => handle)
      return
    end

    if params[:description].blank?
      flash[:alert] = 'Please enter body'
      redirect_to url_for(:controller => 'profiles', :action => 'contact_profile', :id => handle)
      return
    end
    rparams = params.except(:subject, :description, :insightToken, :id)

    NotificationsLoggerWorker.perform_async('Consumer.Message.Create',
                                            {handle: handle,
                                             recipient_handle: sender_user[:_id],
                                             params: rparams,
                                             ref: {referrer: params[:referrer],
                                                   referrer_id: params[:referrer_id],
                                                   referrer_type: params[:referrer_type],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('send-message', current_user[:_id].to_s, {
                                         recipient_handle: handle,
                                         ref: {referrer: params[:referrer],
                                               referrer_id: params[:referrer_id],
                                               referrer_type: params[:referrer_type]}
                                     })
    end

    (new_message_to_user(sender_user, params[:id], params[:subject], get_message_string(params[:description]))) ?
        flash[:notice] = 'You reply has been sent!' :
        flash[:alert] = 'Something went wrong!'

    render 'profiles/send_email'
  end
  
  def reply_message
    unless logged_in?
      return
    end
    handle = params[:id]
    if handle.blank?
      redirect_to '/404?url='+request.url
      return
    end


    @user = current_user

    if @user.blank?
      redirect_to '/404?url='+request.url
      return
    end
    
    @message = get_message_by_hash(params[:message_id])
    
    if @message.blank?
      redirect_to '/404?url='+request.url
      return
    end

    if params[:subject].blank?
      flash[:alert] = 'Please enter a subject'
      return
    end

    if params[:description].blank?
      flash[:alert] = 'Please enter body'
      return
    end
    body = params[:description]
    body = body.gsub("<br/>", "\n")
    body = body.gsub("<br>", "\n")


    (reply_message_to_enterpriser(@user, @message, params[:subject], body)) ?
        flash[:notice] = 'Your reply has been sent!' :
        flash[:alert] = 'Sorry Coudn\'t send your message!'
    rparams = params.except(:subject, :description)

    NotificationsLoggerWorker.perform_async('Consumer.Message.Reply',
                                            {handle: @user[:handle],
                                             message_id: params[:message_id],
                                             enterprise_id: @message[:from_email],
                                             params: rparams,
                                             ref: {referrer: params[:referrer],
                                                   referrer_id: params[:referrer_id],
                                                   referrer_type: params[:referrer_type],
                                                   meed_user_tracker: cookies[:meed_user_tracker]}
                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('reply-message', current_user[:_id].to_s, {
                                          message_id: params[:message_id],
                                          enterprise_id: @message[:from_email],
                                          ref: {referrer: params[:referrer],
                                                referrer_id: params[:referrer_id],
                                                referrer_type: params[:referrer_type]}
                                      })
    end


    redirect_to '/messages'
  end
end
