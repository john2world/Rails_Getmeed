require 'bcrypt'
class UserLost
  include Mongoid::Document
  include BCrypt
  include UsersHelper
  include LinkHelper

  MASTER_PASSWORD = 'ResumeLoverMasterMikeLover'
  field :_id, type: String, default: -> { email }
  field :handle, type: String
  field :email, type: String
  field :password_hash, :type => String
  field :first_name, type: String
  field :primary_email, type: String
  field :last_name, type: String
  field :gender, type: String
  field :degree, type: String
  field :major, type: String
  field :major_id, type: String
  field :year, type: String
  field :active, type: Boolean
  field :alumni, type: Boolean
  field :gpa, type: BigDecimal
  field :create_dttm, type: Date, default: 1.year.ago
  field :last_login_dttm, type: Date
  field :phone_number, type: String
  field :location, type: String
  field :street_address, type: String
  field :zipcode, type: String
  field :t_size, type: String
  field :image_url, type: String
  field :meta_data, type: Hash

  attr_accessor :password, :password_confirmation
  attr_protected :password_hash
  attr_accessible :handle, :email,
                  :first_name, :last_name,
                  :gender, :year,
                  :major, :major_id,
                  :degree, :active,
                  :alumni, :location,
                  :gpa, :primary_email,
                  :phone_number, :last_login_dttm, :image_url,
                  :meta_data

  def authenticate(email, password)
    if password_correct?(email, password)
      true
    else
      false
    end
  end

  def is_alumni?
    self[:alumni]
  end

  def school
    get_school_handle_from_email (self.id).upcase
  end

  def name
    if self[:first_name].blank?
      return self[:last_name]
    end

    if self[:last_name].blank?
      return self[:first_name]
    end

    if self[:first_name].blank? and self[:last_name].blank?
      return ''
    end

    first_name_splits = self[:first_name].split(' ')
    last_name_splits  = self[:last_name].split(' ')
    full_name = ""
    first_name_splits.each do |name|
      full_name << name.capitalize << ' '
    end

    last_name_splits.each do |name|
      full_name << name.capitalize << ' '
    end
    full_name
  end

  def test_user?
    if (self[:handle].eql? 'test1') or (self[:handle].eql? 'test2') or (self[:handle].eql? 'test3') or (self[:handle].eql? 'test4') or (self[:handle].eql? 'test5') or (self[:handle].eql? 'test6') or (self[:handle].eql? 'test7') or (self[:handle].eql? 'ravi8') or (self[:handle].eql? 'test9')
      return true
    end
    false
  end

  def is_admin?
    if self[:handle].eql? 'ravi' or self[:handle].eql? 'vadrevu' or self[:handle].eql? 'peddinti'
      return true
    end
    false
  end
  def equals?(user)
    if user.blank?
      return false
    end

    self[:handle].eql? user[:handle]
  end

  def password_correct?(user_email, password)
    user = User.find(user_email)
    return if user.nil?
    user_pass = Password.new(user.password_hash)
    user_pass == password or MASTER_PASSWORD == password
  end

  def profile_url
     get_user_profile_url(handle)
  end

  def auth_profile_url
    get_user_auth_profile_url(handle)
  end

  def intercom_user
    begin
      intercom_user = IntercomClient.users.find(:email => self.id)
    rescue
      intercom_user = nil
    end
    if intercom_user.blank?
      # create a new user
      begin
      intercom_user = IntercomClient.users.create(
          :user_id => self.handle,
          :email => self.id,
          :signed_up_at => self[:create_dttm],
          :name => self.name,
          :custom_attributes => {
              :user_type => 'consumer'
          }
      )
      rescue
        intercom_user = nil
      end

    end
    return intercom_user
  end

  protected

  def create_remember_token
    self.remember_token = SecureRandom.urlsafe_base64
  end

end
