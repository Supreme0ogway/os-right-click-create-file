# Coding Rules

How code here is written, sorted and reviewed.

---

# 0. The toolchain

* **Swift.** Types are the compiler's job; what they *mean* is DocC (§10).
* **Xcode builds the bundles, SwiftPM builds the modules.** The app and the
  Finder extension are Xcode targets, because an `.appex` cannot be anything
  else. Everything they import is a local package under `Packages/`.
* **`swift test` in `Packages/` is the test run.** Anything that needs
  `xcodebuild` is a bundle, and a bundle holds no decisions (§4b).

---

# 1. Small files

Target under 200 lines. 250 needs a reason. **400 is hard** — lint fails at 401.

A file over the limit is two files nobody split yet. Find the second job and
name it; never compress. If a file's summary needs "and", it is two files.

**Test files may run to 1500 lines.** A test file is one logic file's sibling
(§7b), and splitting it to fit a limit meant for logic would leave a logic file
with two names for its tests. Lint enforces the higher limit on test files and
the lower one everywhere else.

---

# 1b. Rewrite it, do not bolt on to it

**When something does not work, rewriting or deleting the parts around it beats
adding a part on top.** Change whatever it takes so every piece fits together
again. A patch over a shape that is wrong leaves you holding both.

Then: **the least code that is still plain to read.** Not the least code —
the least a stranger still follows without being told anything. Fewer lines is
the goal right up to the line where somebody has to stop and work it out.

* One measurement serving three things beats three features.
* A field beats a state machine — nothing to store, save, migrate or desync.
* Data beats a code path (§6). A file type that is a table row is not code.
* A number beats a mechanism. Check whether a value is read at the wrong scale
  before adding a term.
* **Delete on the way past.** What you replaced goes in the same change. Dead
  code that still compiles is the costly kind, because it gets maintained.
* **Write the refusal down.** A no with its reason is what stops the idea coming
  back in six months.

Not licence to compress. A clever line that takes a paragraph to read costs more
than the three plain ones it replaced.

**Junk is any code not carrying its weight.** It gets in because each piece
looks harmless on its own, and then it is maintained forever. Delete on sight:

* A wrapper that only forwards. Call the thing.
* A parameter, option or case nobody passes. Add it when something needs it.
* A branch for a state that cannot happen. Assert instead (§11).
* An abstraction with one implementation, written for a second one nobody has
  asked for.
* A stub, a placeholder, a "for now". Either it works or it is not there yet.
* Anything left standing that the new thing replaced.

---

# 1c. Use what already exists

**Before writing code, look for the package that already does it.** The platform or a
package almost always got there first, and their version has been run by thousands of
people on hardware you do not own.

* **Apple's framework wins by default.** It ships with the OS, it is already on the
  machine, it needs no version bump and it cannot go unmaintained.
* **Reach outward second.** A well-kept package beats a weekend of your own.
* **Write it yourself last**, and write down why nothing fitted (§1b).

A hand-written replacement for something already provided is junk under §1b, whatever
it cost to write. Delete it the day you notice.

Not licence to add a dependency for three lines. A package that does one small thing you
could name in a sentence costs more to keep updated than it saves.

---

# 1d. Immutable by default

**`let`, not `var`. A value type, not a reference type. A new value, not a changed one.**

1. **A `var` needs a reason**, and the reason is visible where it is written.
2. **`struct` over `class`.** A class is for a thing with an identity that outlives its
   contents — a connection, a window, a store.
3. **Nothing shared is mutable.** A store publishes a new value; subscribers are handed
   it. Nobody reaches in and edits (§5b).
4. **Build it complete.** A value arrives valid from its initialiser, rather than being
   assembled field by field and valid only once somebody remembers the last step.
5. Collections are replaced, not appended to in place, wherever the collection is
   somebody else's.

A value that cannot change cannot change behind your back, cannot be half-updated, and
cannot disagree with the copy another thread is holding.

---

# 2. Folders are the structure

* One folder, one job. Every folder has one way in (§3).
* **No file cap.** Sixty files serving one job is sorted, not full.
* **No `misc/`** — no folder whose job needs more than a sentence.
* **Split on a seam, never a count.** If half the files never import the other
  half, that is two jobs.
