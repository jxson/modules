Makefile

The build tool for this project is a [self-documented Makefile](http://clarkgrubb.com/makefile-style-guide) that allows a simple `make help` task to print details about available tasks. For any new tasks which are intended to be run directly by contributors (not a dependency) MUST have a special comment added to it. This comment will then be displayed by `make help`.

For example a new `foo` task might look like this:

    foo: ## An example of make task information.
         @true

Then running `make help` will output something like in the output with the other help messages:

    $ make help
    all                            Default task to build dependencies.
    foo                            An example of make task information.
    help                           Displays this help message.
    init                           Set path to pick up deps with: eval $(make init)

See also:

* http://clarkgrubb.com/makefile-style-guide
* http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
