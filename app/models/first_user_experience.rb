class FirstUserExperience
  include Mongoid::Document
  field :_id, type: String, default: -> { handle }
  field :handle, type: String
  field :seen_questions_intro, type: Boolean
  field :create_date, type: Date

  attr_accessible :handle, :seen_questions_intro, :create_date
end