# Script to compute and output user engagement stats from DB
# Author: vmk@resu.me

# Reading required data
users = User.all();
enterprise_users = EnterpriseUser.all();
enterprise_user_messages = EnterpriseUserMessages.all();
schools = School.all();
questions = Question.all();
answers = Answer.all();
articles = Article.all();
user_messages = Message.all();
jobs = Job.all();
applicants = JobApplicant.all();
#applications = JobApplications.all();
job_status = UserJobAppStats.all();
feed_items = FeedItems.all();
companies = Company.all();
company_follow = CompanyFollow.all();
instrumentation = Instrumentation.where(:'event_payload.handle'.nin =>
                                            ["test1","peddinti","ravi","test2","test3","test4",
                                             "test5","test6","test7","test8","test9"]).
                                  where(:'event_payload.user_id'.nin =>
                                             ["vmk@resu.me", "ravi@resu.me", "test@testcorp.com"]);

# Adding important stats to dictionary
stats = {};

# Computing and saving stats
stats["# of users"] = users.count();
stats["# of active users"] = users.where(active: true).count();
stats["# of company accounts"] = enterprise_users.count();
stats["# of companies in accounts"] = enterprise_users.distinct("company_id").count();
stats["# of schools"] = schools.count();

stats["# of jobs"] = jobs.count();
stats["# of live jobs"] = jobs.where(live: true).count();
stats["# of companies of Jobs"] = companies.count();
stats["# of applicants"] = applicants.count();
stats["# of job applications"] = applications.count();
stats["# of times labels are used"] = job_status.where(:status.nin => ["NEW", "VIEWED"]).count()

stats["# of messages exchanged"] = user_messages.count();
stats["# of recruiters using messages"] = enterprise_user_messages.count();
stats["# of questions"] = questions.count();
stats["# of answers"] = answers.count();
stats["# of articles"] = articles.count();
stats["# of feed items"] = feed_items.count();
stats["# of company followers"] = company_follow.count();

# Computing engagement stats
def compute_value_average(values)
  return values.map {|val| val["value"]}.sum() * 1.0 / values.count()
end
date_count_map = %Q{
  function() {
    var date = this.event_start.getDate() + '/' + (this.event_start.getMonth()+1) + '/' + this.event_start.getFullYear()
    emit(date, 1);
  }
}

