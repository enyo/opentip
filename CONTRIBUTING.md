Contribute
==========

The latest stable version is always in the **[master](https://github.com/enyo/opentip)** branch (which always
points at the latest version tag).

The latest development version is in the **[develop](https://github.com/enyo/opentip/tree/develop)** branch.

> Use the develop branch if you want to contribute or test features.

Please do also **send pull requests to the `develop` branch**.
I will **not** merge pull requests to the `master` branch.


Make sure that changes pass all [tests](#testing).


### Coffeescript & Stylus (-> Javascript & CSS)

Opentip is written in [Coffeescript](http://coffeescript.org) and
[Stylus](http://learnboost.github.com/stylus/) so *do not* make
changes to the Javascript or CSS files

**I will not merge requests written in Javascript or CSS.**

Getting started
---------------

You need node to compile and test Opentip. So [install node](http://nodejs.org)
first if you haven't done so already.


### Building Opentip


First you have to setup the node modules to build Opentip. Simply run this in
the Opentip directory:

```bash
$ npm install
```

This will setup [Grunt](http://gruntjs.com) so you can compile Coffeescript and
Stylus and generate the download files.

To get a list of available commands use `grunt -h`.

The most important command is

```bash
$ grunt watch
```

This will observe any change to a coffeescript or stylus file and compile it
immediately.


> Please only submit commits with changed `.coffee` and `.stylus` files and do
> *not* include the compiled JS or CSS files.


### Testing

To test the library make sure that the source has been compiled with `grunt js`
(as mentioned before, use `grunt watch` to always stay up to date) and then
either type `npm test` to run the tests on the command line, or open the
file `test/test.html` in a browser.

It should look like this:

![Tests screenshot](https://raw.github.com/enyo/opentip/develop/files/tests.png)

All tests are located in `test/src` and are written in coffeescript.

If you add a change, please make sure that all tests pass!

