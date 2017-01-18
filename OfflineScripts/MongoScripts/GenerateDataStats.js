conn = new Mongo();
db = conn.getDB("futura");

function get_active_user_count() {
    return db.users.find({active: true}).count();
}

function get_total_user_count() {
    return db.users.count();
}

function get_total_recruiter_count(){
    return db.enterprise_users.count();
}

function get_active_recruiter_count(){
    return db.enterprise_users.find({active: true}).count();
}

function get_jobs_count(){
    return db.jobs.count();
}

// This is based on that the email is not eq temp email
function get_real_jobs_count(){
    return db.jobs.find({email: {$nin : ["ssravi@live.com", "applications@resu.me"]}}).count()
}

function get_live_jobs_count(){
    return db.jobs.find({live: true}).count();
}

function get_live_real_jobs_count(){
    return db.jobs.find({email: {$nin : ["ssravi@live.com", "applications@resu.me"]}, live:true}).count();
}

function get_school_count(){
    return db.schools.count();
}

function reduce_array_sum(key, values){
    return Array.sum(values);
}

function get_job_application_histogram(){
    // getting jobs application counts
    var mapFunction = function(){
        emit(this["handles"].length%10, 1);
    };
    var application_counts = db.job_applications.mapReduce(
        mapFunction,
        reduce_array_sum,
        {out: {inline: 1}}
    );

    return application_counts;
}

function get_user_applies_histogram(){
    // getting the application counts
    var mapFunction = function(){
        emit(this["job_ids"].length%10, 1);
    };
    var job_counts = db.user_applied_jobs.mapReduce(
        mapFunction,
        reduce_array_sum,
        {out: {inline: 1}}
    );

    return job_counts;
}

function get_school_from_email(school){
    var cols = school.split('@');
    if(cols.length != 2){
        return "";
    }
    var cols = cols[1].split('.');
    if(cols.length < 2){
        return "";
    }
    return cols[cols.length-2];
}

function get_days_from_now(date){
    if (date == undefined) {
        return Infinity;
    }
    var now = new Date();
    var time_diff = (now - date);
    // time diff is in milli secs
    return Math.round(time_diff/(1000*60*60*24));
}

function get_school_histogram(){
    var mapFunction = function(){
        var school = ""
        var cols = this["email"].split('@');
        if(cols.length == 2){
            var cols = cols[1].split('.');
            if(cols.length >=2){
                school = cols[cols.length-2];
            }
        }
        if(school != "") {
            emit(school, 1);
        }
    };

    var school_counts = db.users.mapReduce(
        mapFunction,
        reduce_array_sum,
        {out: {inline: 1}}
    );
    return school_counts;
}

function get_job_app_status_histogram(){
    var mapFunction = function(){
        emit(this["status"],1);
    }

    var job_app_status_counts = db.user_job_app_stats.mapReduce(
        mapFunction,
        reduce_array_sum,
        {out: {inline: 1}}
    );
    return job_app_status_counts;
}

function get_user_count_by_last_login(){
    return db.users.find(
        {
            $where: function() {
                if (this["last_login"] == undefined){
                    return false;
                }
                var now = new Date();
                var time_diff = Math.round((now-this["last_login"])/(1000*60*60*24));
                if(time_diff < 7){
                    return true;
                }
                else{
                    return false;
                }
            }
        }).count();
}

function get_recruiter_count_by_last_login(){
    return db.enterprise_users.find(
        {
            $where: function() {
                if (this["last_login"] == undefined){
                    return false;
                }
                var now = new Date();
                var time_diff = Math.round((now-this["last_login"])/(1000*60*60*24));
                if(time_diff < 7){
                    return true;
                }
                else{
                    return false;
                }
            }
        }).count();
}

function get_user_counts_by_month(){
    var mapFunction = function(){
        if (this["create_dttm"] == undefined || this["active"] == false){
            return;
        }
        else{
            emit({year: this["create_dttm"].getFullYear(), month: this["create_dttm"].getMonth()}, 1);
        }
    };

    var user_counts_by_month = db.users.mapReduce(
        mapFunction,
        reduce_array_sum,
        {out: {inline: 1}}
    );

    return user_counts_by_month;
}

function get_recruiter_counts_by_month(){
    var mapFunction = function(){
        if (this["create_dttm"] == undefined || this["active"] == false){
            return;
        }
        else{
            emit({year: this["create_dttm"].getFullYear(), month: this["create_dttm"].getMonth()}, 1);
        }
    };

    var recruiter_counts_by_month = db.enterprise_users.mapReduce(
        mapFunction,
        reduce_array_sum,
        {out: {inline: 1}}
    );

    return recruiter_counts_by_month;
}

print("Active User Count: ",get_active_user_count());
print("Total User Count: ",get_total_user_count());
print("Last 7 day active user count: ", get_user_count_by_last_login());
print("Total recruiter Count: ",get_total_recruiter_count());
print("Active recruiter Count: ",get_active_recruiter_count());
print("Last 7 day active recruiter count: ", get_recruiter_count_by_last_login());
print("Total jobs Count: ",get_jobs_count());
print("Real job Count: ",get_real_jobs_count());
print("Live jobs Count: ",get_live_jobs_count());
print("Schools Count: ",get_school_count());
print("job applies hist: ");
printjsononeline(get_job_application_histogram());
print("schools hist: ");
printjsononeline(get_school_histogram());
print("App status hist: ");
printjsononeline(get_job_app_status_histogram());
print("User Counts by month: ");
printjsononeline(get_user_counts_by_month());
print("Recruiter Counts by month: ");
printjsononeline(get_recruiter_counts_by_month());