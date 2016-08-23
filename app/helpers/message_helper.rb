module MessageHelper
  def formatted_recipients(recipients_hash)
    return {'groups' => [], 'users' => []} if recipients_hash.nil?
    users = []
    groups = []
    
    unless recipients_hash['users'].nil?
      users = recipients_hash['users'].map do |x|
        user = User.find(x)
        { 'id' => user.id, 'name' => user.name, 'username' => user.username }
      end
    end

    unless recipients_hash['users'].nil?
      groups = recipients_hash['groups']
    end

    { 
      'groups' => groups,
      'users' => users
    }
  end
end
