class Contact
  include Mongoid::Document
  field :_id, type: String, default: -> { email }
  field :email, type: String
  field :first_name, type: String
  field :last_name, type: String
  embedded_in :contacts_book

  attr_accessible :_id,
                  :email,
                  :first_name,
                  :last_name
end