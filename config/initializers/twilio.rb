# Not currently enabled

# module Twilio
#   class Config
    
#     # Set to true to use a staging number on staging and development environments
#     USE_STAGING_NUMBER = false

#     if Rails.env.production? || (USE_STAGING_NUMBER && Rails.env.staging?)
#       SID  = ""
#       TOKEN = ""
#     else
#       SID  = ""
#       TOKEN = ""
#     end
#   end
# end