Modules
=======

> This repository is a workspace and incubator for Fuchsia modules.

#Configuration

Add an `email/config.yaml` in this directory, it will be ignored by version control.

    # Using make
    make email/config.yaml

Then add two values required for OAuth.

    oauth_id: <your app's id>
    oauth_secret: <your app's secret>

Once you do that it will be possible to generate refresh credentials that can be used by running modules.

## Authenticate

    make auth
