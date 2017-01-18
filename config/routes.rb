require 'sidekiq/web'
Futura::Application.routes.draw do
  resources :stories do
    member do
      put :delete
    end
  end
  get '/:handle/stories/:id', to: 'stories#show', as: :user_story
  resources :story_questions
  resources :companies, only: [:index]
  resources :crm_results

  get 'home/index'
  root :to => 'home#index'
  resources :users, :only => [:create, :verify]
  resources :user_messages, only: [:create]
  resources :feed_items, only: [] do
    member do
      put :downvote
    end
  end

  #error pages

  match '/404' => 'application#page_not_found'
  match '/422' => 'application#server_error'
  match '/500' => 'application#server_error'
  match '/_=_' => 'home#index'

  match '/sitemap.:format', :controller => 'home', :action => 'sitemap', :conditions => {:method => :get}, as: 'sitemap'
  match '/seomagicsitemap.:format', :controller => 'home', :action => 'sitemap_all', :conditions => {:method => :get}, as: 'sitemap'
  match '/sitemap.xml' => 'home#sitemap'
  match '/seomagicsitemap.xml' => 'home#sitemap_all'
  match '/robots.txt' => 'home#robots', format: :text, as: :robots
  match '/promotion' => 'home#promotion'
  match '/fallcompetition' => 'home#competition'
  match '/fallcompetition/leaderboard' => 'home#competition_leaderboard'


  match 'users/incomplete' => 'users#incomplete'
  match 'users/incomplete/submit' => 'users#incomplete_submit'
  match 'users/linkedin/create' => 'users#linkedin_create'
  match 'users/linkedin/complete' => 'users#linkedin_complete'

  match 'users/forgot' => 'users#forgot'
  match 'users/password' => 'users#password'
  match 'users/password/submit' => 'users#passwordsubmit'
  match 'users/forgotme' => 'users#forgotme'
  match 'users/waitlist' => 'users#verify'
  match 'users/verify_easy' => 'users#verify_easy'
  match 'users/create_easy' => 'users#create_easy'
  match 'users/account_easy' => 'users#account_easy'
  match 'users/leaderboard' => 'users#leader_board' , :format => 'json'
  match '/leaderboard/show' => 'users#leader_board_show'
  match 'users/earnmeedpoints' => 'users#earn_meed_points'
  match 'users/promotion' => 'users#promotion'
  match 'users/verify' => 'users#verify'
  match 'users/verify/again' => 'users#verifyagain'
  match 'users/checkhandle/:handle' => 'users#check_handle'
  match 'users/get_current_user' => 'users#get_current_user', :format => 'json'
  match 'users/increment/meed_points' => 'notifications#increment_meed_points', :format => 'json'
  match '/invites' => 'users#invite'
  # match '/login' => 'sessions#new'
  match '/login' => redirect("/")
  match '/enterprise-signup' => 'home#enterprise_pointer'

  match '/emails/unsubscribe' => 'home#unsubscribe'
  match '/emails/subscribe' => 'home#subscribe'
  match '/contactus' => 'home#contact_us'
  match '/contact' => 'home#contact'
  match '/ftue/update' => 'first_user_experiences#ftue_update'
  match '/about/product' => 'home#about_product'
  match '/about/version' => 'home#show_version'
  #schools
  resources :schools, only: [:index]
  match '/school/verify' => 'schools#verify'
  match '/school/:school_id' => 'schools#index'
  match '/school/lookup/email' => 'schools#lookup', :format => 'json'
  #new auth
  match 'users/account' => 'users#account', :format => 'json'
  match 'users/influencers/account' => 'users#influencer_account', :format => 'json'
  match 'users/influencers/expertise/save' => 'users#influencer_expertise_save', :format => 'json'
  match 'users/create' => 'users#create'
  match '/login/verify' => 'sessions#create', :format => 'json'

  #majors
  match '/majors' => 'majors#index'
  match '/majors/degrees' => 'majors#majors_degrees', :format => 'json'
  match '/majors/types' => 'majors#majors_types', :format => 'json'

  #insights
  match '/insights' => 'home#insights'
  match '/questions' => 'questions#dash'
  match '/connections' => 'connections#start'
  match '/connections/gmail' => 'connections#gmail_import'
  match '/connections/save' => 'connections#save'
  match '/connections/invited' => 'connections#invited'
  match '/contacts/failure' => 'connections#failure'
  match 'contacts/gmail/callback' => 'connections#gmail_import_callback'
  match 'contacts/auth/gmail' => 'connections#gmail_import_auth'
  match '/track/click/:data' => 'tracking#track_click'

  #profile import
  match '/auth/linkedin/callback' => 'sessions#social_sign_up'
  match '/auth/github/callback' => 'sessions#social_sign_up'
  match '/auth/twitter/callback' => 'sessions#social_sign_up'
  match '/auth/callback' => 'sessions#social_sign_up', :format => 'json'

  match '/auth/linkedin/' => 'profiles#linkedin_import'
  match '/auth/twitter/' => 'profiles#linkedin_import'
  match '/auth/github/' => 'profiles#linkedin_import'
  match '/resume/upload/' => 'profiles#resume_upload', :format => 'json'


  match '/auth/failure' => 'profiles#linkedin_failure'

  #settings
  match '/settings' => 'home#settings'
  match '/settings/:id/update' => 'home#update_settings'
  match '/settings/deactivate_survey' => 'home#deactivate_survey'

  #posts
  match '/post/publish' => 'posts#publish_story'
  match '/post/job' => 'posts#post_job'
  match '/post/:id/update' => 'posts#update_story'
  match '/show/stories' => 'articles#show_stories'
  match '/scrape' => 'scrape#scrape'

  match '/legal/tos' => 'home#tos'
  match '/invite' => 'home#invite_users'
  match '/waitlist/add' => 'home#add_waitlist_users'
  match '/invite/friends' => 'home#invite_users_mini'
  match '/facebook/friends/save' => 'connections#save_facebook'
  match '/ineedmeed' => 'home#need_meed'
  match '/waitlist_status' => 'home#need_meed_status'
  match '/waitlist/verify' => 'users#waitlist_verify'

  match '/hackathon/:id' => 'hackathon#show'
  match '/home' => 'home#dash'
  match '/activity' => 'feed#activity'
  match '/feed' => 'feed#feed'
  match '/submit/post(/:collection_id)' => 'articles#create_article', as: :create_article
  match '/articles/publish' => 'articles#publish_article'
  match '/articles/:id' => 'articles#show_article'
  match '/articles/:id/edit' => 'articles#edit_article'

  match '/logout' => 'sessions#destroy'
  match '/demigod/usc_auto_session' => 'sessions#demo'
  match '/edit' => 'profiles#edit'
  match '/view' => 'profiles#view'
  match '/share' => 'profiles#share'
  match '/meedfair' => 'home#careerfair'
  match '/jobinbox' => 'home#dash'
  match '/messages' => 'messages#messages'
  match '/profile' => 'profiles#profile'
  #influencers
  match '/influencers' => 'influencers#index'

  match '/recruiting' => 'home#recruiting'
  resources :jobs, only: [:index, :edit, :new, :create, :destroy, :update] do
    collection do
      get :manage
      get :match
    end

    member do
      put :toggle
      put :delete
    end
  end

  resources :job_applicants, only: [:index, :show, :update] do
    collection do
      get :count
    end
    member do
      post :shortlist
      post :archive
      post :invite
    end
  end

  match '/:id/collection/:slug_id/:collection_id'  => 'collections#show_collection_full', as: :show_collection_full
  match '/:id/ama/:event_id' => 'profiles#view', :constraints => {:id => /[^\/]*/}, as: 'user'
  match '/:id' => 'profiles#view', :constraints => {:id => /[^\/]*/}, as: 'user'
  match '/:id/follow' => 'profiles#follow_user', :constraints => {:id => /[^\/]*/}, as: 'user'
  match '/:id/unfollow' => 'profiles#unfollow_user', :constraints => {:id => /[^\/]*/}, as: 'user'
  match '/:id/invite' => 'profiles#invite_user', :constraints => {:id => /[^\/]*/}, as: 'user'

  match '/:id/:year/:month/:day/:article_id' => 'articles#show_story', :constraints => {:id => /[^\/]*/}, as: 'user'
  match '/story/:id/:year/:month/:day/:article_id' => 'articles#show_story', :constraints => {:id => /[^\/]*/}, as: 'user'
  match '/:id/auth' => 'profiles#auth_view', :constraints => {:id => /[^\/]*/}, as: 'user'
  match '/:id/contact' => 'profiles#contact_profile'
  match '/:id/contact/email' => 'profiles#send_email'
  match '/:id/viewers' => 'home#viewers'
  match '/:id/jobviews' => 'home#job_views'

  match '/ama/vmk-google' => 'events#show_ama'
  match '/ama/follow/:ama_id' => 'events#follow_ama'
  match '/user/recommendations'  => 'users#recommended_users', :format => 'json'
  match '/user/lead/recommendations'  => 'users#recommended_lead_users', :format => 'json'


  match '/profiles/objective/save' => 'profiles#save_objective'
  match '/profiles/bio/save' => 'profiles#save_bio'
  match '/profiles/headline/save' => 'profiles#save_headline'
  match '/profiles/publication/save' => 'profiles#save_publication'
  match '/profiles/internship/save' => 'profiles#save_internship'
  match '/profiles/course/save' => 'profiles#save_course'
  match '/profiles/experience/save' => 'profiles#save_experience'
  match '/profiles/education/save' => 'profiles#save_education'
  match '/profiles/header/save' => 'profiles#save_header'
  match '/profiles/photo/save' => 'photos#save_profile_photo'
  match '/articles/photo/save' => 'photos#save_article_photo'
  match '/feed/files/save' => 'feed#save_meed_files'

  match '/profiles/course/invites/:course_id' => 'courses#course_invites', :format => 'json'
  match '/course/invite/:invite_id/remind' => 'courses#invite_reminder', :format => 'json'
  match '/course/invite' => 'courses#create_invite', :format => 'json'


  match '/profiles/bundle' => 'profiles#show_profile_bundle'
  match '/comments/show' => 'comments#show_comments'
  match '/comments/create' => 'comments#create'
  match '/comments/:id/update' => 'comments#update'
  match '/comments/delete' => 'comments#delete'

  #company stuff
  get '/company/edit' => 'companies#edit'
  post '/company/verify' => 'companies#verify'
  get '/company/verified' => 'companies#verified'
  post '/company/update' => 'companies#update'

  match '/company/:id' => 'companies#view', :constraints => {:id => /[^\/]*/}
  match '/company/follow/:id' => 'companies#follow', :constraints => {:id => /[^\/]*/}
  match '/company/:id/auth' => 'companies#auth_view', :constraints => {:id => /[^\/]*/}
  match '/company/unfollow/:id' => 'companies#unfollow', :constraints => {:id => /[^\/]*/}
  match '/user/company/recommendations'  => 'companies#recommended_companies', :format => 'json'
  match '/company/list/all' => 'companies#all_companies', :format => 'json'

  #kudos stuff
  match '/kudos/:id' => 'kudos#give_kudos'
  match '/kudos/:id/profile' => 'kudos#give_kudos_from_profile'

  #jobs stuff
  post '/jobs/import' => 'jobs#import'
  match '/jobs/create' => 'jobs#create_job'
  match '/jobs/load' => 'jobs#jobs', :format => 'json'
  match '/jobs/:job_type'  => 'jobs#all_jobs'
  match '/job/apply' => 'jobs#apply_job', :format => 'json'
  match '/job/contact_recruiter' => 'jobs#contact_recruiter'
  match '/job/share' => 'jobs#share'
  match '/job/forward' => 'jobs#forward'
  match '/job/update_user_status' => 'jobs#update_user_status'
  match '/job/:id' => 'jobs#show_job'
  match '/job/:id/status' => 'jobs#show_job_status'
  match '/job/app/:id/stats' => 'jobs#user_job_app_stats'
  match '/job/:id/edit' => 'jobs#edit_job'
  match '/job/:id/delete' => 'jobs#delete_job'
  match '/jobs/photo_upload' => 'jobs#job_photo_upload'
  match '/jobs' => 'home#dash'


  # messages stuff
  match '/message/initiate' => 'messages#initiate_message'
  match '/message/:id' => 'messages#show_message'
  match '/message/:id/reply' => 'messages#reply_message'

  #q&a
  match '/questions' => 'questions#dash'
  match '/questions/create' => 'questions#handle_create_question'
  match '/questions/publish' => 'questions#publish_question'
  match '/questions/:id' => 'questions#show_question'
  match '/questions/:id/edit' => 'questions#edit_question '
  match '/question/follow/:id' => 'questions#follow_question'
  match '/question/unfollow/:id' => 'questions#unfollow_question'

  #collections
  match '/categories/:category_id'  => 'collections#show_category'
  match '/collection/:collection_id/follow'  => 'collections#collection_follow', :format => 'json'
  match '/collection/:collection_id/unfollow'  => 'collections#collection_unfollow', :format => 'json'
  match '/collection/:slug_id/:collection_id'  => 'collections#show_collection_full', as: :show_collection_full
  match '/collection/:collection_id'  => 'collections#show_collection_full', as: :show_collection_full
  match '/collections/new(/:category_id)'  => 'collections#new'
  match '/collections/create'  => 'collections#create', :format => 'json'
  match '/collections/public'  => 'collections#public_collections', :format => 'json'
  match '/collections/:category_id'  => 'collections#collections_by_category'
  match '/feed/category/:category_id'  => 'feed#category_feed', :format => 'json'
  match '/user/collection/recommendations'  => 'collections#recommended_collections', :format => 'json'
  match '/user/collections'  => 'collections#user_collections'
  match '/user/collections/following'  => 'collections#user_following_collections'

  #tags
  match '/feed/tag/:id' => 'tags#show_tag'
  match '/feed/tags' => 'tags#all_tags'


  match '/answers/create' => 'answers#handle_create_answer'
  match '/answers/publish' => 'answers#publish_answer'
  match '/answers/delete' => 'answers#delete_user_answer'
  match '/upvotes/:id' => 'upvotes#upvote'

  #course reviews
  match '/reviews/course' => 'reviews#course_review'
  match '/reviews/course/submit' => 'reviews#course_review_submit'
  match '/insights/courses' => 'reviews#course_insights'
  match '/insights/courses/search' => 'reviews#course_insights_search'
  match '/insights/courses/dash' => 'reviews#course_insights_dash'

  #work reviews
  match '/reviews/work/dash' => 'reviews#work_references_dash'
  match '/reviews/work' => 'reviews#work_references'
  match '/reviews/work/invite' => 'reviews#work_reference_email_invite'
  match '/reviews/work/invite/view' => 'reviews#work_reference_invite_view'
  match '/reviews/work/submit' => 'reviews#work_reference_submit'

  #admin stuff
  match '/admin/view' => 'admins#view'
  match '/admin/weekly_digest' => 'admins#weekly_digest'
  match '/admin/weekly_digest_generate' => 'admins#weekly_digest_generate'
  match '/admin/influencers' => 'admins#influencers'

  match '/admin/collection' => 'admins#admin_collection'
  match '/admin/submission_to_collection' => 'admins#admin_map_submission_collection'
  match '/admin/submissions' => 'admins#admin_submissions'

  match '/admin/create_collection' => 'admins#admin_create_collection'
  match '/admin/create_intercom_contacts' => 'admins#create_intercom_contacts'
  match '/admin/update_intercom_contacts' => 'admins#update_intercom_contacts'

  match '/admin/sitemap' => 'admins#sitemap_initialize'
  match '/admin/waitlist' => 'admins#waitlist'
  match '/admin/gecko/stats' => 'admins#gecko_stats', :format => 'json'
  match '/admin/job/answer/question' => 'admins#admin_ask_to_answer'
  match '/admin/invitations' => 'admins#invitations'
  match '/admin/email' => 'admins#email'
  match '/admin/email/submit' => 'admins#email_send'
  match '/admin/blogs' => 'admins#blogs'
  match '/admin/blogs/create' => 'admins#new_blog'
  match '/admin/blogs/delete' => 'admins#delete_blog'
  match 'admin/dashboard' => 'admins#dashboard'
  match '/admin/jobs' => 'admins#show_jobs'
  match '/admin/jobs/:id/pause' => 'admins#pause_job'
  match '/admin/jobs/:id/live' => 'admins#live_job'
  match '/admin/emails/send' => 'admins#send_emails'
  match '/admin/emails/new_feature' => 'admins#broadcast_new_feature'
  match '/admin/alerts/incomplete' => 'admins#remind_incomplete_resume'
  match '/admin/search_index' => 'admins#search_index'
  match '/admin/add_group' => 'admins#add_group'
  match '/admin/add_group/submit' => 'admins#add_group_submit'
  match '/admin/add_major_type' => 'admins#add_major_type'
  match '/admin/add_major_type_submit' => 'admins#add_major_type_submit'
  match '/social_group/track/click' => 'articles#social_groups_track'
  match '/admin/lost_users' => 'admins#lost_users'
  match '/admin/show_bdi_jobs' => 'admins#show_bdi_jobs'
  match '/admin/show_bdi_status' => 'admins#show_bdi_status'
  match '/admin/show_bdi_job_status' => 'admins#show_bdi_job_status'
  match '/migrations/primaryemail' => 'migrations#migrate_primary_emails'
  match '/migrations/resumescore' => 'migrations#migrate_resume_score'
  match '/migrations/jobs/allschools' => 'migrations#migrate_jobs_allschools'
  match '/migrations/companies' => 'migrations#migrate_companies'
  match '/migrations/job/applications' => 'migrations#migrate_job_applications'
  match '/migrations/feed/seed' => 'migrations#migrate_seed_activity_feed'
  match '/migrations/feed/public' => 'migrations#migrate_public_feed_create_time'

  #feed
  match '/overlord/:feed_id' => 'home#index'


  match '/feed/load' => 'feed#load', :format => 'json'
  match '/feed/l/:id' => 'feed#perma_link'
  match '/feed/perma/:id' => 'feed#perma_link'
  match '/feed/:id/load' => 'feed#company_load', :constraints => {:id => /[^\/]*/}, as: 'user', :format => 'json'
  match '/notifications/get' => 'notifications#get_notifications', :format => 'json'
  match '/notifications/reset/count' => 'notifications#reset_notification_count', :format => 'json'
  match '/feed/action/skip/:action_id' => 'feed#skip_action'
  match '/feed/action/submit/' => 'feed#submit_action'

  match '/feed/delete' => 'feed#delete'
  match '/feed/track/click/:id' => 'feed#feed_track'
  match '/feed/:collection_id'  => 'feed#collection_feed', :format => 'json'
  match '/thanksgiving/claim' => 'profiles#claim_offer_check'
  match '/thanksgiving/claim/complete' => 'profiles#claim_offer_complete'
  match '/profiles/add/details' => 'profiles#add_user_details'
  match '/profiles/current_company/save' => 'profiles#save_current_company'
  match '/profiles/previous_company/save' => 'profiles#save_previous_company'
  match '/surveys/take_survey' => 'surveys#take_survey'

  #autosuggest
  match '/companies/search/:query' => 'companies#autosuggest', :format => 'json'

  #search
  post '/dashboard/search' => 'search#dashboard_search', :format => 'json'

  #download pdfs
  match '/:id/pdf' => 'profiles#download_pdf'
  match '/pdf/bundle' => 'profiles#download_pdf_bundle'

  #Pingers
  match 'pinger/job/save/:id' => 'pinger#job_save'

  #help pages
  match '/help/resume_score' => 'help#resume_score'

  match '/r/:code' => 'home#redirect'

  #test
  match '/test/vine' => 'tests#vine'
  match '/test/emails/:id' => 'tests#test_emails'


  mount Sidekiq::Web, at: '/admin/sidekiq'

  #adding a generic route to catch unknown pages
  match '*a', :to => 'application#page_not_found'

  match "*path" => redirect("/home")
end