* **Do not over-sort.** Four folders of three files, where one of twelve would
  do, is more to hold in your head.
* Deeper than four levels from the source root means the tree is wrong.

---

# 2b. Interface controls are a library

Every button, switch, slider and labelled row comes from `shared/ui/`
(`@Right-Click-Menu/ui`). No panel builds its own. It depends on nothing in the
app, so anything can reuse it. Lint allows it in `app/` and `ui/` only.

* **A native control, always** — a button is a button, a slider a slider.
  Keyboard, focus and screen readers come free.
* **It carries its own look**, from the ui module's tokens.
* **It holds no words.** Labels are passed in, already looked up.

---

# 2c. MVVM, and it is the sorting

Interface code is three kinds of file. They are never mixed, and the folders say which
is which.

```text
model        the value types in shared/. immutable, knows nothing about screens
view-model   the only thing a view talks to. no SwiftUI import
view         layout. controls from ui/ (§2b). no formatting, no file work
```

1. **A view-model imports no interface framework.** That is what makes every rule in it
   testable by the ordinary test run — the same argument §4b makes for keeping decisions
   out of a handler.
2. **A view-model owns no truth.** It subscribes to the store (§5b) and hands on what it
   is given. Two screens reading one legend cannot disagree, because neither holds it.
3. **A view decides nothing.** No formatting, no branching on a state it could have been
   handed ready, no reaching for a file. If a view needs an `if`, the view-model owes it
   a better value.
4. **Sorted one folder per screen**, the two files side by side:

```text
ui/legend-editor/legend-editor-view.swift
ui/legend-editor/legend-editor-view-model.swift
```

5. A view-model is a logic file and takes its sibling test (§7b). A view is exempt and is
   checked by eye instead (§12).
6. Immutability holds (§1d): a view-model publishes a whole new value, it does not edit
   fields one at a time while a view is drawing them.

---

# 3. One way in: the module's public interface

1. Import the module, never a file inside it.
2. The umbrella header or public interface re-exports and routes. No logic.
3. A module's own files use each other freely.
4. A deep import is a lint error.

So any file inside a module can be renamed, split or rewritten without touching
a line outside it.

---

# 3b. The public surface in one block at the bottom

1. **One sorted list of `public` / `open` extensions, last thing in the file**,
   or grouped under `// MARK:` comments.
2. **Declarations are internal by default.** What a thing is and who may have it
   are separate decisions.
3. An umbrella header is exempt — a funnel is already nothing but re-exports.
4. Types are named in the block like anything else.

One place answers "what does this file give the world?" Otherwise a private
table goes public by one word in the middle of two hundred lines. Binds files
you touch, not the whole repo at once.

---

# 4. Dependencies flow one way

```text
app          bootstrap, launch at login, the menu bar item
ui           panels, screens, the legend editor
core         the app's decisions: templates, naming, writing a file
net          the only layer that fetches
shared       formats, schemas, invariants. Imports nothing.
```

Import your own layer and below, never above. **No cycles** — lint, not
discipline.

* **`shared/` is the floor.** Everything imports it and it must behave
  identically everywhere: no imports, no side effects, no SDK.
* **Only `net/` fetches.**

---

# 4b. Handler, usecase, repository

Server code is sorted by how far a request has got. One file per stop.

```text
handler       one per callable. Thin: read the request, check who is asking,
              call one usecase, turn a throw into a reply. Holds no rules.
usecase       the decision. Takes its repositories as arguments.
repository    the only files importing the backend SDK. One per collection.
              Reads and writes records. Decides nothing.
shared        the shapes every side agrees on.
```

* **A usecase never imports an SDK** — that is what makes the half of the
  backend with the decisions in it testable by the ordinary test run.
* **A handler holds no rules.** A rule decided there cannot be tested without a
  request.
* **Models live in `shared/`.** Two answers to "what is a template" is how
  records go missing.
* One file per thing. The funnel applies unchanged (§3).

---

# 5. Nothing blocks the frame

