describe("BFApp.Views.ActivityItemComment", function() {

	it("escapes angular brackets", function() {
		var model = new App.Modelss.ActivityItemComment({
			user: new App.Modelss.User(),
			text: "<script>",
			created_at: "1999-01-01T01:00:00Z"
		}); 
		var view = new BFApp.Views.ActivityItemComment({
			model: model
		});
		view.render();

		expect(view.$el.find(".actual-comment-text")).toContainHtml("&lt;script&gt;");
	});

});
