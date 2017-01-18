class Company
  include Mongoid::Document
  include LinkHelper
  searchkick
  field :name, type: String
  field :company_id, type: String
  field :company_logo, type: String
  field :description, type: String
  field :location, type: String
  field :culture_video_id, type: String
  field :culture_video_type, type: String
  field :view_count, type: Integer, :default => 0
  field :follow_count, type: Integer, :default =>  0
  field :cover_image_url, type: String
  field :culture_video_url, type: String
  field :current_plan, type: String
  field :stripe_customer_id, type: String
  field :live_job_count, type: Integer, :default => 0
  field :license_count, type: Integer, :default => 0
  field :job_credits, type: Integer, :default => 0
  field :culture_photo_ids, type: Array
  field :video_urls, type: Array, :default => Array.[]
  field :target_majors, type: Array, :default => Array.[]
  field :meta_data, type: Hash, :default => {}
  has_many :jobs, foreign_key: :company, primary_key: :name

  attr_accessible :name,
                  :culture_video_id,
                  :company_logo,
                  :description,
                  :location,
                  :culture_video_id,
                  :culture_photo_ids,
                  :culture_video_type,
                  :view_count,
                  :company_id,
                  :follow_count,
                  :video_urls,
                  :cover_image_url,
                  :culture_video_url,
                  :stripe_customer_id,
                  :current_plan


  set_callback(:save, :before, if: (:name_changed? || :company_logo_changed? || :company_description_changed? ||
                        :location_changed? || :culture_video_id_changed? || :cover_image_url_changed? ||
                        :culture_video_url_changed?)) do |document|
    SitemapPingerWorker.perform_async(get_company_url(id))
  end

  def search_data
    as_json only: [:name, :description]
  end

  def profile_url
    get_company_url(id)
  end

  def auth_profile_url
    get_company_auth_profile_url(id)
  end

  def get_video_urls
    urls = video_urls
    cover_video = cover_video_url
    unless cover_video.blank?
      unless cover_video.include? 'http'
        cover_video = "https://#{cover_video}"
      end
      urls << cover_video
    end
    urls
  end


  def cover_video_url
    unless culture_video_type.blank?
      if culture_video_type.eql? 'youtube'
        return get_youtube_url(culture_video_id)
      elsif culture_video_type.eql? 'vimeo'
        return get_vimeo_url(culture_video_id)
      end
    end
  end

  def get_cover_image_url
    unless culture_video_type.blank?
      if culture_video_type.eql? 'youtube'
        return get_youtube_default_image_url(culture_video_id)
      end
    end

    unless cover_image_url.blank?
      return cover_image_url
    end

    company_logo
  end


  def as_json(options={})
    options[:except] ||= [:view_count, :current_plan, :stripe_customer_id, :job_credits, :license_count, :meed_credits, :meta_data, :culture_photo_ids, :live_job_count, :target_majors]
    super(options)
  end


end
