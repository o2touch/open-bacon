/**
 * Standings and Adjustments
 */
BFApp.Views.StandingsTable = Marionette.ItemView.extend({

  template: "backbone/templates/common/content/results/standings_table",

  className: "standings-table",

  events: {
    "click .expand-table": "clickedExpand",
    "click button[name='save']": "submitAdjustment"
  },

  ui: {
    "expandTableButton": ".expand-table",
    "adjustButton": "button[name='save']",
    "adjustTeam": "select[name='team']",
    "adjustDesc": "input[name='desc']",
    "adjustAmount": "input[name='amount']"
  },

  initialize: function(options) {
    this.ld = options.ld;
    this.isExpanded = false;
  },

  serializeData: function() {
    var standings_obj = this.ld.division.get("standings");

    var standings = standings_obj["data"];
    var series = standings_obj["series"];
    var adjustments = this.ld.division.get("points_adjustments");

    return {
      isAdmin: this.ld.adminUser,
      // apparently this is the neatest way to get the first element from a JS object?!
      cols: _.values(standings)[0],
      teams: this.ld.division.get("teams"),
      standings: standings,
      series: series,
      adjustments: adjustments,
      hasAdjustments: (adjustments && _.size(adjustments))
    };
  },

  onShow: function() {
    this.ui.expandTableButton.hide();
    this.collapseTable();
  },

  collapseTable: function() {
    var that = this;
    this.$("table.standings tbody tr").each(function(index) {
      if (index > 4) {
        $(this).hide();
        that.ui.expandTableButton.show();
      }
    });
    this.isExpanded = false;
    this.updateInformation();
  },

  expandTable: function() {
    this.$("table.standings tbody tr").show();
    this.isExpanded = true;
    this.updateInformation();
  },

  updateInformation: function() {
    var totalTeam = 0;
    var visibleTeam = 0;
    this.$("table.standings tbody tr").each(function(index) {
      totalTeam += 1;
      if ($(this).is(":visible")) {
        visibleTeam += 1;
      }
    });

    if (totalTeam !== visibleTeam) {
      this.$(".team-number").text("(" + visibleTeam + "/" + totalTeam + ")");
    } else {
      this.$(".team-number").text("");
    }
  },

  clickedExpand: function() {
    if (this.isExpanded) {
      this.collapseTable();
      this.ui.expandTableButton.text(this.ui.expandTableButton.data("show"));
    } else {
      this.expandTable();
      this.ui.expandTableButton.text(this.ui.expandTableButton.data("hide"));
    }
  },

  validate: function() {
    var desc = BFApp.validation.validateInput({
      htmlObject: this.ui.adjustDesc,
      require: true
    });

    var amount = BFApp.validation.validateInput({
      htmlObject: this.ui.adjustAmount,
      require: true,
      regex: BFApp.validation.regex.nonZeroNum,
      regexMessage: BFApp.validation.msg.adjustmentAmountRegex
    });

    return (desc && amount);
  },

  submitAdjustment: function() {
    if (this.validate()) {
      disableButton(this.ui.adjustButton);

      var adjustment = this.ui.adjustAmount.val();
      // ignore any leading +
      if (adjustment.substr(0, 1) == "+") {
        adjustment = adjustment.substr(1);
      }

      var that = this;
      $.ajax({
        type: "post",
        url: "/api/v1/divisions/" + this.ld.division.get("id") + "/points_adjustments",
        dataType: 'json',
        data: {
          points_adjustment: {
            team_id: this.ui.adjustTeam.val(),
            desc: this.ui.adjustDesc.val(),
            adjustment: adjustment
          }
        },
        success: function(data) {
          that.ld.division.get("points_adjustments").push(data);
          that.trigger("reload:standings");
        },
        error: function() {
          errorHandler({
            button: that.ui.adjustButton
          });
        }
      });
    }
    return false;
  }

});