* No `await` in the frame path. Ever.
* No parsing or file work on the main thread.
* No allocation in steady state: reuse scratch buffers, hold typed arrays.
* No bulk disposal in a visibility or update pass; disposal is its own phase.
* Anything over a millisecond is a **job**: prioritised, cancellable, sliced.
* Every system declares a budget and the profiler shows it.

---

# 5b. One store, and everything subscribes to it

**Anything several parts need is one store, and the parts subscribe to it.** The
legend of file types is one reading and every menu subscribes. That is the shape
to reach for first.

1. **One source.** A value that two systems each keep is a value that disagrees.
2. **Subscribe, never poll and never reach in.** A subscription tells the
   subscriber now and on every change, and returns how to stop. Nothing reads a
   store on a timer to see if it moved.
3. **Installed once, at boot, under one seam.** Everything below gets it as an
   argument or through that seam, so a test hands in a fake.
4. **Absent is normal.** A store nobody installed answers like an empty one and
   the app runs on. No store is ever load-bearing for the frame.
5. **A new thing plugs in by subscribing**, not by the store learning its name.
   The store never imports a subscriber.

A store that knows who listens is two systems glued together, and it is the
one that cannot be swapped.

---

# 6. Data over code

* Content is **data files**: file types, templates, menu entries, icons,
  extensions, default names.
* Ids are **namespaced**: `core:plain-text`, `user.will:invoice`.
* Every record carries `version`. Adding that later is a migration of
  everything.
* Tuning numbers live in a constants folder (§6b).

If someone cannot add a file type without a rebuild, it is in the wrong place.

---

# 6b. Constants live in three folders and nowhere else

| folder | holds | read by |
| --- | --- | --- |
| `src/constants/` | interface, input, profiler | the app |
| `shared/constants/app/` | limits, defaults, schema version | app **and** server |
| `shared/constants/backend/` | paths, regions, timeouts, batch sizes | everything |

1. **Constants only.** No functions, no logic, no imports.
2. **Every string is a constant, including one used once** — that is the one
   duplicated with a typo six months later.
3. Numbers, ids, event names, element names, keys, formats, messages, all of it.
4. **Two mechanical exemptions:** a module specifier in an import, and literals
   inside a test file.
5. Constants files need no sibling test. A constants file outside those folders
   **fails the build**.
6. **User-facing text is a localisation key.** Logs and thrown messages are
   constants.

The expensive thing is never writing a value, it is finding every place one was
written.

---

# 6d. Keybinds are sorted by who they are for

`keybinds/user` — everyone, rebindable, listed in the menu.
`keybinds/developer` — only with the instrumentation flag.

* **A user is never one keystroke from a diagnostic.**
* **Developer actions never appear in the rebinding list** — offering them
  advertises them.
* **A developer binding is never worth anything.** It changes what the app shows
  or how cheaply it draws, never what gets written to disk.
* **Bind by physical key code, never by letter.** `KeyW` is the same physical
  key on a French keyboard; `W` is not.
* **Sort by what a hand does**, not alphabetically.

The flag decides what is offered, never what anything is worth.

---

# 6e. Arithmetic in named steps

**Break a calculation into small steps, each in a named variable, and use the
names.** No bare numbers inside a longer expression.

1. One step, one name. `let acrossPoints = spanPoints / cells` beats the same
   division buried in a bigger line.
2. A number that means something is a **constant with a name** (§6b), not a digit
   in the middle of an expression. 0, 1, 2 and −1 are fine where they plainly
   mean nothing, none, both or back.
3. The names are the working. Somebody reading it should follow the arithmetic
   without holding it in their head.
4. It costs nothing at run time and it is where the wrong-unit and
   wrong-order bugs get caught.
5. **Tests are exempt.** A test states the numbers it is checking, and naming
   them hides what it asserts.

---

# 7b. Tests come first

**The test file is written before the file it tests.** The test decides the
behaviour; the implementation makes it pass.

1. **Same path, same base name.** A test mirrors its source file's folder path and name
   under `Tests/`, so there is one obvious sibling and no hunting:

```text
Sources/RightClickMenuCore/legend/legend-store.swift
Tests/RightClickMenuCoreTests/legend/legend-store-tests.swift
```

   The mirror exists because a package manager will not let a test target and a source
   target share a directory, and the test run is `swift test` (§0). Never a `__tests__`
   tree, never one bag of tests per module, never a name that does not match its source.
