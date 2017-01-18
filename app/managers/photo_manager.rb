module PhotoManager
  MIN_WIDTH = 500
  MEDIUM_WIDTH = 250
  SMALL_WIDTH = 150
  TINY_WIDTH = 40
  LITTLE_WIDTH = 25

  DEFAULT_CLOUDINARY_IDS = %w(Screen_Shot_2015-09-04_at_12.30.49_AM_najre6.png Screen_Shot_2015-09-04_at_12.26.34_AM_yvzezq.png cvwgu5w8mvmbzbcxok56.png latest_gkfrrs.png Screen_Shot_2015-09-04_at_12.28.08_AM_shdjua.png Screen_Shot_2015-09-04_at_12.22.53_AM_aginiy.png PSD_eruyyd.png Screen_Shot_2015-09-04_at_12.30.49_AM_najre6.png Screen_Shot_2015-09-04_at_12.31.43_AM_onyo9n.png)
  include PhotoHelper
  include LinkHelper
  YOUTUBE_IMAGE = 'http://i1.ytimg.com/vi/'
  MAX_DEF_THUMB = '/maxresdefault.jpg'
  DEFAULT_THUMB = '/0.jpg'
  CLOUDINARY_PREFIX_HTTPS = 'https://res.cloudinary.com/resume/image/upload'
  CLOUDINARY_PREFIX_HTTP = 'http://res.cloudinary.com/resume/image/upload'
  CLOUDINARY_PREFIX = 'res.cloudinary.com/resume/image/upload'

  def downloadalbe_format(format)
    if %w(ppt pptx doc docx pdf txt).include? format
      return true
    end
    false
  end

  def get_cloudinary_facial_image_url(handle, url)
    if url.include? 'filepicker'
      url = url.split('/convert?')[0]
    end

    if url.include? 'cloudinary'
      image_id = get_cloudinary_image_id(url)
      #http://res.cloudinary.com/demo/image/upload/w_90,h_90,c_thumb,g_face/butterfly.jpg
      return "#{CLOUDINARY_PREFIX_HTTPS}/w_#{TINY_WIDTH},h_#{TINY_WIDTH},c_thumb,g_face/#{image_id}"
    end
    begin
      upload_hash = Cloudinary::Uploader.upload(url,
                                                :crop => :thumb, :width => TINY_WIDTH, :height => TINY_WIDTH, :gravity => :face,
                                                :tags => ['profile_picture', handle], :secure => true)
      return upload_hash['secure_url']
    end
  rescue Exception => ex
    return url
  end

  def get_cloudinary_large_image_url(handle, url)
    if url.include? 'filepicker' and !url.include? 'crop'
      url = url.split('/convert?')[0]
    end

    if url.include? 'cloudinary'
      image_id = get_cloudinary_image_id(url)
      #http://res.cloudinary.com/demo/image/upload/w_90,h_90,c_thumb,g_face/butterfly.jpg
      return "#{CLOUDINARY_PREFIX_HTTPS}/w_#{SMALL_WIDTH},c_fit/#{image_id}"
    end
    begin
      upload_hash = Cloudinary::Uploader.upload(url,
                                                :crop => :fit, :width => SMALL_WIDTH,
                                                :tags => ['profile_picture_large', handle], :secure => true)
      return upload_hash['secure_url']
    end
  rescue Exception => ex
    return url
  end

  # converts any url to clodunary url so if the url is deleted cloudrinary backsoff
  def convert_to_cloudinary(url, width, height, tag="")
    if url.blank?
      return nil
    end
    upload_hash = Cloudinary::Uploader.upload(url,
                                              :crop => :fit, :height => height, :width => width, :radius => 6,
                                              :eager => [
                                                  {:width => height/2, :height => width/2,
                                                   :crop => :fit,
                                                   :radius => 6},
                                                  {:width => 150, :height => 150,
                                                   :radius => 6,
                                                   :crop => :fit, :format => 'png'}
                                              ],
                                              :tags => ['blog', tag])
    return upload_hash['secure_url']
  end


  def get_doc_thumbnail_for_type(type)
    if type.include? 'ppt' or type.include? 'pptx' or type.include? 'presentation'
      return 'https://res.cloudinary.com/resume/image/upload/c_scale,w_50/v1441351620/Screen_Shot_2015-09-04_at_12.26.34_AM_yvzezq.png'
    elsif type.include? 'xls' or type.include? 'xlsx' or type.include? 'sheet'
      return 'https://res.cloudinary.com/resume/image/upload/c_scale,w_50/v1441351704/Screen_Shot_2015-09-04_at_12.28.08_AM_shdjua.png'
    elsif type.include? 'document' or type.include? 'docx'
      return 'https://res.cloudinary.com/resume/image/upload/c_scale,w_50/v1441351429/Screen_Shot_2015-09-04_at_12.22.53_AM_aginiy.png'
    elsif type.include? 'psd'
      return 'https://res.cloudinary.com/resume/image/upload/c_scale,w_50/v1441152508/PSD_eruyyd.png'
    elsif type.include? 'pdf'
      return 'https://res.cloudinary.com/resume/image/upload/c_scale,w_50/v1441351865/Screen_Shot_2015-09-04_at_12.30.49_AM_najre6.png'
    elsif type.include? 'zip'
      return 'https://res.cloudinary.com/resume/image/upload/c_scale,w_50/v1441351923/Screen_Shot_2015-09-04_at_12.31.43_AM_onyo9n.png'
    else
      codes = CodeType.all
      codes.each do |code|
        if code.file_ext.include? type
          return 'https://res.cloudinary.com/resume/image/upload/c_scale,w_50/v1441352556/Screen_Shot_2015-09-04_at_12.42.11_AM_rxygpe.png'
        end
      end
      'https://res.cloudinary.com/resume/image/upload/c_scale,w_50/v1451955244/latest_gkfrrs.png'
    end
  end

  def is_previewable_format(type)
    %w(ppt pptx presentation xls xlsx sheet document doc docx psd pdf).each do |format|
      if !type.blank? and type.include? format
        return true
      end
    end
    false
  end

  def migrate
    feed_items = []
    feed_items.each do |feed_item|
      feed_item.small_image_url = 'https://res.cloudinary.com/resume/image/upload/c_scale,w_50/v1451955244/latest_gkfrrs.png'
      feed_item.medium_image_url = 'https://res.cloudinary.com/resume/image/upload/c_scale,w_100/v1451955244/latest_gkfrrs.png'
      feed_item.large_image_url = 'https://res.cloudinary.com/resume/image/upload/c_scale,w_200/v1451955244/latest_gkfrrs.png'
      begin
        feed_item.save
      rescue Exception => ex
      end
    end
  end

  def get_hd_youtube_image_url(video_id)
    max_def_url = "#{YOUTUBE_IMAGE}#{video_id}#{MAX_DEF_THUMB}"
    standard_def_url = "#{YOUTUBE_IMAGE}#{video_id}#{DEFAULT_THUMB}"
    obj = nil
    begin
      embedly_api =
          Embedly::API.new :key => ENV['embedly_key'], :user_agent => 'Mozilla/5.0 (compatible; mytestapp/1.0; ravi@resu.me)'
      obj = embedly_api.extract :url => max_def_url
    rescue
      return standard_def_url
    end


    if obj.blank?
      return nil
    end

    json_hash = obj[0].marshal_dump
    if json_hash.blank?
      return nil
    end

    unless json_hash[:error_code].blank?
      embedly_api =
          Embedly::API.new :key => ENV['embedly_key'], :user_agent => 'Mozilla/5.0 (compatible; mytestapp/1.0; ravi@resu.me)'
      obj = embedly_api.extract :url => standard_def_url
      if obj.blank?
        return standard_def_url
      end

      json_hash = obj[0].marshal_dump
    end

    if json_hash.blank?
      return standard_def_url
    end

    if json_hash[:images].blank? or json_hash[:images][0].blank?
      return standard_def_url
    end

    width = json_hash[:images][0][:width.to_s]
    height = json_hash[:images][0][:height.to_s]

    begin
      if width < MIN_WIDTH or height < MIN_WIDTH
        max_def_url = standard_def_url
        height = height * 3
        width = width * 3
      end

      upload_hash = Cloudinary::Uploader.upload(max_def_url,
                                                :crop => :fit, :height => height, :width => width, :radius => 6,
                                                :eager => [
                                                    {:width => height/2, :height => width/2,
                                                     :crop => :fit,
                                                     :radius => 6},
                                                    {:width => 150, :height => 150,
                                                     :radius => 6,
                                                     :crop => :fit, :format => 'png'}
                                                ],
                                                :tags => ['blog', video_id])
      return upload_hash['secure_url']
    end
  rescue
    return standard_def_url
  end

  def stuff_feed_image_sizes(feed_item)
    unless feed_item.large_image_url.blank?
      cloudinary_image_id = get_cloudinary_image_id(feed_item.large_image_url)
      if cloudinary_image_id.blank?
        return
      end

      if DEFAULT_CLOUDINARY_IDS.include? cloudinary_image_id
        medium_url = Cloudinary::Utils.cloudinary_url(cloudinary_image_id, {:crop => :fit, :width => TINY_WIDTH, :radius => 6, :secure => true})
        small_url = Cloudinary::Utils.cloudinary_url(cloudinary_image_id, {:crop => :fit, :width => TINY_WIDTH, :radius => 6, :secure => true})
        feed_item.small_image_url = small_url
        feed_item.medium_image_url = medium_url
        return
      end

      medium_url = Cloudinary::Utils.cloudinary_url(cloudinary_image_id, {:crop => :fit, :width => MEDIUM_WIDTH, :radius => 6, :secure => true})
      small_url = Cloudinary::Utils.cloudinary_url(cloudinary_image_id, {:crop => :fit, :width => SMALL_WIDTH, :radius => 6, :secure => true})
      feed_item.small_image_url = small_url
      feed_item.medium_image_url = medium_url
    end
  end

  def stuff_feed_image_sizes_save(feed_item)
    unless feed_item.large_image_url.blank?
      cloudinary_image_id = get_cloudinary_image_id(feed_item.large_image_url)
      if cloudinary_image_id.blank?
        return
      end
      medium_url = Cloudinary::Utils.cloudinary_url(cloudinary_image_id, {:crop => :fit, :width => MEDIUM_WIDTH, :radius => 6, :secure => true})
      small_url = Cloudinary::Utils.cloudinary_url(cloudinary_image_id, {:crop => :fit, :width => SMALL_WIDTH, :radius => 6, :secure => true})
      feed_item.small_image_url = small_url
      feed_item.medium_image_url = medium_url
      begin
        feed_item.save
      rescue Exception => ex
      end
    end
  end

  def upload_photo(url, width, height, object_id, type)
    begin
      if width < MIN_WIDTH or height < MIN_WIDTH
        width = width * 2
        height = height * 2
      end

      upload_hash = Cloudinary::Uploader.upload(url,
                                                :crop => :fit, :height => height, :width => width, :radius => 6,
                                                :eager => [
                                                    {:width => height/2, :height => width/2,
                                                     :crop => :fit,
                                                     :radius => 6},
                                                    {:width => 150, :height => 150,
                                                     :radius => 6,
                                                     :crop => :fit, :format => 'png'}
                                                ],
                                                :tags => ['blog', object_id.truncate(50, :omission => '..')])
      large_image_url = upload_hash['secure_url']
      small_image_url = upload_hash['eager'][0]['url']
      square_image_url = upload_hash['eager'][1]['url']
      photo = Photo.new
      photo.large_image_url = large_image_url
      photo.medium_image_url = small_image_url
      photo.square_image_url = square_image_url
      photo.subject_id = object_id
      photo.type = type
      photo.save
      return photo
    end
  rescue
    return nil
  end

  def upload_photo_file(file_path, width, height, object_id, type)
    begin
      crop_type = 'fit'
      if type.eql? 'article_photo'
        crop_type = 'scale'
      end

      upload_hash = Cloudinary::Uploader.upload(file_path,
                                                :crop => :fit, :height => height, :width => width, :radius => 6,
                                                :eager => [
                                                    {:width => height/2, :height => width/2,
                                                     :crop => crop_type,
                                                     :radius => 6},
                                                    {:width => 150, :height => 150,
                                                     :radius => 6,
                                                     :crop => crop_type, :format => 'png'}
                                                ],
                                                :tags => ['blog', object_id.truncate(50, :omission => '..')], :secure => true)
      large_image_url = upload_hash['secure_url']
      small_image_url = upload_hash['eager'][0]['url']
      square_image_url = upload_hash['eager'][1]['url']
      photo = Photo.new
      photo.large_image_url = large_image_url
      photo.medium_image_url = small_image_url
      photo.square_image_url = square_image_url
      photo.subject_id = object_id
      photo.type = type
      photo.save
      return photo
    end
  rescue Exception => ex
    return nil
  end

  def get_photo(id)
    Photo.find(id)
  end

  def get_photos_by_ids(ids)

    if ids.blank?
      return Array.[]
    end
    ids.compact!
    Photo.find(ids)
  end

  def stuff_image_scrape(scrape_data, data, image_url, external_image)

    unless external_image
      scrape_data.large_image_url = image_url
      scrape_data.medium_image_url = image_url
      scrape_data.small_image_url = image_url
      return
    end
    image_height = 400
    image_width = 400
    if image_url.blank?
      if data[:images].blank?
        if data[:thumbnail_url].blank?
          image_url = data[:url]
        else
          image_url = data[:thumbnail_url]
          image_height = data[:thumbnail_height]
          image_width = data[:thumbnail_width]
        end
      else
        image_url = data[:images][0]['url']
        image_height = data[:images][0]['height']
        image_width = data[:images][0]['width']
      end
    end


    if image_height <= 500 or image_width <= 500
      image_height = image_height * 2
      image_width = image_width * 2
    end

    begin
      upload_hash = Cloudinary::Uploader.upload(image_url,
                                                :crop => :fit, :height => image_height, :width => image_width, :radius => 6,
                                                :eager => [
                                                    {:width => image_height/2, :height => image_width/2,
                                                     :crop => :fit,
                                                     :radius => 6},
                                                    {:width => 150, :height => 150,
                                                     :radius => 6,
                                                     :crop => :fit, :format => 'png'}
                                                ],
                                                :tags => ['blog', data[:url]], :secure => true)
      scrape_data.large_image_url = upload_hash['secure_url']
      scrape_data.medium_image_url = upload_hash['eager'][0]['secure_url']
      scrape_data.small_image_url = upload_hash['eager'][1]['secure_url']
    rescue Exception => ex

    end

  end

  def get_place_holder_image_url(text, height, width, bgcolor='222', textcolor='fff')
    colors = %w(0f3353 00a651 ff59ac 6872ff 6872ff)
    "https://dummyimage.com/#{width}x#{height}/#{colors.sample}/#{textcolor}&text=#{text}"
  end

end