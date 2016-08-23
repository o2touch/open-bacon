class BluefieldPhoneNumberFormatter 
	
	attr_reader :phone_number

	INTERNATIONAL_DIALING_CHARACTER = "+"

	def initialize(phone_number, country)
    raise ArgumentError, 'Argument country is not a valid 2 character String' unless not country.nil? and country.is_a? String and country.length == 2
    raise ArgumentError, 'Argument phone_number is not a valid String' unless not phone_number.nil? and phone_number.is_a? String and phone_number.length > 6
    
    @phone_number = phone_number.clone
  end

  def format
    formatted_phone_number = @phone_number
    formatted_phone_number = strip_non_numeric_characters_from formatted_phone_number
    raise ArgumentError, 'Argument phone_number without numberic characters must be length 6 or greater' unless formatted_phone_number.length > 6
    formatted_phone_number
  end

  def number_begins_with(characters, number)
 		if number =~ Regexp.new("^" + Regexp.quote(characters))
		  return true
 		end
 		return false
 	end

  def strip_non_numeric_characters_from(number)
    append_international_dialing_character_prefix = false
    if self.number_begins_with INTERNATIONAL_DIALING_CHARACTER, number
      append_international_dialing_character_prefix = true
    end

    number = number.gsub!(/[^0-9]/,'')

    return append_international_dialing_character_prefix ? INTERNATIONAL_DIALING_CHARACTER + number : number
  end
end