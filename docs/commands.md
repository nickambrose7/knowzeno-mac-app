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

## Package for Direct Download

From the `knowzeno` repository root:

```sh
scripts/package-direct-download
```

This creates a Developer ID signed, notarized, stapled DMG for website
distribution. See [direct-download-release.md](direct-download-release.md) for
the full checklist and required Apple credentials.

The Release build uses `https://knowzeno.com` as the backend base URL. Do not
ship a direct-download build pointed at `api.knowzeno.com` unless that subdomain
has been deliberately configured.

To test packaging before Apple notarization is configured:

```sh
scripts/package-direct-download --skip-notarization
```

To publish a notarized DMG to GitHub Releases:

```sh
scripts/publish-github-release v1.0.0 build/direct-download/Knowzeno-1.0-1.dmg
```

The helper validates the stapled notarization ticket and Gatekeeper assessment,
generates the Sparkle appcast, then uploads the assets as `Knowzeno.dmg` and
`appcast.xml`. This keeps the website's `/download/mac` redirect and Sparkle's
update feed stable.

To replace `Knowzeno.dmg` and `appcast.xml` on an existing release after
rebuilding a notarized artifact:

```sh
scripts/publish-github-release v1.0.0 build/direct-download/Knowzeno-1.0-1.dmg --clobber
```


## Troubleshooting
- If the tests are failing, go to Product > Clean Build Folder.
