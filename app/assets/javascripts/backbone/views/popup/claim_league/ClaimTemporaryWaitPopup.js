BFApp.Views.ClaimTemporaryWait = Marionette.Layout.extend({

  template: "backbone/templates/popups/claim_league/claim_temporary_wait",

  className: "temporary-waiting-message",

  events: {
    "submit form": "saveEmail"
  },

  saveEmail: function(e) {
    var that = this;
    e.preventDefault();

    var isEmail = BFApp.validation.isEmail({
      htmlObject: that.$("input[name='email']")
    });

    if (isEmail) {
      disableButton(this.$('[type="submit"]'));

      var email = that.$("input[name='email']").val();
      $.ajax({
        type: "post",
        url: "/api/v1/users/registrations?save_type=USERCLAIMLEAGUE",
        dataType: 'json',
        data: {
          user: {
            name: email,
            email: email
          },
          league_id: that.options.leagueID,
        },
        success: function(data) {
          analytics.track("Send email via claim popup");
          that.$('.text-confirmation').removeClass("hide");
          that.$("form").addClass("hide");
        },
        error: function(response) {
          errorHandler({
            button: that.$("button")
          });
        }
      });
    }
  },

  serializeData: function() {
    return {
      leagueName: this.options.leagueName
    };
  }

});