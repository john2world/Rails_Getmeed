class Survey
  include Mongoid::Document

  field :handle, type: String
  field :type, type: String
  field :response, type: Boolean


  attr_accessible :handle,
                  :type, :response


end