shared_examples_for "an email received by a parent" do
  describe "the email body" do
    it "should contain the parents name" do
      @email.body.encoded.should match(parent.first_name)
    end
  end
  
  it "should have the parents email as the mail-to address" do
    @email.should deliver_to format_user_email(parent)
  end
end
