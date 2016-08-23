BFApp.Views.ResultsEventRow = BFApp.Views.EventRow.extend({

  customRender: function() {
    if (((ActiveApp.ProfileTeam) && this.model.get("permissions").canEdit && this.model.get('game_type_string') == 'game')) {
      var editPanel = new BFApp.Views.EventRowEditScore({
        model: this.model
      });
      this.$el.append(editPanel.render().el).addClass('can-edit-score');
    }
  }

});