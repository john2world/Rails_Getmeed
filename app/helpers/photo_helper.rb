module PhotoHelper

  def get_cloudinary_image_id(url)
    if url.blank?
      return ''
    end
    splits = url.split('resume/image/upload')
    if splits.blank? or splits.length <= 1
      return url
    end
    further_splits = splits[1].split('/')
    if further_splits.blank?
      return url
    end
    further_splits[further_splits.length - 1]
  end


  def filepicker_profile_crop(url)
    if url.blank?
      return url
    end

    if url.include? 'convert'
      return url
    end
    "#{url}/convert?w=100"
  end

  def filepicker_tiny_url_crop(url)
    if url.blank?
      return url
    end

    if url.include? 'convert'
      return url
    end
    "#{url}/convert?w=100"
  end

  def filepicker_medium_url_crop(url)
    if url.blank?
      return url
    end

    if url.include? 'convert'
      return url
    end
    "#{url}/convert?w=400"
  end

  def convert_filepicker_small_url(url)
    if url.blank?
      return url
    end

    if url.include? 'convert'
      return "#{url.split('convert')[0]}convert?w=40"
    else
      return url
    end
  end

  def filepicker_small_url_crop(url)
    if url.include? 'convert'
      return url
    end
    "#{url}/convert?w=200"
  end

  def filepicker_id(url)
    if url.blank? or !url.include? 'filepicker'
      return ''
    end
    splits = url.split('api/file/')
    if splits.blank? or splits.length <= 1
      splits = url.split('api/preview/')
      if splits.blank? or splits.length <= 1
        return url
      end
    end
    splits[splits.length - 1]
  end

end
