# Simple constant values that will be app-wide

angular.module("meed").constant "CONSTS", {
  app_dir: "angular_app"
  components_dir: "angular_app/components"
  shared_dir: "angular_app/shared"

  default_avatar: "https://res.cloudinary.com/resume/image/upload/v1409877319/user_male4-128_q1iypj_lgzk5i.jpg"
  default_image: "https://res.cloudinary.com/resume/image/upload/c_scale,w_250/v1443046231/Screen_Shot_2015-09-23_at_3.10.16_PM_dlxhiq.png"
  default_feed_image: "https://res.cloudinary.com/resume/image/upload/c_scale,w_50/v1451955244/latest_gkfrrs.png"
  default_collection_image: "https://res.cloudinary.com/resume/image/upload/c_scale,w_200/v1451955244/latest_gkfrrs.png"

  meed_logo: "https://res.cloudinary.com/resume/image/upload/c_scale,w_50/v1439937394/Meed_logo_green_fcfhir.png"
  full_meed_logo: "https://res.cloudinary.com/resume/image/upload/c_scale,w_120/v1427155934/crescent_green_rt6rit.png"
  filepicker_api_key: "Agxb1eRqwSB2mr4BhJwj2z"

  general_email_pattern: /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.[a-z]{2,3}$/
  university_email_pattern: /^([A-Za-z0-9_\-\.])+\@((([A-Za-z0-9_\-\.])+\.[Ee][Dd][Uu])|(([A-Za-z0-9_\-\.])+\.[Cc][Aa]))$/
  phone_number_pattern: /^\(?(\d{3})\)?[ .\-]?(\d{3})[ .\-]?(\d{4})$/
  name_pattern: /^[a-zA-Z\s,]+$/
  gpa_pattern: /^\d(\.\d{1,2}){0,1}$/
  handle_pattern: /^[a-z0-9\.\-]+$/

}
