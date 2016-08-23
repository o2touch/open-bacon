BFApp.Views.UserCardView = Marionette.ItemView.extend({
	template: "backbone/templates/profiles/user/content/user_card",

	serializeData:function(){
		return {
			name: this.model.get("name"),
			htmlPic: this.model.getPictureHtml("medium"),
			events: user_meta.numUserEvents,
			teams: user_meta.numUserTeams,
			friends: user_meta.numUserFriends,
			
		};
	}

});
