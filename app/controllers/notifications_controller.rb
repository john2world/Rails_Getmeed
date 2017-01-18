class NotificationsController < ApplicationController
include NotificationsManager

  def get_notifications
    return render(json: { success: false }) unless current_user

    notifications = get_notifications_for_user(current_user.handle)
    build_notification_models(notifications)
    respond_to do |format|
      format.json { render json: notifications }
    end
  end

  def reset_notification_count
    return render(json: { success: false }) unless current_user

    set_notification_counts(current_user.handle, 0)
    current_user[:notifications_count] = 0

    respond_to do |format|
      format.json { render json: { success: true } }
    end
  end

  def increment_meed_points
    unless logged_in_json?
      return
    end
    return render(json: { success: false }) unless current_user or params[:points].blank?
    if params[:meed_points_type].eql? 'facebook' and reward_for_fan_page_like(current_user.handle)
      current_user[:meed_points] += MEED_POINTS::FACEBOOK_LIKE
    elsif params[:meed_points_type].eql? 'twitter' and reward_for_twitter_follow(current_user.handle)
      current_user[:meed_points] += MEED_POINTS::TWITTER_FOLLOW
    end
    respond_to do |format|
      format.json { render json: {
        success: true,
        meed_points: current_user.meed_points
      }

    }
    end
  end




end