class EventsController < ApplicationController
  include EventsManager
  include EventsHelper
  include EnterpriseUsersManager

  def show_ama
    redirect_to '/peddinti'
  end

  def follow_ama
    ama_id = params[:ama_id]
    if ama_id.blank?
      error_redirect("ama id missing", nil)
    end
    if current_user.blank?
      error_redirect('login required', '/')
    end
    follow = true
    unless params[:value].blank?
      follow = params[:value]
    end
    result = user_follow_ama(params[:ama_id], current_user.handle, follow)
    respond_to do |format|
      format.json {
        return render json: {result: result}
      }
    end
  end
end