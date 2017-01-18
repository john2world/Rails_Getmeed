# Script to populate the Profile tags for profiles. This is a one of script to populate the tags.
# Author: VMK@
require 'thread/pool'

include ProfilesHelper
ThreadPoolLimit = 5

def generate_save_tags(profile)
  tags = get_profile_tags(profile)
  if tags.blank?
    return
  end
  profile[:tags] = tags
  profile.save()
end
pool = Thread.pool(ThreadPoolLimit);
start_time = Time.now
Profile.each do |profile|
  pool.process{generate_save_tags(profile)}
end
pool.shutdown
end_time = Time.now
puts "Time taken: #{end_time - start_time}"