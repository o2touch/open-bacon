BFApp.Views.FaftEmailClubPanel = Marionette.ItemView.extend({

  className: "club-create-signup",

  template: "backbone/templates/faft/panel/faft_email_club_panel",

  events: {
    "submit .club-form": "sendQuery",
    "change .club-form input[name='email-me']": "toggleEnable",
    "click .show-create-club-form-link": "showForm"
  },

  toggleEnable: function(e) {
    if ($(e.currentTarget).is(":checked")) {
      enableButton(this.$(".club-form button"));
    } else {
      disableButton(this.$(".club-form button"), false);
    }
  },

  showForm: function(e) {
    e.preventDefault();
    this.$(".hide-after-click").addClass("hide");
    this.$(".club-create-hidden").removeClass("hide");
  },


  sendQuery: function(e) {
    var that = this;
    e.preventDefault();
    var data = {
      club: this.$(".club-form input[name='club']").val(),
      user: this.$(".club-form input[name='user-name']").val(),
      email: this.$(".club-form input[name='user-email']").val(),
      position: this.$(".club-form input[name='club-position']").val(),
      emailMe: this.$(".club-form input[name='email-me']").is(":checked")
    }

    var club = (this.$(".club-form input[name='club']").val().length > 4);
    var email = BFApp.validation.isEmail({
      htmlObject: this.$(".club-form input[name='user-email']")
    });

    var name = BFApp.validation.isName({
      htmlObject: this.$(".club-form input[name='user-name']")
    });

    if (club && email && name) {

      disableButton(this.$(".club-form button"));

      $.ajax({
        type: "post",
        url: "/contact_requests/create",
        dataType: 'json',
        data: data,

        success: function(data) {
          that.$(".message-confirmation").removeClass("hide");
          that.$(".club-form input").val("").text("");
          enableButton(that.$(".club-form button"));
        },
        error: function(data) {
          errorHandler({
            button: that.$(".club-form button")
          });
        }
      });

    }
  },


});