module CrmHelper

  def get_email_invitation_variation
    rand(1..3)
  end

  def get_subject_for_variation(variation, school_handle)
    # ' Preparing for career success'
    case variation
      when 1
        "[#{school_handle}] How to prepare for career success?"
      when 2
        "[#{school_handle}] The professional platform for students"
      when 3
        "[#{school_handle}] Are you on Meed yet?"
      # when 4
      #   'Are you taking the right courses this semester?'
      else
        'The professional platform for students!'
    end
  end

  def get_job_email_variation
    rand(1..3)
  end

  def get_subject_for_job_variation(variation, company_name, job_title, job_location, school_handle)
    # ' Preparing for career success'
    case variation
      when 1
        "#{company_name.capitalize} is looking for @#{school_handle} students"
      when 2
        "#{company_name.capitalize} is hiring for #{job_title} in #{job_location}"
      when 3
        "A job opportunity with #{company_name}"
      # when 4
      #   'Are you taking the right courses this semester?'
      else
        'The professional platform for students!'
    end
  end

end