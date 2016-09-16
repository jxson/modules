# Workflow

There are numerous, pre-defined tasks to help with workflow and code hygiene. To see a list run:

    make help

## Git Workflow

**1. Create a feature branch.**

Before you start hacking it is strongly advised that you create a new feature branch in git.

> A feature branch is simply a separate branch in your Git repo used to implement a single feature in your project. When “using feature branches,” you are creating a new branch for each new feature you develop, instead of just checking in all your changes into the master branch (which is typically the name given for the main development branch). - [Jim Vallandingham](https://bocoup.com/weblog/git-workflow-walkthrough-feature-branches)

Using feature branches is considered good practice for this project, regardless of your intention to [contribute] or not. Be sure to assign a meaningful name to your branch name!

Setup.

    export FEATURE="my-new-feature"

Create the branch with the `jiri` CLI tool or directly with `git`.

    # Via jiri.
    jiri cl new $FEATURE

    # Via git.
    git checkout -b $FEATURE

**2. Start hacking, commit incrementally.**

It will be valuable to keep a tight loop between the code you draft and saving commits. We call these "incremental commits", and while not useful to anyone else but yourself they have the strong potential to increase your productivity. Even while prototyping and experimenting.

Commit anytime your code is in a state that would be useful to capture.

    # Add untracked work to git's staging.
    git add --patch .

The `--patch` flag above will provide an interactive session where you can review your changes as diff's and incrementally apply them. This helps you remember exactly what you did as well as leave out any superfluous code or comments.

Verify that your changes look good.

    git status

Once your staged changes are well encapsulated and make sense to you, you should commit them. Be sure to add a meaningful commit message. For instance "Adds working button action" will be helpful to "future you" when looking at the commit log.

    git commit -m "A meaningful commit message"

Continue doing the hack & `git add --patch` process incrementally until you have fulfilled the goals of your feature branch.

Remember git enables the ability to move through and work with your commit history. It is okay to commit explorations and what might become dead ends. You can always return to a previous point in your commit history without being a Git Wizard. For example, if you want to continue working from a previous commit without rewriting history you can do something like:

    # Add all the changes from commit <sha1> to staging.
    git checkout <sha1> -- .

    # Only changes from a specific file in commit <sha1> to staging.
    git checkout <sha1> -- README.md

**3. Optional: Sync work across your development machines**

Many of the Authors and Contributors of this project work across multiple development machines; desktops, laptops, etc. Work can start on one machine and need to be carried on from a separate machine. The recommended workflow for this is to use GitHub Forks of this project's mirror () for the synchronization of git history.

    export GITHUB_USERNAME="jxson"

Fork https://github.com/fuchsia-mirror/modules to your GitHub account and then add your fork as a remote.

    git remote add $GITHUB_USERNAME "git@github.com:${GITHUB_USERNAME}/modules.git"

Push your feature branch to your remote.

    git push ${GITHUB_USERNAME} --set-upstream

On a separate machine you can add your remote fork as a new origin and push/pull your changes as needed. Be sure this new machine has already been [setup](setup.md) and configured for GitHub ssh access. Once you are ready to sync on the new machine use the following commands to configure your local repository.

    # Setup.
    export FEATURE="my-new-feature"
    export GITHUB_USERNAME="jxson"

    # Add remote and checkout branch.
    git remote add $GITHUB_USERNAME "git@github.com:${GITHUB_USERNAME}/modules.git"
    git fetch $GITHUB_USERNAME
    git checkout --track "${GITHUB_USERNAME}/${FEATURE}"

You can now repeat step #2 as many times as you want on either computer.

**NOTE:** Since forks of any repositories hosted at https://github.com/fucshia-mirror are public, please remember that your incremental commits sync'd to your personal fork will be as well.

**4. Contribute, maybe?**

If your feature branch is complete and you would like to contribute your work back to this project, review and follow the [contribution documentation].

[contribution documentation]: ../contributing/README.md
