# Contributing

Here are the rules and guidelines for contributors.


## Commit Messages

Capitalized, short (50 chars or less) summary

More detailed explanatory text, if necessary. Wrap it to about 72
characters or so. In some contexts, the first line is treated as the
subject of an email and the rest of the text as the body. The blank
line separating the summary from the body is critical (unless you omit
the body entirely); tools like rebase can get confused if you run the
two together.

Write your commit message in the imperative: "Fix bug" and not "Fixed bug"
or "Fixes bug." This convention matches up with commit messages generated
by commands like git merge and git revert.

Further paragraphs come after blank lines.

- Bullet points are okay, too

- Typically a hyphen or asterisk is used for the bullet, followed by a
  single space, with blank lines in between, but conventions vary here

- Use a hanging indent

Shamelessly stolen from
http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html,
have a look at it for more information.


## Branching

Generally the following branching model is considered as an ideal:

	http://nvie.com/posts/a-successful-git-branching-model/

But often, a more pragmatic, stripped down approach is appropriate.
But at least these few rules shall be adhered to:

1. The origin/master branch is the main branch where the source code
   of HEAD always reflects a production-ready state.

2. The origin/develop is the branch where the source code of HEAD
   always reflects a state with the latest delivered development changes
   for the next release.

3. For each larger change to the source code a new branch called
   feature/* is branched off from origin/develop. If the feature is ready,
   the branch has to pass testing and then may be merged back to develop.
   Feature branches typically exist in developer repos only, not in origin.
