require 'logger'

begin
  PDFKit.configure do |config|
    config.wkhtmltopdf = '/home/ubuntu/.rvm/gems/ruby-2.2.1/bin/wkhtmltopdf' if Rails.env.production?
    config.default_options = {
      :page_size => 'Letter'
    }
    config.verbose = true
    config.default_options[:ignore_load_errors] = true
    config.default_options[:load_error_handling] = "ignore"
    config.default_options[:print_media_type] = true
  end
  Rails.logger.info "Finished Initializing PDF Kit"
rescue Exception => ex
  Rails.logger.error "Error initializing PDF Kit: #{ex}"
end
