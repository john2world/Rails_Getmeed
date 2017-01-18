class IntercomDailyExperimentEmailTaggingWorker
  include Sidekiq::Worker
  include IntercomHelper
  sidekiq_options retry: true, :queue => :default

  ################
  def perform()
    # get total users required for each school
    school_counts = Hash.new(0)
    BucketSizeMapping.each do |bucket, counts|
      Schools.each do |school|
        if counts.has_key? school
          school_counts[school] += counts[school]
        else
          school_counts[school] += counts['all']
        end
      end
    end

    # tagging ppl based on bucket
    tagging_counts = Hash.new(0)
    Schools.each do |school|
      segment_name = "#{school}_fresh"
      contacts = get_contacts_by_segment(segment_name, school_counts[school]);
      # update info for the contact
      contacts.each do |contact|
        begin
          update_contact_info(contact)
        rescue Exception => ex
          sleep(10)
          begin
            update_contact_info(contact)
          rescue
          end
        end
      end
      if contacts.blank?
        next
      end
      BucketSizeMapping.keys().each do |bucket|
        count = get_count_by_school_bucket(bucket, school)
        tag_contacts = contacts.pop(count)
        # incrementing counts
        tagging_counts["#{bucket}_#{school}"] += tag_contacts.count()
        tagging_counts["#{bucket}"] += tag_contacts.count()
        tagging_counts["#{school}"] += tag_contacts.count()
        tagging_counts["all"] += tag_contacts.count()
        # tag with the same name as bucket
        if tag_contacts.blank?
          break
        end
        IntercomClient.tags.tag(name: bucket, users: tag_contacts.map{|contact| {id: contact.id}})
      end
    end
    date_string = (Time.now() + Time.zone_offset('PST')).to_date.to_s
    key = "IDT_#{date_string}"
    $redis.set(key, tagging_counts.to_s)
    $redis.expire(key, 14.days)

    # scheduling the next job
    ss = Sidekiq::ScheduledSet.new
    scheduled_jobs = ss.to_a.map{|j| j.item["class"]}
    unless scheduled_jobs.include? "IntercomDailyExperimentEmailTaggingWorker"
      time = (Date.today() + 1.day + 8.hours)
      IntercomDailyExperimentEmailTaggingWorker.perform_at(time)
    end
  end
end