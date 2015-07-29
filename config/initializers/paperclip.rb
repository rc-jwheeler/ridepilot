Paperclip::Attachment.default_options[:hash_secret] = Rails.application.secrets.secret_key_base

if Rails.env.development?
  Paperclip::Attachment.default_options[:storage] = :filesystem
  Paperclip::Attachment.default_options[:url]     = "/system/:class/:attachment/:id_partition/:style/:hash.:extension"
  Paperclip::Attachment.default_options[:path]    = ":rails_root/public:url"
elsif Rails.env.test?
  Paperclip::Attachment.default_options[:storage] = :filesystem
  Paperclip::Attachment.default_options[:path]    = ":rails_root/tmp/test_files/:class/:attachment/:id/:style/:filename"
else
  Paperclip::Attachment.default_options[:storage] = :s3
  Paperclip::Attachment.default_options[:url]     = ":s3_path_url"
  Paperclip::Attachment.default_options[:path]    = "/system/:class/:attachment/:id_partition/:style/:hash.:extension"
  Paperclip::Attachment.default_options[:s3_credentials] = {
    :bucket => ENV['AWS_BUCKET'],
    :access_key_id => ENV['AWS_KEY_ID'],
    :secret_access_key => ENV['AWS_ACCESS_KEY']
  }
end