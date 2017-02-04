# Chat

> Status: Experimental

What exists here mostly boilerplate for the tooling and infrastructure needed
to build out the UI as a set of Flutter Widgets that can be run on Fuchsia and have the UI developed on Android.

# Structure

This repo contains code for running a vanilla [Flutter][flutter] application (iOS & Android) and a [Fuchsia][fuchsia] specific set of [modules][modular].

* **modules**: Fuchsia application code using Modular APIs.
  * **chat**: Is a Flutter app with two entry points, one for Fuchsia and one for Vanilla Flutter.
* **services**: [FIDL][fidl] service definitions.
* **tools**: Development helper scripts.

# Development

## Setup

This repo is already part of the default jiri manifest.

Follow the instructions for setting up a fresh Fuchsia checkout.  Once you have the `jiri` tool installed and have imported the default manifest and updated return to these instructions.

It is recommended you set up the [Fuchsia environment helpers][fuchsia-env] in `scripts/env.sh`:

    source scripts/env.sh

## Workflow

There are Makefile tasks setup to help simplify common development tasks. Use `make help` to see what they are.

When you have changes you are ready to see in action you can build with:

    make build

Once the system has been built you will need to run a bootserver to get it
over to a connected Acer. You can use the `env.sh` helper to move the build from your host to the target device with:

    freboot

Once that is done (it takes a while) you can run the application with:

    make run

You can run on a connected android device with:

    make flutter-run

Optional: In another terminal you can tail the logs

    ${FUCHSIA_DIR}/out/build-magenta/tools/loglistener

[flutter]: https://flutter.io/
[fuchsia]: https://fuchsia.googlesource.com/fuchsia/
[modular]: https://fuchsia.googlesource.com/modular/
[pub]: https://www.dartlang.org/tools/pub/get-started
[dart]: https://www.dartlang.org/
[fidl]: https://fuchsia.googlesource.com/fidl/
[widgets-intro]: https://flutter.io/widgets-intro/
[fuchsia-setup]: https://fuchsia.googlesource.com/fuchsia/+/HEAD/README.md
[fuchsia-env]: https://fuchsia.googlesource.com/fuchsia/+/HEAD/README.md#Setup-Build-Environment
[clang-wrapper]: https://fuchsia.googlesource.com/magenta-rs/+/HEAD/tools
