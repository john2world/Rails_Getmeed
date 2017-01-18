########################################################################################################################
####### Computes the no. of documents(profiles) each keyword appears. So that IDF can be computed for each word.########
########################################################################################################################
require 'thread/pool'
include ProfilesManager
include ProfilesHelper
include Math

$idf = {}
$doc_count = 0
Semaphore = Mutex.new
#filename = ARGV[-1]
NN_TAGS = ['NN', 'NNS', 'NNP', 'NNPS']
def get_keywords_profiles(profiles)
  idf = {};
  doc_count = 0;
  if profiles.blank?
    return {};
  end
  profiles.each do |profile|
    if profile.blank?
      next
    end
    keywords = get_profile_keywords(profile);
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
  end
  # Update IDF
  Semaphore.synchronize {
    $idf = $idf.merge(idf){ |k, val1, val2| val1 + val2 };
    $doc_count += doc_count;
  }
end

profiles = Profile.desc(:score);
$idf = {}
Groups = 2 # because there are 2 cores
pool = Thread.pool(Groups);
group_profiles = profiles.in_groups(Groups).to_a;
start_time = Time.now()
group_profiles.each do |p|
  pool.process{get_keywords_profiles(p)};
end
pool.shutdown
puts "Finished processing in #{Time.now()-start_time}"
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

puts "#TimeStamp\t#{Time.now}"
