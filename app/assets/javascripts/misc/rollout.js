Rollout = {
	groups: [],
	
	activate: function(group_name){
		this.groups[group_name] = true;
	},
	
	active: function(group_name){
		return (this.groups[group_name]==true)
	}
}
