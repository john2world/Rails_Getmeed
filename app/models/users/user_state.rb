    class UserState
  include Mongoid::Document
  include BCrypt
  include UsersHelper
  include UsersManager
  include MeedPointsTransactionManager
  include LinkHelper

  field :_id, type: String, default: -> { handle }
  field :handle, type: String
  field :profile_picture_blank, type: Boolean, default: -> {true}
  field :profile_complete, type: Boolean, default: -> {false}
  field :last_profile_updated, type: Time
  field :apply_jobs_date, type: Time
  field :follow_collection_date, type: Time
  field :follow_company_date, type: Time
  field :create_collection_date, type: Time
  field :meed_badge, type: String
  field :last_submission_date, type: Time
  field :last_portfolio_submission_date, type: Time
  field :last_upvote_receive_date, type: Time
  field :last_comment_receive_date, type: Time
  field :last_follower_receive_date, type: Time
  field :last_meed_points_date, type: Time
  field :facebook_import, type: Boolean, default: -> {false}
  field :create_dttm, type: Time, default: -> {Time.now}


  attr_accessible :handle,
                  :profile_picture_blank,
                  :facebook_import,
                  :last_profile_updated,
                  :apply_jobs_date,
                  :follow_collection_date,
                  :follow_company_date,
                  :meed_badge,
                  :create_collection_date,
                  :last_submission_date,
                  :last_upvote_receive_date,
                  :last_comment_receive_date,
                  :last_follower_receive_date,
                  :last_meed_points_date,
                  :last_portfolio_submission_date


end