date_count_reduce = %Q{
  function(key, values) {
    var result = 0;
    values.forEach(function(value) {
      result += value;
    });
  return result;
  }
}
average_func = %Q{
  function(key,value) {
    var sum = 0;
    var count = 0;
    values.forEach(function(value) {
      count += 1;
      sum += value;
    }
  return sum * 1.0/count;
  }
}

stats["7day avg login count"] = compute_value_average (instrumentation.
    where(:event_name => "Consumer.Session.Login").
    where(:event_start.gte => Time.now-7.days).
    map_reduce(date_count_map, date_count_reduce).
    out(inline:1).to_a)
stats["7day avg account creation"] = compute_value_average (instrumentation.
    where(:event_name => "Consumer.User.Create").
    where(:event_start.gte => Time.now-7.days).
    map_reduce(date_count_map, date_count_reduce).
    out(inline:1).to_a)
stats["7day avg signup"] = compute_value_average (instrumentation.
    where(:event_name => "Consumer.User.SignUp").
    where(:event_start.gte => Time.now-7.days).
    map_reduce(date_count_map, date_count_reduce).
    out(inline:1).to_a)

stats["7day avg profile views"] = compute_value_average (instrumentation.
    where(:event_name => "Consumer.Profile.ViewProfile").
    where(:event_start.gte => Time.now-7.days).
    map_reduce(date_count_map, date_count_reduce).
    out(inline:1).to_a)

stats["7day avg article views"] = compute_value_average (instrumentation.
    where(:event_name => "Consumer.Article.View").
    where(:event_start.gte => Time.now-7.days).
    map_reduce(date_count_map, date_count_reduce).
    out(inline:1).to_a)

stats["7day avg Company views"] = compute_value_average (instrumentation.
    where(:event_name => "Consumer.Company.View").
    where(:event_start.gte => Time.now-7.days).
    map_reduce(date_count_map, date_count_reduce).
    out(inline:1).to_a)

stats["7day avg Feed views"] = compute_value_average (instrumentation.
    where(:event_name => "Consumer.Feed.View").
    where(:event_start.gte => Time.now-7.days).
    map_reduce(date_count_map, date_count_reduce).
    out(inline:1).to_a)

stats["7day avg Job dash views"] = compute_value_average (instrumentation.
    where(:event_name => "Consumer.Jobs.ViewJobs").
    where(:event_start.gte => Time.now-7.days).
    map_reduce(date_count_map, date_count_reduce).
    out(inline:1).to_a)

stats["7day avg Insight views"] = compute_value_average (instrumentation.
    where(:event_name => "Consumer.Profile.ViewInsights").
    where(:event_start.gte => Time.now-7.days).
    map_reduce(date_count_map, date_count_reduce).
    out(inline:1).to_a)

stats["7day avg Message views"] = compute_value_average (instrumentation.
    where(:event_name => "Consumer.Message.View").
    where(:event_start.gte => Time.now-7.days).
    map_reduce(date_count_map, date_count_reduce).
    out(inline:1).to_a)

stats["7day avg View Job"] = compute_value_average (instrumentation.
    where(:event_name => "Consumer.Jobs.ViewJob").
    where(:event_start.gte => Time.now-7.days).
    map_reduce(date_count_map, date_count_reduce).
    out(inline:1).to_a)

stats["7day avg Profile contact"] = compute_value_average (instrumentation.
    where(:event_name => "Consumer.Profile.Contact").
    where(:event_start.gte => Time.now-7.days).
    map_reduce(date_count_map, date_count_reduce).
    out(inline:1).to_a)

stats["7day avg new message"] = compute_value_average (instrumentation.
    where(:event_name => "Consumer.Message.Create").
    where(:event_start.gte => Time.now-7.days).
    map_reduce(date_count_map, date_count_reduce).
    out(inline:1).to_a)

stats["7day avg video clicks"] = compute_value_average (instrumentation.
    where(:event_name => "Consumer.Video.Click").
    where(:event_start.gte => Time.now-7.days).
    map_reduce(date_count_map, date_count_reduce).
    out(inline:1).to_a)

stats["7day avg Email invite"] = compute_value_average (instrumentation.
    where(:event_name => "Consumer.Home.EmailInvite").
    where(:event_start.gte => Time.now-7.days).
    map_reduce(date_count_map, date_count_reduce).
    out(inline:1).to_a)

stats["7day avg enterprise login"] = compute_value_average (instrumentation.
    where(:event_name => "Enterprise.Session.Login").
    where(:event_start.gte => Time.now-7.days).
    map_reduce(date_count_map, date_count_reduce).
    out(inline:1).to_a)

stats["7day avg enterprise home"] = compute_value_average (instrumentation.
    where(:event_name => "Enterprise.Home.Dash").
    where(:event_start.gte => Time.now-7.days).
    map_reduce(date_count_map, date_count_reduce).
    out(inline:1).to_a)

stats["7day avg job applications view"] = compute_value_average (instrumentation.
    where(:event_name => "Enterprise.Job.Applications.View").
    where(:event_start.gte => Time.now-7.days).
    map_reduce(date_count_map, date_count_reduce).
    out(inline:1).to_a)

stats["7day avg enterprise home"] = compute_value_average (instrumentation.
    where(:event_name => "Enterprise.Job.Applications.ViewTheater").
    where(:event_start.gte => Time.now-7.days).
    map_reduce(date_count_map, date_count_reduce).
    out(inline:1).to_a)

stats["7day avg enterprise messages home"] = compute_value_average (instrumentation.
    where(:event_name => "Enterprise.Messages.Dash").
    where(:event_start.gte => Time.now-7.days).
    map_reduce(date_count_map, date_count_reduce).
    out(inline:1).to_a)

# Printing results
stats.each do |name, value|
  puts "#{name}\t#{value}"
end



