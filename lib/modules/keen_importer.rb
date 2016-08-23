class KeenImporter

  def self.import_member_added_to_team

    keen = Keen::Client.new(
      :project_id => '5387a4adce5e430ca900001b',
      :write_key  => '77c448be8e5d06de8074f36becb1a08d5a6713f17435401fadabc1fdb9ac4a5d8d1da8aeb54961425553b2eda46a17543285c060049c7453e94490acbada4be90c61418d6c23305ab6953d5382dc915d8d25a8e6494d0fe888d8fa001c085c6e20fdcf3c23db793a0c427274573b3144',
      :read_key   => '47d3c5288966027a48494e40665261db3409290f295df959c704bb0c55b15201b70d2aec39c2a0e535f5d979048ec5e09f9bf381fa6e45d47ec682b4678555ddda6fd3e794b678f0a04002238b9a9d09cad67eb187ed8407e083e32db11e6ecc47eb9d86ea68e20846d909aead3c8141',
      :master_key => 'EC5E17A28DA5732D85E180CD3001BA7A'
    )

    date_from = Date.new(2014,9,1)
    time_to = Time.new(2014,9,16,0,0,0)

    PolyRole.where(:obj_type => "Team").where("created_at > ?", date_from).where("created_at < ?", time_to).find_each do |pr|

      user = User.find(pr.user_id)
      team = Team.find(pr.obj_id)

      member_type = :player if pr.role_id == PolyRole::PLAYER 
      member_type = :parent if pr.role_id == PolyRole::PARENT
      member_type = :follower if pr.role_id == PolyRole::FOLLOWER
      member_type = :organiser if pr.role_id == PolyRole::ORGANISER

      added_type = AddedToTeamEnum::TEAM_JOINED
      added_type = AddedToTeamEnum::TEAM_INVITED if user.invited_by_source_user_id.nil? && user.invited_by_source == "TEAMFOLLOW"

      timestamp = pr.created_at.to_time.iso8601

      data = {
        :keen => { :timestamp => timestamp },
        

        'tenant_id' => user.tenant_id,
        'userId' => user.id,

        'type' => added_type,
        'member_type' => member_type,
        'team' => {
          'id' => team.id,
          'source' => team.source,
          'tenant_id' => team.tenant_id
         },
        'platform' => nil
      }

      keen.publish(:"Added To Team", data)
    end

  end

end