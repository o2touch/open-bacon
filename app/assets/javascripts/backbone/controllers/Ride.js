BFApp.Controllers.Ride = Marionette.Controller.extend({

	initialize:function(){
		this.NextStepSelector = 0;
	},
	
	initEventTour:function(layout){
		this.tourStep = {
			"step":[
				{
					"selector" :"#r-gamecard",
					"title":"Event",
					"description":"event card copy"
				},
				{
					"selector" :".primary-content",
					"title":"Activity",
					"description":"Everybody is responding!"
				},
				{
					"selector" :"#reminders-container",
					"title":"Reminders panel",
					"description":"Hit ‘Send reminders’, to remind everyone (yourself included) to respond"
				},
				
				{
					"selector" :"#teamsheet-container",
					"title":"Teamsheet panel",
					"description":"See all your player running around"
				},
				{
					"selector" :"#action-container",
					"title":"Action panel",
					"description":"See all your player running around"
				}
			]
		}
		
		this.tourLayout = layout.eventTour;
		this.analyticsName = "Event Tour - user flow";
		this.analyticsScenario = "the user ";
	},
	
	
	startTour:function(){
		$("body").append("<div class='grey-overlay'></div>");
		this.introduction();
	},
	
	endTour:function(){
		this.tourLayout.close();
		$(".grey-overlay").remove();
		var that = this;
		analytics.track(that.analyticsName, {
			user: ActiveApp.CurrentUser.get("id"),
			scenario: that.analyticsScenario
		});
		
	},
	
	introduction:function(){
		var that = this;
		var rideIntroView = new BFApp.Views.RideIntroduction();
		
		this.tourLayout.show(rideIntroView);
		
		this.analyticsScenario+="see the introduction";
		
		rideIntroView.on("next:clicked", function(){
			that.nextStep(true);
		});
		
		rideIntroView.on("exit:clicked", function(){
			that.analyticsScenario+= ", then quit immediatly";
			that.endTour();
		});
	},
	
	
	conclusion:function(){

		$(this.tourStep.step[this.NextStepSelector -1].selector).css({
			"z-index" : "0",
			"position": "inherit"
		});
		
		var that = this;
		var rideConclusionView = new BFApp.Views.RideConclusion();
		this.tourLayout.show(rideConclusionView);
		that.analyticsScenario+= ", see the conclusion";
		rideConclusionView.on("exit:clicked", function(){
			that.endTour()
		});
	},
	
	
	nextStep:function(firstStep){
		var that = this;
		this.analyticsScenario+= ", step " + (this.NextStepSelector+1) + "/" + this.tourStep.step.length;
		
		if(!firstStep){
			$(this.tourStep.step[this.NextStepSelector - 1].selector).css({
				"z-index" : "",
				"position": ""
			});
		}
		
		var htmlObjectSelector = $(this.tourStep.step[this.NextStepSelector].selector);
		
		htmlObjectSelector.css({
			"z-index" : "4001",
			"position": (htmlObjectSelector.css("position") == "absolute") ? "absolute" : "relative"
		});
		
		var rideStep = new BFApp.Views.RideStep({
			stickyElement: htmlObjectSelector,
			title: this.tourStep.step[this.NextStepSelector].title,
			description: this.tourStep.step[this.NextStepSelector].description
		});
		
		this.tourLayout.show(rideStep);
	
		this.NextStepSelector+=1;
		var that = this;
		rideStep.on("next:clicked", function(){
			if(that.NextStepSelector < that.tourStep.step.length){
				that.nextStep()
			}else{
				that.conclusion()
			}
		});
		
		rideStep.on("exit:clicked", function(){
			that.analyticsScenario+= ", then exit tour";
			that.endTour()
		});
		
	},
	

});