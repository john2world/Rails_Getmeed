range = 15

# get users who logged in within the range days
recent_handles = Instrumentation.where(:event_start.gt => (Time.now - range.days), :event_name => 'Consumer.Session.Login').map{|e| e.event_payload['handle']}.uniq

# filter handles who signed up before the 15 days
handles = User.where(:handle.in => recent_handles, :create_dttm.gt => (Time.now - range.days)).pluck(:handle)

# looking at events for the handles
events = Instrumentation.where(:event_start.gt => (Time.now - range.days), :'event_payload.handle'.in => handles)
events.group_by{|e| e.event_name}.map{|k,v| [k,v.count()]}.sort_by{|v| -v[1]}