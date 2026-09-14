# Right Click Menu

Adds **New _<type>_** entries to the macOS right click menu, on the Desktop and in any
Finder window. Click one and the file appears in the folder you clicked.

The types are yours. Add or remove them in the app, no rebuild. Remove every last one
and the menu goes back to looking exactly like a stock macOS menu, as though the app
had never been installed.

- **Lives in the menu bar.** Opening the window puts it in the dock; closing the window
  takes it back out and leaves it running. Quit is in the menu bar item.
- **Opens at login**, if you want it to.
- **Appears where you say.** Everywhere, or only in folders you pick. A picked folder
  covers everything inside it.

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
make lint        # swiftlint
make diagnose    # is the extension registered and elected?
make clean
```

`make run` installs to `/Applications`. An extension run from anywhere else is the
usual cause of Finder quietly loading a stale copy.

## How it is put together

```
Right Click Menu.app                 finder-extension.appex
not sandboxed                        sandboxed, because it must be
menu bar, window, login item         thin. builds the menu, forwards a click
** writes every file **              reads the legend, writes nothing
        |                                      ^
        | writes legend + scope                | reads
        +---------> shared app group <---------+
```

The extension is not allowed to write anything, so a click travels to the app as an
address and the app makes the file.

| | |
|---|---|
| `Packages/RightClickMenu` | Every decision, and every test. `swift test` needs no Xcode. |
| ┗ `…Shared` | The records. Imports nothing at all, so they read the same inside the sandbox as out. |
| ┗ `…Core` | The store, choosing a free file name, writing the file, planning the menu. |
| ┗ `…UI` | The screens, each a view beside its view model. |
| `bundles/` | The two bundles. They hold no decisions. |
| `project.yml` | The whole Xcode project. The `.xcodeproj` is generated, never committed. |
| `scripts/make-icon.sh` | Draws the app icon. It is code, not a picture. |
| `docs/CODE-RULES.md` | How the code here is written. |

## Licence

GPL v3 — see [LICENSE](LICENSE). Ship a changed version and you publish your source too.
