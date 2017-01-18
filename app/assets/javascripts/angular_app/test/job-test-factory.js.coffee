JobTestFactory = (MeedApiFactory) ->
  fixed = () ->
    id: "5214b5b83f3f35224a000001"
    slug: "asdlkfjasdlf"
    companyLogoUrl: "http://lorempixel.com/output/cats-q-c-50-50-1.jpg"
    title: "Banjoz"
    type: "fulltime"
    location: "San Francisco, CA, United States"
    companySlug: "google"
    timestamp: "2015-07-04T09:24:17Z"
    status: "not applied"
    companyName: "Cool Co."
    companyVideos: [
      "http://vimeo.com/12309423"
    ]
    companyPhotos: [
      {
        large_image_url: "http://lorempixel.com/output/cats-q-c-640-480-5.jpg"
        description: "Cool cats"
      }
    ]
    question: {
      id: 123
      title: "question title"
      description: "question description"
      is_coding: true
      code_types: [
        {
          display_id: "Ruby"
          file_ext: ".rb"
        }
        {
          display_id: "Javascript"
          file_ext: ".js"
        }
      ]
    }
    is_valid: true # Might have to do logic on this
    companyOverview: "The path of the righteous man is beset on all sides by the inequities of the selfish and the tyranny of evil men. Blessed is he, who in the name of charity and good will, shepherds the weak through the valley of darkness, for he is truly his brother's keeper and the finder of lost children. And I will strike down upon thee with great vengeance and furious anger those who would attempt to poison and destroy my brothers. And you will know my name is the Lord when I lay my vengeance upon thee."
    description: "
      <p>We are currently looking for highly ambitious, creative, fun, and outgoing people to serve as our Social Media Interns for 5-8 weeks starting in early May. We want to change how students connect with startups by making the process streamlined and simple for our users.</p>

      <p><strong>Duties and Responsibilities include:</strong></p>

      <ul>
        <li>Represent Meed and our values on social media for your campus.</li>

        <li>Demonstrate enthusiasm around Meed in a persuasive manner.</li>

        <li>Post social media content in relevant student and academic groups.</li>

        <li>We will provide content but you will also have the opportunity to write your own posts!</li>
      </ul>

      <p><strong>Benefits:</strong></p>

      <ul>
        <li>We pay!</li>

        <li>We are a career platform so we are able to connect our social media interns with the best startups for summer internships and post-grad full time work.</li>

        <li>Opportunity to become a business development interns in the fall semester!</li>

        <li>Learn about social media marketing with one on one mentorship.</li>

        <li>Work in close proximity with fast growing start-ups.</li>

        <li>Flexible Hours</li>
      </ul>

      <p><strong>Qualifications:</strong></p>

      <ol>
        <li>Energetic, creative, and outgoing with strong social media skills</li>

        <li>Be involved on your campus! (Business clubs, Greek Life, Student Cooperatives, Technology Organizations, Student Government, Band, Community Service, etc.)</li>

        <li>Currently enrolled in school.</li>
      </ol>
      "

  return {
    fixed: fixed
  }

JobTestFactory.$inject = [
  "MeedApiFactory"
]

angular.module("meed").factory "JobTestFactory", JobTestFactory
