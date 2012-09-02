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
      box.opentip("Normal style", { target: true, tipJoint: "bottom right", targetJoint: "bottom right" });
      box.opentip("Dark style", { style: "dark", target: true, tipJoint: "top right", targetJoint: "top right" });

      // Stems
      var box = boxes.find(".stems.box");
      Opentip.styles.stemsDemo = {
        stem: true,
        containInViewport: false,
      };
      box.opentip("Stems", { style: "stemsDemo", tipJoint: "bottom right", stem: "right" });
      box.opentip("are", { style: "stemsDemo", tipJoint: "bottom", stem: "right" });
      box.opentip("very", { style: "stemsDemo", tipJoint: "bottom left", stem: "bottom", stemLength: 20, stemBase: 20 });
      box.opentip("cool", { style: "stemsDemo", tipJoint: "left", stem: "left", stemLength: 20, stemBase: 20 });
    }

  });
})(ender)