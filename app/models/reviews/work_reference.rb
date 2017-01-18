module WorkReferenceType
  INTERNSHIP = 'internship'
  WORK = 'work'
end
class WorkReference
  include FeedItemsManager
  include Mongoid::Document
  field :work_id, type: String
  field :internship_id, type: String
  field :work_type, type: String
  field :review_text, type: String
  field :create_dttm, type: Time, default: -> { Time.zone.now }
  belongs_to :enterprise_user
  belongs_to :user_work
  belongs_to :user_internship

  attr_accessible :reviewer_id, :work_type, :review_text, :create_dttm

  set_callback(:save, :after) do |document|
    handle = nil
    unless user_work.blank?
      handle = user_work.handle
    end
    unless user_internship.blank?
      handle = user_internship.handle
    end
    if handle.blank?
      return
    end
    CreateFeedItemWorker.perform_async(handle, id.to_s, UserFeedTypes::USER_WORK_REFERENCE.downcase, nil)
  end
end