# Commands

## Run Tests

From the repository root:

```sh
xcodebuild test -project knowzeno.xcodeproj -scheme knowzeno -destination 'platform=macOS'
```

In Xcode:

1. Open `knowzeno.xcodeproj`.
2. Select the `knowzeno` scheme.
3. Choose Product > Test, or press Command-U.


## Troubleshooting
- If the tests are failing, go to Product > Clean Build Folder.
