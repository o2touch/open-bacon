BFApp.Views.MitooTeamForm = BFApp.Views.TeamForm.extend({

	customOnRender: function() {
		// setup the custom ui hash
		this.ui.leagueName = this.$("#league-name");
		this.ui.sportSelect = this.$(".team-sport");
		this.ui.colour1 = this.$("input[name=primary]");
		this.ui.colour2 = this.$("input[name=secondary]");

		// setup the custom events hash
		this.$(".colour-selector li").click(this.changeColour);

		// Hide UI elements in certain contexts
		if (this.options.context == "league_admin") {
			this.removeFormField(this.ui.leagueName);
			this.removeFormField(this.ui.sportSelect);
		}
	},

	getCustomSerializeData: function() {
		return {
			bottomFieldsHtml: BFApp.renderHtml("backbone/templates/profiles/user/content/team_form/mitoo_fields", {
				edit: (this.options.type == "edit"),
				sport: this.model.get("sport"),
				sportsList: BFApp.constants.sports,

				colours: BFApp.constants.teamColours,
				// no longer need to pick randoms, since we assign defaults in the team model
				colour1: this.model.get("colour1"),
				colour2: this.model.get("colour2"),

				league: this.model.get("league_name"),
				showLeague: (this.model.get("league")) ? false : true
			})
		};
	},

	changeColour: function(e) {
		var list = $(e.currentTarget).parent();
		list.children("li").removeClass("showChecked");
		list.find("input:checked").parents("li").addClass("showChecked");
	},

	validateSave: function() {
		var leagueNameElem = (this.options.type == "edit" && !this.isRemovedFormField(this.ui.leagueName)) ? this.ui.leagueName : null;
		return this.model.validateSave(this.ui.teamName, leagueNameElem);
	},

	getCustomParams: function() {
		var data = {
			league_name: (this.options.type == "edit") ? this.ui.leagueName.val() : "",
			sport: this.ui.sportSelect.val(),
			colour1: this.ui.colour1.filter(":checked").val(),
			colour2: this.ui.colour2.filter(":checked").val()
		};
		if (this.options.type != "edit") {
			data.tenant_id = BFApp.constants.getTenantId("Mitoo");
		}
		return data;
	}

});