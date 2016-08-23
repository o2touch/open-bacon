BFApp.Views.TenantSelect = Marionette.ItemView.extend({

  template: "backbone/templates/partials/tenant_select",

  tagName: 'form',

  className: 'classic tenant-form',

  ui: {
    tenantSelect: "select[name=tenant]"
  },

  serializeData: function() {
    return {
      tenants: BFApp.constants.tenants
    };
  },

  onRender: function() {
    // probably should pass this in as an option
    this.ui.tenantSelect.val(BFApp.constants.getTenantId("O2 Touch"));
  }

});