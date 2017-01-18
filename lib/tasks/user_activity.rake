namespace :user_activity do
  task send_course_review_invitation: :environment do
    include NotificationsManager
    start_date = "2014-05-01"
    end_date = "2015-06-01"
    profiles = Profile.find(User.where(:create_dttm.gt => start_date).where(:create_dttm.lte => end_date).pluck(:handle)).compact.select{|profile| !profile[:user_course_ids].blank?}.select{|profile| profile[:user_course_ids].count()>0};
    profiles.each do |profile|
      user = User.find_by(handle: profile[:handle])
      course_id = profile[:user_course_ids][0]
      course = UserCourse.find(course_id)
      Notifier.email_course_review(user, course).deliver
    end
  end
end