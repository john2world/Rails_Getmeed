include PhotoHelper
User.where(:image_url.ne => nil).each do |user|
  if user[:image_url].starts_with? 'https://media.licdn.com'
    begin
      new_url = convert_to_cloudinary(user[:image_url], 75, 75, user[:handle])
      unless new_url.blank?
        user[:image_url] = new_url
      end
    rescue Exception => ex
      user[:image_url] = nil
    end
    user.save()
  end
end