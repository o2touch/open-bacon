BFApp.Views.ResultsNavigation = Marionette.ItemView.extend({
	
	template: "backbone/templates/profiles/team/content/results/results_navigation",
	
	events: {
		"keyup .results-search": "searchChange"
	},
	
	className:"results-navigation classic",
	tagName:"form",
	
	ui: {
		"search": ".results-search",
	},

	serializeData: function() {
		return {
			showSearch: (this.collection.length > 3)
		};
	},
	
	searchChange: function(e) {
		if(keyIsCharacter(e.keyCode)){
			this.trigger("results-search:changed");
			if(this.ui.search.val()==""){
				this.ui.searchReset.addClass("hide");
			}else{
				this.ui.searchReset.removeClass("hide");
			}
		}
	},

  onRender: function() {
    this.$("input, textarea").placeholder();
    this.$el.submit(function(){
    	return false;
    });
    
    if(this.collection.length < 3){
	    this.$el.hide();
    }
  }

});