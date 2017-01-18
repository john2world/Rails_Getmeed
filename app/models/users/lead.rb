require 'bcrypt'
require 'autoinc'
class Lead
  include Mongoid::Document
  include Mongoid::Autoinc
  include BCrypt
  include UsersHelper
  searchkick

  field :_id, type: String, default: -> { email }
  field :first_name, type: String
  field :last_name, type: String
  field :email, type: String
  field :major_text, type: String
  field :major_id, type: String
  field :major_type_id, type: String
  field :year, type: String
  field :department_text, type: String

  attr_accessible :_id, :first_name, :last_name, :email, :major_text, :major_id, :major_type_id, :year, :department_text
  def as_json(options={})
    options[:except] ||= [:_id]
    super(options).reject { |k, v| v.nil? }
  end

  def search_data
    school = get_school_handle_from_email(email)
    basic = as_json only: [:first_name, :last_name, :email, :company_overview, :major_text, :major_id, :major_type_id, :year, :department_text]
    basic.merge({school: school})
  end
end

