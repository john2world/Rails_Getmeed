class ConnectionsController < ApplicationController
  include UsersHelper
  include ConnectionsManager
  include UsersManager
  include CommonHelper

  def gmail_import

  end

  def gmail_import_auth
    unless logged_in?
      return
    end

    redirect_to '/contacts/gmail'
  end

  def gmail_import_callback
    contacts_hash = request.env['omnicontacts.contacts']
    if contacts_hash.nil?
      failure
      return
    end
    user = current_user
    if user.blank? and !session[:verify_email]
      user = get_user_by_email(session[:verify_email])
    end

    if user.blank?
      add_to_waitlist(contacts_hash)
      return
    end
    @school_contacts_all = Array.new
    contacts_hash.each do |contact|
      if !contact[:email].blank? and (get_school_handle_from_email(user.id).eql? get_school_handle_from_email(contact[:email]))
        @school_contacts_all << contact
      end
    end
    @school_contacts = filter_active_users(@school_contacts_all)
    @school_prefix = get_school_handle_from_email(current_user.id)
    save_contacts_book(user.handle, contacts_hash)
    NotificationsLoggerWorker.perform_async('Consumer.Connections.GmailImport',
                                            {handle: current_user[:handle],
                                             params: params,
                                             count: @school_contacts_all.count(),
                                             active_count: @school_contacts.count(),
                                             meed_user_tracker: cookies[:meed_user_tracker]})
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('gmailImport', current_user[:_id].to_s, {
                                        :import_count => @school_contacts_all.count(),
                                        :active_count => @school_contacts.count(),
                                        :ref => params[:ref]
                                    })
    end

    page_heading("Total found — #{@school_contacts.length}")
    respond_to do |format|
      format.html
    end
  end

  def start
    unless logged_in?
      return
    end
    @school_prefix_handle = get_school_prefix_from_email(current_user[:_id])
    @school_prefix = get_school_handle_from_email(current_user.id).upcase
    if params[:reg].blank?
      page_heading("Invite #{@school_prefix} connections")
      @show_fb_box = false
    else
      page_heading("Import your #{@school_prefix} connections")
      @show_fb_box = false
    end
    respond_to do |format|
      format.html
    end
  end

  def get

  end

  def failure
    if current_user.blank?
      @school_prefix_handle = session[:school_handle]
    else
      @school_prefix_handle = get_school_prefix_from_email(current_user[:_id])
      @school_prefix = get_school_handle_from_email(current_user.id).upcase
    end
    respond_to do |format|
      format.html
    end
  end

  def save
    unless logged_in?
      return
    end

    selected_contact_list = get_selected_items_from_params(params, 'contact')
    save_connections(current_user.handle, selected_contact_list)
    update_profile_invite_flag(current_user[:handle])
    unless Rails.env.development?
      selected_contact_list.each do |email|
        EmailInvitationWorker.perform_async(email, current_user[:_id], '0', true)
      end
    end

    NotificationsLoggerWorker.perform_async('Consume.Connections.Invite',
                                            {handle: current_user[:handle],
                                             params: params,
                                             count: selected_contact_list.count,
                                             meed_user_tracker: cookies[:meed_user_tracker]})
    # Logging event in Intercom
    unless current_user.blank?
      IntercomLoggerWorker.perform_async('invite-connections', current_user[:_id].to_s, {
                                               :count => selected_contact_list.count,
                                               :ref => params[:ref]
                                           })
    end

    if params[:source].eql? 'from_invites'
      redirect_to '/insights?alert=invite_success'
    else
      redirect_to '/home'
    end
  end

  def filter_active_users(contacts_hash)
    result_contact_hash = Array.new
    emails = Array.new
    contacts_hash.each do |contact|
      emails << contact[:email]
    end
    user_map = get_active_users_map(emails)
    contacts_hash.each do |contact|
      existing_user = user_map[contact[:email]]
      if existing_user.blank?
        result_contact_hash << contact
      end
    end
    result_contact_hash.sort_by! { |m| m[:first_name] }
    result_contact_hash
  end

  def add_to_waitlist(contacts_hash)
    if session[:school_handle].blank?
      return
    end

    @school_contacts_all = Array.new
    contacts_hash.each do |contact|
      if !contact[:email].blank? and (session[:school_handle].eql? get_school_handle_from_email(contact[:email]))
        @school_contacts_all << contact
      end
    end
    @school_contacts_all.each do |contact|
      put_in_wait_list(session[:school_handle], contact[:email])
    end
  end

  def save_facebook
    unless logged_in?(root_path)
      return
    end
    save_facebook_connections(current_user.handle, params[:friends])
    respond_to do |format|
      format.html { return render layout: "angular_app", template: "angular_app/index" }
      format.json {
        return render json: { success: true }
      }
    end
  end

end
