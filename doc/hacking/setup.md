# Setup

You must use the `jiri` CLI to clone a local git repository for CL submissions. If you do not have an existing fuchsia workspace one can be setup by:

    # Edit the $FUCHSIA_WORKSPACE path to taste.
    export FUCHSIA_WORKSPACE="${HOME}/fuchsia"

    # Install the jiri tool.
    curl -s https://raw.githubusercontent.com/fuchsia-mirror/jiri/master/scripts/bootstrap_jiri | bash -s "${FUCHSIA_WORKSPACE}"

    # Add `jiri` scripts to your $PATH.
    export PATH="${FUCHSIA_WORKSPACE}/.jiri_root/bin:$PATH"

**OPTIONAL:** If you don't want to re-export between terminal sessions, add the following to your `~/.bashrc`:

    # Add fuchsia's jiri tools to $PATH if they are installed.
    export FUCHSIA_WORKSPACE="${HOME}/fuchsia"
    if [ -d "${FUCHSIA_WORKSPACE}/.jiri_root" ]; then
      export PATH="${FUCHSIA_WORKSPACE}/.jiri_root/bin:$PATH"
    fi

Once you have a working fucshia workspace you can add the `experience` manifest and clone/update with `jiri update`:

    jiri import experience https://fuchsia.googlesource.com/manifest
    jiri update
    cd "${FUCHSIA_WORKSPACE}/modules

For more details see the [jiri documentation][jiri].

[jiri]: github.com/fuchsia-mirror/jiri
