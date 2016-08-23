RACKSPACE_CONFIG = {
  'production' => {
    path: '',
    storage: :fog,
    fog_credentials: {
      provider: 'AWS',
      aws_access_key_id: 'AKIAJKUC2CHYCGLXQK2Q',
      aws_secret_access_key: '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',
      persistent: false,
      region: 'eu-west-1'
    },
    fog_directory: "bacon-uploads-prod",
    fog_public: true,
    fog_host: 'http://bacon-uploads-prod.s3.amazonaws.com',
  },
  'staging' => {
    path: '',
    storage: :fog,
    fog_credentials: {
      provider: 'AWS',
      aws_access_key_id: 'AKIAJKUC2CHYCGLXQK2Q',
      aws_secret_access_key: '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',
      persistent: false
    },
    fog_directory: "bacon-uploads-staging", # NOTE: DOES NOT EXIST (though neither does staging)
    fog_public: true,
    fog_host: 'http://bacon-uploads-prod.s3.amazonaws.com'
  },
  'development' => {
  # Couldn't get Fog to work with local storage, so all comented to revert to
  #  paper clip default local storage.
  #   path: '',
  #   storage: :fog,
  #   fog_credentials: {
  #     provider: 'Local',
  #     local_root: "#{Rails.root}/public/",
  #   },
  #   fog_directory: "",
  #   fog_host: "http://localhost:3000",
  # },
    path: '',
    storage: :fog,
    fog_credentials: {
      provider: 'Rackspace',
      rackspace_username: 'bluefields',
      rackspace_api_key: 'ea772e526fa7b5dc72eaecc18dbbc942',
      persistent: false
    },
    fog_directory: "bluefields_#{Rails.env}_static",
    fog_public: true,
    fog_host: 'http://dev.img.mstatic.co'
  },
}
 
unless RACKSPACE_CONFIG[Rails.env].nil?
  Paperclip::Attachment.default_options.update(RACKSPACE_CONFIG[Rails.env])
  Paperclip::Attachment.default_options[:url] = ':s3_domain_url'
  Paperclip::Attachment.default_options[:s3_host_name] = 's3-eu-west-1.amazonaws.com'
end