# ingests the Processed student data into the User Model
# All the processing of the data should happen before.
include UsersManager;

filename = ARGV[0];
fh = File.open(filename, 'r');
fh.readlines().each do |line|
  cols = line.strip().split("\t");
  name = cols[0]
  email = cols[1]
  major_id = cols[2]
  degree = cols[3]
  year = cols[4]

  user = get_user_by_email(email);
  if user.blank?
    # create a new user
    user = create_passive_user(email);
    unless name.blank?
      name_cols = name.rpartition(' ');
      user[:first_name] = name_cols[0];
      user[:last_name] = name_cols[2];
    end

    user[:degree] = degree;
    user[:major] = major_id;
    user[:year] = year;

    meta_data = {}
    meta_data[:source] = ["school_dir_scrapping"];
    user[:meta_data] = meta_data;

    user.save();
  end
end
