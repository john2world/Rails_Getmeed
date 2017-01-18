// script that computes the popularity of courses by company
// The courses related to the company are obtained by the people who applied to the company

conn = new Mongo();
db = conn.getDB("futura");

function onlyUnique(value, index, self) {
  return self.indexOf(value) === index;
}

var GetEducationInformation = function(edu_id){
  return db.user_educations.findOne({_id: edu_id});
}

var GetEducationYears = function(edu_id){
  edu = GetEducationInformation(edu_id);
  return (edu.end_year - edu.start_year);
}

var GetInternshipInformation = function(intern_id){
  return db.user_internships.findOne({_id: intern_id});
}
var GetInternDurationMonths = function(intern){
  var timeDiff = Date.parse(intern.end_month + " " +intern.end_year) - Date.parse(intern.start_month + " " + intern.start_year);
  return Math.floor(timeDiff/(30*24*3600*1000));
}
var GetInternSkills = function(intern){
  return intern.skills.split(",");
}

var GetWorkInformation = function(work_id) {
  return db.user_works.findOne({_id: work_id});
}
var GetSkills = function(obj){
  if((!obj.skills) || obj.skills.length == 0) {
	return [];
  }
  return obj.skills.split(/\s*,\s*/);
}
var GetWorkDurationMonths = function(workExp){
  var startDate = Date.parse(workExp.start_month +" "+workExp.start_year);
  if(!workExp.end_year)
  {
    var endDate = Date.now();
  }
  else
  {
    var endDate = Date.parse(workExp.end_month + " " +workExp.end_year);
  }
  timeDiff = endDate-startDate;
  return Math.floor(timeDiff/(30*24*3600*1000));
}
var SanitizeGpa = function(gpa){
  if (!gpa) { return null; }
  var matches = gpa.toString().match(/\d+\.\d*/);
  if((matches != null) && (matches.length > 0)) {
    return parseFloat(matches[0]);
  }
  else {
    return null;  
  }
}
var GetProfileInformation = function(user){
    profile = db.profiles.findOne({handle: user.handle})
    objective_present = (!profile.objective)? 0 : 1
    internships = (!profile.user_internship_ids)? null : profile.user_internship_ids.map(GetInternshipInformation)
    workExps = (!profile.user_work_ids)? null: profile.user_work_ids.map(GetWorkInformation)
    educations = (!profile.user_edu_ids)? null : profile.user_edu_ids.map(GetEducationInformation);
    mailParts = user._id.split("@")[1].split(".") 
    return { 
	handle: user.handle,
        school: mailParts[mailParts.length -2], 
	objective: (!profile.objective)? 0 : 1, 
	workExp_count: (!workExps || workExps.length == 0)? 0 : workExps.length, 
	workExp_duration: (!workExps || workExps.length == 0)? 0: Array.sum(workExps.map(GetWorkDurationMonths)),
   	workExp_skillCount: (!workExps || workExps.length == 0)? 0: workExps.map(GetSkills).reduce(function(a,b){return [].concat(a,b);}).filter(onlyUnique).length,
	internship_count: (!internships || internships.length == 0)? 0 : internships.length,
        internship_duration: (!internships || internships.length == 0)? 0: Array.sum(internships.map(GetWorkDurationMonths)),
        internship_skillCount: (!internships || internships.length == 0)? 0: internships.map(GetSkills).reduce(function(a,b){return [].concat(a,b);}).filter(onlyUnique).length, 
	pub_count: (!profile.user_publication_ids || profile.user_publication_ids.length == 0)? 0 : profile.user_publication_ids.length, 
	courses_count: (!profile.user_course_ids || profile.user_course_ids.length == 0)? 0 : profile.user_course_ids.length, 
	edu_years: (!profile.user_edu_ids || profile.user_edu_ids.length == 0)? 0 : Array.sum(profile.user_edu_ids.map(GetEducationYears)),
	gpa: SanitizeGpa(user.gpa)
	};
}
//db.users.find({active:true,email:{$regex: '.*@usc.edu'}}).forEach(function(doc){print(doc.email+","+doc.first_name+","+doc.last_name)});

