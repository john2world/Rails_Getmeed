module IntercomManager
  include ProfilesManager
  include UsersHelper

  IntercomHeaders = {
      "Origin"=>"https://app.intercom.io",
      "Accept-Encoding"=>"gzip, deflate",
      "X-CSRF-Token"=>"YdwnZm2wY+Hnf2vEFP3KtT6hfgTHKJsV80EOzep/mTo=",
      "Accept-Language"=>"en-US,en;q=0.8",
      "User-Agent"=>"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.106 Safari/537.36",
      "Content-Type"=>"application/json; charset=UTF-8",
      "Accept"=>"application/json, text/javascript, */*; q=0.01",
      "Referer"=>"https://app.intercom.io/a/apps/51a4564c6a008d823163382d7abbbbfff07ab03b/users/segments/all-users",
      "X-Requested-With"=>"XMLHttpRequest",
      "Connection"=>"keep-alive",
      "Cookie"=>"optimizelyEndUserId=oeu1426650217676r0.609937610803172; active_app_pricing=123679e4d4f1744e272c17de7a54603c51a4564c6a008d823163382d7abbbbfff07ab03b; _gauges_unique_year=1; _gauges_unique=1; anon_id=BAhJIilBRTY1QTFBMy0yMUNFLTRGRUUtOUU1RC02NUZDQ0U1QTJFRDMGOgZFVA%3D%3D--941b63f55c41668793949d67ff5ed2841ecc40d0; optimizelySegments=%7B%22187184848%22%3A%22false%22%2C%22187874316%22%3A%22referral%22%2C%22187879380%22%3A%22gc%22%7D; optimizelyBuckets=%7B%222490300871%22%3A%222524640228%22%7D; onboarding_email=vmk%40getmeed.com; mp_5b664a4558225267766f5b51246c7a79_mixpanel=%7B%22distinct_id%22%3A%20%2259564%22%2C%22%24initial_referrer%22%3A%20%22%24direct%22%2C%22%24initial_referring_domain%22%3A%20%22%24direct%22%2C%22__mps%22%3A%20%7B%7D%2C%22__mpso%22%3A%20%7B%7D%2C%22__mpa%22%3A%20%7B%7D%2C%22__mpu%22%3A%20%7B%7D%2C%22__mpap%22%3A%20%5B%5D%2C%22%24search_engine%22%3A%20%22google%22%7D; mp_3fe9800e028ca0883b50700f93c7fbc8_mixpanel=%7B%22distinct_id%22%3A%20%2214cbc02dae0fb-0a5f06cb8-32617703-fa000-14cbc02dae1196%22%2C%22%24search_engine%22%3A%20%22google%22%2C%22%24initial_referrer%22%3A%20%22https%3A%2F%2Fwww.google.com%2F%22%2C%22%24initial_referring_domain%22%3A%20%22www.google.com%22%7D; gtm_id=BAhJIik3YWJjMTg4MC04Y2VkLTQ2YTAtODQ5YS05YjJhN2RhYjAwMWYGOgZFVA%3D%3D--997c7a3465dc999d731215b7c776588d7e550b28; __insp_uid=2378108556; fs_uid=www.fullstory.com`R4ZV`4819036386885632:5629499534213120; fs_intercom=4819036386885632:5629499534213120; optimizelySegments=%7B%22187184848%22%3A%22false%22%2C%22187874316%22%3A%22referral%22%2C%22187879380%22%3A%22gc%22%7D; optimizelyBuckets=%7B%7D; intercom_tracker=7abc1880-8ced-46a0-849a-9b2a7dab001f; __insp_slim=1452227948827; __insp_wid=1340500707; __insp_nv=false; __insp_ref=d; __insp_targlpu=https%3A%2F%2Fwww.intercom.io%2F; __insp_targlpt=Customer%20Communication%20Platform%20%7C%20Intercom; __insp_norec_sess=true; _ga=GA1.2.835202248.1426650218; amplitude_idintercom.io=eyJkZXZpY2VJZCI6IjYzYmVhOWQ1LTBhOTctNDdmYy1iMjIzLThkMzEyMTBkNTg4NCIsInVzZXJJZCI6IjU5NTY0IiwiZ2xvYmFsVXNlclByb3BlcnRpZXMiOnsiYXBwX2lkIjoiNTFhNDU2NGM2YTAwOGQ4MjMxNjMzODJkN2FiYmJiZmZmMDdhYjAzYiJ9LCJvcHRPdXQiOmZhbHNlfQ==; __ar_v4=G3NH3TKNVVEIBI7546ABEV%3A20160101%3A30%7CG6LHS4DKLBDFZAQ3LE6NYG%3A20160101%3A30%7CNLJXKNEDOFCHPMAFCJALT5%3A20160101%3A30; intercom-id=650c6674-d288-4baa-a36e-84667dd17cb9; intercom-session-tx2p130c=OUJrd2Eza3pDSG1UTEJZSnIrUXRIRkNiaEFtZFVOWmR6aFpKZDNWVENydURSVVNoM1g2N25Jd0l5NklWUlY4Ti0tQmhzb3VRZG82Ujl4cDNuV1BaYmwyZz09--e4fd470126e7aad8431d7f9e856991abeed08320; active_app_pricing_model_name=51a4564c6a008d823163382d7abbbbfff07ab03b%3Ajobs_to_be_done_with_variable_costs; _intercom_session=dnJ1VDhDZ2hLcmM0eFg2RXh1Y2dYajZIU2czNUFQU3JGL09uZ0xJSFFZbzRja1dwWGtoa0UwMGNMWDZtS0QxeTZXZkE1YTNoSDN5YVlzMEJNbFdpMEFPSGZ4YzBFTGZCdXY3dm5OQmc5VVZXNTBLTllRYWluaHYwMzNmSldDL1ExRVpBY2lwN1NBRE15dU5kb0FMdCs1L0d3NWE4U0JITk5zMUtOd2pqc01XL01HRk1FVkpmZ0psTEtFQkV6RWhwMlk0R1h3ekYwMC84TXBqUDRxUEYvSUdHUXFBclVBU09IaEQ1QjEzUlBZUmlkZzNldGFvK0crK3ZWVmtvODE2dDRFZ015VXF6Z080NWE0UVBiVVFoUVI4YzRSS3JiOXk3V2RCRDljOVJEZDFrR0doVkd0c2dxeVI3Z0JnTnM5VDRpTEdEV0Z0TGROVUttSTRtV2NBL1d6dkEyaXU3TDVKVTl2M2dvNmJGS2xwOXEySzFaSTJrMkFIdlZsZXZTZUNhMnFqM3VMVnlleEgxSFJtZU8vWFJObWR0NDB1TmVqWmNtVkhwaFR6cXBzUkRReDNMWDZCZTl3V3hTZ3ZyZFgvL1hNZDlKTERnOVdOZk9GSXNmM3c3Mkt3RzNYTU1VWHE1WXhnc01Cb1M2V2o2TmxiVk4yczladmp5ZnFnYXh4djhSU01SVGNRU1pHallEMUpFSENsQVlmZEtUQ09Ca1MrcXJQT0VCSzI1K3RXSll2aGY1UE9seWl6STZNSFdCRG10Z2xzSTRFV3dlektNUGwyV1FlSzdmOXNLOVR6bE1raHFqcDFwbUtkWkJBd1YxMzYzT2laQjl4eWI0WkF1ZXZxNE0vTU9DWHozOHBKelM2V0R1bllUTFpEK0tVclk1cWRTUnlwRU9wVDlBL0E9LS1ZNkRLbG5yaEVIQlNvZVh2ZE1VYTVBPT0%3D--51d0a14ca5050585f26fb5cf9169da2513350502; _gat=1"
  }

  IntercomSignInHeaders = {
      'Origin' => 'https://app.intercom.io',
      'Accept-Encoding' => 'gzip, deflate',
      'Accept-Language' => 'en-US,en;q=0.8',
      'Upgrade-Insecure-Requests' => '1',
      'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.106 Safari/537.36',
      'Content-Type' => 'application/x-www-form-urlencoded',
      'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
      'Cache-Control' => 'max-age=0',
      'Referer' => 'https://app.intercom.io/admins/sign_in',
      'Connection' => 'keep-alive',
  }

  IntercomSearchUrl = 'https://app.intercom.io/ember/users/search.json'
  IntercomSignInUrl = 'https://app.intercom.io/admins/sign_in'


  def get_intercom_user(user)
    begin
     return IntercomClient.users.find(:email => user.id)
    rescue Exception => ex
      Rails.logger.error"Error updating intercom_user : #{ex}"
      return nil
    end
  end

  def update_intercom_user_state(user, user_state)
    iu_user = get_intercom_user(user)
    if iu_user.blank?
      return
    end
    if iu_user.user_id != user.handle
      iu_user.user_id = user.handle
    end
    if iu_user.signed_up_at != user[:create_dttm]
      iu_user.signed_up_at = user[:create_dttm]
    end
    if iu_user.name != user.name
      iu_user.name = user.name
    end

    custom_attributes = iu_user.custom_attributes

    custom_attributes.merge!({
      :state_profile_picture_blank => user_state.profile_picture_blank,
      :state_profile_complete => user_state.profile_complete,
      :state_last_profile_updated => user_state.last_profile_updated,
      :state_follow_collection_date => user_state.follow_collection_date,
      :state_create_collection_date => user_state.create_collection_date,
      :state_last_submission_date => user_state.last_submission_date,
      :state_last_upvote_receive_date => user_state.last_upvote_receive_date,
      :state_last_comment_receive_date => user_state.last_comment_receive_date,
      :state_last_follower_receive_date => user_state.last_follower_receive_date,
      :state_last_meed_points_date => user_state.last_meed_points_date,
      :state_last_portfolio_submission_date => user_state.last_portfolio_submission_date,
      :meed_points => user.meed_points,
      :meed_badge => user.badge
    })
    custom_attributes.delete_if {|k,v| v.blank?}
    iu_user.custom_attributes = custom_attributes
    IntercomClient.users.save(iu_user)
  end

  def add_intercom_user_attributes(user, attributes={})
    iu_user = get_intercom_user(user)
    if iu_user.blank?
      return
    end
    custom_attributes = iu_user.custom_attributes
    custom_attributes.merge!(attributes)
    custom_attributes.delete_if {|k,v| v.blank?}
    iu_user.custom_attributes = custom_attributes
    IntercomClient.users.save(iu_user)
  end

  def migrate_intercom_influencers
    users = User.where(:badge => 'influencer', :active => true).to_a
    users.each do |user|
      iu_user = get_intercom_user(user)
      if iu_user.blank?
        iu_user = create_intercom_user(user)
      end
      custom_attributes = iu_user.custom_attributes
      custom_attributes['badge'] = 'influencer'
      custom_attributes.delete_if {|k,v| v.blank?}
      iu_user.custom_attributes = custom_attributes
      IntercomClient.users.save(iu_user)
    end
  end

  def update_intercom_user(user, iu_user)
    if iu_user.user_id != user.handle
      iu_user.user_id = user.handle
    end
    if iu_user.signed_up_at != user[:create_dttm]
      iu_user.signed_up_at = user[:create_dttm]
    end
    if iu_user.name != user.name
      iu_user.name = user.name
    end
    major_type = get_major_type_from_major_id(user.major_id)
    major = get_major_by_code(user.major_id)
    profile = get_user_profile(user.handle)
    iu_user.custom_attributes = {
        :user_type => 'consumer',
        :major_id => user.major_id,
        :major => major.blank? ? '' : major.major,
        :major_type => major_type.blank? ? '' : major_type.name,
        :major_type_id => major_type.blank? ? '' : major_type.major_type_id,
        :degree => user.degree,
        :alumni => user.alumni,
        :year => user.year,
        :badge => (user.badge.eql? 'influencer') ? 'influencer' : 'student',
        :school => get_school_handle_from_email(user.id).titleize,
        :active => user.active,
        :profile_complete => profile.blank? ? false : !is_incomplete_profile(profile)
    }
    IntercomClient.users.save(iu_user)
  end

  def create_intercom_user(user, referrer = '')
    profile = get_user_profile(user.handle)
    begin
      major_type = get_major_type_from_major_id(user.major_id)
      major = get_major_by_code(user.major_id)
      intercom_user = IntercomClient.users.create(
          :user_id => user.handle,
          :email => user.id,
          :signed_up_at => user[:create_dttm],
          :name => user.name,
          :custom_attributes => {
              :user_type => 'consumer',
              :major_id => user.major_id,
              :major => major.blank? ? '' : major.major,
              :major_type => major_type.blank? ? '' : major_type.name,
              :major_type_id => major_type.blank? ? '' : major_type.major_type_id,
              :degree => user.degree,
              :referrer => referrer,
              :alumni => user.alumni,
              :year => user.year,
              :badge => (user.badge.eql? 'influencer') ? 'influencer' : 'student',
              :school => get_school_handle_from_email(user.id).titleize,
              :profile_complete => is_incomplete_profile(profile)
          }
      )
      IntercomClient.users.save(intercom_user)
    rescue
      intercom_user = nil
    end
    return intercom_user
  end

  def create_intercom_contact(user, referrer = '')
    begin
      intercom_contact = IntercomClient.contacts.find_all(email: user.id)
      if intercom_contact.count() > 0
        return intercom_contact[0]
      end
      major_id = user.major_id
      if major_id.blank?
        major_type = nil
      else
        major_type_id = Major.find(major_id)[:major_type_id]
        major_type = MajorType.find(major_type_id)
      end
      intercom_contact = IntercomClient.contacts.create(
          :email => user.id,
          :name => user.name.blank? ? '' : user.name,
          :custom_attributes => {
              :contact_type => 'consumer',
              :major => user.major_id.blank? ? '' : user.major_id,
              :degree => user.degree.blank? ? '' : user.degree,
              :alumni => user.alumni.blank? ? '' : user.alumni,
              :year => user.year.blank? ? '' : user.year,
              :school => get_school_handle_from_email(user.id).titleize,
              :major_type => major_type.blank? ? 'Not Available' : major_type.name,
              :first_name => user.first_name.blank? ? get_handle_from_email(user.id) : user.first_name,
              :last_name => user.last_name.blank? ? '' : user.last_name,
              :referrer => referrer
          }
      )
    rescue
      intercom_contact = nil
    end
    return intercom_contact
  end

  def tag_intercom_users(user_handles, tag_name)
    user_chunks = get_users_by_handles(user_handles).each_slice(20).to_a
    user_chunks.each do |chunk|
      chunk.each do |user|
        begin
          IntercomClient.tags.tag(name: tag_name, users: [{email: "#{user.id}"}])
        rescue Exception => ex
          puts("error resource not found: #{user.id}")
        end
      end
    end
  end

  def update_intercom_contact(user, referrer = nil)
    begin
      intercom_contact = IntercomClient.contacts.find_all(email: user.id)
      if intercom_contact.count() == 0
        return create_intercom_user(user, referrer)
      end
      major_id = user.major_id
      if major_id.blank?
        major_type = nil
      else
        major_type_id = Major.find(major_id)[:major_type_id]
        major_type = MajorType.find(major_type_id)
      end
      # creating a contact with user_id is going to update the contact
      intercom_contact = IntercomClient.contacts.create(
          :email => user.id,
          :user_id => intercom_contact.user_id,
          :name => user.name.blank? ? '' : user.name,
          :custom_attributes => {
              :contact_type => 'consumer',
              :major => user.major_id.blank? ? '' : user.major_id,
              :degree => user.degree.blank? ? '' : user.degree,
              :alumni => user.alumni.blank? ? '' : user.alumni,
              :year => user.year.blank? ? '' : user.year,
              :school => get_school_handle_from_email(user.id).titleize,
              :major_type => major_type.blank? ? 'Not Available' : major_type.name,
              :first_name => user.first_name.blank? ? get_handle_from_email(user.id) : user.first_name,
              :last_name => user.last_name.blank? ? '' : user.last_name,
              :referrer => referrer
          }
      );
    rescue
      intercom_contact = nil
    end
    return intercom_contact
  end

  def convert_intercom_contact_to_user(user, referrer = '')
    contact = IntercomClient.contacts.find_all(email: user.id)
    if contact.count() == 0
      return nil
    end
    contact = contact[0]
    if contact.blank?
      return
    end
    # Update the attribute for contact for Goal
    custom_attributes = contact.custom_attributes
    custom_attributes['contact-converted'] = true
    custom_attributes['badge'] = (user.badge.eql? 'influencer') ? 'influencer' : 'student'
    custom_attributes.delete_if {|k,v| v.blank?}
    IntercomClient.contacts.save(contact)

    # first create a intercom user
    iu_user = create_intercom_user(user, referrer)
    iu_user = IntercomClient.contacts.convert(contact, iu_user)

    return iu_user
  end

  def log_intercom_event(event_name, iu_user, metadata={})
    if iu_user.blank? || iu_user.user_id.blank?
      return
    end
    begin
      IntercomClient.events.create(
          :event_name => event_name,
          :created_at => Time.now.to_i,
          :email => iu_user.email,
          :metadata => metadata
      )
    rescue Exception => e
      logger.info('LogIntercomEvent - ' + e.message)
    end
  end

  # currently the ruby API doesn't support this call using curl to perform
  def log_contact_event(event_name, iu_contact, metadata={})
    auth = {:username => ENV['intercom_app_id'], :password => ENV['intercom_secret']}
    events_url = 'https://api.intercom.io/events'
    post_data = {
        "event_name" => event_name,
        "created_at"=> Time.now.to_i,
        "id" => iu_contact.id,
        "metadata"=> metadata
    }
    begin
      HTTParty.post(events_url, :basic_auth => auth, :headers => {'Accept' => 'application/json'}, :body => post_data)
    rescue Exception => e
      logger.info('LogIntercomContactEvent - ' + e.message)
    end
  end

  def get_csrf_token(response)
    doc = Nokogiri::HTML(response.body)
    return doc.at_xpath("//head/meta[@name='csrf-token']").attributes["content"].value
  end

  def intercom_get_authenticity_token()
    response = HTTParty.get(IntercomSignInUrl, :headers => IntercomHeaders)
    headers = response.headers
    IntercomSignInHeaders['Cookie'] = headers['set-cookie']
    return get_csrf_token(response)
  end

  def intercom_signin()
    # Intial CSRF Token
    IntercomSignInHeaders.delete("Cookie")
    results = HTTParty.get(IntercomSignInUrl, :headers => IntercomSignInHeaders)
    IntercomSignInHeaders['Cookie'] = results.headers['set-cookie']
    IntercomSignInHeaders['X-CSRF-Token'] = get_csrf_token(results)
    form_data = {
        "admin[email]" => "vmk@getmeed.com",
        "admin[password]" => "ManiKiran5*",
        "admin[remember_me]" => 1
    }
    token = intercom_get_authenticity_token()
    form_data["authenticity_token"] = token
    addressable = Addressable::URI.new
    addressable.query_values = form_data
    results = HTTParty.post(IntercomSignInUrl, :body => addressable.query, :headers => IntercomSignInHeaders);
    IntercomHeaders['Cookie'] = results.headers['set-cookie']
    IntercomHeaders['X-CSRF-Token'] = get_csrf_token(results)
  end

  def intercom_search_api(predicates, count = 10, retryLimit = 1)
    post_data = {
        "app_id"=>"51a4564c6a008d823163382d7abbbbfff07ab03b",
        "predicates" => [
            {"type" =>"or",
             "predicates" => [
                 {"type" => "and",
                  "predicates"=>[
                      {"type"=>"anonymous", "attribute"=>"anonymous", "comparison"=>"false", "value"=>"nil"},
                      {"type"=>"and",
                       "predicates"=>predicates
                      }
                  ]
                 },
                 {"type" => "and",
                  "predicates"=>[
                      {"type"=>"anonymous", "attribute"=>"anonymous", "comparison"=>"true", "value"=>"nil"},
                      {"type"=>"and",
                       "predicates"=>predicates
                      }
                  ]
                 }
             ]
            }
        ],
        "page"=>1,
        "per_page"=>count,
        "include_count"=>false,
        "use_intersearch"=>true
    }
    results = HTTParty.post(IntercomSearchUrl, :body => post_data.to_json, :headers => IntercomHeaders);
    if results.code != 200
      if retryLimit > 5
        Notifier.send_admin_message("Intercom Failed", "Intercom Search failed").deliver
      else
        # do a sign in again and retry
        intercom_signin()
        return intercom_search_api(predicates, count, retryLimit+1)
      end
    end
    return results
  end

  def search_lead_user_by_name(user, name)
    # construct the predicates
    predicates = []
    predicates.push({"attribute":"name","comparison":"contains","value":name,"type":"string"})
    # get school from user
    school = user.id.split('@')[1]
    predicates.push({"attribute":"email","comparison":"contains","value":"@#{school}","type":"string"})
    results = intercom_search_api(predicates, 10)
    return results["users"]
  end

  def search_lead_by_email(email)
    predicates = []
    predicates.push({'attribute':'email','comparison':'eq','value':"#{email}",'type':'string'})
    results = intercom_search_api(predicates, 1)
    return results["users"]
  end
end