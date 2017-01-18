conn = new Mongo();
db = conn.getDB("futura");
db.users.find({},{email:1,_id:0}).forEach(function(doc){var args = doc.email.split("@"); print(args[1]);})
