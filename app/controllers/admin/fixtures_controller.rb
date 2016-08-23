class Admin::FixturesController < Admin::AdminController
	def show
		@fixture = Fixture.find_by_faft_id(params[:faft_id])

		respond_to do |format|
			format.html
		end
	end
end