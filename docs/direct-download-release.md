# Direct Download Release

Use this path while Knowzeno is distributed from the website instead of the Mac
App Store.

## Prerequisites

- Apple Developer Program membership.
- A `Developer ID Application` certificate installed in Keychain for team
  `BH9Q5V7U24`.
- A notarytool keychain profile named `notarytool-knowzeno`.
- A public `nickambrose7/knowzeno-mac-app` GitHub repository for release
  assets.
- GitHub CLI installed and authenticated with `gh auth login`.
- Sparkle's `generate_appcast` available on `PATH`, or `SPARKLE_BIN_DIR` set to
  the directory containing it.
- The Sparkle EdDSA private key stored outside the repo at
  `~/.config/knowzeno/sparkle/ed25519_private_key`, or available in the login
  Keychain for account `com.knowzeno.knowzeno`.

Create the notarytool profile once:

```sh
xcrun notarytool store-credentials notarytool-knowzeno \
  --apple-id "APPLE_ID_EMAIL" \
  --team-id "BH9Q5V7U24" \
  --password "APP_SPECIFIC_PASSWORD"
```

## Build Release DMG

Direct-download releases must use the production web host as the backend base
URL:

```text
https://knowzeno.com
```

Do not use an `api.knowzeno.com` subdomain unless DNS, TLS, and backend routing
for that subdomain have been intentionally added. The package script fails if
the Release build setting is not `https://knowzeno.com`.

From the repository root:

```sh
scripts/package-direct-download
```

The script:

1. Runs the macOS test suite.
2. Archives the Release build.
3. Exports the archive with Developer ID signing.
4. Creates a drag-to-Applications DMG.
5. Submits the DMG for notarization.
6. Staples the notarization ticket.
7. Verifies Gatekeeper assessment.

For a local packaging dry run without notarization:

```sh
scripts/package-direct-download --skip-notarization
```

The DMG is written to `build/direct-download/Knowzeno-VERSION-BUILD.dmg`.

## Publish

Upload the notarized DMG to GitHub Releases. The website currently points at:

```text
https://github.com/nickambrose7/knowzeno-mac-app/releases/latest/download/Knowzeno.dmg
```

Sparkle reads the appcast from:

```text
https://github.com/nickambrose7/knowzeno-mac-app/releases/latest/download/appcast.xml
```

Every public release must include an asset named exactly `Knowzeno.dmg`. The
local package artifact is versioned, such as `Knowzeno-1.0-1.dmg`, but the
uploaded GitHub release asset uses the stable name so the website can always
link to the latest release. Every release must also include `appcast.xml`,
generated from the stable `Knowzeno.dmg` asset so Sparkle can discover and
install updates.

Use the helper script:

```sh
scripts/publish-github-release v1.0.0 build/direct-download/Knowzeno-1.0-1.dmg \
  --title "Knowzeno 1.0.0" \
  --notes "Direct download release."
```

The publish helper validates the stapled notarization ticket and Gatekeeper
assessment, generates `appcast.xml`, then uploads both `Knowzeno.dmg` and
`appcast.xml`. If validation fails, do not upload that DMG; rebuild with
`scripts/package-direct-download` without `--skip-notarization`.

If the release already exists and the assets need to be replaced, use the
guarded replacement mode:

```sh
scripts/publish-github-release v1.0.0 build/direct-download/Knowzeno-1.0-1.dmg --clobber
```

Or run the equivalent commands manually:

```sh
mkdir -p /tmp/knowzeno-release
cp build/direct-download/Knowzeno-1.0-1.dmg /tmp/knowzeno-release/Knowzeno.dmg
xcrun stapler validate /tmp/knowzeno-release/Knowzeno.dmg
spctl -a -vvv -t install /tmp/knowzeno-release/Knowzeno.dmg
scripts/generate-appcast /tmp/knowzeno-release
gh release create v1.0.0 \
  /tmp/knowzeno-release/Knowzeno.dmg \
  /tmp/knowzeno-release/appcast.xml \
  --repo nickambrose7/knowzeno-mac-app \
  --title "Knowzeno 1.0.0" \
  --notes "Direct download release."
```

If the release already exists and the assets need to be replaced:

```sh
mkdir -p /tmp/knowzeno-release
cp build/direct-download/Knowzeno-1.0-1.dmg /tmp/knowzeno-release/Knowzeno.dmg
xcrun stapler validate /tmp/knowzeno-release/Knowzeno.dmg
spctl -a -vvv -t install /tmp/knowzeno-release/Knowzeno.dmg
scripts/generate-appcast /tmp/knowzeno-release
gh release upload v1.0.0 \
  /tmp/knowzeno-release/Knowzeno.dmg \
  /tmp/knowzeno-release/appcast.xml \
  --repo nickambrose7/knowzeno-mac-app \
  --clobber
```

## Smoke Test

After upload:

1. Confirm the GitHub repository is public.
2. Open
   `https://github.com/nickambrose7/knowzeno-mac-app/releases/latest/download/Knowzeno.dmg`.
3. Open `https://knowzeno.com/download/mac`.
4. Download the DMG.
5. Open the DMG.
6. Drag Knowzeno to Applications.
7. Launch Knowzeno from Applications.
8. Confirm macOS does not show an unidentified-developer warning.
9. Paste a website API token.
10. Grant Accessibility permission.
11. Capture selected text and send it to production.
12. Choose Knowzeno > Check for Updates and confirm Sparkle can read the
    release appcast.

## Updates

Direct download updates use Sparkle 2. The app checks automatically and exposes
Knowzeno > Check for Updates.

The appcast is generated during publishing. To generate it manually, use:

```sh
scripts/generate-appcast path/to/upload-directory
```

The upload directory should contain a notarized release DMG named
`Knowzeno.dmg`. Upload the resulting `appcast.xml` next to the DMG.
