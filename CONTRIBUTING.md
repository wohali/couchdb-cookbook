# Contributing to this cookbook

Please take a moment to review this document in order to make the contribution
process easy and effective for everyone involved.

Following these guidelines helps to communicate that you respect the time of the
developers managing and developing this open source project. In return, they
should reciprocate that respect in addressing your issue, assessing changes, and
helping you finalize your pull requests.

Contributions to this repository are governed by the [CouchDB Code of
Conduct][6].

## Using the issue tracker

First things first: **Do NOT report security vulnerabilities in public issues!**
Please disclose responsibly by letting [the Apache CouchDB Security
team](mailto:security@couchdb.apache.org?subject=Security)
know upfront. We will assess the issue as soon as possible on a best-effort
basis and will give you an estimate for when we have a fix and release available
for an eventual public disclosure.

The GitHub issue tracker is the preferred channel for [bug reports](#bugs),
[features requests](#features) and [submitting pull requests](#pull-requests),
but please respect the following restrictions:

* Please **do not** use the issue tracker for personal support requests.
  Commercial support is available through [Neighbourhoodie Software GmbH]
  (http://neighbourhood.ie/).

* Please **do not** derail or troll issues. Keep the discussion on topic and
  respect the opinions of others.

## Bug reports

A bug is a _demonstrable problem_ that is caused by the code in our
repositories.  Good bug reports are extremely helpful - thank you!

Guidelines for bug reports:

1. **Use the GitHub issue search** &mdash; check if the issue has already been
   reported.

2. **Check if the issue has been fixed** &mdash; try to reproduce it using the
   latest `master` or `next` branch in the repository.

3. **Isolate the problem** &mdash; ideally create a reduced test case.

A good bug report shouldn't leave others needing to chase you up for more
information. Please try to be as detailed as possible in your report. What is
your environment? What steps will reproduce the issue? What OS experiences the
problem? What would you expect to be the outcome? All these details will help
people to fix any potential bugs. Our issue template will help you include all
of the relevant detail.

Example:

> Short and descriptive example bug report title
>
> A summary of the issue and the browser/OS environment in which it occurs. If
> suitable, include the steps required to reproduce the bug.
>
> 1. This is the first step
> 2. This is the second step
> 3. Further steps, etc.
>
> `<url>` - a link to the reduced test case
>
> Any other information you want to share that is relevant to the issue being
> reported. This might include the lines of code that you have identified as
> causing the bug, and potential solutions (and your opinions on their
> merits).


## Feature requests

Feature requests are welcome. But take a moment to find out whether your idea
fits with the scope and aims of the project. It's up to *you* to make a strong
case to convince the project's developers of the merits of this feature. Please
provide as much detail and context as possible.


## Pull requests

Good pull requests - patches, improvements, new features - are a fantastic
help. They should remain focused in scope and avoid containing unrelated
commits.

**Please ask first** before embarking on any significant pull request (e.g.
implementing features, refactoring code), otherwise you risk spending a lot of
time working on something that the project's developers might not want to merge
into the project. We're always open to suggestions and will get back to you as
soon as we can!

### For new Contributors

If you never created a pull request before, welcome :tada: :smile: [Here is a
great
tutorial](https://egghead.io/series/how-to-contribute-to-an-open-source-project-on-github)
on how to send one :)

1. [Fork](http://help.github.com/fork-a-repo/) the project, clone your fork,
   and configure the remotes:

   ```bash
   # Clone your fork of the repo into the current directory
   git clone https://github.com/<your-username>/<repo-name>
   # Navigate to the newly cloned directory
   cd <repo-name>
   # Assign the original repo to a remote called "upstream"
   git remote add upstream https://github.com/wohali/couchdb-cookbook
   ```

2. If you cloned a while ago, get the latest changes from upstream:

   ```bash
   git checkout master
   git pull upstream master
   ```

3. Create a new topic branch (off the main project development branch) to
   contain your feature, change, or fix:

   ```bash
   git checkout -b <topic-branch-name>
   ```

4. Make sure to update, or add to the tests when appropriate. Patches and
   features will not be accepted without tests. Run `make check` to check that
   all tests pass after you've made changes. Look for a `Testing` section in
   the project’s README for more information.

5. If you added or changed a feature, make sure to document it accordingly in
   the [CouchDB documentation](https://github.com/apache/couchdb-documentation)
   repository.

6. Push your topic branch up to your fork:

   ```bash
   git push origin <topic-branch-name>
   ```

8. [Open a Pull Request](https://help.github.com/articles/using-pull-requests/)
    with a clear title and description.

## Functional and Unit Tests

This cookbook is set up to run tests under
[test-kitchen](https://github.com/test-kitchen/test-kitchen). It
uses minitest-chef to run integration tests after the node has been
converged to verify that the state of the node.

Test kitchen should run completely without exception using the default
[baseboxes provided by Chef](https://github.com/chef/bento).
Because Test Kitchen creates VirtualBox machines and runs through
every configuration in the Kitchenfile, it may take some time for
these tests to complete.

If your changes are only for a specific recipe, run only its
configuration with Test Kitchen. If you are adding a new recipe, or
other functionality such as a custom resource or definition, please add
appropriate tests and ensure they run with Test Kitchen.

If any don't pass, investigate them before submitting your patch.

Any new feature should have unit tests included with the patch with
good code coverage to help protect it from future changes. Similarly,
patches that fix a bug or regression should have a _regression test_.
Simply put, this is a test that would fail without your patch but
passes with it. The goal is to ensure this bug doesn't regress in the
future. Consider a regular expression that doesn't match a certain
pattern that it should, so you provide a patch and a test to ensure
that the part of the code that uses this regular expression works as
expected. Later another contributor may modify this regular expression
in a way that breaks your use cases. The test you wrote will fail,
signalling to them to research your ticket and use case and accounting
for it.

If you need help writing tests, please ask on the [chef-dev mailing list](https://discourse.chef.io/c/dev) or the [Chef Community Slack](https://community-slack.chef.io/).

## Cookbook Contribution Do's and Don't's

Please do include tests for your contribution. If you need help, ask on the [chef-dev mailing list](https://discourse.chef.io/c/dev) or the [Chef Community Slack](https://community-slack.chef.io/). Not all platforms that a cookbook supports may be supported by Test Kitchen. Please provide evidence of testing your contribution if it isn't trivial so we don't have to duplicate effort in testing.

Please do indicate new platform (families) or platform versions in the commit message, and update the relevant ticket.

If a contribution adds new platforms or platform versions, indicate such in the body of the commit message(s), and update the relevant issues. When writing commit messages, it is helpful for others if you indicate the issue. For example: git commit -m '[ISSUE-1041] - Updated pool resource to correctly delete.'

Please do ensure that your changes do not break or modify behavior for other platforms supported by the cookbook. For example if your changes are for Debian, make sure that they do not break on CentOS.

Please do **not** modify the version number in the `metadata.rb`, a maintainer will select the appropriate version based on the release cycle information above.

Please do **not** update the `CHANGELOG.md` for a new version. Not all changes to a cookbook may be merged and released in the same versions. A maintainer will update the `CHANGELOG.md` when releasing a new version of the cookbook.

Please do use [foodcritic](http://www.foodcritic.io/) to lint-check the
cookbook. Except FC007, it should pass all correctness rules. FC007 is
okay as long as the dependent cookbooks are *required* for the default
behavior of the cookbook, such as to support an uncommon platform,
secondary recipe, etc.

## Thanks

Special thanks to [Hoodie][https://github.com/hoodiehq/hoodie] for the great
CONTRIBUTING.md template.

[6]: http://couchdb.apache.org/conduct.html
