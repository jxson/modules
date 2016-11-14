
## Configuration

Add a `config.yaml` in this directory, it will be ignored by version control.

    touch config.yaml

Then add two values required for OAuth.

    oauth_id: <your app's id>
    oauth_secret: <your app's secret>

Once you do that it will be possible to continue by generating a file that includes an auto-refreshing HTTP client. Follow the instructions below.

## Setup

    eval $(make init)

## Authenticate

    make auth

## Test

    cd service && flutter test
