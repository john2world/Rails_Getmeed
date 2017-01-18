class School
  include Mongoid::Document
  field :_id, type: String, default: -> { handle }
  field :handle, type: String
  field :name, type: String
  field :default_collection_ids, type: Array
  field :major_collection_ids, type: Array
  field :description, type: String
  field :logo, type: String
  field :active, type: Boolean

  attr_accessible :_id, :handle, :name, :description, :logo, :default_collection_ids, :major_collection_ids

  def get_short_school_name
    if self[:handle].length == 3
      return self[:handle].upcase()
    else
      return self[:handle].camelcase()
    end
  end

  def has_private_collections
    !major_collection_ids.blank?
  end

  def as_json(options={})
    options[:except] ||= [:_id, :description]
    super(options)
  end
end