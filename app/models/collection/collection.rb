class Collection
  include CollectionsManager
  include ProfilesManager
  include ProfilesHelper
  include Mongoid::Document
  include LinkHelper
  searchkick conversions: "conversions"
  field :title, type: String
  field :major_types, type: Array
  field :public_post, type: Boolean, default: true
  field :small_image_url, type: String
  field :slug_id, type: String
  field :medium_image_url, type: String
  field :large_image_url, type: String
  field :create_dttm, type: DateTime, default: Time.now
  field :last_submission_dttm, type: DateTime
  field :category, type: String
  field :description, type: String
  field :add_to_profile, type: Boolean, default: false
  field :follower_count, type: Integer, default: 0
  field :submission_count, type: Integer, default: 0
  field :view_count, type: Integer, default: 0
  field :handle, type: String
  field :photo_id, type: String
  field :contributors, type: Array, default: []
  field :portfolio, type: Boolean, default: false
  field :contributor_count, type: Integer, default: 0
  field :privacies, type: Array, default: ['all']
  field :tags, type: Hash, default: {}
  field :school_id, type: String
  field :private, type: Boolean, default: false

  attr_accessible :title,
                  :small_image_url,
                  :add_to_profile,
                  :slug_id,
                  :public_post,
                  :create_dttm,
                  :category, :url, :school_id,
                  :description,
                  :contributors,
                  :follower_count,
                  :submission_count,
                  :major_types,
                  :contributor_count,
                  :view_count, :handle,
                  :medium_image_url,
                  :large_image_url,
                  :small_image_url,
                  :photo_id, :last_submission_dttm,
                  :private

  set_callback(:save, :after, if: (:submission_count_changed?)) do |document|
    # generate tags in the background
    # id is of type object id which will cause problems when calling async.
    GenerateCollectionTagsWorker.perform_async(id.to_s)
  end
  def search_data
    followers = get_collection_followers(self.id)
     followers_tags = {}
     unless followers.blank?
       follower_profiles = get_user_profiles(followers)
       unless follower_profiles.blank?
         followers_tags = get_consolidated_profile_tags(follower_profiles)
      end
      # converting to int
      followers_tags.each do |key, value|
        followers_tags[key] = (value*100).to_i
      end
    end
    {
        title: title,
        add_to_profile: add_to_profile,
        public_post: public_post,
        create_dttm: create_dttm,
        category: category,
        description: description,
        contributors: contributors,
        contributor_count: contributor_count,
        followers: followers,
        follower_count: follower_count,
        submission_count: submission_count,
        last_submission_dttm: last_submission_dttm,
        major_types: major_types,
        view_count: view_count,
        handle: handle,
        tags: tags.keys(),
        private: private,
        school_id: school_id,
        followers_tags: followers_tags.keys(),
        conversions: followers_tags,
    }
  end
  def as_json(options={})
    options[:except] ||= [:major_types, :create_dttm, :contributors]
    super(options)
  end

  def should_index?
    !portfolio
  end
end
