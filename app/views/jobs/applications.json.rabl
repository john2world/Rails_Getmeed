collection @applicants
attribute :_id, :create_dttm, :applied

node(:story) do |applicant|
  if applicant.answer.present?
    applicant.answer.description
  elsif applicant.cover_note.present?
    applicant.cover_note
  elsif applicant.user && applicant.user.profile.present?
    applicant.user.profile.summary || applicant.user.profile.objective
  end
end

child(:user) { attribute :_id, :badge, :handle, :headline, :name, :small_image_url, :degree, :major }

child(:job) { attribute :_id, :handle, :title }

child(:answer) do
  attribute :_id, :gist_id
  node(:date) { |a| a.date.strftime("%B %d") }
  node(:description) { |a| a.description.truncate(1200, :omission => '..') }
end

# json.show_tab @applicants
# json.matches @applicants
# json.shortlisted @applicants
