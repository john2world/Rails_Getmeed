module SurveysManager

  def record_survey(user, survey_type, response)
    survey = Survey.new
    survey.handle = user.handle
    survey.type = survey_type
    survey.response = response
    survey.save
  end
end