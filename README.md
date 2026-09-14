# Right Click Menu

Adds a **New File** entry to the macOS right click menu, on the Desktop and in any
Finder window. Hover it and your file types fly out, each with the icon macOS already
uses for that kind. Click one and the file appears in the folder you clicked.

The types are yours. Add, rename, reorder or remove them in the app, no rebuild.
Remove every last one and the menu goes back to looking exactly like a stock macOS
menu, as though the app had never been installed.

It arrives with Markdown, JSON, Shell, JavaScript and Python.

## What it does

- **Add a type** from a list of 13 kinds it already knows, or type your own extension.
  Names and extensions are checked as you go: no dots or spaces in an extension, no
  leading or trailing blanks anywhere, nothing that would write the file somewhere else.
- **Give each type its starting contents** in an editor with line numbers and coloring
  that follows the extension.
- **Search** your types by name or extension.
- **Drag to reorder** them. The order in the list is the order in the menu.
- **Choose where the menu appears** — everywhere, or only in folders you pick. A folder
  you choose includes every folder inside it.
- **Choose what the add screen opens on**, including a custom extension you use often.
- **Export and import** your types as a JSON file. Importing adds to your list, so
  nothing is lost. A file that cannot be read says so and changes nothing.
- **Lives in the menu bar.** Opening the window puts it in the dock; closing the window
  takes it back out and leaves it running. Quit is in the menu bar item.
- **Opens at login**, if you want it to.

The menu bar says when the menu is switched off by your own settings — no folders
chosen, or no types left — because both are allowed and both look exactly like the app
being broken.

## Install

You need macOS 14 or newer, Xcode, [Homebrew](https://brew.sh), and an Apple developer
account — the free one is enough.

```sh
git clone <this repo> && cd os-right-click-create-file
cp sample.env .env          # then put your team id in it, see below
make bootstrap              # installs xcodegen and swiftlint
make run                    # builds, installs, registers, restarts Finder
```

Then switch the extension on: **System Settings → General → Login Items & Extensions →
Extensions → Finder**. The app's menu bar item says so, with a button that takes you
there, until you do.

### Your team id

A Finder extension **must** be sandboxed, and a sandboxed extension can only reach the
app when both are signed by the same team. So the build needs your team id. Put it in
`.env`, which is never committed:

```sh
security find-identity -v -p codesigning
security find-certificate -c "Apple Development: YOUR NAME (XXXXXXXXXX)" -p \
  | openssl x509 -noout -subject      # the OU= field is your team id
```

Nothing else needs changing. The app reads the team back off its own signature at run
time, so no source file names one.

A team id is not a secret — it is in the signature of every app anyone ships. The thing
that must never leave your mac is the private key in your keychain, and nothing here
touches it.

## Commands

```sh
make run         # build, install to /Applications, register, restart Finder, launch
make test        # the test run. seconds, no Xcode needed
make lint        # swiftlint, and the spelling check
make diagnose    # is the extension registered and elected?
make clean
```

`make run` installs to `/Applications` and stops any copy already running first.
An extension run from anywhere else, or an old copy left running, is the usual reason a
change appears to do nothing.

## How it is put together

```
Right Click Menu.app                 finder-extension.appex
not sandboxed                        sandboxed, because it must be
menu bar, window, login item         thin. builds the menu, forwards a click
** writes every file **              reads the legend, writes nothing
        |                                      ^
        | writes legend, scope, settings       | reads
        +---------> shared app group <---------+
```

The extension is not allowed to write anything, so a click travels to the app as an
address and the app makes the file. The shared folder is named after whoever signed
both halves, which the app reads off its own signature.

Everything it keeps is plain JSON in that folder, written to be read by a person:
`legend.json`, `scope.json`, `preferences.json`.

| | |
|---|---|
| `Packages/RightClickMenu` | Every decision, and all 287 tests. `swift test` needs no Xcode. |
| ┗ `…Shared` | The records. Imports nothing at all, so they read the same inside the sandbox as out. |
| ┗ `…Core` | The store everything subscribes to, choosing a free file name, writing the file, planning the menu. |
| ┗ `…UI` | The screens, each a view beside its view model. A view model imports no drawing framework, which is why its rules are tested. |
| `bundles/` | The app and the extension. They hold no decisions. |
| `project.yml` | The whole Xcode project. The `.xcodeproj` is generated, never committed. |
| `scripts/make-icon.sh` | Draws the app icon. It is code, not a picture. |
| `docs/CODE-RULES.md` | How the code here is written. |
| `docs/USAGE-LAWS.md` | What an assistant working in here may touch. |

The one outside dependency is [Highlightr](https://github.com/raspu/Highlightr), which
colors the contents editor.

## Licence

GPL v3 — see [LICENSE](LICENSE). Ship a changed version and you publish your source too.
