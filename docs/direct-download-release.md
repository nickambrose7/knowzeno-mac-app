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

Every public release must include an asset named exactly `Knowzeno.dmg`. The
local package artifact is versioned, such as `Knowzeno-1.0-1.dmg`, but the
uploaded GitHub release asset uses the stable name so the website can always
link to the latest release.

Use the helper script:

```sh
scripts/publish-github-release v1.0.0 build/direct-download/Knowzeno-1.0-1.dmg \
  --title "Knowzeno 1.0.0" \
  --notes "Direct download release."
```

The publish helper validates the stapled notarization ticket and Gatekeeper
assessment before upload. If either check fails, do not upload that DMG; rebuild
with `scripts/package-direct-download` without `--skip-notarization`.

If the release already exists and only the `Knowzeno.dmg` asset needs to be
replaced, use the guarded replacement mode:

```sh
scripts/publish-github-release v1.0.0 build/direct-download/Knowzeno-1.0-1.dmg --clobber
```

Or run the equivalent `gh` commands manually:

```sh
cp build/direct-download/Knowzeno-1.0-1.dmg /tmp/Knowzeno.dmg
xcrun stapler validate /tmp/Knowzeno.dmg
spctl -a -vvv -t install /tmp/Knowzeno.dmg
gh release create v1.0.0 /tmp/Knowzeno.dmg \
  --repo nickambrose7/knowzeno-mac-app \
  --title "Knowzeno 1.0.0" \
  --notes "Direct download release."
```

If the release already exists and only the asset needs to be replaced:

```sh
cp build/direct-download/Knowzeno-1.0-1.dmg /tmp/Knowzeno.dmg
xcrun stapler validate /tmp/Knowzeno.dmg
spctl -a -vvv -t install /tmp/Knowzeno.dmg
gh release upload v1.0.0 /tmp/Knowzeno.dmg \
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

## Updates

Direct download does not include updates by default. Add Sparkle 2 before users
depend on automatic upgrades:

1. Add `https://github.com/sparkle-project/Sparkle` to the Xcode project.
2. Link the `Sparkle` product to the app target.
3. Add an updater controller to the app lifecycle.
4. Generate Sparkle EdDSA keys and store the private key outside the repo.
5. Add `SUFeedURL` and `SUPublicEDKey` to `Config/knowzeno-Info.plist`.
6. Add Sparkle sandbox temporary mach-lookup exceptions to
   `knowzeno/knowzeno.entitlements`.
7. Generate and upload `appcast.xml` for each release.

Once Sparkle is installed, use:

```sh
scripts/generate-appcast path/to/upload-directory
```

The upload directory should contain notarized release DMGs. Upload the resulting
`appcast.xml` next to the DMGs.
