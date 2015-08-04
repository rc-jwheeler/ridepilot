if ENV['AWS_REGION'] && ENV['AWS_KEY_ID'] && ENV['AWS_ACCESS_KEY']
  Aws.config.update(
    region: 
    credentials: Aws::Credentials.new(
      ENV['AWS_KEY_ID'],
      ENV['AWS_ACCESS_KEY'])
  )
end

S3_BUCKET =  Aws::S3::Resource.new.bucket(ENV['AWS_BUCKET']) if ENV['AWS_BUCKET']