---
layout: default
title: The free tooltip
---

<h1 id="intro" markdown="1">
  opentip is a javascript tooltip framework  
  yes - it's free, open source and comes with different styles!
</h1>

* * *

demo
====

<div id="demo-boxes">
  <div class="styles box">
    <h2>styles</h2>
    <p>
      There are great styles built right into opentip and it's easy to create
      your own.
    </p>
  </div>
  <div class="effects box">
    <h2>effects</h2>
    <p>
      Out of the box, opentips have nice fade in and fade out effects, but it's
      very easy to adapt the effects to your needs.
    </p>
  </div>
  <div class="ajax box">
    <h2>ajax</h2>
    <p>
      Opentips can automatically download their contents via AJAX. It's
      extremely easy to configure them to do so.
    </p>
  </div>
  <div class="joints-and-targets box">
    <h2>joints &amp; targets</h2>
    <p>
      Joints and targets allow you to position the tooltip.
    </p>
  </div>
  <div class="stems box">
    <h2>stems</h2>
    <p>
      Stems are those little pointers.
    </p>
  </div>
  <div class="events box">
    <h2>events</h2>
    <p>
      You can trigger tooltips with any event you like: mouseovers, focus, etc...
    </p>
  </div>
</div>

* * *


implementation
==============

Creating a tooltip is really easy.  
The easiest way to define a tooltip is with element tags:

{% highlight html %}
<div data-ot="Shown after 2 seconds" data-ot-delay="2"></div>
{% endhighlight %}

All tooltip options can be passed like this. Just prefix them with `data-ot-`
and use dashes (eg.: `data-ot-show-effect="blindDown"`).

To create a tooltip with Javascript you can instantiate the `Opentip`
class like this:

{% highlight javascript %}
new Opentip("#my-element", "Shown after 2 seconds", { delay: 2 });
// Or within your framework, eg.: ender
$("#my-element").opentip("Shown after 2 seconds", { delay: 2 });
{% endhighlight %}



For a list of valid options and the complete documentation please visit the
[documentation](/documentation) page.

