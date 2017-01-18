class DevSearch
  include Mongoid::Document
  include AlgoliaSearch

  field :handle, type: String
  field :name, type: String
  field :type, type: String
  field :picture, type: String
  field :degree, type: String
  field :major, type: String
  field :coursework, type: Array
  field :internships, type: Array
  field :experience, type: Array
  field :skills, type: Array
  field :university, type: String
  field :score, type: String


  attr_accessible :handle, :name,
                  :type, :picture,
                  :internships,
                  :degree,
                  :experience,
                  :major,
                  :coursework,
                  :skills, :university, :score


  algoliasearch do
    attributesToIndex %w(name major coursework internships experience skills university picture type handle)
    customRanking ['desc(score)']
  end



end