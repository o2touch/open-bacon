class ClubBuilderWorker
	include Sidekiq::Worker
	sidekiq_options queue: "default"

	def perform(row_hash)
		build_club(row_hash)
	end

  private
  def build_club(row_hash)
    ActiveRecord::Base::transaction do

    	# clean the data
    	row_hash.each do |_, v|
    		v.strip! unless v.nil?
    	end

      club = Club.create!({
        name: row_hash['club_name'],
        faft_id: row_hash['id'] 
      })

      # make colour do what we want...
      colour1 = process_colour(row_hash['colour1'])
      colour2 = process_colour(row_hash['colour2'])
      if colour1 == "FEFEFE"
        tmp = colour2
        colour1 = colour2
        colour2 = tmp
      end
      colour1 = "333333" if colour1 == "FEFEFE"

      club.create_profile({
        age_group: 99, # don't care
        sport: SportsEnum::SOCCER,
        colour1: colour1 || '333333',
        colour2: colour2 || 'DDDDDD'
      })
      image = Dir["/tmp/club_images/#{row_hash['id']}.*"].first
      Rails.logger.debug("image: #{image}")
      club.profile.profile_picture = open(image) unless image.nil?
      club.profile.save!

      club.create_location({
        title: row_hash['ground_title'],
        address: row_hash['ground_address']
      })

      club.create_marketing({
        contact_name: clean_contact_name(row_hash['contact_name']),
        contact_position: row_hash['contact_position'],
        contact_phone: row_hash['contact_phone'],
        contact_email: row_hash['contact_email'],
        twitter: row_hash['twitter'],
        junior: row_hash['junior']
      })

      club.save!
    end
  end

  def clean_contact_name(name)
  	tokens = name.split('\s')
  	if %w(mr miss mrs dr sir ms).include? tokens[0].downcase
  		tokens.delete_at(0)
  	end
  	tokens.join(' ')
  end

  def process_colour(colour)
    return nil if colour.nil?
    colour = colour.downcase.split('\s').join('')

    colours = {
      'black' => '333333',
      'orange' => 'E0652D',
      'red' => 'CC3543',
      'green' => '2ABD7A',
      'blue' => '4FADE3',
      'yellow' => 'FAB800',
      'white' => 'FEFEFE',
      'navy' => '000080',
      'navyblue' => '000080',
      'skyblue' => '87CEEB',
      'royalblue' => '002366',
      'gold' => 'FFD700',
      'lightblue' => '8FD8D8',
      'purple' => '000080',
      'turqoise' => '00f5ff',
      'maroon' => '800000',
      'amber' => 'FF7E00'
    }

    Rails.logger.info("Could not find colour #{colour}") unless colours.keys.include? colour
    colours[colour]
  end
end