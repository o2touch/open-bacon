FadeInRegion = Backbone.Marionette.Region.extend({

  open: function(view){
    var that = this;
    var children = this.$el.children();

    //console.log(children);

    children.each(function(el){
      //console.log(el);
      el.fadeOut(200, function(){
        that.$el.html(view.el);
        that.$el.fadeIn();
      });
    });

    if(children.length==0){
      this.$el.html(view.el);
      this.$el.fadeIn();
    }
    
  }

});