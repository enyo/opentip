$ = require("jquery");

require("excanvas");
Opentip = require("opentip");

$(function() {

  var scrolled = false;
  var bod = $(document.body);

  Opentip.styles.logo = {
    className: "logo",
    borderWidth: false,
    background: [ [ 0, "#ACE5AE" ], [ 0.5, "#B1EAB3" ], [ 0.5, "#ADE6AF" ], [ 1, "#ADE6AF" ] ],
    shadowColor: "rgba(0, 0, 0, 0.15)",
    stemLength: 3,
    showOn: "creation",
    hideOn: "null",
    target: true,
    autoOffset: false,
    borderRadius: 15,
    offset: [ -40, -50 ]
  };

  var logoOpentip = new Opentip("#header #name", "2.0", { style: "logo" });

  $(window).scroll(function() {
    var scrollTop = bod.scrollTop() || $("html").scrollTop(), showTimeout;

    if (scrollTop > 0) {
      logoOpentip.hide();
      clearTimeout(showTimeout);
    }
    else {
      showTimeout = setTimeout(function() { logoOpentip.show(); }, 500);
    }
    if (scrollTop > 85) {
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
    Opentip.styles.drop = {
      className: "drop",
      borderWidth: 1,
      stemLength: 12,
      stemBase: 16,
      borderRadius: 20,
      borderColor: "#c3e0e6",
      background: [ [ 0, "#f1f7f0" ], [ 1, "#d3f0f6" ] ]
    };

    var box = boxes.find(".styles.box");
    new Opentip(box, "Normal style", { target: true, tipJoint: "left", targetJoint: "bottom right", containInViewport: false });
    new Opentip(box, "Alert style", { style: "alert", target: true, tipJoint: "left", targetJoint: "right", containInViewport: false });
    new Opentip(box, "Dark style", { style: "dark", target: true, tipJoint: "left", targetJoint: "top right", containInViewport: false });
    new Opentip(box, "Glass style", { style: "glass", target: true, tipJoint: "top", targetJoint: "bottom", containInViewport: false });
    new Opentip(box, "drop", { style: "drop", target: true, tipJoint: "bottom", targetJoint: "top", containInViewport: false });

    // Joints and targets
    box = boxes.find(".joints-and-targets.box");
    new Opentip(box, "This tooltip has the AJAX box as target.<br />The <strong>tipJoint</strong> is \"top right\", and the <strong>targetJoint</strong> is \"bottom left\".", { target: ".ajax.box", tipJoint: "top right", stemLength: 15, stemBase: 10 });

    // AJAX
    box = boxes.find(".ajax.box");
    new Opentip(box, { ajax: "ajax.txt" });

    // Stems
    box = boxes.find(".stems.box");
    Opentip.styles.stemsDemo = {
      stem: true,
      containInViewport: false
    };
    new Opentip(box, "Stems...", { style: "stemsDemo", tipJoint: "bottom", stem: "bottom right", stemLength: 10, stemBase: 30 });
    new Opentip(box, ".are...", { style: "stemsDemo", tipJoint: "left", stem: "left", stemLength: 20, stemBase: 10 });
    new Opentip(box, ".very...", { style: "stemsDemo", tipJoint: "right", stem: "bottom" });
    new Opentip(box, ".cool", { style: "stemsDemo", tipJoint: "top right", stem: "top right", stemLength: 30, stemBase: 20 });

    // Canvas
    box = boxes.find(".canvas.box");
    new Opentip(box, "The borders and stems are drawn perfectly, and the shadows do not rely on CSS3.", { borderWidth: 5, stemLength: 18, stemBase: 20, style: "glass", target: true, tipJoint: "top", borderColor: "#317CC5" });

    // AJAX
    box = boxes.find(".more.box");
    new Opentip(box, "Opentip supports all major frameworks: jQuery, prototype, component and ender.<br /><br />Opentips stay inside the browser viewport automatically.<br /><br />Opentips can be grouped so only one in a group is visble at all time.<br /><br />etc...", { style: "dark", target: true, tipJoint: "top" });

  }

});
