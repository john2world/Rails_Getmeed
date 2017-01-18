class KudosController < ApplicationController
  include KudosManager

  def give_kudos
    unless logged_in?
      return
    end

    if params[:id].blank?
      return
    end
    @position = params[:position]
    give_kudos_from_feed(current_user.handle, params[:id])
    @data = get_feed_item_model_for_id(current_user, params[:id])
    respond_to do |format|
      format.js
      format.json{ return render json: {success: true, kudos_count: @data.kudos_count} }
    end
  end

  def give_kudos_from_profile
    unless logged_in?
      return
    end

    if params[:id].blank?
      return
    end
    feed_item = give_kudos_for_subject_id(current_user.handle, params[:id])
    unless feed_item.blank?
      @data = get_feed_item_model_for_id(current_user, feed_item.id)
    end

    respond_to do |format|
      format.js
      format.json{ return render json: {success: true, kudos_count: @data.kudos_count} }
    end
  end

  def get_kudos_map_feed_ids(feed_ids)
    kudos = Kudos.where(:feed_ids.include => feed_ids)
    kudos_map = Hash.new
    kudos.each do |kudo|
      kudos_map[kudo.feed_id] = kudo
    end
    kudos_map
  end
end