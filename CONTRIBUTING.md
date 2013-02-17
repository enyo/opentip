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

This will setup Coffeescript, Stylus and a few other dependencies to build and
bundle the library.

To compile (build) and bundle the library use `cake`.

Just type the command without any arguments `$ cake` in the source directory to
list all commands available. It will look something like this:

```bash
cake docs                 # generate documentation
cake build                # compile source
cake watch                # compile and watch
cake css                  # compile stylus
cake watchcss             # compile and watch stylus
```

To compile all source files:

```bash
$ cd path/to/opentip-source 
$ cake build
```

> I prefer pull requests that only changed `.coffee` and `.stylus` files, since
> I only checkin the `.css` and `.js` files before a release. But I accept
> pull requests that contain the compiled files as well.


### Testing

Go into the `test/` directory and install all dependencies. (You only have
to do this the first time):

```bash
$ cd test/
$ npm install
```

And you're ready to launch the server:

```bash
$ ./server.js
```

Now simply visit `http://localhost:3000` in your browser to see the tests.

It should look like this:

![Tests screenshot](https://raw.github.com/enyo/opentip/develop/files/tests.png)

All tests are located in `assets/js/tests/` and are written in coffeescript but
compiled on the fly.

The webserver also automatically compiles any opentip changes (as well as the
adapter changes), so don't worry about compiling coffeescript. When the time
comes to deploy everything, I'll take care of properly bundling all Javascript
files.

If you add a change, please make sure that all tests pass!

