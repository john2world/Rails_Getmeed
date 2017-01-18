# Old users have year populated as string. In the new login, it is a number. so converting them to year

users = User.where(active: true, :year.ne => nil);

# getting indices of users where year is not a no
years = users.map{|u| u.year.match(/^\d{4}$/)};
illegal_year_indices = years.map.with_index{|year, i| year.blank? ? i : nil}.compact;

# parsing the year if possible and updating user
illegal_year_indices.each_with_index do |index, i|
  user = users[index];
  begin
    date = Date.parse(user.year);
    user.year = date.year.to_s;
    user.save;
    illegal_year_indices.delete_at(i);
  rescue
  end
end

# using regex to match
illegal_year_indices.each_with_index do |index, i|
  user = users[index]
  matches = /.*(20\d{2})/.match(user.year)
  unless matches.blank?
    year = matches[1]
    user.year = year
    user.save
    illegal_year_indices.delete_at(i)
  end
end

