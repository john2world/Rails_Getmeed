// Script that computes the unique set of skills from user table and also generate the counts for popularity

conn = new Mongo();
db = conn.getDB("futura");

var sanitize_skill = function (skill){
  skill = skill.toLowerCase();
  skill = skill.trim();
  return skill;
};


var get_skills = function() {
   if (this.skills != undefined){
     local_skills = this.skills.split(",");
     for(var i in local_skills) {
       skill = sanitize_skill(local_skills[i]);
       if(skill){
         emit(skill, 1);
       }
    }
  }
};

var merge_skills = function(key, values){
  return Array.sum(values);
};

final_skills = []
final_skills = final_skills.concat(db.user_works.mapReduce(get_skills, merge_skills, {out: {inline: 1}, query: {skills: {$exists:true}}, scope: {"sanitize_skill": sanitize_skill}}).results);
final_skills = final_skills.concat(db.user_courses.mapReduce(get_skills, merge_skills, {out: {inline: 1}, query: {skills: {$exists:true}}, scope: {"sanitize_skill": sanitize_skill}}).results);
final_skills = final_skills.concat(db.user_internships.mapReduce(get_skills, merge_skills, {out: {inline: 1}, query: {skills: {$exists:true}}, scope: {"sanitize_skill": sanitize_skill}}).results);
var skills_final_count = final_skills.reduce(function(prev,item){
                                                                 if(item._id in prev) prev[item._id] += item.value;
                                                                 else prev[item._id] = item.value;
                                                                 return prev;
                                                                 }, {});
for(skill in skills_final_count) {
  print(skill+"\t"+skills_final_count[skill]);
}
