require 'csv'
filename = "/Users/ViswaMani/Downloads/Meed_Users_115827_export_2016-02-03_21_56.csv"
file = File.open(filename)
lines = file.readlines()
# remove header
header = lines.shift()
header_cols = header.strip.split(',')
leads = []
lines.each do |line|
  cols = line.strip.split(',')
  leads.push({
                 :_id => cols[header_cols.index('Email')],
                 :first_name => cols[header_cols.index('Name')],
                 :last_name => cols[header_cols.index('Last Name')],
                 :email => cols[header_cols.index('Email')],
                 :major_text => cols[header_cols.index('major_text')],
                 :major_type_id => cols[header_cols.index('major_type_id')],
                 :major_id => cols[header_cols.index('major_id')],
                 :department_text => cols[header_cols.index('department_text')],
                 :year => cols[header_cols.index('year')],
             })
end
Lead.collection.insert(leads)