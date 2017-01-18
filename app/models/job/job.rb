class Job
  include Mongoid::Document
  include LinkHelper
  include JobsHelper
  include JobsManager
  searchkick

  field :email, type: String
  field :title, type: String
  field :company, type: String
  field :company_id, type: String
  field :company_logo, type: String
  field :job_url, type: String
  field :location, type: String
  field :company_overview, type: String
  field :description, type: String
  field :majors, type: Array
  field :major_types, type: Array
  field :schools, type: Array
  field :skills, type: Array, default: -> {[]}
  field :type, type: String
  field :live, type: Boolean, default: -> {false}
  field :culture_video_id, type: String
  field :culture_video_type, type: String
  field :compensation, type: Integer
  field :culture_video_url, type: String
  field :view_count, type: Integer, default: -> {0}
  field :job_req_id, type: String
  field :create_dttm, type: Date, default: 1.year.ago
  field :delete_dttm, type: Date
  field :question_id, type: String
  field :manual_boost, type: Integer, default: -> {0}
  field :emails, type: Array, default: -> {[]}
  field :meed_share, type: Integer, default: -> {0}
  field :email_notifications, type: Boolean, default: -> {true}
  field :tags, type: Hash, default: -> {}
  field :meta_info, type: Hash, default: -> {}

  field :fixed_compensation, type: Integer
  field :hourly_compensation, type: Float
  field :hourly_hours, type: Integer
  field :start_date, type: Date
  field :end_date, type: Date
  has_one :question
  validates_presence_of :title, message: "Job title can't be blank."
  validates_presence_of :type, message: "Job Type can't be blank."
  validates_presence_of :location
  validates_presence_of :description
  validates_length_of :majors, minimum: 1, message: "Please select at least one major."
  validates_length_of :skills, minimum: 1, message: "Audience: Select at least one skill."
  validates_length_of :schools, minimum: 1, message: "Audience: Select at least one school."

  attr_accessible :email, :title, :job_url, :location,
                  :description, :majors, :major_types, :schools, :type, :skills,
                  :live, :culture_video_id, :company_id,
                  :culture_video_type, :culture_video_url,
                  :delete_dttm,:create_dttm,:compensation,
                  :view_count,:company, :company_logo,
                  :question_id, :question, :job_req_id, :company_overview,
                  :email_notifications, :tags, :emails

  set_callback(:save, :after, if: (:title_changed? || :company_changed? || :company_logo_changed? || :location_changed? ||
                        :company_overview_changed? || :description_changed? ||
                        :culture_video_url_changed?)) do |document|
    SitemapPingerWorker.perform_async(get_company_url(company_id))
    # generate tags in the background
    # id is of type object id which will cause problems when calling async.
    GenerateJobTagsWorker.perform_async(id.to_s)
  end

  # stuffing company information before save
  set_callback(:save, :before) do |document|
    unless self.company_id.blank?
      company = get_or_create_company_by_id(self.company_id)
      if self.company.blank? && !company.blank?
        self.company = company.name
      end
      if self.company_logo.blank? && !company.blank?
        self.company_logo = company.company_logo
      end
    end
  end

  # only indexing live jobs
  def should_index?
    live
  end

  def company_url
    get_company_url(company_id)
  end

  def job_url
    get_job_url_id(encode_id(id))
  end

  def test_job?
    company_id.eql? 'testcorp'
  end

  def is_organic?
    is_organic(self)
  end

  # index only specific fields
  def search_data
    organic = is_organic(self)
    application_count = get_job_applicant_count(self.id)
    basic = as_json only: [:title, :company, :location, :company_overview, :description, :majors, :major_types, :schools, :skills, :type, :create_dttm, :delete_dttm, :live, :_id, :view_count, :tags]
    basic.merge({organic: organic, application_count: application_count})
  end

  def as_json(options={})
    options[:except] ||= [:view_count, :tags, :email, :label_stats, :schools, :majors, :major_types, :emails, :email_notifications, :match_pool_count, :job_req_id, :delete_dttm, :meed_share, :manual_boost, :skills]
    super(options)
  end

end
