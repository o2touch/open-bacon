describe("App.Modelss.ActivityItem", function() {

	var msgObj;

	beforeEach(function() {
		msgObj = {
			messageable_type: "event"
		};
	});

	it("parses obj_type correctly", function() {
		var objType = "EventMessage";
		var model = new App.Modelss.ActivityItem({
			obj: msgObj,
			obj_type: objType
		}, {parse: true});

		// the FE needs the obj_type to be within the obj, so we copy it there during parse()
		expect(model.get("obj").get("obj_type")).toEqual(objType);
	});


	describe("sets starred_at for msg activity items", function() {

		function getCollection(context) {
			var collection = new App.Collections.ActivityItems();
			// we're not testing the set function here, so reset it
			collection.set = Backbone.Collection.prototype.set;
			collection.context = context;
			return collection;
		}

		it("uses meta_data value when collection has correct context", function() {
			var collection = getCollection("event");

			var starredAt = "1999-01-01T01:00:00Z";
			collection.add({
				meta_data: '{"starred_at": "'+starredAt+'"}',
				obj: msgObj,
				obj_type: "EventMessage"
			}, {parse: true});

			var model = collection.at(0);
			expect(model.get("starred_at")).toEqual(starredAt);
		});

		it("ignores meta_data value when collection has wrong context", function() {
			var collection = getCollection("team");

			collection.add({
				meta_data: '{"starred_at": "1999-01-01T01:00:00Z"}',
				obj: msgObj,
				obj_type: "EventMessage"
			}, {parse: true});

			var model = collection.at(0);
			expect(model.get("starred_at")).toEqual(false);
		});

		it("sets to false if empty meta_data", function() {
			var model = new App.Modelss.ActivityItem({
				meta_data: '{}',
				obj: msgObj,
				obj_type: "EventMessage"
			}, {parse: true});

			expect(model.get("starred_at")).toEqual(false);
		});

	});

});
