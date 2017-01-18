class UserMessagesController < ApplicationController
  def create
    handle = params[:handle]
    if handle.blank?
      redirect_to '/404?url='+request.url
      return
    end

    sender_user = current_user
    if params[:subject].blank?
      flash[:alert] = 'Please enter a subject'
      return
    end

    if params[:description].blank?
      flash[:alert] = 'Please enter body'
      return
    end
    ActiveSupport::Notifications.instrument('Consumer.Message.Create',
                                            {handle: handle,
                                             recipient_handle: sender_user[:_id],
                                             ref: params[:ref]
                                            })
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('send-message', current_user.id.to_s, {
                                         handle: handle,
                                         ref: params[:ref]
                                     })
    end

    body = params[:description]
    body = body.gsub('<br/>', "\n")
    body = body.gsub('<br>', "\n")
    if params[:id].blank?
      params[:id] = params[:handle]
    end
    @message = MessagesService.new_message_to_user(sender_user, params[:id], params[:subject], body, params[:job_id], params[:message_type])
    head :ok
  end
end
