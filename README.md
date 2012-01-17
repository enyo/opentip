# Opentip Version 1.4.2

The [opentip][opentip]-class is a free opensource Java-Script tooltip class based on the [prototype][prototype] framework.

It supports:

- Stems (little pointers)
- Automatic content download with [AJAX][ajax]
- Different styles
- Automatic repositioning of the tooltip if it's not in the viewport of the browser anymore
- All kind of triggers (The tooltip can be triggered by mouse over, click, form submit,... everything you can think of really)
- CSS3 Animations if available. (If not, it uses scriptaculous if available).

As of Version 1.2.6 Opentip does no longer depend on scriptaculous.

## Usage

    <div onmouseover="javascript:Tips.add(this, event, 'Content', { options });"></div>

Or the preferred external method:

	$('elementId').addTip('Content', { options });

For the complete documentation please visit [www.opentip.org][opentip].


## Changelog

Here's a list of major changes, so you know what to expect when you upgrade (Minor bugfixes are not listed here!).

### 1.3

- Stems are no longer images, but drawn with canvas. (I'm using [excanvas] for IE < 9). **Remember to include the excanvas.js file.**




## Future plans

- Become library independant. I'm currently working on extracting all prototype functionality, so I can switch library easily. The next library
  I'll support will be jquery, and then mootools.

- Add more skins.

- Add cooler loading animation.

- Implement qunit tests.


If you have ideas, please contact me!


## Tagging

Tagging in this project is done with my [tag script](http://github.com/enyo/tag).


## Author
Opentip is written by Matias Meno.<br>
All graphics by Tjandra Mayerhold.

### Contributors
Thanks to the following people for providing bug reports, feature requests and sometimes fixes:

- Torsten Saam
- Aaron Peckham
- Oguri

If I forgot somebody, please just tell me.

## License
Copyright (c) 2012 Matias Meno<br>
Licenced under the MIT Licence.


[opentip]: http://www.opentip.org/
[prototype]: http://www.prototypejs.org/
[ajax]: http://en.wikipedia.org/wiki/Ajax_(programming)
[excanvas]: http://code.google.com/p/explorercanvas/
