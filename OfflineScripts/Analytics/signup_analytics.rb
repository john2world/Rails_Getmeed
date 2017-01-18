require 'uri'
include

range = 15

def get_referer_for_tracker(trackers, range)
  referer_events = Instrumentation.where(:event_start.gt => (Time.now - range.days), :"event_payload.ref.meed_user_tracker".in => trackers,
                                         :'event_payload.params.request_referer'.ne => nil).asc(:event_start).select{|i| !i.event_payload['params']['request_referer'].include? 'getmeed'}
  if referer_events.blank? || referer_events.count() == 0
    return nil
  end

  referer_urls = referer_events.group_by{|e| e.event_payload['ref']['meed_user_tracker']}.map{|k, v| v[0].event_payload['params']['request_referer']}.compact
  return referer_urls.map{|u| URI.parse(u).host}
end

# getting all users who signed up less than input days ago

sign_up_events = Instrumentation.where(:event_name => 'Consumer.User.Account', :event_start.gt => (Time.now - range.days))
trackers = sign_up_events.map{|e| e.event_payload['ref']['meed_user_tracker'].to_s}.uniq
# get events for these trackers where the referel url is external
source = get_referer_for_tracker(trackers, range).group_by{|t| t}.map{|k,v| [k,v.count()]}.sort_by{|v| -v[1]}
