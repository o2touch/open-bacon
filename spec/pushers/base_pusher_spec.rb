require 'spec_helper'

describe BasePusher do
	describe '#push' do
		before :each do 
			@attrs = {
				devices: [double("device")],
				alert: "hi",
				button: "push here",
				extrs: { "read" => "all_about_it" }
			}
		end
		it 'should return null push if no devices supplied' do
			@attrs[:devices] = nil
			push = BasePusher.push(@attrs)
			push.is_a?(NullPushNotification).should be_true
		end
		it 'should return null pushif not alert supplied' do
			@attrs[:alert] = nil
			push = BasePusher.push(@attrs)
			push.is_a?(NullPushNotification).should be_true
		end
		it 'should call PushNotification.build' do
			PushNotification.should_receive(:build).with(@attrs[:devices], kind_of(Hash))
			BasePusher.push(@attrs)
		end

		context "when alert message is too big" do
			it "gets truncated so payload never exceeds 256 bytes" do
				@attrs[:alert] = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur laoreet sem ac quam porta, at posuere diam semper. Nunc sagittis, lacus eu mattis tristique, tortor risus convallis orci, id iaculis urna lectus eu velit. Integer at mauris sollicitudin, commodo risus commodo, dignissim turpis."
				PushNotification.should_receive(:build) do |arg1, arg2|
					arg2.to_s.bytesize.should <= 256
				end
				BasePusher.push(@attrs)
			end
		end

	end
end