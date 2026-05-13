# Commands

## Run Tests

From the repository root:

```sh
xcodebuild test -project knowzeno.xcodeproj -scheme knowzeno -destination 'platform=macOS'
```

## Build and Launch the App

From the `knowzeno` repository root:

```sh
scripts/run-mac-app
```

This builds the `knowzeno` scheme, quits any running copy, installs the updated
app to `~/Applications/knowzeno.app`, refreshes Spotlight metadata, and launches
it. After this runs, Spotlight should find the updated app from
`~/Applications`.

Useful options:

| Option | What it does | Use when |
| --- | --- | --- |
| `--no-install` | Builds the app and launches it directly from Xcode's DerivedData build output instead of copying it to `~/Applications/knowzeno.app`. | You only need a quick test run and do not care whether Spotlight opens this build later. |
| `--no-kill` | Skips quitting an already running `knowzeno` process before launching. | You are debugging launch behavior or want to avoid interrupting a running copy. Usually skip this for normal testing. |
| `--configuration Release` | Builds the Release configuration instead of the default Debug configuration. | You want to test behavior closer to a distributable app, including Release optimization and signing settings. |
| `--configuration Debug` | Builds the Debug configuration. This is the default. | Normal development testing. You usually do not need to pass this explicitly. |

Examples:

```sh
# Fastest normal loop: build, install to ~/Applications, refresh Spotlight, launch.
scripts/run-mac-app

# Quick throwaway launch from DerivedData.
scripts/run-mac-app --no-install

# Release-mode smoke test.
scripts/run-mac-app --configuration Release
```

In Xcode:

1. Open `knowzeno.xcodeproj`.
2. Select the `knowzeno` scheme.
3. Choose Product > Test, or press Command-U.


## Troubleshooting
- If the tests are failing, go to Product > Clean Build Folder.
