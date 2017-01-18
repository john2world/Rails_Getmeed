class MessagesService
  def self.new_message_to_user(sender, recipient_handle, subject, body, job_id, message_type = nil)
    user = User.find_by(handle: recipient_handle)
    if user.blank?
      return false
    end

    if sender.id.eql? user.id
      return false
    end

    if job_id
      job = Job.find job_id
      body = "#{body} \n \n Apply here:
                          #{job.job_url} #{job.title}"
    end

    message = Message.create(
      email: user.id,
      from_email: sender[:_id],
      handle: user.handle,
      subject: subject,
      body: body,
      status: 'new',
      posted_dttm: Time.zone.now
    )

    user_messages = UserMessages.find_or_create_by(handle: user[:handle])
    user_messages.push(:message_ids, message[:_id])
    user_messages.save

    #send only direct messages. All job_invitations are handled in worker.
    # send email to user
    Notifier.email_message_to_user(user, message, sender, job, message_type).deliver
    message
  end
end
