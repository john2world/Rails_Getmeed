# ActiveSupport::Notifications.subscribe 'process_action.action_controller' do |name, start, finish, id, payload|
#   Instrumentation.new(
#       event_name: name,
#       event_start: start,
#       event_end: finish,
#       event_id: id,
#       event_payload: payload
#   ).save()
# end

BufferLimit = 1000
Buffer = Array.new()
BufferMutex = Mutex.new()

ignore_handles = %w(test1 test2 test3 test4 test5 test6 test7 test8 ravi peddinti)
ignore_ids = ['testcorp']
ignore_company_ids = ['testcorp']

ActiveSupport::Notifications.subscribe /Consumer.*/ do |name, start, finish, id, payload|
  # business logic to skip instrumentation
  log = true
  if !payload[:handle].blank? && ignore_handles.include?(payload[:handle])
    log = false
  end
  if !payload[:id].blank? && ignore_ids.include?(payload[:id])
    log = false
  end
  if !payload[:company_id].blank? && ignore_company_ids.include?(payload[:company_id])
    log = false
  end
  if log
    if Buffer.count() < BufferLimit
      Buffer.push({
                      event_name: name,
                      event_start: start,
                      event_end: finish,
                      event_id: id,
                      event_payload: payload
                  })
    else
      # bulk insert to db and clear queue
      BufferMutex.synchronize {
        Instrumentation.collection.insert Buffer
        Buffer.clear()
      }
    end
  end
end