2. **A logic file without a sibling test fails the build.**
3. Exempt, and the list is closed: umbrella headers, data tables, constants
   folders (§6b), and entry points, whose decisions live in a module that is not
   exempt.
4. Write the test, watch it fail for the right reason, write the smallest thing
   that passes. A test that never failed proved nothing.
5. **A bug fix starts with a test that reproduces the bug.** If it cannot be
   written as a failing test, it is not understood yet.

Not a coverage number. Where correctness is "does it look right", the sibling
test covers what the interface is told and the picture is checked by eye (§12).

---

# 7c. Flat code, not nested code

Target one level inside a function. Two needs a reason. **Three is the hard
limit.** Everything that indents counts.

**A loop never goes inside a loop.** Nothing worse than linear. Walking a grid is
one loop over the cells with row and column derived from the index; a grid is
not an exception.

How depth goes away, in order:

1. **Return early.** `if x == nil { return [] }` beats wrapping the body.
2. **Name the condition.** `if canCreate(...)` instead of four clauses.
3. **One loop.** Give the inner one a function, or walk a flat thing.
4. **`continue` and `guard`, never `else`** — see below.
5. **Flatten the data.** Nested loops usually mean nested data.

Two loops over one collection read better than one loop with a branch in it.
Depth is the cost, not repetition. **No nested ternaries** — a `?:` inside a `?:`
is an `if` somebody refused to write.

**No `else`.** An `if` that needs one is either an exit somebody indented
instead of taking, or a choice that wants to be a `switch`.

1. **`guard` is the exit.** `guard let folder else { return nil }`, and the rest
   of the function reads at one level with the bad case already gone.
2. **`switch` is the choice.** Two or more branches on one value is a `switch`
   on that value. The compiler then checks you covered every case, which is the
   whole point: an `else if` chain checks nothing, and the `else` on the end of
   it silently swallows the case added next year.
3. **A lone `if` is fine.** One-sided work — do it or do not — has no other side
   to write.
4. **`switch` needs no `default` when the cases are closed.** Writing one throws
   away the exhaustiveness check. Keep it only where the value is genuinely open,
   like a number or a string from outside.

**Tests are exempt**, as they are from §6e and for the same reason: a test is
read as a statement of what it checks, and the shapes that keep production code
flat — a helper for the inner loop, an index the reader has to unpack — hide the
thing being asserted behind machinery.

---

# 8. Naming

* `lower-hyphen-case` files, `PascalCase` types, `camelCase` values,
  `UPPER_SNAKE` true constants.
* Names say **what a thing is**: `menuEntry`, not `getEntryStruct`.
* No abbreviations except `id`, `url`, `fps`.
* Booleans read as assertions: `isVisible`, `hasDiff`, `canCreate`.
* No `manager`, `helper`, `util`, `data`, `stuff`, `misc` — the names things get
  when nobody decided the responsibility.
* **`color`, never `colour`**, in code, filenames, strings and these documents.
  Every graphics API spells it `color`, so half a codebase spelling it `colour`
  makes every lookup a guess and every rename two renames. `metres`,
  `normalise`, `centre` and `behaviour` are unchanged.

---

# 10. Documentation, not comments

**No inline comments.** If a passage needs one, it needs a name — extract a
well-named function or constant. `// MARK:` is a heading, not a comment, and is
the one allowed use.

```swift
// ✗ wrong
// check the extension is allowed and the folder is writable
if allowed.contains(ext) && folder.isWritable && !name.isEmpty {

// ✓ right
if canCreate(type: type, in: folder, named: name) {
```

**Write it for a ten-year-old.** Plain words, short sentences, as few as
possible. No corporate phrasing, no wind-up, no restating the code. Explain a
hard idea in one plain sentence and define the term in brackets the first time
it appears in a file. Same for documents in `literature/`: short, plain, around
100 lines unless the content truly needs more. The *why* stays; it gets fewer
words.

**Everything else is DocC on the declaration.**

* Every public declaration has a block, including one-line helpers. Every file
  opens with one saying what it is for and what it is deliberately not for.
