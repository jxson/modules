Modules
=======

> A workspace and incubator for Fuchsia Modules.

# Development

## Setup

You must use the `jiri` CLI to clone a local git repository for CL submissions. If you do not have an existing fuchsia workspace one can be setup by:

    # Edit the $FUCHSIA_WORKSPACE path to taste.
    export FUCHSIA_WORKSPACE="${HOME}/fuchsia"

    # Install the jiri tool.
    curl -s https://raw.githubusercontent.com/fuchsia-mirror/jiri/master/scripts/bootstrap_jiri | bash -s "${FUCHSIA_WORKSPACE}"

    # Add `jiri` scripts to your $PATH.
    export PATH="${FUCHSIA_WORKSPACE}/.jiri_root/scripts:$PATH"

**OPTIONAL:** If you don't want to re-export between terminal sessions, add the following to your `~/.bashrc`:

    # Add fuchsia's jiri tools to $PATH if they are installed.
    export FUCHSIA_WORKSPACE="${HOME}/fuchsia"
    if [ -d "${FUCHSIA_WORKSPACE}/.jiri_root" ]; then
      export PATH="${FUCHSIA_WORKSPACE}/.jiri_root/scripts:$PATH"
    fi

Once you have a working fucshia workspace you can add the `modules` manifest and clone/update with `jiri update`:

    jiri import modules https://fuchsia.googlesource.com/manifest
    jiri update
    cd "${FUCHSIA_WORKSPACE}/modules

For more details see the [jiri documentation][jiri].

## Workflow

The `jiri` tool will not allow you to commit to the master branch, it is recommended that all changes occur in a feature branch. Start a new branch for a CL with:

    # Similar to: git checkout -b <meaningful branch name>.
    jiri cl new <meaningful branch name>

You can hack and make incremental commits on this branch, once you are ready to submit the change for review you can use `jiri` to submit a patch to [Gerrit][gerrit].

    jiri cl upload

Open the URL printed by `jiri` and add the appropriate reviewers. Address and commit any feedback and then upload a new patch using the same command as above.

Once your CL has been submitted you can remove your local branch with:

    jiri cl cleanup <branch-name>

## Tasks

There are numerous, pre-defined tasks to help with workflow and code hygiene. To see a list run:

    make help

[jiri]: https://fuchsia.googlesource.com/jiri
[gerrit]: https://fuchsia-review.googlesource.com/
