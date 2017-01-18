class Question
  include Mongoid::Document
  field :title, type: String
  field :url, type: String
  field :tag_line, type: String
  field :description, type: String
  field :company, type: String
  field :image_url, type: String
  field :view_count, type: Integer
  field :date, type: Date
  field :majors, type: Array
  field :schools, type: Array
  field :syllabus_id, type: String
  field :syllabus_name, type: String
  field :exp_date, type: Date
  field :comment_ids, type: Array
  field :view_count, type: Integer
  field :is_live, type: Boolean
  field :answer_count, type: Integer
  field :follow_handles, type: Array
  field :is_coding, type: Boolean
  belongs_to :job

  attr_accessible :title, :url, :tag_line, :description, :image_url, :view_count,
                  :date, :majors, :schools, :syllabus_id, :syllabus_name,
                  :exp_date, :answer_count, :comment_ids, :company,
                  :is_live, :is_coding, :skills

  def as_json(options={})
    options[:except] ||= [:view_count, :tags, :email, :schools, :majors, :major_types, :live, :emails, :skills]
    super(options)
  end
end
