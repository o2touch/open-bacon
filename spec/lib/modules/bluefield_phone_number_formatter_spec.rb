require 'spec_helper'
require 'BluefieldPhoneNumberFormatter'

describe BluefieldPhoneNumberFormatter do

	it "strips non numeric characters specified in the phone number except a prefixing international dialing character" do
		"+4412345678".should == BluefieldPhoneNumberFormatter.new("++_()*4412345678Aa><", "GB").format
	end

	it "throws an exception if the country specified is nil" do
		expect { 
			BluefieldPhoneNumberFormatter.new("1412332555", nil).format 
		}.to raise_error
	end

	it "throws an exception if the phone number specified is nil" do
		expect { 
			BluefieldPhoneNumberFormatter.new(nil, "HK").format 
		}.to raise_error
	end

	it "throws an exception if the country specified is not 2 characters in length" do
		expect { 
		  BluefieldPhoneNumberFormatter.new("1412332555", "").format 
		}.to raise_error
		expect { 
			BluefieldPhoneNumberFormatter.new("1412332555", "H").format 
		}.to raise_error
		expect { 
			BluefieldPhoneNumberFormatter.new("1412332555", "HKG").format 
		}.to raise_error
	end

	it "throws an exception if the phone number is not specified" do
		expect { 
			BluefieldPhoneNumberFormatter.new("", "HK").format
		}.to raise_error
	end

	it "throws an exception if the length of the phone number is less that 6 characters after stripping" do
		expect { 
			BluefieldPhoneNumberFormatter.new("+{}powpoqw2345", "HK").format
		}.to raise_error
	end
end
