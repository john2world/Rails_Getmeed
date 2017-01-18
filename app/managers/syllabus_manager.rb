module SyllabusManager

  def admin_all_syllabus_chapters
    Syllabus.all
  end

  def get_syllabus_by_id (id)
    Syllabus.find(id)
  end

  def push_question_to_syllabus (syllabus_id, question_id)
    syllabus_questions = SyllabusQuestions.find(syllabus_id)
    if syllabus_questions.blank?
      syllabus_questions = SyllabusQuestions.new
    end
    syllabus_questions.push(:question_ids, question_id)
    syllabus_questions.save
  end

end