module AdminsHelper

  Colors = ['#4D4D4D', '#5DA5DA','#FAA43A', '#60BD68','#F17CB0', '#B2912F','#B276B2', '#DECF3F', '#F15854']

  def create_gecko_response(x_labels, y_labels, name)
    gecko_series= Array.[]
    json_hash = Hash.new
    x_series = Hash.new
    x_series[:name] = name
    x_series[:data] = y_labels
    gecko_series << x_series
    json_hash[:series] = gecko_series
    #supports "currency", "percent", "decimal"
    json_hash[:y_axis] = { :format => "decimal"}
    json_hash[:x_axis] = { :labels => x_labels}
    return json_hash
  end

  def create_gecko_pie_response(x_labels, y_labels)
    count = [x_labels.size(), Colors.size()].min()
    x_labels = x_labels.take(count)
    y_labels = y_labels.take(count)
    colors = Colors.take(count)
    vals = x_labels.zip(y_labels, colors)
    vals = vals.map{|val| {"value": val[1], "label": val[0], "color": val[2]}}
    return {"item": vals}
  end

  def get_user_growth_gecko_stats(days)
    user_array = User.where(:create_dttm.gt => (Time.now - days.days)).desc(:create_dttm).to_a.group_by{|u| u.create_dttm}.map{|k,v| [k.strftime("%m-%d"), v.count()]}
    data_array = Array.[]
    label_array = Array.[]
    user_array.each do |user_stat|
      data_array << user_stat[1]
      label_array << user_stat[0]
    end

    return create_gecko_response(label_array, data_array, 'UserGrowth')
  end

  def get_user_signup_referer_gecko_stats(days)
    sign_up_events = Instrumentation.where(:event_name => 'Consumer.User.Account', :event_start.gt => (Time.now - days.days))
    trackers = sign_up_events.map{|e| e.event_payload['ref']['meed_user_tracker'].to_s}.uniq
    # get events for these trackers where the referel url is external
    sources = get_referer_for_trackers(trackers, days)
    unless sources.blank?
      sources = sources.group_by{|t| t}.map{|k,v| [k,v.count()]}.sort_by{|v| -v[1]}
    end
    data_array = Array.[]
    label_array = Array.[]
    sources.each do |source|
      data_array << source[1]
      label_array << source[0]
    end

    return create_gecko_pie_response(label_array, data_array)
  end

  def get_user_work_references_gecko_stats(days)
    work_references = WorkReferenceInvitation.where(:create_dttm.gt => (Time.now - days.days))
    unless work_references.blank?
      work_references = work_references.group_by{|invite| invite.status}.map{|k, v| [k, v.count()]}.sort_by{|v| -v[1]}
      data_array = Array.[]
      label_array = Array.[]
      work_references.each do |invite|
        data_array << invite[1]
        label_array << invite[0]
      end

      return create_gecko_pie_response(label_array, data_array)
    end
  end

  def get_referer_for_trackers(trackers, range)
    referer_events = Instrumentation.where(:event_start.gt => (Time.now - range.days), :"event_payload.ref.meed_user_tracker".in => trackers,
                                           :'event_payload.params.request_referer'.ne => nil).asc(:event_start).select{|i| !i.event_payload['params']['request_referer'].include? 'getmeed'}
    if referer_events.blank? || referer_events.count() == 0
      return []
    end

    referer_urls = referer_events.group_by{|e| e.event_payload['ref']['meed_user_tracker']}.map{|k, v| v[0].event_payload['params']['request_referer']}.compact
    return referer_urls.map{|u| URI.parse(u).host}
  end

  def get_signup_source_event_for_tracker(tracker, events)
    return events[0]
  end

  def get_user_signup_source_gecko_stats(days)
    sign_up_events = Instrumentation.where(:event_name => 'Consumer.User.Account', :event_start.gt => (Time.now - days.days))
    trackers = sign_up_events.map{|e| e.event_payload['ref']['meed_user_tracker'].to_s}.uniq
    prior_events = Instrumentation.where(:event_start.gt => (Time.now - days.days - 1),
                                         :"event_payload.handle"=>"public",
                                         :"event_payload.ref.meed_user_tracker".in => trackers)
    event_names_hist = prior_events.group_by{|e| e.event_payload['ref']['meed_user_tracker']}.map{|k,v| v[0].event_name}.group_by{|e| e}.map{|k, v| [k,v.count()]}.sort_by{|h| -h[1]}
    # for trackers where there is no public event see if they can be attributed to organic - home page signin
    left_over_trackers = trackers - prior_events.map{|e| e.event_payload['ref']['meed_user_tracker']}.uniq
    left_over_events = Instrumentation.where(:event_start.gt => (Time.now - days.days - 1),
                                             :event_name=>'Consumer.Home.Index',
                                             :"event_payload.ref.meed_user_tracker".in => left_over_trackers)
    leftover_events = left_over_events.group_by{|e| e.event_payload['ref']['meed_user_tracker']}
    leftover_names_hist = leftover_events.map{|k,v| v[0].event_name}.group_by{|e| e}.map{|k, v| [k,v.count()]}.sort_by{|h| -h[1]}
    hist = event_names_hist.concat(leftover_names_hist)
    hist.concat([["unknown", left_over_trackers.count() - leftover_events.count()]])

    data_array = Array.[]
    label_array = Array.[]
    hist.each do |source|
      data_array << source[1]
      label_array << source[0]
    end

    return create_gecko_pie_response(label_array, data_array)
  end

end
