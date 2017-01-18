module FirstUserExperienceManager

  def get_ftue_for_handle(handle)
    ftue = FirstUserExperience.find(handle)
    if ftue.blank?
      ftue = FirstUserExperience.new(:handle => handle)
      ftue.seen_questions_intro = false
      ftue.create_date = Time.zone.now
      ftue.save
    end
    ftue
  end


  def update_ftue_for_handle (handle, ftue_type)
    ftue = get_ftue_for_handle (handle)
    if ftue_type.eql? 'seen_questions_intro'
      ftue.seen_questions_intro = true
      ftue.save
    end


  end

end