describe("BFApp.Views.ActivityItemLayout", function() {

	var view, model;

	beforeEach(function() {
		// this is required here to call model.destroy() in afterEach() w/o hitting the server
		spyOn($, "ajax");

		ActiveApp = {
			CurrentUser: new App.Modelss.User()
		};
		
		var msgObj = new App.Modelss.Message();
		// force obj.getType() to return "event"
		sinon.stub(msgObj, "getType").returns("event");

		model = new App.Modelss.ActivityItem({
			id: 123,
			obj: msgObj,
			obj_type: "EventMessage",
			subj: new App.Modelss.User(),
			verb: "created"
		});
		
		view = createView();

		// we want to make sure these methods are being called, but not actually run them
		spyOn(view.collection, "sort");
		spyOn(model, "save");
	});

	afterEach(function() {
		delete ActiveApp;
		model.destroy();
	});

	function createView() {
		var view = new BFApp.Views.ActivityItemLayout({
			model: model,
			collection: new Backbone.Collection(),
			isOrganiser: true,
			context: "event"
		});
		view.render();
		return view;
	}

	it("can star a msg", function() {
		view.$el.find(".star").click();
		// at this point we send request to BE to star item
		// then we call collection.sort, which re-creates the item view as starred
		expect(view.model.save).toHaveBeenCalled();
		expect(view.collection.sort).toHaveBeenCalled();
		// but in the test collection.sort wont get called, so we have to manually re-create the view
		view = createView();
		expect(view.$el).toHaveClass("starred");
		expect(view.$el.find(".star")).toHaveClass("selected");
	});

	it("can like a msg", function() {
		view.$el.find(".activity-item-like").click();

		// should make ajax request
		var request = $.ajax.mostRecentCall.args[0];
		expect(request.type).toEqual("POST");
		expect(request.url).toEqual('/api/v1/activity_items/' + model.get("id") + '/likes');

		// and the like button should have text Unlike
		expect(view.$el.find(".activity-item-like")).toHaveText("Unlike");
	});

	it("can comment on a msg", function() {
		var commentText = "Some text";
		// bring up comment form
		view.$el.find(".toggle-comment-form").click();
		var commentForm = view.$el.find(".activity-comment-form");
		expect(commentForm).not.toHaveClass("hide");
		// submit form
		var e = jQuery.Event('keypress', {
			which: 13,
			keyCode: 13
		});
		commentForm.find("input").val(commentText).trigger(e);

		// should make ajax request
		var request = $.ajax.mostRecentCall.args[0];
		var data = JSON.parse(request.data);
		expect(request.type).toEqual("POST");
		expect(request.url).toEqual('/api/v1/activity_items/' + model.get("id") + '/comments');
		expect(data.activity_item_comment.text).toEqual(commentText);
	});

});
