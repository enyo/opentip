---
layout: default
title: Installation
---

installation
============

Opentip uses adapters to make the framework available for all major frameworks
and provides a *native adapter* that works without framework.  

> **You have to first include opentip, and then the adapter of the framework you use:**

jQuery, Prototype, Native
-------------------------


First download the the appropriate [opentip bundle from github](https://github.com/enyo/opentip/tree/master/downloads)
for your framework. (Example: if you're using jQuery, download either `opentip-jquery.js` or if
you also want to support <=IE8 `opentip-jquery-excanvas.js`).

You also need to download and include the [Opentip CSS] file.

> If you bundle your scripts yourself, or want to be able to debug opentip,
> use the files from the [lib folder](https://github.com/enyo/opentip/tree/master/lib)
> and include `opentips.js` and `adapter.jquery.js` **in that order**.

### embedding

Now embed the **Javascript** and the **CSS** file in your page.

{% highlight html %}
<script src="path/to/adapter-jquery.js"></script><!-- Change to the adapter you actually use -->
<link href="path/to/opentip.css" rel="stylesheet" type="text/css" />
{% endhighlight %}

That's it. Opentip now automatically scans the document to find any elements
with a `data-ot` attribute. To programmatically create Opentips please refer
to the [documentation](/documentation.html).


(For Internet Explorer 7 & 8 support please see the [internet explorer section](#internet_explorer) below)

* * * 

component
---------

To install Opentip as [component](https://github.com/component) just specify
it as dependency in your `component.json` file:

```json
"dependencies": { "enyo/opentip": "*" }
```

To activate it you still have to include it once in your app:

```js
require("opentip");
```

(Don't forget to include the `build.css` which includes the `opentip.css`).



ender
-----

To install Opentip with [ender](http://ender.no.de) simply type one of these:

{% highlight bash %}
$ ender build opentip # to create a new build
$ ender add opentip   # if you already have an ender build
{% endhighlight %}

(Don't forget to download and add the [Opentip CSS]).


* * * 


internet explorer
-----------------

If you want Opentip to correctly work in <= IE8, you have to include excanvas
as well. Get my [version of excanvas](https://raw.github.com/enyo/excanvas/master/index.js) (which supports IE8).

If you're using component, you can simply add `enyo/excanvas` as dependency, but
**don't forget** to require it before opentip: `require("excanvas");`.



[opentip css]: https://raw.github.com/enyo/opentip/master/css/opentip.css
