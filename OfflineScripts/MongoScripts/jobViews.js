conn = new Mongo();
db = conn.getDB("futura");
// creating the map function
map = function(){if(this.view_count >0 ){emit(this.company, this.view_count);}};
// defininf the reduce function
reduce = function(key,values){return Array.sum(values);};
sortValue = function(a,b){return a.value - b.value;};
results = db.jobs.mapReduce(map, reduce, {out: {inline: 1}}).results;
for(var i in results.sort(sortValue).reverse())
{
    job = results[i];
    print(job._id+":"+job.value);
} 
