(function($) {
  $.domReady(function() {
    var scrolled = false;
    var bod = $(document.body);

    $(document).scroll(function() {
      if (bod.scrollTop() > 85) {
        if (scrolled) return;
        scrolled = true;
        bod.addClass("scroll");
      }
      else {
        if (!scrolled) return;
        scrolled = false;
        bod.removeClass("scroll");
      }
    });


    var boxes = $("#demo-boxes");
    if (boxes.length) {
      // Styles
      var box = boxes.find(".styles.box");
      box.opentip("Normal style", { target: true, tipJoint: "left", targetJoint: "bottom right" });
      box.opentip("Alert style", { style: "alert", target: true, tipJoint: "left", targetJoint: "right" });
      box.opentip("Dark style", { style: "dark", target: true, tipJoint: "left", targetJoint: "top right" });
      box.opentip("Glass style", { style: "glass", target: true, tipJoint: "top", targetJoint: "bottom" });
      box.opentip("Funny style", { style: "standard", target: true, tipJoint: "bottom", targetJoint: "top" });

      // Stems
      var box = boxes.find(".stems.box");
      Opentip.styles.stemsDemo = {
        stem: true,
        containInViewport: false,
      };
      box.opentip("Stems...", { style: "stemsDemo", tipJoint: "bottom", stem: "bottom right", stemLength: 10, stemBase: 30 });
      box.opentip("...are...", { style: "stemsDemo", tipJoint: "left", stem: "left", stemLength: 20, stemBase: 10 });
      box.opentip("...very...", { style: "stemsDemo", tipJoint: "right", stem: "bottom" });
      box.opentip("...cool", { style: "stemsDemo", tipJoint: "top right", stem: "top right", stemLength: 30, stemBase: 20 });
    }

  });
})(ender)