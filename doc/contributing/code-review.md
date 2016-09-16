# Code Review

The `jiri` tool will not allow you to commit to the master branch, it is recommended that all changes occur in a feature branch. Start a new branch for a CL with:

    # Similar to: git checkout -b <meaningful branch name>.
    jiri cl new <meaningful branch name>

You can hack and make incremental commits on this branch, once you are ready to submit the change for review you can use `jiri` to submit a patch to [Gerrit][gerrit].

    jiri cl upload

Before the `jiri` tool sends the CL off to https://fuchsia-review.googlesource.com it will open your text editor `$EDITOR` asking for a commit message to attach to your changes. Please draft a commit message adhering to the [Angular Git Commit Guidelines](https://git.io/viDaW):

* A header that defines the "type" of change and it's "scope" followed by a brief description in the following format: <type>(<scope>): <description>, lower case please.

* The body of the commit message can contain more concise details

* Add a footer for any references, links to issues, etc.

An example commit message:

    feature(doc): commit message instructions

    Adds a short summary about writing commit messages for this project.

    See also: https://git.io/viDaW
    Closes #555

Open the URL printed by `jiri` and add the appropriate reviewers. Address and commit any feedback and then upload a new patch using the same command as above.

Once your CL has been submitted you can remove your local branch with:

    jiri cl cleanup <branch-name>


Instructions for using Gerrit directly:

 * https://gerrit-review.googlesource.com/Documentation/
