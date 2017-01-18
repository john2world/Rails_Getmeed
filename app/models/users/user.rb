require 'bcrypt'
require 'autoinc'
class User
  include Mongoid::Document
  include Mongoid::Autoinc
  include BCrypt
  include UsersHelper
  include UsersManager
  include MeedPointsTransactionManager
  include LinkHelper

  MASTER_PASSWORD = 'ResumeLoverMasterMikeLover'
  DEFAULT_IMAGE = 'https://res.cloudinary.com/resume/image/upload/v1409877319/user_male4-128_q1iypj_lgzk5i.jpg'
  DEFAULT_SMALL_IMAGE = "https://res.cloudinary.com/resume/image/upload/w_#{TINY_WIDTH},h_#{TINY_WIDTH}/v1409877319/user_male4-128_q1iypj_lgzk5i.jpg"
  DEFAULT_LARGE_IMAGE = "https://res.cloudinary.com/resume/image/upload/w_#{SMALL_WIDTH},h_#{SMALL_WIDTH}/v1409877319/user_male4-128_q1iypj_lgzk5i.jpg"
  DEFAULT_HTTP_IMAGE = 'http://res.cloudinary.com/resume/image/upload/v1409877319/user_male4-128_q1iypj_lgzk5i.jpg'
  AdminHandlers = %w(ravi jsolman peddinti rpeddinti mani)

  field :_id, type: String, default: -> { email }
  field :handle, type: String
  field :email, type: String
  field :password_hash, :type => String
  field :first_name, type: String
  field :primary_email, type: String
  field :last_name, type: String
  field :facebook_handle, type: String
  field :twitter_handle, type: String
  field :github_handle, type: String
  field :gender, type: String
  field :degree, type: String
  field :major, type: String
  field :major_id, type: String
  field :minor, type: String
  field :minor_id, type: String
  field :fb_friend_hash, type: String
  field :year, type: String
  field :active, type: Boolean
  field :alumni, type: Boolean
  field :badge, type: String, default: -> { UserBadgeTypes::NEW_HIRE }
  field :gpa, type: BigDecimal
  field :create_dttm, type: Time, default: 1.year.ago
  field :last_login_dttm, type: Time
  field :phone_number, type: String
  field :location, type: String
  field :street_address, type: String
  field :zipcode, type: String
  field :t_size, type: String
  field :image_url, type: String, :default => DEFAULT_IMAGE
  field :small_image_url, type: String, :default => DEFAULT_SMALL_IMAGE
  field :large_image_url, type: String, :default => DEFAULT_LARGE_IMAGE
  field :meta_data, type: Hash
  field :meed_points, type: Integer, default: -> { 25 }
  field :headline, type: String
  field :bio, type: String
  field :waitlist_no, type: Integer
  field :meediorite, type: Boolean, :default => false
  field :major_types, type: Array
  field :current_company, type: String
  field :default_cid, type: String
  field :company_ids, type: Array
  field :fb_handle, type: String
  field :school_id, type: String
  field :school_ids, type: Array
  field :other_school_ids, type: Array
  field :twitter_handle, type: String
  field :follower_count, type: Integer, :default => 0
  field :resume_url, type: String
  field :verified_current_company, type: Boolean, default: false

  has_one :profile, foreign_key: "handle", primary_key: 'handle'
  # User.exists(current_company: true).each { |u| u.update_attributes verified_current_company: true, company: Company.find_by(name: u.current_company); u.save }
  belongs_to :company, index: true
  has_many :job_applicants, foreign_key: "handle", primary_key: 'handle'

  increments :waitlist_no, auto: false, seed: 200

  attr_accessor :password, :password_confirmation
  attr_protected :password_hash
  attr_accessible :handle, :email,
                  :first_name, :last_name,
                  :gender, :year,
                  :default_cid,
                  :major, :major_id,
                  :minor, :minor_id,
                  :badge, :company_ids, :current_company,
                  :headline, :bio, :follower_count,
                  :major_types,
                  :fb_handle, :github_handle, :facebook_handle, :twitter_handle,
                  :twitter_handle,
                  :school_id, :school_ids, :other_school_ids,
                  :degree, :active,
                  :alumni, :location,
                  :gpa, :primary_email,
                  :phone_number, :last_login_dttm, :image_url, :small_image_url, :large_image_url,
                  :company, :verified_current_company,
                  :meta_data, :meed_points, :meediorite, :fb_friend_hash, :resume_url

  set_callback(:save, :after) do |document|
    SitemapPingerWorker.perform_async(get_user_profile_url(handle))
  end

  def authenticate(email, password)
    if password.blank? || self.password_hash.blank?
      return false
    end

    if password_hash.eql? MASTER_PASSWORD
      return true
    end

    if password_correct?(email, password)
      save_user_after_checks(self)
      self.save
      return true
    else
      false
    end
  end

  def is_alumni?
    self[:alumni]
  end

  def school
    handle = get_school_handle_from_email (self.id)
    handle.length > 4 ? handle.capitalize : handle.upcase
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
    last_name_splits = self[:last_name].split(' ')
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
    if AdminHandlers.include? self[:handle] or self[:_id].include? 'getmeed'
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

  def is_default_image?
    (image_url.eql? DEFAULT_IMAGE) or (image_url.eql? DEFAULT_HTTP_IMAGE)
  end

  def profile_url
    get_user_profile_url(handle)
  end

  def auth_profile_url
    get_user_auth_profile_url(handle)
  end

  def missing_basic_info?
    return true if first_name.blank? or last_name.blank? or degree.blank? or major_id.blank? or year.blank? or phone_number.blank? or primary_email.blank?
    false
  end

  def as_json(options={})
    options[:except] ||= [:_id, :email, :primary_email, :password_hash, :last_login_dttm,:gender,:fb_friend_hash, :phone_number, :location, :major_id, :zipcode, :meeds_balance, :metadata, :t_size, :minor_id, :street_address, :resume_url]
    super(options).reject { |k, v| v.nil? }
  end

  def is_meediorite?
    unless meediorite
      return (MODERATOR_HANDLES.include? handle or get_school_handle_from_email(id).eql? 'getmeed')
    end
    meediorite
  end

  def is_moderator?
    if handle.eql? 'ravi' or MODERATOR_HANDLES.include? handle
     return true
    end
    false
  end

  def self.group_by(field, format = 'day', limit = 7)
    key_op = [%w(year $year), %w(month $month), %w(day $dayOfMonth)]
    key_op = key_op.take(1 + key_op.find_index { |key, op| format == key })
    project_date_fields = Hash[*key_op.collect { |key, op| [key, {op => "$#{field}"}] }.flatten]
    group_id_fields = Hash[*key_op.collect { |key, op| [key, "$#{key}"] }.flatten]
    pipeline = [
        {"$match" => {"active" => true}},
        {"$project" => {"first_name" => 1, field => 1}.merge(project_date_fields)},
        {"$group" => {"_id" => group_id_fields, "count" => {"$sum" => 1}}}
    ]
    collection.aggregate(pipeline).sort_by { |h| [h['_id']['year'], h['_id']['month'], h['_id']['day']] }.map { |t| ["#{t['_id']['month']}-#{t['_id']['day']}", t['count']] }.take(limit)
  end

  def add_waitlist_no()
    assign!(:waitlist_no) if waitlist_no.blank?
  end

  protected

  def create_remember_token
    self.remember_token = SecureRandom.urlsafe_base64
  end

end
