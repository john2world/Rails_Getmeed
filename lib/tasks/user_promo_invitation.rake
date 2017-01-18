#should go out once in every two weeks
namespace :user_promo_invitation do
  task send_user_promo_invitation: :environment do
    User.where(:active => true).to_a.each do |user|
      if user[:handle].blank?
        next
      end
      school_handle = get_school_handle_from_email(user.id)
      if school_handle.eql? 'illinois' or school_handle.eql? 'gatech' or school_handle.eql? 'rice' or school_handle.eql? 'ufl'
        EmailUserPromoWorker.perform_async(user.id)
      end
    end
  end
end

def get_school_handle_from_email(email)
  unless email.blank?
    email_parts = email.split('@')
    school_prefix = email_parts[1]
    if school_prefix.blank? || school_prefix.nil?
      return ''
    end
    edu_splits = school_prefix.split('.')
    return edu_splits[edu_splits.length - 2]
  end
  ''
end
