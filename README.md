Modules
=======

> This repository is a workspace and incubator for Fuchsia modules.

# Email

## Configure

Add `email/config.json` in this directory, it will be ignored by version control.

    # Using make
    make email/config.json

Then add two values required for OAuth.

    {
      "oauth_id": "<Google APIs client id>"
      "oauth_secret: "<Google APIs client secret>"
    }

## Authenticate

Once you have the OAuth id and secret it is possible to generate refresh
credentials with:

    make auth

Follow the link in the instructions.

## Build

Make sure to start from a "very clean build" (remove $FUCHSIA_DIR/out) if you have built before but didn't do the auth steps above. There is a make task to help with this:

    make depclean all

This will clean and create a release build. To do this manually you can use:

    source $FUCHSIA_DIR/scripts/env.sh
    rm -rf $FUCHSIA_DIR/out
    fset x86-64 --release --modules default
    fbuild

## Run

Assuming you have an Acer properly networked and running `fboot` in another
terminal session you can run email two different ways.

Running with the full sysui

    netruncmd : "@ bootstrap device_runner"

Running the email story directly

    netruncmd : "@ bootstrap device_runner --user-shell=dev_user_shell --user-shell-args=--root-module=email_story"
