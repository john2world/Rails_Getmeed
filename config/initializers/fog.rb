#
#CarrierWave.configure do |config|
#      config.storage = :fog
#      config.fog_credentials = {
#          :provider => 'AWS',
#          :aws_access_key_id => ENV['aws_access_key_id'],
#          :aws_secret_access_key => ENV['aws_secret_access_key'],
#          :region => 'us-west-1',
#          #:host => 'https://s3-us-west-1.amazonaws.com/resumeuploads',
#          #:endpoint => 'https://s3-us-west-1.amazonaws.com/resumehandle'
#      }
#
#      config.fog_directory = 'resumehandle'
#      #config.fog_public = false
#      config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}
#    end
