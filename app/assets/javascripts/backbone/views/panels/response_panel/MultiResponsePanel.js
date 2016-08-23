BFApp.Views.MultiResponsePanel = Marionette.CollectionView.extend({
	
	appendHtml: function(cv, iv, i) {
		var status = iv.model.get("response_status");
		if(status == 2){
			this.$el.prepend(iv.el);
		}else{
			this.$el.append(iv.el);
		}
	
	}
	
});