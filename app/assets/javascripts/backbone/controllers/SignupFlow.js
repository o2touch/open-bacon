SFApp.Controllers.SignupFlow = Marionette.Controller.extend({

  team: null,
  organiser: null,
  analyticsProperties: {},

  initialize: function() {
    //console.log("SignupFlow::init");

    // if returning from facebook, there will be a team_uuid
    var team_uuid = getParameterByName("team_uuid");
    var team_id = getParameterByName("team_id");
    //console.log("params: uuid="+team_uuid+", id="+team_id);

    // Check if user has received invite code
    if(typeof window.invitedUser != "undefined"){
      this.organiser = new App.Modelss.User();
      this.organiser.set('name', window.invitedUser.name);
      this.organiser.set('email', window.invitedUser.email);
      this.analyticsProperties = {'type':'Beta Invite'}
      if(typeof _kmq != "undefined"){
        _kmq.push(['set',this.analyticsProperties]);
      }
    }

    if (team_uuid != "" && team_id != "") {
      this.team = new App.Modelss.Team({
        id: team_id,
        uuid: team_uuid
      });
      window.location.hash = "#step3";
    } else {
      window.location.hash = "#step1";
    }
    
    $("body").addClass("signup-bg");


  },




  showTeam: function() {
    //console.log("SignupFlow::showTeam");
    this.kmq("Step 1 - Team");

    // first run
    if (this.team == null) {
      this.team = new App.Modelss.Team();
      this.team.url = "/api/v1/teams/guest_create";
    }
    // already saved - so just updating
    else {
      //console.log("team not null, so updating with uuid from team object = %o",this.team);
      this.team.url = "/api/v1/teams/" + this.team.get("uuid") + "/guest_update";
    }
    var teamView = new SFApp.Views.SignupFlowTeam({
      model: this.team
    });
    SFApp.content.show(teamView);
  },

  showOrganiser: function() {
    //console.log("SignupFlow::showOrganiser");
    this.kmq("Step 2 - Organiser");

    // we need a team uuid for this page
    if (this.team == null) {
      window.location.hash = "#step1";
      return;
    }
    if (this.organiser == null) this.organiser = new App.Modelss.User();
    var teamView = new SFApp.Views.SignupFlowOrganiser({
      model: this.organiser,
      team_uuid: this.team.get("uuid")
    });
    SFApp.content.show(teamView);
  },

  showFacebook: function() {
    //console.log("SignupFlow::showFacebook");
    this.kmq("Step 3 - Facebook");

    // we need a team uuid for this page
    if (this.team == null) {
      window.location.hash = "#step1";
      return;
    }
    var teamView = new SFApp.Views.SignupFlowFacebook({
      team_uuid: this.team.get("uuid")
    });
    SFApp.content.show(teamView);
  },

  showConfirmation: function() {
    //console.log("SignupFlow::showConfirmation");
    this.kmq("Step 4 - Confirmation");

    // we need a team id for this page
    if (this.team == null) {
      window.location.hash = "#step1";
      return;
    }
    var confirmationView = new SFApp.Views.SignupFlowConfirmation({
      team_id: this.team.get("id")
    });
    SFApp.content.show(confirmationView);
  },

  kmq: function(step) {
    var page = 'Sign Up Page - ' + step;
    analytics.track('Viewed ' + page, this.analyticsProperties);
  }

});