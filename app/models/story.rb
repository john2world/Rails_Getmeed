class Story
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Slug
  include LinkHelper

  field :title
  slug :title, history: true
  field :location
  field :position
  field :photo
  field :type

  validates_presence_of :title, :location, :company, :position, :group, :tags

  belongs_to :user, primary_key: 'handle'
  belongs_to :company
  has_and_belongs_to_many :tags, inverse_of: nil

  # 'collection' is a reserved word
  belongs_to :group, class_name: "Collection", foreign_key: "collection_id"

  has_and_belongs_to_many :collections, inverse_of: nil
  embeds_many :story_answers
  accepts_nested_attributes_for :story_answers, reject_if: proc { |attrs| attrs['title'].blank? || attrs['content'].blank? }

  after_destroy :destroy_dependents
  after_update :update_feed
  after_create :create_feed

  # metadata is reserved word
  def get_metadata
    {
      title: title,
      description: description,
      image_url: photo,
      url: Rails.application.routes.url_helpers.user_story_url(self.user.handle, self)
    }
  end

  def description
    answer = story_answers.first
    if answer
      answer.title + " " + answer.content
    else
      title
    end
  end

  def destroy_dependents
    feed_item && feed_item.destroy
  end

  def create_feed
    FeedItemStore.create_feed_item user.handle, self.id, 'native_story', 'everyone', attributes_for_feed
  end

  def attributes_for_feed
    {
      title: process_text(self.title),
      photo_url: self.photo,
      tag_ids: self.tag_ids,
      collection_ids: [self.collection_id],
      last_updated: Time.zone.now,
      description: self.description,
      url: Rails.application.routes.url_helpers.user_story_url(self.user.handle, self),
      path: Rails.application.routes.url_helpers.user_story_url(self.user.handle, self),
      external_url: Rails.application.routes.url_helpers.user_story_url(self.user.handle, self),
      large_image_url: self.photo
    }
  end

  def update_feed
    feed_item.update_attributes attributes_for_feed
  end

  def feed_item
    @feed_item ||= FeedItems.where(subject_id: self.id).first_or_create
  end

  def stuff_questions_and_tags type
    self.type = type
    unless self.persisted?
      if type == 'intern'
        tag = Tag.find_by title: 'Internship Experience'
        self.tags = [tag]
      end
    end

    @questions = StoryQuestion.where(type: type).to_a
    if @questions.none?
      false
    else
      question_ids = self.story_answers.map(&:question_id)
      @questions.reject { |q| q.id.in? question_ids }.each do |q|
        self.story_answers.new question: q, title: q.title
      end

      true
    end
  end

  attr_accessible :title,
    :location,
    :company_id,
    :company,
    :position,
    :photo,
    :type,
    :collection_id,
    :tag_ids,
    :tags,
    :story_answers_attributes
end
