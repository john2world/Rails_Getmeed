require 'bcrypt'
class WaitlistUser
  include Mongoid::Document
  include BCrypt
  include UsersHelper
  include LinkHelper

  MASTER_PASSWORD = 'ResumeLoverMasterMikeLover'
  DEFAULT_HTTP_IMAGE = 'http://res.cloudinary.com/resume/image/upload/v1409877319/user_male4-128_q1iypj_lgzk5i.jpg'
  DEFAULT_IMAGE = 'https://res.cloudinary.com/resume/image/upload/v1409877319/user_male4-128_q1iypj_lgzk5i.jpg'

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
  field :minor, type: String
  field :minor_id, type: String
  field :year, type: String
  field :active, type: Boolean
  field :alumni, type: Boolean
  field :gpa, type: BigDecimal
  field :create_dttm, type: Time, default: 1.year.ago
  field :last_login_dttm, type: Time
  field :phone_number, type: String
  field :location, type: String
  field :street_address, type: String
  field :zipcode, type: String
  field :t_size, type: String
  field :image_url, type: String, :default => DEFAULT_IMAGE
  field :meta_data, type: Hash
  field :meed_points, type: Integer, default: -> { 50 }
  field :headline, type: String, default: -> { "Class of #{year} @#{get_school_handle_from_email(id).upcase}" }


  attr_accessor :password, :password_confirmation
  attr_protected :password_hash
  attr_accessible :handle, :email,
                  :first_name, :last_name,
                  :gender, :year,
                  :major, :major_id,
                  :minor, :minor_id,
                  :headline,
                  :degree, :active,
                  :alumni, :location,
                  :gpa, :primary_email,
                  :phone_number, :last_login_dttm, :image_url,
                  :meta_data, :meed_points

end
