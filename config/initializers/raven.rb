require 'raven'
require 'logger'

if Rails.env.downcase == "production"
  begin
    Raven.configure do |config|
      config.dsn = 'https://9646730815d54262af2336b023256cf8:d5080752bb9b4435a9626a71a85e1a5b@app.getsentry.com/22552'
    end
    Rails.logger.info "Finished initializing raven"
  rescue Exception => ex
    Rails.logger.error "Error initializing raven: #{ex}"
  end

end
