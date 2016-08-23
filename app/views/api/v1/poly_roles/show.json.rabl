object @poly_role
cache root_object

attributes :id, :role_id, :user_id

node_string = root_object.obj.class.name.underscore
node("#{node_string}_id".to_sym){ |pr| !pr.obj.nil? && pr.obj.id }