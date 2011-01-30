# Opentip
The [opentip][opentip]-class is a free opensource Java-Script tooltip class based on the [prototype][prototype] framework.

It supports:

- Stems (little pointers)
- Automatic content download with [AJAX][ajax]
- Different styles
- Automatic repositioning of the tooltip if it's not in the viewport of the browser anymore
- All kind of triggers (The tooltip can be triggered by mouse over, click, form submit, … everything you can think of really)
- CSS3 Transitions / Animations if available. (If not, it uses scriptaculous).

## Usage

    <div onmouseover="javascript:Tips.add(this, event, 'Content', { options });"></div>

Or the preferred external method:

	$('elementId').addTip('Content', { options });

For the complete documentation please visit [www.opentip.org][opentip].

## Author
Opentip is written by Matthias Loitsch.<br>
All graphics by Tjandra Mayerhold.

## License
Copyright (c) 2009 Matthias Loitsch<br>
Licenced under the MIT Licence.


[opentip]: http://www.opentip.org/
[prototype]: http://www.prototypejs.org/
[ajax]: http://en.wikipedia.org/wiki/Ajax_(programming)