# Usage Laws

Rules for the assistant working in this repo. Not about the code — about what it is
allowed to touch. `docs/CODE-RULES.md` covers how code is written.

---

# 1. Never access the root

**Stay inside `/Users/willlattus/`.** Read, write and shell commands go no higher than
the home folder.

Off limits: `/`, `/System`, `/Library`, `/Applications`, `/usr`, `/Volumes`, and anything
else outside the user folder.

* **App data lives under `~/Library/`.**
* If a system path genuinely has to be inspected, **ask** — the user runs it themselves.

**One exception, asked for by name:** this app installs to `/Applications`. Nothing
else outside the home folder is written, and the exception covers this app's own
bundle and nothing more. It exists because an extension run from anywhere else is the
usual cause of the Finder quietly loading a stale copy.

This is about the assistant, not the app. What the app watches at run time is the user's
choice in its own settings, and *Everywhere* scope covering the whole disk is that choice
being exercised, not this law being broken.

---

# 2. Never write to git

**Never run `git add`, `git commit`, or `git push`.** Not when it seems helpful, not
when a piece of work is finished, not when asked to "save" something.

Also off limits: anything that writes history by another name — `git commit -a`,
`git merge`, `git rebase`, `git cherry-pick`, `git revert`, `git stash`, `git tag`,
`git reset` against the index, and `gh pr create`.

Reading is fine and often useful: `git status`, `git diff`, `git log`, `git show`.

* **Leave the work in the working tree.** Say what changed and let the user stage and
  commit it themselves.
* **An explicit one-off instruction overrides this**, and only for that one commit.
