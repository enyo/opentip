Contribute
----------

The latest stable version is always in the **[master](https://github.com/enyo/opentip)** branch (which always
points at the latest version tag).

The latest development version is in the **[develop](https://github.com/enyo/opentip/tree/develop)** branch.

> Use the develop branch if you want to contribute or test features.

Please do also **send pull requests to the `develop` branch**.

### Coffeescript

Opentip is written in [Coffeescript](http://coffeescript.org) so *do not* make
changes in the Javascript files. **I will not merge requests written in Javascript.**

### Node

To start the test environment [install node](http://nodejs.org) first if you haven't done so already.

Then go into the `test/` directory and install all dependencies. (You only have
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
adapter changes), so don't worry about compiling coffeescript. When the time comes
to deploy everything, I'll take care of properly bundling all Javascript files.

If you add a change, please make sure that all tests pass!


### Cake

To compile and bundle the library use `cake`.

Just type the command without any arguments `$ cake` in the source directory to list all commands available.

To compile all source files:

```bash
$ cd path/to/opentip-source 
$ cake build
```

> You don't have to do this if you simply want me to merge a change. The test
> webserver compiles on the fly, and I only build and bundle the files before
> I release a new version.

