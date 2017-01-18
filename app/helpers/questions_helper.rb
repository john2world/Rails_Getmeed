module QuestionsHelper
  include LinkHelper

  def get_question_metadata(question)
    if !question.blank?
      metadata = Hash.new
      metadata[:title] = "#{question.title}"
      metadata[:description] = "#{question.description}"
      metadata[:url] = get_question_url(question.id)
      metadata
    end
  end


end