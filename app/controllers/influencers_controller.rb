class InfluencersController < ApplicationController

  def index
    unless current_user.blank?
      redirect_to '/'
      return
    end

    respond_to do |format|
      format.html {
        return render layout: "angular_app", template: "angular_app/index"
      }
      format.json {
        return render json: {
                          success: true
                      }
      }
    end
  end
end