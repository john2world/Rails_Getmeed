module EventsManager
  include UsersManager
  include LinkHelper
  AMA_EVENT_ID = 'ama'

  def get_ama_by_handle(handle)
    ama_id = "#{AMA_EVENT_ID}-#{handle}"
    event = Event.find(ama_id)
    if event.blank?
      event = Event.new
      event.id = ama_id
      event.author_id = handle
      event.save
    end
    event
  end
  #time_string format 2007-01-31 12:22:26
  def schedule_ama(handle, time_string)
    ama_id = "#{AMA_EVENT_ID}-#{handle}"
    event = Event.find(ama_id)
    if event.blank?
      event = Event.new
      event.id = ama_id
      event.author_id = handle
      event.save
    end
    event.start_dttm = Time.parse(time_string)
    event.end_dttm = event.start_dttm + 2.hours
    event.save
    event
  end

  def get_events(event_ids)
    Event.find(event_ids)
  end

  def get_event_map(event_ids)

  end

  def user_follow_ama(ama_id, handle, value=true)
    ama = get_ama_by_handle(handle)
    if ama.blank?
      return false
    end
    if value
      unless ama.followers.include? handle
        ama.followers.append(handle)
        ama.save
      end
    else
      if ama.followers.include? handle
        ama.followers.delete(handle)
        ama.save
      end
    end
    if value
      EmailAmaFollowWorker.perform_async(ama.author_id, handle)
    end
    true
  end
end