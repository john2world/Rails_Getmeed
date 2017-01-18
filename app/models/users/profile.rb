class Profile
  include Mongoid::Document
  include ProfilesManager
  include LinkHelper
  field :_id, type: String, default: -> { handle }
  field :handle, type: String
  field :objective, type: String
  field :summary, type: String
  field :social_links, type: Array
  field :user_work_ids, type: Array
  field :user_edu_ids, type: Array
  field :user_course_ids, type: Array
  field :user_publication_ids, type: Array
  field :user_internship_ids, type: Array
  field :invited_friends, type: Boolean, default: -> {false}
  field :last_update_dttm, type: Date
  field :imported_social_connections, type: Boolean, default: -> {false}
  field :score, type: Integer
  field :tags, type: Hash, default: -> {}
  field :linkedin_import, type: Boolean
  searchkick
  belongs_to :user, foreign_key: "handle", primary_key: 'handle'

  attr_accessible :handle, :objective, :social_links,
                  :user_work_ids,:user_course_ids,
                  :user_internship_ids , :user_publication_ids,
                  :last_update_dttm, :invited_friends, :user_edu_ids, :score, :linkedin_import, :tags

  set_callback(:save, :before, if: :objective_changed?) do |document|
      SitemapPingerWorker.perform_async(get_user_profile_url(id))
  end

  set_callback(:save, :after) do |document|
    is_incomplete = is_incomplete_profile(self)
    unless is_incomplete
      reward_for_profile_completeness(self.handle)
      save_user_state(self.handle, UserStateTypes::PROFILE_COMPLETE)
    end

  end

  def search_data
    if user_work_ids.blank?
      user_works = []
    else
      user_works = UserWork.find(user_work_ids)
    end
    if user_edu_ids.blank?
      user_edu = []
    else
      user_edu = UserEducation.find(user_edu_ids)
    end
    if user_course_ids.blank?
      user_course = []
    else
      user_course = UserCourse.find(user_course_ids)
    end
    if user_publication_ids.blank?
      user_publications = []
    else
      user_publications = UserPublication.find(user_publication_ids)
    end
    if user_internship_ids.blank?
      user_internships = []
    else
      user_internships = UserInternship.find(user_internship_ids)
    end

    user = User.find_by(handle: handle);
    if user.blank?
      school = ''
      major = ''
      name = ''
      profile_picture = ''
    else
      school = user.school
      major = user[:major_id]
      minor = user[:minor_id]
      unless school.blank?
        school = school.downcase
      end
      name = user.name
      profile_picture = user.image_url
    end
    user_state = get_user_state(handle)
    profile_picture_blank = true
    unless user_state.blank?
      profile_picture_blank = user_state.profile_picture_blank
    end
    settings = UserSettings.find_or_create_by(handle: handle)
    {
        school: school,
        name: name,
        profile_picture: profile_picture,
        profile_picture_blank: profile_picture_blank,
        major: major,
        handle: handle,
        objective: objective,
        summary: summary,
        public: settings.public_profile,
        user_work_titles: user_works.map{|d| d[:title]},
        user_work_desc: user_works.map{|d| d[:description]},
        user_edu_titles: user_edu.map{|d| d[:title]},
        user_edu_desc: user_edu.map{|d| d[:description]},
        user_course_titles: user_course.map{|d| d[:title]},
        user_course_desc: user_course.map{|d| d[:description]},
        user_publication_titles: user_publications.map{|d| d[:title]},
        user_publication_desc: user_publications.map{|d| d[:description]},
        user_internships_titles: user_internships.map{|d| d[:title]},
        user_internships_desc: user_internships.map{|d| d[:description]},
        tags: tags,
        score: score
    }
  end

end
