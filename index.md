---
layout: default
title: The free tooltip
---

<script>

App.demo();
</script>

<h1 id="intro" markdown="1">
  opentip is a javascript tooltip framework  
  yes - it's free, open source and comes with different styles!
</h1>

* * *


demo
====

<div class="demo-boxes">
  <div class="styles box">
    <h2>styles</h2>
    <p>
      There are great styles built right into opentip and it's easy to create
      your own.
    </p>
  </div>

  <!--
  <div class="effects box">
    <h2>effects</h2>
    <p>
      Out of the box, opentips have nice fade in and fade out effects, but it's
      very easy to adapt the effects to your needs.
    </p>
  </div>
  -->
  <div class="ajax box">
    <h2>ajax</h2>
    <p>
      Opentips can automatically download their contents via AJAX. It's
      extremely easy to configure them to do so.
    </p>
  </div>
  <div class="joints-and-targets box">
    <h2>joints&amp;targets</h2>
    <p>
      Joints and targets allow you to position the tooltip exactly where you
      want it.
    </p>
  </div>
  <div class="stems box">
    <h2>stems</h2>
    <p>
      Stems are those little pointers. You can configure them to point in any
      direction.
    </p>
  </div>
  <div class="canvas box">
    <h2>canvas</h2>
    <p>
      Opentips are drawn on canvas which creates beautifully rendered tooltips
      in all browsers.
    </p>
  </div>
  <div class="more box">
    <h2>many more...</h2>
    <p markdown="1">
      There are many more features! Dive into the [documentation] to get more information.
    </p>
  </div>
</div>


<div class="columns">
  <div class="left">

    <div id="show-your-work">
      <img src="/images/show_your_work.png" alt="Show your work" />

      <h2>showcase</h2>
      
      <p>If you built a website using Opentip, <a href="mailto:m@tias.me">tell me about it</a>!
      I'm building a showcase and would be happy to include your work.</p>
      

    </div>
  </div>

  <div class="right">

    <h2>browser support</h2>

    <p>
      Opentip has been developed for and tested in all major browser, including IE7+.
    </p>

    <img src="/images/browser_logos.png" alt="Browser support" />

  </div>
</div>




usage
=====

Creating a tooltip is really easy.  
The easiest way to define a tooltip is with element tags:

{% highlight html %}
<div data-ot="Shown after 2 seconds" data-ot-delay="2"></div>
{% endhighlight %}

All tooltip options can be passed like this. Just prefix them with `data-ot-`
and use dashes (eg.: `data-ot-hide-trigger="closeButton"`).


To create a tooltip with Javascript you can instantiate the `Opentip`
class like this:

{% highlight javascript %}
new Opentip("#my-element", "Shown after 2 seconds", { delay: 2 });
// Or within your framework, eg.: ender, jQuery, prototype
$("#my-element").opentip("Shown after 2 seconds", { delay: 2 });
{% endhighlight %}



For a list of valid options and the complete documentation please visit the
[documentation] page.


[documentation]: /documentation.html

