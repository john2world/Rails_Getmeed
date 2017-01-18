object @story
attributes :type, :slug, :location, :position, :title, :company_id, :collection_id, :tag_ids, :photo
child(:company) { attributes :id, :name }
child(:story_answers => :story_answers_attributes) do
  attributes :id, :content, if: lambda { |answer| answer.persisted? }
  attributes :question_id, :title
  child(:question) { attributes :id, :title, :required, :placeholder }
end
