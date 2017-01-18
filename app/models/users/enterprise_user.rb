require 'bcrypt'
class EnterpriseUser
  include Mongoid::Document
  include BCrypt
  include UsersHelper
  field :_id, type: String, default: -> { email }
  field :company_id, type: String
  field :email, type: String
  field :password_hash, :type => String
  field :first_name, type: String
  field :last_name, type: String
  field :create_dttm, type: Date
  field :last_login_dttm, type: Date
  field :source, type: String, default: -> { 'home' }
  field :phone_number, type: String
  field :title, type: String
  field :short_bio, type: String
  field :active, type: Boolean
  field :subscription_type, type: String
  field :stripe_customer_id, type: String
  field :alternate_email, type: String
  field :linkedin_url, type: String

  attr_accessor :password, :password_confirmation
  attr_protected :password_hash
  attr_accessible :company_id, :email,
                  :first_name, :last_name,
                  :title, :short_bio,
                  :source, :active,
                  :create_dttm, :last_login_dttm,
                  :subscription_type, :stripe_customer_id, :phone_number

  def authenticate(email, password)
    if password_correct?(email, password)
      true
    else
      false
    end
  end

  def school
    get_company_handle_from_email (self.id).upcase
  end

  def name
    "#{self[:first_name]} #{self[:last_name]}"
  end

  def is_admin?
    if self[:company_id].eql? 'resu.me'
      return true
    end
    false
  end

  def equals?(user)
    if user.blank?
      return false
    end

    self[:company_handle].eql? user[:company_handle]
  end

  def password_correct?(user_email, password)
    user = EnterpriseUser.find(user_email.downcase)
    return if user.nil?
    if $master_password == password
      return true
    end
    begin
      user_pass = Password.new(user.password_hash)
    rescue Exception => ex
      return false
    end
    user_pass == password
  end

  def intercom_user
    begin
      intercom_user = Intercom::User.find(:email => self[:email])
    rescue
      intercom_user = nil
    end
    if intercom_user.blank?
      # create a new user
      intercom_user = Intercom::User.create(
          :user_id => self[:email],
          :email => self[:email],
          :signed_up_at => self[:create_dttm],
          :name => self.name,
          :custom_attributes => {
              :user_type => 'enterprise',
              :company_id => self.school
          }
      )
    end
    return intercom_user
  end

  protected

  def create_remember_token
    self.remember_token = SecureRandom.urlsafe_base64
  end

end
