describe("BFApp.Views.ActivityFeedTab", function() {

	var msgWidgetStub, itemListStub;

	beforeEach(function() {
		msgWidgetStub = sinon.stub(BFApp.Views, "ActivityMessageWidget").returns(new Marionette.View());
		itemListStub = sinon.stub(BFApp.Views, "ActivityItemList").returns(new Marionette.View());
	});

	afterEach(function() {
		msgWidgetStub.restore();
		itemListStub.restore();
	});

	function getView(canPostMsg) {
		var view = new BFApp.Views.ActivityFeedTab({
			canPostMsg: canPostMsg
		});
		view.render();
		return view;
	};

	it("user with canPostMsg permission can see the msg widget", function() {
		var view = getView(true);
		expect(view.$el.find(".r-message-form")).not.toBeEmpty();
	});

	it("user without canPostMsg permission cannot see the msg widget", function() {
		var view = getView(false);
		expect(view.$el.find(".r-message-form")).toBeEmpty();
	});

});
