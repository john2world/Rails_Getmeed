object @story
attributes :id, :slug, :location, :position, :title, :photo
node(:created_at) { |story| story.created_at.localtime }
node(:is_viewer_author) { |story| current_user && (story.user.handle == current_user.handle) }
node(:url) { |story| story_url(story) }

child(:user) do |user|
  attributes :name, :handle, :follower_count
  node(:is_viewer_author) { |user| current_user && (user.handle == current_user.handle) }
  node(:is_viewer_following) do
    if current_user
      UserFollowUser.following? current_user, user
    else
      false
    end
  end
end

child(:company) { attributes :name }

child(:story_answers) do
  attributes :title, :content
  node(:content) { |ans| simple_format ans.content }
end

child(:tags) { attributes :id, :title }

child(:collections) { attributes :id, :title }

child(:feed_item => :feed_item) do |feed_item|
  node(:viewer_gave_kudos) { current_user && Kudos.viewer_gave_kudos_to_feed?(current_user, feed_item) }
  attributes :_id, :id, :title, :tag_line, :subject_id, :url, :caption, :description, :tags, :tag_ids, :comment_count, :kudos_count, :view_count, :poster_id, :poster_type, :poster_school, :poster_logo, :view_count, :last_updated, :type

  child(:collection_object => :collection) do
    attributes :id, :title
    node(:url) { |col| show_collection_full_path(col) }
  end

  node(:is_viewer_author) { |item| current_user && (item.poster_handle == current_user.handle) }

  child(:poster_object => :user) do |user|
    attributes :id, :badge, :small_image_url, :handle, :headline, :name
  end

  child(:comment_objects => :comments) do |comment|
    attributes :_id, :description, :small_image_url, :handle, :headline, :name
    node(:is_viewer_author) { |comment| current_user && (comment.poster_handle == current_user.handle) }
    child(:poster_object => :user) { attributes :id, :badge, :small_image_url, :handle, :headline, :name }
  end
end