var profiles = db.users.find({active:true}, {handle: 1, gpa: 1}).map(function(doc){return GetProfileInformation(doc)});
objective_stats = {}
workExp_count_stats = {}
workExp_duration_stats = {}
workExp_skillCount_stats = {}
internship_count_stats = {}
internship_duration_stats = {}
internship_skillCount_stats = {}
pub_count_stats = {}
courses_count_stats = {}
edu_years_stats = {}
gpa_stats = {}
for (var i in profiles) {
  if(!(profiles[i].school in objective_stats)) {
    objective_stats[profiles[i].school] = [];
    workExp_count_stats[profiles[i].school] = [];
    workExp_duration_stats[profiles[i].school] = [];
    workExp_skillCount_stats[profiles[i].school] = [];
    internship_count_stats[profiles[i].school] = [];
    internship_duration_stats[profiles[i].school] = [];
    internship_skillCount_stats[profiles[i].school] = [];
    pub_count_stats[profiles[i].school] = [];
    courses_count_stats[profiles[i].school] = [];
    edu_years_stats[profiles[i].school] = [];
    gpa_stats[profiles[i].school] = [];
  }

  if((profiles[i].objective != null) && (profiles[i].objective != NaN) && (profiles[i].objective != undefined))
  {
    objective_stats[profiles[i].school] = objective_stats[profiles[i].school].concat([profiles[i].objective]);
  }
  if((profiles[i].workExp_count != null) && (profiles[i].workExp_count != NaN) && (profiles[i].workExp_count != undefined))
  {
    workExp_count_stats[profiles[i].school] = workExp_count_stats[profiles[i].school].concat([profiles[i].workExp_count]);
  }
  if((profiles[i].workExp_duration != null) && (profiles[i].workExp_duration != NaN) && (profiles[i].workExp_duration != undefined))
  {
    workExp_duration_stats[profiles[i].school] = workExp_duration_stats[profiles[i].school].concat([profiles[i].workExp_duration]);
  }
  if((profiles[i].workExp_skillCount != null) && (profiles[i].workExp_skillCount != NaN) && (profiles[i].workExp_skillCount != undefined))
  {
    workExp_skillCount_stats[profiles[i].school] = workExp_skillCount_stats[profiles[i].school].concat([profiles[i].workExp_skillCount]);
  }
  if((profiles[i].internship_count != null) && (profiles[i].internship_count != NaN) && (profiles[i].internship_count != undefined))
  {
    internship_count_stats[profiles[i].school] = internship_count_stats[profiles[i].school].concat([profiles[i].internship_count]);
  }
  if((profiles[i].internship_duration != null) && (profiles[i].internship_duration != NaN) && (profiles[i].internship_duration != undefined))
  {
    internship_duration_stats[profiles[i].school] = internship_duration_stats[profiles[i].school].concat([profiles[i].internship_duration]);
  }
  if((profiles[i].internship_skillCount != null) && (profiles[i].internship_skillCount != NaN) && (profiles[i].internship_skillCount != undefined))
  {
    internship_skillCount_stats[profiles[i].school] = internship_skillCount_stats[profiles[i].school].concat([profiles[i].internship_skillCount]);
  }
  if((profiles[i].pub_count != null) && (profiles[i].pub_count != NaN) && (profiles[i].pub_count != undefined))
  {
    pub_count_stats[profiles[i].school] = pub_count_stats[profiles[i].school].concat([profiles[i].pub_count]);
  }
  if((profiles[i].courses_count != null) && (profiles[i].courses_count != NaN) && (profiles[i].courses_count != undefined))
  {
    courses_count_stats[profiles[i].school] = courses_count_stats[profiles[i].school].concat([profiles[i].courses_count]);
  }
  if((profiles[i].edu_years != null) && (profiles[i].edu_years != NaN) && (profiles[i].edu_years != undefined))
  {
    edu_years_stats[profiles[i].school] = edu_years_stats[profiles[i].school].concat([profiles[i].edu_years]);
  }
  if((profiles[i].gpa != null) && (profiles[i].gpa != NaN) && (profiles[i].gpa != undefined))
  {
    gpa_stats[profiles[i].school] = gpa_stats[profiles[i].school].concat([profiles[i].gpa]);
  }
   
}
  //outputString = profiles[i].handle +"\t"
  //		+ profiles[i].school + "\t"
  //		+ profiles[i].objective + "\t"
  //		+ profiles[i].workExp_count + "\t"
  //		+ profiles[i].workExp_duration + "\t"
  //		+ profiles[i].workExp_skillCount + "\t"
  //		+ profiles[i].internship_count + "\t"
  //		+ profiles[i].internship_duration + "\t"
  //		+ profiles[i].internship_skillCount + "\t"
  //		+ profiles[i].pub_count + "\t"
  //		+ profiles[i].courses_count + "\t"
  //		+ profiles[i].edu_years + "\t"
  //		+ profiles[i].gpa;
  //print(outputString);

// Printing the Means and STDEVS
for (var key in objective_stats) {
  print(key+"\t"+"objective\t"+Array.avg(objective_stats[key])+"\t"+Array.stdDev(objective_stats[key]))
  print(key+"\t"+"workExp_count\t"+Array.avg(workExp_count_stats[key])+"\t"+Array.stdDev(workExp_count_stats[key]))
  print(key+"\t"+"workExp_duration\t"+Array.avg(workExp_duration_stats[key])+"\t"+Array.stdDev(workExp_duration_stats[key]))
  print(key+"\t"+"workExp_skillCount\t"+Array.avg(workExp_skillCount_stats[key])+"\t"+Array.stdDev(workExp_skillCount_stats[key]))
  print(key+"\t"+"internship_count\t"+Array.avg(internship_count_stats[key])+"\t"+Array.stdDev(internship_count_stats[key]))
  print(key+"\t"+"internship_duration\t"+Array.avg(internship_duration_stats[key])+"\t"+Array.stdDev(internship_duration_stats[key]))
  print(key+"\t"+"internship_skillCount\t"+Array.avg(internship_skillCount_stats[key])+"\t"+Array.stdDev(internship_skillCount_stats[key]))
  print(key+"\t"+"pub_count\t"+Array.avg(pub_count_stats[key])+"\t"+Array.stdDev(pub_count_stats[key]))
  print(key+"\t"+"courses_count\t"+Array.avg(courses_count_stats[key])+"\t"+Array.stdDev(courses_count_stats[key]))
  print(key+"\t"+"edu_years\t"+Array.avg(edu_years_stats[key])+"\t"+Array.stdDev(edu_years_stats[key]))
  print(key+"\t"+"gpa\t"+Array.avg(gpa_stats[key])+"\t"+Array.stdDev(gpa_stats[key])) 
}
//print(internship_duration_stats["usc"]);
