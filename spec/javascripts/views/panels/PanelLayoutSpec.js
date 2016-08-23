describe("BFApp.Views.PanelLayout", function() {

  it("create the view and show Spinner", function() {
    panelLayout = new BFApp.Views.PanelLayout();
    var showLoadingSpy = sinon.spy(panelLayout, "showLoading");

    panelLayout.render();
    panelLayout.onShow();

    expect(panelLayout.el.nodeName).toEqual("DIV");
    expect(panelLayout.$el).toHaveClass('panel');
    expect(showLoadingSpy).toHaveBeenCalledOnce();

    expect(panelLayout.$el.find(".panel-content").length).toEqual(1);
    expect(panelLayout.$el.find("footer").length).toEqual(0);
    expect(panelLayout.$el.find("header").length).toEqual(0);
  });


  it("diplay header if title is specify", function() {
    var panelLayout = new BFApp.Views.PanelLayout({
      panelTitle: "Title"
    });
    panelLayout.render();

    expect(panelLayout.$el.find("header").length).toEqual(1);
    expect(panelLayout.$el.find("h3").text()).toEqual("Title");
  });

  it("diplay tips if tips is specify", function() {
    var panelLayout = new BFApp.Views.PanelLayout({
      panelTips: {
        text: "text",
        link: {
          url: "www",
          short: "linkname"
        }
      }
    });

    panelLayout.render();
    expect(panelLayout.$el.find("footer").length).toEqual(1);
    expect(panelLayout.$el.find(".tips").length).toEqual(1);
    expect(panelLayout.$el.find(".tips").text()).toEqual("text - linkname");
    expect(panelLayout.$el.find(".tips a").attr("href")).toEqual("www");
  });

});