require 'logger'

Rails.application.config.middleware.use OmniAuth::Builder do
  begin
    OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
    provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET'], {
                         :secure_image_url => 'true',
                         :image_size => 'original',
                     }
    provider :linkedin, ENV['linkedin_client_id'], ENV['linkedin_client_secret'], :scope => 'r_basicprofile r_emailaddress'
    provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'], scope: 'user,repo,gist'

    Rails.logger.info "Finished initializing omniauth"
  rescue Exception => ex
    Rails.logger.error "Error loading OmniOauth: #{ex}"
  end

end