* **Types are named in the doc** — `- Parameter`, `- Returns`, `- Throws`. A
  parameter the reader has to infer is undocumented.
* Shapes are a named type referenced by name. The same shape spelled out twice
  is a shape nobody named.
* **The signature says what it is; the words say what it means**, in what units,
  what range, and what happens if it is wrong.
* **Traps go in a `- Note:`** on the declaration that holds them.
* **No reference to these documents from code** — no path, no name, no section
  number. Citations rot and send the reader away. Write the reason instead.
* A block repeating the declaration name is deleted. Private declarations are
  documented the same way, and are the alternative to a comment.
* A limitation or deferred decision is a tracked issue, never a `TODO`.

**Budgets**: file header **10 lines**, a declaration's prose **3 sentences**, a
note **5 lines**. Going over means the file does too much (§1) or the reason
belongs in `literature/`. Cut the war story (`git log` has it), the
re-argument, the restatement, the wind-up. Never cut the non-obvious reason a
line exists, the units, the ranges, or the one trap.

---

# 11. Errors

* No silent `catch`. Ever.
* A missing template, icon or folder is a **state** with defined behaviour.
* Real errors are reported once, with context, and the app keeps running. An
  exception must never be a dead menu.
* Assertions in development, removed in production, never load-bearing.

---

# 12. Verification

A change is done when its tests pass **and** it has been seen. Neither
substitutes for the other.

* The test run green, including the sibling test written first (§7b).
* **Run it. Screenshot it. Look at it.** The worst bugs here threw nothing and
  failed no test: a menu entry that never appeared, a file written to the wrong
  folder, an icon that rendered blank.
* **Interface is looked at in `tools/inspect/`**, one panel with nothing else
  running. Judging a menu inside the whole app means judging it against whatever
  else is on screen. Subject and state come from the address, so a screenshot is
  a URL. A panel marked hidden that was still on screen shipped here, because an
  inline style beat the framework's own rule.
* Frame graph before and after on anything in the frame path. A performance
  claim without a number is decoration.

---

# 13. Review checklist

- [ ] Test written **first**; every logic file has its mirrored sibling. The test run green.
- [ ] Language `Swift`
- [ ] Every file 400 lines or fewer, one job each.
- [ ] What it replaced was **rewritten or deleted**, not bolted on to (§1b).
- [ ] Nothing hand-written that a framework or package already provides (§1c).
- [ ] `let` not `var`, `struct` not `class`, nothing shared and mutable (§1d).
- [ ] View, view-model and model stayed separate; no framework import in a view-model,
      no decision in a view (§2c).
- [ ] Nothing added that a field, a number or a data file could have carried.
- [ ] No junk: nothing forwarding, unused, unreachable, stubbed or superseded (§1b).
- [ ] No inline comments; every export has DocC with types, inside budget (§10).
- [ ] Nothing nested past two; no loop in a loop; no nested ternaries.
- [ ] No `else`; `guard` to leave, `switch` to choose, no needless `default` (§7c).
- [ ] No `literature/` reference in code. Spelled `color` never `colour`.
- [ ] Every constant, **including every string**, in one of the properly separated constant folders
- [ ] Arithmetic in named steps; no bare numbers mid-expression, tests aside (§6e).
- [ ] Controls came from `@Right-Click-Menu/ui`.
- [ ] New bindings went in the file for their audience (§6d).
- [ ] Interface changes looked at in `tools/inspect/`.
- [ ] Imports go through the module's umbrella header or public interface; dependencies flow down; no new cycles.
- [ ] One sorted list of public / open extensions at the bottom of the file, or grouped using // MARK: comments.
- [ ] No `fetch` outside `net/`. Backend in its layer; no SDK in a usecase.
- [ ] Nothing new blocks the frame; new work is a job with a budget.
- [ ] Shared state is one store that others subscribe to; no polling, no store that names a subscriber (§5b).
- [ ] Nothing allocates per frame; any new cache has a budget and eviction rule.
- [ ] New content is data, with namespaced ids and a version.
- [ ] Any new failure path degrades rather than stopping.
- [ ] It was run, and the picture was looked at.
