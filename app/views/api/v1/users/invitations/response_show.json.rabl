object @invitation_response

node :response do |ir|
  JSON.parse(ir.response)
end
