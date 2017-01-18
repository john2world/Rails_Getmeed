module QuestionsManager
  include SyllabusManager
  include CommonHelper

  def get_question_for_id (id)
    Question.find(id)
  end

  def get_questions_for_ids (ids)
    if ids.blank?
      return Array.[]
    end
    Question.find(ids)
  end

  def get_all_code_types
    CodeType.all
  end

  def update_question_view_count (id)
    if id.blank?
      return nil
    end
    Question.where(_id: id).inc(:view_count, 1)
  end


  def follow_question_user(id, handle)
    Question.where(_id: id).add_to_set(:follow_handles, handle)
  end


  def unfollow_question_user(id, handle)
    Question.where(_id: id).pull(:follow_handles, handle)
  end

  def get_questions_map(ids)
    questions = Question.find(ids)
    question_map = Hash.new
    questions.each do |question|
      question_map[question.id] = question
    end
    question_map
  end


  def get_current_question (major_id)
    if major_id.blank?
      return nil
    end
    major_question = get_major_question(major_id)
    question = nil
    unless major_question.blank?
      question = Question.find(major_question.question_id)
    end
    question
  end

  def create_question(params, majors)
    id = generate_id_from_text(params[:title]).downcase
    question = Question.find(id)
    if question.blank?
      question = Question.new
      question.id = id
    end

    syllabus = get_syllabus_by_id (params[:syllabus_id])
    question.title = process_text(params[:title])
    question.description = process_text(params[:description])
    question.syllabus_id = syllabus.id
    question.date = Time.zone.now.to_date
    question.syllabus_name = syllabus.name
    question.exp_date = Time.zone.now + (7*24*60*60)
    question.majors = majors
    question.company = params[:company]
    question.save

    push_question_to_syllabus(params[:syllabus_id], question.id)
    push_question_to_majors(question.id, majors)
    question
  end


  def get_major_question (major)
    MajorQuestion.find(major)
  end

  def push_question_to_majors(question_id, majors)
    majors.each do |major|
      major_question = get_major_question (major)
      if major_question.blank?
        major_question = MajorQuestion.new
        major_question.id = major
        major_question.major = major
      end
      major_question.question_id = question_id
      major_question.save
    end
  end


  def push_answer_to_question(answer_id, question_id)
    question = get_question_for_id (question_id)
    if question.blank?
      nil
    end
    question.push(:comment_ids, answer_id)
    question.inc(:view_count, 1)
    question.save
  end

end