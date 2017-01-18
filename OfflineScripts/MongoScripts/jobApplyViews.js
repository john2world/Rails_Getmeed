// script that outputs the no of job applies for each job and no of views
conn = new Mongo();
db = conn.getDB("futura");

jobApplies = db.job_applications.find().map(function(doc){return {_id: doc._id, applyCount: doc.handles.length};});

// for each job applies get the view count
for(var i in jobApplies)
{
    job = db.jobs.findOne({_id: ObjectId(jobApplies[i]._id)});
    if(job)
    {
       if(job.view_count > 0)
       {
           print(jobApplies[i]._id+":"+job.view_count+":"+jobApplies[i].applyCount);
       }
    }
} 
