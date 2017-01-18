class SurveysController < ApplicationController
  include SurveysManager

  def take_survey
    unless logged_in?(root_path)
      return
    end
    record_survey(current_user, 'meediorite_interest', (params['survey']['meediorite_interest'].eql? 'yes'))

    respond_to do |format|
      format.js
      format.json {
        return render json: { success: true, redirect_url: root_path}
      }
    end

  end
end