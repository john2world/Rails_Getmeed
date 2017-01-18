module MessagesHelper
  include CommonHelper
  
  def get_reply_message_string(message)
    if message.blank?
      return
    end
    # adding new line and a border
    reply_message = "-"*100 + "\n" + message
    reply_message = "\n\n" + reply_message
    # replace <br/> lines with new lines
    reply_message = reply_message.gsub("\n", "<br/>")
    #reply_message = reply_message.gsub("\n", "<br>")
    # adding extra new lines on top
    reply_message
  end

  def get_message_string(message)
    if message.blank?
      return
    end
    # adding new line and a border
    reply_message = message.gsub("\n", "<br/>")
    reply_message = reply_message.gsub("\n", "<br>")
    # adding extra new lines on top
    reply_message
  end
  

end