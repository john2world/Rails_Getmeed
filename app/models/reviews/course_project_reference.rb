class CourseProjectReference
  include FeedItemsManager
  include Mongoid::Document
  field :reviewer_handle, type: String
  field :reviewer_type, type: String
  field :review_text, type: String
  field :create_dttm, type: Time, default: -> { Time.zone.now }
  belongs_to :user_course

  attr_accessible :reviewer_handle, :reviewer_type, :review_text, :create_dttm

  set_callback(:save, :after) do |document|
    handle = nil
    # unless user_work.blank?
    #   handle = user_work.handle
    # end
    # unless user_internship.blank?
    #   handle = user_internship.handle
    # end
    if handle.blank?
      return
    end
    # CreateFeedItemWorker.perform_async(handle, id.to_s, UserFeedTypes::USER_WORK_REFERENCE.downcase, nil)
  end

  def as_json(options={})
    options[:except] ||= [:create_dttm, :user_course]
    super(options)
  end
end