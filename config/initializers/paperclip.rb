RACKSPACE_CONFIG = {
  'production' => {
    path: '',
    storage: :fog,
    fog_credentials: {
      provider: 'AWS',
      aws_access_key_id: ENV['AWS_ACCESS_KEY'],
      aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
      persistent: false,
      region: ENV['AWS_REGION'],
    },
    fog_directory: ENV['S3_BUCKET'],
    fog_public: true,
    fog_host: "http://#{ENV['S3_BUCKET']}.s3-eu-west-1.amazonaws.com",
  },
  'staging' => {
    path: '',
    storage: :fog,
    fog_credentials: {
      provider: 'AWS',
      aws_access_key_id: '',
      aws_secret_access_key: '',
      persistent: false
    },
    fog_directory: '',
    fog_public: true,
    fog_host: ''
  },
  'development' => {
    path: '',
    storage: :fog,
    fog_credentials: {
      provider: 'AWS',
      aws_access_key_id: ENV['AWS_ACCESS_KEY'],
      aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
      persistent: false,
      region: ENV['AWS_REGION'],
      path_style: true
    },
    fog_directory: ENV['S3_BUCKET'],
    fog_public: true,
    fog_host: "http://#{ENV['S3_BUCKET']}.s3-eu-west-1.amazonaws.com",
      path_style: true
  },
}
 
unless RACKSPACE_CONFIG[Rails.env].nil?
  Paperclip::Attachment.default_options.update(RACKSPACE_CONFIG[Rails.env])
end