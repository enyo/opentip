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

The `content` and `title` are optional but it doesn't make much sense to ommit
the `content` unless the content gets downloaded with **AJAX**.

* * *

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
  can be ommited.

  ![Joints examples](images/joints.png)

- `OFFSET`  
  An array with `x` and `y` position as contents.

  Example: `[ 100, 50 ]`

* * *

- `title` *\[ String \]*  
  You can pass the title in the constructor, or as option

- `escapeTitle` *\[ Boolean \]*, Default: `true`  
  Whether the provided title should be html escaped

- `escapeContent` *\[ Boolean \]*, Default: `false`  
  Whether the content should be html escaped

- `className` *\[ String \]*, Default: `"Standard"`  
  The class name of the style. Opentip will get this class prefixed with `style-`

- `stem` *\[ Boolean | JOINT \]*, Default: `true`  
  Defines the stem.
  - `false`: No stem
  - `true`: Stem at the `tipJoint`
  - `JOINT`: Define where to place the stem

- `delay` *\[ Float | null \]*, Default: `null`  
  The delay after which the opentip should be shown in seconds. If null Opentip decides which
  time to use (0.2 for mouseover, 0 for click).

- `hideDelay` *\[ Float \]*, Default: `0.1`  
  The delay after which an opentip should be hidden in seconds.

- `fixed` *\[ Boolean \]*, Default: `false`  
  If the target is not null, elements are always fixed. Fixed Opentips without
  target appear at the position of the cursor but don't follow the mouse when visible.

- `showOn` *\[ Event name | "creation" | null \]*, Default: `mouseover`  
  - `eventname` Eg.: `"click"`, `"mouseover"`, etc..
  - `"creation"` the tooltip will show when created
  - `null` if you want to handle it yourself (Opentip will not register any events)

- `hideTrigger` *\[ "trigger" | "tip" | "target" | "closeButton" | ELEMENT \]*, Default: `"trigger"`  
  This is just a shortcut, and will be added to the `hideTriggers` array.

- `hideTriggers` *\[ Array \]*, Default: `[ ]`  
  An array of hideTriggers. Defines which elements should trigger the hiding of an Opentip.

- `hideOn` *\[ Event name | Array of eventnames | null \]*, Default: `null`  
  If null Opentip decides which event is best based on the hideTrigger.

- `offset` *\[ OFFSET \]*, Default: `[ 0, 0 ]`  

- `containInViewport` *\[ Boolean \]*, Default: `true`  
  Whether the targetJoint/tipJoint should be changed if the tooltip is not in
  the viewport anymore.

- `autoOffset` *\[ Boolean \]*, Default: `true`  
  If set to true, offsets are calculated automatically to position the tooltip
  (pixels are added if there are stems for example). This should stay `true` unless
  you manually position the tooltip.

- `showEffect` *\[ String \]*, Default: `appear`  
  Will be added as class to the Opentip element with `"show-effect-"` as prefix.

- `hideEffect` *\[ String \]*, Default: `fade`  
  Will be added as class to the Opentip element with `"hide-effect-"` as prefix.

- `showEffectDuration` *\[ Float \]*, Default: `0.3`  

- `hideEffectDuration` *\[ Float \]*, Default: `0.2`  

- `stemLength` *\[ Integer \]*, Default: `5`  

- `stemBase` *\[ Integer \]*, Default: `8`  

- `tipJoint` *\[ JOINT \]*, Default: `"top left"`  
  Defines where the tooltip should be attached. If the `tipJoint` is `"top left"`
  then the tooltip will position itself so the top left corner will be at the
  targetJoint.

- `target` *\[ ELEMENT | true | null \]*, Default: `null`  
  - `null` No target, Opentip uses the cursor position as target.
  - `true` The `triggerElement` will be used as target.
  - `ELEMENT` Any element you provide.

- `targetJoint` *\[ JOINT | null \]*, Default: `null`  
  - `JOINT` the joint of the target to align with. Will be ignored if no target.
  - `null` Opentip will use the opposite of the tipJoint.

- `ajax` *\[ Boolean | String \]*, Default: `false`  
  - `false` No AJAX
  - `true` Opentip uses the `href` attribute of the trigger element if the
    trigger element is a link.
  - `String` An URL to download the content from.

- `ajaxMethod` *\[ "GET" | "POST" \]*, Default: `"GET"`  

- `ajaxCache` *\[ Boolean \]*, Default: `yes`  
  If `false`, the content will be downloaded every time the tooltip is shown.

- `group` *\[ String | null \]*, Default: `null`  
  You can group opentips together. So when a tooltip shows, it looks if there are others in the same group, and hides them.

- `style` *\[ String | null \]*, Default: `null`  
  Will be set automatically in constructor

- `background` *\[ String | Array \]*, Default: `"#fff18f"`  
  The background color of the tip. This can be an array of gradient points.
  Eg.: `[ [ 0, "white" ], [ 1, "black" ] ]` Defines a gradient from white to black.

- `closeButtonOffset` *\[ Offset \]*, Default: `[ 5, 5 ]`  
  Positive values offset inside the tooltip

- `closeButtonRadius` *\[ Float \]*, Default: `7`  
  The little circle that stick out of a tip

- `closeButtonCrossSize` *\[ Float \]*, Default: `4`  
  Size of the cross

- `closeButtonCrossColor` *\[ String \]*, Default: `"#d2c35b"`  
  Color of the cross

- `closeButtonCrossLineWidth` *\[ Float \]*, Default: `1.5`  
  The stroke width of the cross

- `closeButtonLinkOverscan` *\[ Float \]*, Default: `6`  
  You will most probably never want to change this.
  It specifies how many pixels the invisible `<a />` element should be larger
  than the actual cross

- `borderRadius` *\[ Float \]*, Default: `5`  
  Border radius...

- `borderWidth` *\[ Float \]*, Default: `1`  
  Set to 0 or false if you don't want a border

- `borderColor` *\[ String \]*, Default: `"#f2e37b"`  
  Color of the border

- `shadow` *\[ Boolean \]*, Default: `true`  
  Set to false if you don't want a shadow

- `shadowBlur` *\[ Float \]*, Default: `10`  
  How the shadow should be blurred. Set to 0 if you want a hard drop shadow 

- `shadowOffset` *\[ Offset \]*, Default: `[ 3, 3 ]`  

- `shadowColor` *\[ String \]*, Default: `"rgba(0, 0, 0, 0.1)"`  
