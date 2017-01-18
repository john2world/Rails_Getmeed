json.schools @schools do |school|
  json.value school._id
  json.text school.name
end

json.skills @skills

json.majors @majors do |major|
  json.value major._id
  json.text major.major
  json.optgroup major.major_type_id
end

json.majorOptionGroups @major_option_groups do |group|
  json.value group._id
  json.text group.name
end
