########################################################################################################################
####### Computes the no. of documents(profiles) each keyword appears. So that IDF can be computed for each word.########
########################################################################################################################
require 'thread/pool'
include JobsHelper
include Math

$idf = {}
$doc_count = 0
Semaphore = Mutex.new
#filename = ARGV[-1]
NN_TAGS = ['NN', 'NNS', 'NNP', 'NNPS']
def get_keywords_jobs(jobs)
  idf = {};
  doc_count = 0;
  if jobs.blank?
    return {};
  end
  jobs.each do |job|
    if job.blank?
      next
    end
    keywords = get_job_keywords(job);
    # removing duplicates as counts are not important for IDF
    keywords = keywords.uniq
    keywords.each do |keyword|
      if idf.has_key?(keyword)
        idf[keyword] += 1;
      else
        idf[keyword] = 1;
      end
    end
    doc_count += 1;
    STDERR.puts "processed docs: #{doc_count}"
  end
  # Update IDF
  Semaphore.synchronize {
    $idf = $idf.merge(idf){ |k, val1, val2| val1 + val2 };
    $doc_count += doc_count;
  }
end

jobs = Job.desc(:create_dttm);
$idf = {}
Groups = 5 # because there are 2 cores
# threading is not working somehow
pool = Thread.pool(1);
group_jobs = jobs.in_groups(Groups).to_a;
start_time = Time.now()
group_jobs.each do |j|
  #get_keywords_jobs(j)
  pool.process{get_keywords_jobs(j)};
end
pool.shutdown
STDERR.puts "Finished processing in #{Time.now()-start_time}"
# remove elements which has single count
$idf = $idf.select{|_key, value| value > 1}
$idf = $idf.sort_by{|_key, value| -value}
$idf.each do |key,value|
  # check the tag again
  # tag = key.tag :stanford
  # if !NN_TAGS.include? tag
  #   next
  # end
  # idf = log (N/count)
  # optional step - normalizing so that the IDF is between 0 & 1
  val = 1 - (Math.log(value)/Math.log($doc_count))
  puts "#{key}\t#{val}\n"
end
# print the time stamp
puts "#TimeStamp\t#{Time.now}"
