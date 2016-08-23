def fg_name
  females = ['Sunita Greco', 'Louise Andricopoulos', 'Paris Archer', 'Michele Bain', 'Nina Blankley', 'Nicole Bouttell']
  males = ['Pepe Bluefields', 'Jack Dunton', 'Piers Enna', 'Tim Furnival', 'Leo Gentile', 'Andy Gibson']
  females.concat(males).shuffle.sample
end

def fg_junior_name
  fg_name + " " + %w(jr jnr 2nd 3rd).sample
end

def fg_mobile_number
  # dont include 0 as '+0' isn't a valid start to an international number
  mobile_number = '123456789'.split('').shuffle.join
  "+#{mobile_number}" 
end

def fg_email(name, guid)
  domain = ['gmail', 'hotmail', 'bass', 'googlemail'].sample
  postfix = ['com', 'org', 'org.uk', 'co.uk'].sample
  prefix = name.delete(' ').downcase
  "#{prefix}_#{guid}@#{domain}.#{postfix}"
end

def fg_team_name
  ['Real Santa Monica', 'South Bay Force Quigs', 'So Cal Blues Baker', 'Fullerton Rangers White', 'San Diego Surf SC White', 'Arsenal FC', 'Laguna Hills Eclipse White', 'Eagles SC', 'Ajax United Elite', 'West Coast FC', 'Santa Rosa United Earthquakes', 'Real So Cal White'].sample
end

def fg_sport
  SportsEnum.values.sample
end

def fg_colour
  ColourEnum.values.sample
end

def fg_age_group
  AgeGroupEnum.values.sample
end

def fg_title
  'Vs ' + fg_team_name
end

def fg_fixture_title
  "game"
end

def fg_game_type
  GameTypeEnum.values.sample
end

def fg_league_title
  ['Alliance Nevada Youth Soccer League', 'Clark County Soccer League', 'Mission Youth Soccer League', 'NorCal Athletics', 'Southern Nevada Adult Baseball', "Tri-Valley Mens Senior Baseball League", 'South Bay Basketball Alliance', 'Golden Gate Sport and Social Club', 'I Play For San Francisco', 'National Junior Basketball Norcal', 'Triple Threat Youth Organization', 'Sunday Recess'].sample
end

def fg_division_title
  ['Premiership', 'Championship', 'League one', 'League two', 'league three', 'Conference', 'Blue Square Premier', 'Guiness Premiership', 'Top 14', 'Super 14s'].sample
end

def fg_region
  ['Archway, London', 'A-Town, London', 'N19, London', 'The Arch, London', 'North London', 'Newcastle-under-Lyme, England', 'Clark County, Nevada', 'Palermo, Buenos Aires', 'Barranco, Lima', 'Bristol, England', 'Old Town, Swindon', 'British Columbia, Canada'].sample
end

def fg_lorem(words=-1)
	# there are 67 words, you alway get three.
	words = 3 + rand(67) if words <= 0
  lorem = %w(sit amet, consectetur adipiscing elit. Ut ac orci justo. Proin sit amet dolor ante, at blandit orci. Phasellus at quam non ligula vehicula commodo lobortis at urna. Etiam id eleifend orci. Etiam porttitor eros non mauris tempus consectetur. Mauris quis nunc eget magna pretium porttitor. Morbi bibendum erat eget lorem sodales feugiat. Vivamus quis rhoncus eros. Lorem ipsum dolor sit amet, consectetur adipiscing elit.)
  %w(Lorem ipsum dolar).concat(lorem.sample(words-3)).join(" ")
end

