db.feed_items.ensureIndex({privacy: 1})
db.feed_items.ensureIndex({poster_id: 1})
db.feed_items.dropIndex( {'feed_key' : 1 } )
db.feed_items.dropIndex( {'subject_id' : 1 } )
