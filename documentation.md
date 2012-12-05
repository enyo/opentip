---
layout: default
title: Documentation
---

documentation
=============

To programmatically instantiate an Opentip you use this syntax:

{% highlight javascript %}
new Opentip("#my-element", "Optional content", "Optional title", { ...options... })
{% endhighlight %}

The `content` and `title` are optional but it doesn't make much sense to omit
the `content` unless the content gets downloaded with **AJAX**.


Alternatively you can use html attributes to create opentips:

### html attributes


When the document is loaded Opentip scans the document and finds all elements
with a `data-ot` attribute, and instantiates an Opentip automatically. To
configure the Opentip this way simply add attributes beginning with `data-ot-`
and the *dashed* option name. Example:

{% highlight html %}
<div data-ot="The content" data-ot-delay="2" data-ot-hide-trigger="closeButton">Hover me</div>
{% endhighlight %}


* * *


options
-------

### Glossary



- `JOINT`  
  Defines a position inside an Opentip. This is a case insensitive
  string with a horizontal position (`left`, `center`, `right`) and a vertical
  position (`top`, `middle`, `bottom`) in any order where `center` and `middle`
  can be omited.

  ![Joints examples](images/joints.png)

- `OFFSET`  
  An array with `x` and `y` position as contents.

  Example: `[ 100, 50 ]`

* * *


Option                      | Type                                                       | Default                | Comment
----------------------------|------------------------------------------------------------|------------------------|--------------------------------------------------------------------------------
`title`                     | String                                                     |                        | You can pass the title in the constructor, or as option
`escapeTitle`               | Boolean                                                    | `true`                 | Whether the provided title should be html escaped
`escapeContent`             | Boolean                                                    | `false`                | Whether the content should be html escaped
`className`                 | String                                                     | `"Standard"`           | The class name of the style. Opentip will get this class prefixed with `style-`
`stem`                      | Boolean, JOINT                                             | `true`                 | Defines the stem. <br />`false`: No stem <br />`true`: Stem at the `tipJoint` <br />`JOINT`: Define where to place the stem
`delay`                     | Float, `null`                                              | `null`                 | The delay after which the opentip should be shown in seconds. If null Opentip decides which time to use (0.2 for mouseover, 0 for click).
`hideDelay`                 | Float                                                      | `0.1`                  | The delay after which an opentip should be hidden in seconds.
`fixed`                     | Boolean                                                    | `false`                | If the target is not null, elements are always fixed. Fixed Opentips without target appear at the position of the cursor but don't follow the mouse when visible.
`showOn`                    | Event name, `"creation"`, `null`                           | `mouseover`            | `eventname` Eg.: `"click"`, `"mouseover"`, etc..<br />`"creation"` the tooltip will show when created<br />`null` if you want to handle it yourself (Opentip will not register any events)
`hideTrigger`               | `"trigger"`, `"tip"`, `"target"`, `"closeButton"`, ELEMENT | `"trigger"`            | This is just a shortcut, and will be added to the `hideTriggers` array.
`hideTriggers`              | Array                                                      | `[ ]`                  | An array of hideTriggers. Defines which elements should trigger the hiding of an Opentip.
`hideOn`                    | Event name, Array of eventnames, `null`                    | `null`                 | If null Opentip decides which event is best based on the hideTrigger.
`offset`                    | OFFSET                                                     | `[ 0, 0 ]`             | Additional offset of the tooltip
`containInViewport`         | Boolean                                                    | `true`                 | Whether the targetJoint/tipJoint should be changed if the tooltip is not in the viewport anymore.
`autoOffset`                | Boolean                                                    | `true`                 | If set to true, offsets are calculated automatically to position the tooltip (pixels are added if there are stems for example). This should stay `true` unless you manually position the tooltip.
`showEffect`                | String                                                     | `appear`               | Will be added as class to the Opentip element with `"show-effect-"` as prefix.
`hideEffect`                | String                                                     | `fade`                 | Will be added as class to the Opentip element with `"hide-effect-"` as prefix.
`showEffectDuration`        | Float                                                      | `0.3`                  | &nbsp;
`hideEffectDuration`        | Float                                                      | `0.2`                  | &nbsp; 
`stemLength`                | Integer                                                    | `5`                    | &nbsp;
`stemBase`                  | Integer                                                    | `8`                    | &nbsp;
`tipJoint`                  | JOINT                                                      | `"top left"`           | Defines where the tooltip should be attached. If the `tipJoint` is `"top left"` then the tooltip will position itself so the top left corner will be at the targetJoint.
`target`                    | ELEMENT, true, null                                        | `null`                 | `null` No target, Opentip uses the cursor position as target.<br />`true` The `triggerElement` will be used as target.<br />`ELEMENT` Any element you provide.
`targetJoint`               | JOINT, null                                                | `null`                 | `JOINT` the joint of the target to align with. Will be ignored if no target.<br />`null` Opentip will use the opposite of the tipJoint.
`ajax`                      | Boolean, String                                            | `false`                | `false` No AJAX<br />`true` Opentip uses the `href` attribute of the trigger element if the trigger element is a link.<br />`String` An URL to download the content from.<br />
`ajaxMethod`                | `"GET"`, `"POST"`                                          | `"GET"`                | &nbsp; 
`ajaxCache`                 | Boolean                                                    | `yes`                  | If `false`, the content will be downloaded every time the tooltip is shown.
`group`                     | String, `null`                                             | `null`                 | You can group opentips together. So when a tooltip shows, it looks if there are others in the same group, and hides them.
`style`                     | String, `null`                                             | `null`                 | Will be set automatically in constructor
`background`                | String, Array                                              | `"#fff18f"`            | The background color of the tip. This can be an array of gradient points.<br />Eg.: `[ [ 0, "white" ], [ 1, "black" ] ]` Defines a gradient from white to black. Right now only gradients from top to bottom are supported.
`closeButtonOffset`         | Offset                                                     | `[ 5, 5 ]`             | Positive values offset inside the tooltip
`closeButtonRadius`         | Float                                                      | `7`                    | The little circle that stick out of a tip
`closeButtonCrossSize`      | Float                                                      | `4`                    | Size of the cross
`closeButtonCrossColor`     | String                                                     | `"#d2c35b"`            | Color of the cross
`closeButtonCrossLineWidth` | Float                                                      | `1.5`                  | The stroke width of the cross
`closeButtonLinkOverscan`   | Float                                                      | `6`                    | You will most probably never want to change this.<br />It specifies how many pixels the invisible `<a />` element should be larger than the actual cross
`borderRadius`              | Float                                                      | `5`                    | &nbsp; 
`borderWidth`               | Float                                                      | `1`                    | Set to 0 or false if you don't want a border
`borderColor`               | String                                                     | `"#f2e37b"`            | Color of the border
`shadow`                    | Boolean                                                    | `true`                 | Set to false if you don't want a shadow
`shadowBlur`                | Float                                                      | `10`                   | How the shadow should be blurred. Set to 0 if you want a hard drop shadow 
`shadowOffset`              | Offset                                                     | `[ 3, 3 ]`             | &nbsp; 
`shadowColor`               | String                                                     | `"rgba(0,0,0,0.1)"`    | &nbsp; 
