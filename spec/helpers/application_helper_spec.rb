# require 'spec_helper'

# describe ApplicationHelper do
	
# 	describe "#get_tenant_domain" do

# 		context "when given a tenantable model" do
# 			it "viewing an o2touch team redirects to correct url" do
				
# 				@tenant = mock_model(Tenant)
# 				@tenant.stub(:subdomain).and_return("o2touch")

# 				@team = mock_model(Team)
# 				@team.stub(:is_mitoo_team?).and_return(false)
# 				@team.stub(:tenant).and_return(@tenant)

# 				helper.get_tenant_domain(@team).should_not be_nil
# 				helper.get_tenant_domain(@team).should eq("o2touch.test.host")
# 			end

# 			it "viewing a mitoo team redirects to correct url" do
				
# 				@tenant = mock_model(Tenant)
# 				@tenant.stub(:subdomain).and_return("")

# 				@team = mock_model(Team)
# 				@team.stub(:is_mitoo_team?).and_return(true)
# 				@team.stub(:tenant).and_return(@tenant)

# 				helper.get_tenant_domain(@team).should be_nil
# 			end
# 		end

#     context "when given a non-tenantable model" do
#       it "viewing a mitoo team redirects to correct url" do
        
#         @tenant = mock_model(Tenant)
#         @tenant.stub(:subdomain).and_return("")

#         @non_tenanted = mock_model(AppEvent)

#         helper.get_tenant_domain(@non_tenanted).should be_nil
#       end
#     end
# 	end

# end