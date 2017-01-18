class ConsumerNotification
  include Mongoid::Document
  include LinkHelper
  field :handle, type: String
  field :from_handles, type: Array, default: -> { Array.new }
  field :caption, type: String
  field :image_url, type: String
  field :from_company_id, type: String
  field :subject_id, type: String
  field :notification_url, type: String
  field :notification_type, type: String
  field :unread, type: Boolean, default: -> { true }
  field :last_update_dttm, type: Date, default: -> { Time.now }

  attr_accessible :handle, :from_handles, :image_url,
                  :from_company_id, :notification_type, :notification_url,
                  :last_update_dttm, :subject_id, :unread

  def as_json(options={})
    options[:except] ||= [:from_handles, :from_company_id, :subject_id]
    super(options)
  end
end