Modules
=======

> This repository is a workspace and incubator for Fuchsia modules.

#Configuration

Add an `email/config.json` in this directory, it will be ignored by version control.

    # Using make
    make email/config.json

Then add two values required for OAuth.

    oauth_id: <your app's id>
    oauth_secret: <your app's secret>

## Authenticate

Once you have the OAuth id and secret it is possible to generate refresh
credentials with:

    make auth
