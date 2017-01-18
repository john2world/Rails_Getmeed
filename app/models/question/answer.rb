class Answer
  include Mongoid::Document
  field :description, type: String
  field :question_id, type: String
  field :code_description, type: String
  field :date, type: Date
  field :user_handle, type: Array
  field :lang_type, type: String
  field :job_id, type: String
  field :view_count, type: Integer
  field :gist_id, type: String
  field :upvote_count, type: Integer
  field :show_on_resume, type: Boolean


  attr_accessible :description, :date,
                  :user_handle, :view_count,
                  :job_id,
                  :code_description, :question_id,
                  :upvote_count, :gist_id, :show_on_resume
end