class TrackingController < ApplicationController

  def track_click

   if params[:data].blank?
      return
    end

    splits = params[:data].split('--')

    begin
      position = splits[1]
      source = splits[0]
      id = splits[2]
      rparams = params.except(:data)

      NotificationsLoggerWorker.perform_async('Consumer.Video.Click',
                                              {
                                                  handle: (current_user.blank?) ? 'public' : current_user[:handle],
                                                  id: id,
                                                  source: source,
                                                  position: position,
                                                  params: rparams,
                                                  ref: {referrer: params[:referrer],
                                                        referrer_id: params[:referrer_id],
                                                        referrer_type: params[:referrer_type],
                                                        meed_user_tracker: cookies[:meed_user_tracker]}
                                              })

    rescue

      respond_to do |format|
        format.json { render json: {success: false} }
      end
      return
    end

   respond_to do |format|
     format.json { render json: {success: true} }
   end

  end
end