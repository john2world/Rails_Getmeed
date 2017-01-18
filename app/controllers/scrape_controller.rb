class ScrapeController < ApplicationController
  include ScrapeManager
  include LinkHelper

  def scrape
    unless logged_in?(root_path)
      return
    end
    if params[:url].blank?
      file_url = params['feed_items']['file_url']
      if file_url.blank?
        return
      end
      params[:url] = file_url
    end
    @data = get_or_create_scrape_data(params, current_user.handle)
    if @data.blank?
      respond_to do |format|
        format.js{
          return
        }
        format.json{
          return render json: {success: false, error: "Scrape failed"}
        }
      end
    end
    @data[:majors] = admin_all_majors
    skills_as = get_autosuggest_skills_by_major('all')
    skills_as.insert(0, '')
    @data[:topics] = admin_all_topics
    @data[:skills_as] = skills_as
    @data[:business_major_types] = get_business_major_types
    @data[:engineering_major_types] = get_engineering_major_types
    @data[:other_major_types] = get_other_major_types

    unless @data.blank?
      @data[:url] = get_story_url(@data[:company_id], @data[:_id])
    end

    respond_to do |format|
      format.js
      format.json{

        business_major_types = @data[:business_major_types].map do |x, y|
          {id: x, name: y.name}
        end
        engineering_major_types = @data[:engineering_major_types].map do |x, y|
          {id: x, name: y.name}
        end
        other_major_types = @data[:other_major_types].map do |x, y|
          {id: x, name: y.name}
        end

        ret = {
          _id: @data[:_id],
          company_id: @data[:company_id],
          large_image_url: @data[:large_image_url],
          poster_logo: @data[:poster_logo],
          business_major_types: business_major_types,
          engineering_major_types: engineering_major_types,
          other_major_types: other_major_types,
          title: @data[:title],
          topics: @data[:topics],
          type: @data[:type],
          user_handle: @data[:user_handle],
        }
        return render json: ret
      }
    end
  end
end