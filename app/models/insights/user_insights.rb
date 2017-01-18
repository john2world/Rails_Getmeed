class UserInsights
  include Mongoid::Document
  field :_id, type: String, default: -> { handle }
  field :handle, type: String
  field :profile_views, type: Hash
  field :resume_score, type: Hash

  def self.find_or_create(handle)
    user_insight = UserInsights.where(:handle => handle).first_or_create
    if user_insight[:profile_views].blank?
      user_insight[:profile_views] = {"total_views" => 0, "company_views" => [], "date_views" => []}
    end
    if user_insight[:resume_score].blank?
      user_insight[:resume_score] = {:score => 0, :contributions =>[]}
    end
    return user_insight
  end

  attr_accessible :handle, :profile_views,
                  :resume_score

end