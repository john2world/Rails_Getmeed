class JobApplicantsController < ApplicationController
  before_filter :logged_in?
  before_filter :set_applicant, only: [:invite, :update, :archive]

  def index
    respond_to do |format|
      format.html { render layout: "angular_app", template: "angular_app/index" }
      format.json do
        job_ids = Job.in(company: current_user.company.name).map(&:id)
        @applicants = ApplicantsStore.load params[:type], job_ids
        @applicants = Kaminari.paginate_array(@applicants).page(params[:page])

        render json: @applicants.to_json
      end
    end
  end

  def count
    job_ids = current_user.company.jobs.pluck(:id)
    render json: {
      applications_count: ApplicantsStore.applications(job_ids).count,
      recommendations_count: ApplicantsStore.recommendations(job_ids).count,
      shortlisted_count: ApplicantsStore.shortlisted(job_ids).count
    }
  end

  def update
    if current_user.is_admin? || @applicant.job.email == current_user.email
      @applicant.update_attributes notes: params[:job_applicant][:notes]
      ActiveSupport::Notifications.instrument('Enterprise.Job.Notes.Save',
                                              {user_id: current_user.id,
                                               job_id: params[:job_id],
                                               handle: params[:handle]})
      IntercomLoggerWorker.perform_async('save-notes', current_user.id.to_s, {
                                       job_id: params[:job_id],
                                       handle: params[:handle],
                                       ref: params[:ref]
                                   })
      head :ok
    else
      head :bad_request
    end
  end

  def show
    handle = params[:id].split('_')[0]
    job_id = params[:id].split('_')[1]
    ProfileViewWorker.perform_async(handle, job_id, false)
    application = JobApplicant.where(
      handle: handle,
      job_id: job_id,
      opened: false
    ).update_all(opened: true)
    head :ok
  end

  def shortlist
    @application = ApplicantsStore.job_shortlist_application(params[:id], params[:job_id], false)
    @surge = !@application.applied
    ProfileViewWorker.perform_async(@application.handle, @application.job_id, true)
    head :ok
  end

  def archive
    @applicant.update_attributes(
      create_dttm: Time.now,
      archived: true
    )
    head :ok
  end

  def invite
    if params[:handle].blank? || params[:job_id].blank?
      head :bad_request
    else
      @application = ApplicantsStore.job_shortlist_application(params[:handle], params[:job_id])
      ActiveSupport::Notifications.instrument(
        'Consumer.Message.Create',
        {
          handle: current_user.handle,
          recipient_handle: params[:handle],
          ref: params[:ref]
        }
      )
      IntercomLoggerWorker.perform_async(
        'send-message',
        current_user.id.to_s,
        {
         handle: params[:handle],
         ref: params[:ref]
        }
      )

      @message = MessagesService.new_message_to_user(
        current_user,
        params[:handle],
        params[:subject],
        params[:description].gsub(/<br\/?>/, "\n"),
        params[:job_id]
      )
      EmailJobInvitationWorker.perform_async(current_user.id, @user.handle, params[:job_id], @message.id)
      head :ok
    end
  end

private
  def set_applicant
    @applicant = JobApplicant.where(id: params[:id]).first_or_create(
      job_id: params[:id].split('_').first,
      applied: false,
      handle: params[:id].split('_').last,
    )
  end
end
