class MajorsController < ApplicationController
  include SchoolsManager

  # Added to enable retrieving list of majors via json
  def index
    @majors = majors
    respond_to do |format|
      format.json{
        return render json: ret
      }
    end
  end


  def majors_degrees

    cache_key = [
      File.mtime(Rails.root.join("app", "controllers", "majors_controller.rb")),
      File.mtime(Rails.root.join("config", "initializers", "global_variables.rb"))
    ].max.to_i


    ret = Rails.cache.fetch("#{REDIS_KEYS::CACHE_MAJOR_DEGREES}-#{cache_key}") do
      @majors = majors
      @degrees = Futura::Application.config.UserDegreesSmall
      {majors: @majors, degrees: @degrees}
    end

    respond_to do |format|
      format.json{
        return render json: ret
      }
    end
  end

  def majors_types
    respond_to do |format|
      format.json{
        return render json: get_all_major_types
      }
    end
  end

  private

  def majors
    @majors = Major.only(:_id, :major).order_by({major: 1})
    ret = @majors.map{|x| {:_id => x._id, major: x.major} }
    return ret
  end


end