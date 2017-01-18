module CourseProjectReferenceInvitationStatus
  INVITATION_SENT = 'Invitation Sent'
  INVITATION_VIEWED = 'Invitation Viewed'
  REFERENCE_RECEIVED = 'Reference Received'
end
class CourseProjectReferenceInvitation
  include Mongoid::Document
  field :reference_type, type: String
  field :reference_email, type: String
  field :message, type: String
  field :reference_first_name, type: String
  field :reference_last_name, type: String
  field :status, type: String, default: CourseProjectReferenceInvitationStatus::INVITATION_SENT
  field :reminder_count, type: Integer, default: 0
  field :skipped, type: Boolean, default: false
  field :create_dttm, type: Time, default: -> { Time.zone.now }

  belongs_to :user_course

  index({reference_email: 1})

  attr_accessible :reference_type, :reference_email, :message, :reference_first_name, :reference_last_name, :status, :reminder_count, :skipped, :create_dttm

  def name
    return "#{self.reference_first_name} #{self.reference_last_name}"
  end

  def update_status(new_status)
    unless new_status.blank?
      self.status = new_status
      self.save!
    end
  end
end