class PingerController < ApplicationController
  include JobsManager
  def job_save
    job = get_job_by_id(params[:id])
    unless job.blank?
      job.save()
    end
  end
end