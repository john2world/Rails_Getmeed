module WorkReferenceInvitationStatus
  INVITATION_SENT = 'invitation sent'
  INVITATION_VIEWED = 'invitation viewed'
  REFERENCE_RECEIVED = 'reference received'
end
class WorkReferenceInvitation
  include Mongoid::Document
  field :work_id, type: String
  field :internship_id, type: String
  field :work_type, type: String
  field :reference_email, type: String
  field :message, type: String
  field :reference_first_name, type: String
  field :reference_last_name, type: String
  field :status, type: String, default: WorkReferenceInvitationStatus::INVITATION_SENT
  field :reminder_count, type: Integer, default: 0
  field :create_dttm, type: Time, default: -> { Time.zone.now }

  attr_accessible :work_id, :internship_id, :work_type, :reference_email, :reference_first_name, :reference_last_name, :reminder_count, :create_dttm

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