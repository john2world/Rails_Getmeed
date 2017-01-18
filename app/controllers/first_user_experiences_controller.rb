class FirstUserExperiencesController < ApplicationController
  def ftue_update
    if !logged_in?
      return
    end

    ftue_type = params[:ftue_type]
    update_ftue_for_handle(current_user.handle, ftue_type)
    redirect_to root_path
  end
end