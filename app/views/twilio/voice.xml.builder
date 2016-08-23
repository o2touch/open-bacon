xml.instruct!
xml.Response do
  xml.Say "Hello " + @name + ", you're through to Mitoo. This is an automated line which your team organiser is using. We only support text messages, so please reply to your text to let your organiser know. You can find out more by visiting mitoo.co"
  xml.Hangup
end