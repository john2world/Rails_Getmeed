module CrmManager

  def get_email_invitation_by_id(id)
    if id.length() == 8 || id.length() == 7
      return get_email_invitation_by_token(id)
    else
      EmailInvitation.find(id)
    end
  end

  def get_email_invitation_by_token(token)
    EmailInvitation.find_by(token: token)
  end

  def get_email_invitation_for_email(email)
    EmailInvitation.where(:email => email).desc(:time).first
  end

  def track_email_send(ab_id)
    results = CrmResults.find(ab_id)
    if results.blank?
      results = CrmResults.new
      results.id = ab_id
      results.ab_id = ab_id
      results.send_count = 1
    else
      if results[:send_count].blank?
        total_sends = 1
      else
        total_sends = results.send_count + 1
      end
      results.send_count = total_sends
    end
    results.update_dttm = Time.zone.now
    results.save
  end

  def track_email_click(ab_id)
    results = CrmResults.find(ab_id)
    if results.blank?
      results = CrmResults.new
      results.id = ab_id
      results.ab_id = ab_id
      results.clicks = 1
    else
      if results[:clicks].blank?
        total_clicks = 1
      else
        total_clicks = results.clicks + 1
      end
      results.clicks = total_clicks
    end
    results.update_dttm = Time.zone.now
    results.save
  end

  def track_email_conversion(ab_id)
    results = CrmResults.find(ab_id)
    if results.blank?
      results = CrmResults.new
      results.id = ab_id
      results.ab_id = ab_id
      results.clicks = 1
      results.conversions = 1
    else
      if results[:conversions].blank?
        results.conversions = 1
      else
        total_conversions = results.conversions + 1
        results.conversions = total_conversions
      end

    end
    results.update_dttm = Time.zone.now
    results.save
  end

  def create_email_invitation_for_email(email, invitor_handle = nil)
    email_invitation = EmailInvitation.new
    email_invitation[:email] = email
    email_invitation[:activated] = false
    email_invitation[:token] = rand(36**8).to_s(36)
    unless invitor_handle.blank?
      email_invitation[:invitor_handle] = invitor_handle
    end
    email_invitation[:time] = Time.zone.now
    begin
      email_invitation.save
    rescue Exception => ex
      $log.error "Error in saving email_invitation!: #{ex}"
      flash[:alert] = 'Something went wrong! Please try again.'
      return nil
    end
    return email_invitation
  end
end
