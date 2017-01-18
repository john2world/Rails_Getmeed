# Simple service for retrieving job feed for the main dashboard
JobFeedTestFactory = (MeedApiFactory) ->
  fixed = () ->
    [
      {
        '_id': '534ad02bf2521a0c700000a8'
        'applied': true
        'company': 'Kabam'
        'company_id': 'kabam'
        'company_logo': 'http://res.cloudinary.com/resume/image/upload/v1400130020/hdrlvhvqowgspinhf6lo.png'
        'company_overview': null
        'compensation': null
        'create_dttm': '2014-11-13'
        'create_time': '2014-11-13T00:00:00Z'
        'culture_video_id': null
        'culture_video_type': null
        'culture_video_url': null
        'delete_dttm': null
        'description': '<br>Kabam is the leader in the western world for free-to-play core games with 1st and 3rd party published titles available on mobile devices via the Apple Store, Google Play and on the Web via Facebook, Yahoo, Kabam.com and other leading platforms. In 2013 Kabam revenues grew by 100 percent to more than $360 million. Kabam has 800 employees across three continents, with corporate headquarters in San Francisco. The company\'s investors include Google, Warner Brothers, MGM, SK Telecom, Intel, Canaan '
        'email_notifications': true
        'emails': []
        'external_id': '233929'
        'hash': 'XWY6fo7j3Ddvmlrc'
        'job_req_id': null
        'job_url': 'http://localhost:3000/job/XWY6fo7j3Ddvmlrc'
        'live': true
        'location': 'San Francisco, CA, US'
        'manual_boost': 0
        'meed_share': 0
        'post_date': '2014-04-12T00:00:00+00:00'
        'question_id': null
        'skills': []
        'source': 'VentureLoop'
        'status': null
        'title': 'Software Engineer - Unity 3D'
        'type': 'full_time_entry_level'
      }
    ]

  return {
    fixed: fixed
  }

JobFeedTestFactory.$inject = [
  "MeedApiFactory"
]

angular.module("meed").factory "JobFeedTestFactory", JobFeedTestFactory
