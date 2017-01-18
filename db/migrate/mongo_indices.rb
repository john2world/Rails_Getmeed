use futura;

#feed
db.feed_items.ensureIndex({poster_id: 1})
db.feed_items.ensureIndex({create_time: 1})
db.feed_items.ensureIndex({privacy: 1})
db.feed_items.ensureIndex({poster_school: 1})
db.feed_items.ensureIndex({subject_id: 1})


#emails
db.email_invitation.ensureIndex({email: 1})


#kudos
db.kudos.ensureIndex({giver_handle: 1})
db.kudos.ensureIndex({feed_id: 1})

#jobs
db.job_apps.ensureIndex({handle: 1})
db.job_applicants.ensureIndex({job_id: 1})
db.job_applicants.ensureIndex({create_dttm: 1})
db.job_applicants.ensureIndex({handle: 1})
db.jobs.ensureIndex({company_id: 1})
db.jobs.ensureIndex({live: 1})



#users
db.users.ensureIndex({handle: 1})
db.users.ensureIndex({create_dttm: 1})
db.users.ensureIndex({active: 1})
db.users.ensureIndex({major_id: 1})


# Notifications
ConsumerNotification.index(:last_update_dttm => -1)
ConsumerNotification.create_indexes




