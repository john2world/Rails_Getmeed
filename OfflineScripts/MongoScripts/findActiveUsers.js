conn = new Mongo();
db = conn.getDB("futura");
db.users.find({active:true}).forEach(function(doc){print(doc.email+","+doc.first_name+","+doc.last_name)});
