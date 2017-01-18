class UserSettings
  include Mongoid::Document
  field :_id, type: String, default: -> { handle }
  field :handle, type: String
  field :public_profile, type: Boolean, default: true
  field :notification_email_frequency, type: String, default: "weekly"
  field :notification_email_subscriptions, type: Hash, default: { 'job' => false, 'company' => true, 'message' => true,
                                                          'social' => true, 'tips' => true, 'digest' => true}
  attr_accessible :handle, :public_profile, :notification_email_frequency

  set_callback(:save, :after, if: (:public_profile_changed?)) do |document|
    profile = get_user_profile(handle)
    # save will trigger index
    unless profile.blank?
      profile.save
    end

  end

  # methods
  def is_profile_public
     self.public_profile;
  end

  def set_profile_public(value)
    self.public_profile = value;
    self.save!;
  end

  def email_frequency
    EmailFrequency.constants.each do |constant|
      if self.notification_email_frequency.downcase.eql? constant.to_s.downcase
        return constant
      end
    end
    return nil
  end

  def set_email_frequency(value)
    self.notification_email_frequency = value.to_s.downcase
    self.save!
  end

  def email_notification_subscription_enabled(type)
    return self.notification_email_subscriptions.fetch(type, true)
  end

  def email_notification_update_subscription(type, val)
    subscriptions = self.notification_email_subscriptions
    subscriptions[type] = val
    self.notification_email_subscriptions = subscriptions
    self.save!
  end
end