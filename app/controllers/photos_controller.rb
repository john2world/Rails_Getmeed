class PhotosController < ApplicationController
  include PhotoHelper
  include PhotoManager
  def save_profile_photo
    unless pseudo_logged_in?
      return
    end

    upload_url = filepicker_profile_crop(params[:user][:image_url])
    user = save_user_profile_picture(upload_url, current_user.handle)
    update_current_user(user)
    save_user_state(user.handle, UserStateTypes::PROFILE_PICTURE_BLANK, true, 'false')

    respond_to do |format|
      format.js
      format.json{ return render json: {success: true}}
    end
  end

  def save_article_photo
    unless logged_in?
      return
    end

    @photo = upload_photo_file(params[:photo], 1000, 500, current_user.handle, 'article_photo')
    if @photo.blank?
      respond_to do |format|
        format.js
        format.json{ return render json: @photo}
      end
      return
    end

    respond_to do |format|
      format.js
      format.json{ return render json: @photo}
    end
  end
end