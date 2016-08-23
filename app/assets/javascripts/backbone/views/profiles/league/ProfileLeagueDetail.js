BFApp.Views.ProfileLeagueDetail = Marionette.ItemView.extend({

	template: "backbone/templates/profiles/league/league_detail",

	className: "league-profile-details",

	ui: {
		"title": "[name=league-title]",
		"dropdown": ".division-dropdown",
		"currentDivision": ".current-division",
		"otherDivision": ".other-division"
	},

	events: {
		"click li.division": "changeDivision",
		"click li.current-division": "openDropdown",
		"click #btn-edit-profile": "editLeague",
		"click button[name=add]": "showCreateDivision"
	},

	modelEvents: {
		"change:title": "titleChanged"
	},

	initialize: function(options) {
		this.ld = options.ld;
	},

	titleChanged: function() {
		this.ui.title.text(this.model.get("title"));
	},

	showCreateDivision: function() {
		BFApp.vent.trigger("create-division-form:show", {
			league: this.model
		});
	},

	changeDivision: function(e) {
		if (!$(e.currentTarget).hasClass("active-division")) {
			this.trigger("division:change", $(e.currentTarget).data("id"));
			this.updateDropdown($(e.currentTarget).data("id"));
		} else {
			this.closeDropdown();
		}
	},

	closeDropdown: function() {
		this.ui.dropdown.removeClass("open");
	},

	openDropdown: function() {
		this.ui.dropdown.addClass("open");
		var currentDivisionIndex = _.indexOf(ActiveApp.ProfileLeague.get("divisions").models, this.ld.division);
		this.ui.otherDivision.css({
			"top": function() {
				var position = (currentDivisionIndex * -31);
				if($(this).offset().top + position > 30) {
					return position;
				}else {
					return "-100px";
				}
			}
		});
	},

	updateDropdown: function() {
		this.$(".division").removeClass("active-division");
		this.$(".division[data-id=" + this.ld.division.get("id") + "]").addClass("active-division");
		this.ui.currentDivision.text(this.ld.division.get("title"));
		this.closeDropdown();
	},

	onRender: function() {
		var that = this;
		this.ui.dropdown.outside('click', function() {
			that.closeDropdown();
		});
	},

	serializeData: function() {
		var location = this.model.get("location");
		return {
			htmlPic: this.model.getPictureHtml("medium"),
			colour1: this.model.get("colour1"),
			title: this.model.get("title"),
			sport: this.model.get("sport"),
			location: (location) ? location.get("title") : "",
			leagueDivisions: this.model.get("divisions").models,
			// for now, only o2_touch leagues can be updated (mitoo league forms need more work)
			canUpdateLeague: (this.ld.adminUser && ActiveApp.Tenant.get("name") == "o2_touch"),
			currentDivision: this.ld.division || this.model.get("divisions").models[0],
			isLeagueAdmin: this.ld.adminUser
		};
	},

	editLeague: function(e) {
		e.preventDefault();
		BFApp.vent.trigger("league-form:show", {
			title: "Edit League",
			model: this.model
		});
	}

});