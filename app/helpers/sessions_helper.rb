module SessionsHelper
  def update_session_with_user(user)
    if user.blank?
      return
    end
    #temp_session = session.dup
    #reset_session
    #session.replace(temp_session)
    session[:handle] = user[:handle]
    session[:last_seen] = Time.zone.now
  end

  def update_session_pseudo
    session[:pseudo] = true
  end

  def session_pseudo?
    return (session[:pseudo] == true)
  end
end
