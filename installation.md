---
layout: default
title: Installation
---

installation
============

Opentip uses adapters to make the framework available for all major frameworks
and provides a *native adapter* that works without framework.  
Use any of the following methods depending on the framework you use:


### Component

To install Opentip as [component](https://github.com/component) just specify
it as dependency in your `component.json` file:

```json
"dependencies": { "enyo/opentip": "*" }
```

To activate it you still have to include it once in your app:

```js
require("opentip");
```

### Ender

To install Opentip with [ender](http://ender.no.de) simply type one of these:

{% highlight bash %}
$ ender build opentip # to create a new build
$ ender add opentip   # if you already have an ender build
{% endhighlight %}



### jQuery, Prototype, Native

Download the appropriate build from github:

- [jQuery build](#)
- [Prototype build](#)
- [Native build](#) (No framework needed)



css
---

You also need to download and include the Opentip CSS file. Download the
[CSS from github](https://github.com/enyo/opentip/raw).

* * *

embedding
=========

You have to embed the **Javascript** files and the **CSS** in your page.

{% highlight html %}
<script src="path/to/opentip.js"></script>
<link href="path/to/opentip.css" rel="stylesheet" type="text/css" />
{% endhighlight %}

* * *

That's it. Opentip now automatically scans the document to find any elements
with a `data-ot` attribute. To programmatically create Opentips please refer
to the [documentation](/documentation.html).