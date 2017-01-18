class JobStatusType
  def JobStatusType.add_item(key, value)
    @hash ||= {}
    @hash[key]=value
  end

  def JobStatusType.const_missing(key)
    @hash[key]
  end

  def JobStatusType.contains(constant)
    @hash.each { |key, value| constant.eql? key }
  end

  def JobStatusType.each
    @hash.each { |key, value| yield(key, value) }
  end

  JobStatusType.add_item :VIEWED, 1
  JobStatusType.add_item :STARRED, 2
  JobStatusType.add_item :CONTACT, 3
  JobStatusType.add_item :INTERVIEW, 4
  JobStatusType.add_item :OFFER, 5
  JobStatusType.add_item :ACCEPTED, 6
  JobStatusType.add_item :DECLINED, 7
  JobStatusType.add_item :ARCHIVE, 8
end
