class ContactsBook
  include Mongoid::Document
  field :_id, type: String, default: -> { handle }
  field :handle, type: String
  embeds_many :contacts, as: :contacts


  attr_accessible :handle ,
                  :_id, :contacts
end