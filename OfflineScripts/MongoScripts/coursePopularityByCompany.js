// script that computes the popularity of courses by company
// The courses related to the company are obtained by the people who applied to the company

conn = new Mongo();
db = conn.getDB("futura");

// get people who applied to a job and get te company

// For each job application, get company using job id and get skills from handles

var FindJobCompany = function(doc){
    var job = db.jobs.findOne({_id: ObjectId(doc._id)});
    if(job)
    {
        printjson(job);
        return {company: job.company, handles: doc.handles};
    }
}
var ReduceHandles = function(key,values){
    var finalHandles = new Array();
    for(var i in values)
    {
        finalHandles = finalHandles.concat(values[i]);
    }
    finalHandles.unique();
    return {company: key, handles: finalHandles};
}
var applications = db.job_applications.mapReduce(FindJobCompany, ReduceHandles, {out: {inline:1}, query: {handles: {$exists:true}}}).results;
printjson(applications);
//for(var i in applications)
//{
//    printjson(applications[i]);
//}
//while(applications.hasNext())
//{
//    printjson(applications.next());
//}
//.map(FindJobCompany);
//printjson(applications);
