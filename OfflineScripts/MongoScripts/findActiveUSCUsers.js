conn = new Mongo();
db = conn.getDB("futura");
db.users.find({active:true,email:{$regex: '.*@usc.edu'}}).forEach(function(doc){print(doc.email+","+doc.first_name+","+doc.last_name)});
