collection @jobs
attributes :_id, :company_logo, :description, :title
node(:hash) { |job| encode_id(job.id) }
