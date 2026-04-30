Hedvig is a new approach to insurance currently available in Sweden, we belive in transparency hence we code in the open and publish all our source code here on Github, feel free to take a peek, if you are interested in working with us check out our [jobs page](https://www.hedvig.com/se/hedvig/karriar).


🦉 It's just an insurance app for iOS

## Run the app

1. Install Xcode

   `get it from Mac App Store`

2. Install tuist by following this guide

   `https://docs.tuist.io/guides/quick-start/install-tuist`

3. Run post-checkout

   `scripts/post-checkout.sh`
   
## Formatting

We use swift-format for formatting, it's ran on all staged files automatically in a pre-commit hook.

1. Install githooks
   
   sh `scripts/githooks.sh`
   
2. Install swift-format
   
   sh `scripts/install-swift-format.sh`
   
## Localisation Update
1. Add LOKALIZE_TOKEN
   
   echo `'export LOKALIZE_TOKEN="your_token_value_here"' >> ~/.zshrc` 
  
2. After adding it, reload your shell config:

   `source ~/.zshrc`
3. run `scripts/translations.sh`
   
## How to release

### Before release 

Before release making sure you `Cancel` or release any pending releases on App Store Connect.

1. Go to `Actions` -> `CreateRelease`

2. Click `Run workflow`

3. Wait for the build to complete and get processed by App Store Connect

### After release

1.  Go to `Actions` -> `IncreaseVersionNumber`

5. Enter desired App Store version number

6. Click `Run workflow`

## Iterating on shared KMP code (HedvigShared aka Umbrella)

Production builds consume `HedvigShared.xcframework` as a Swift Package published from the [Android repo](https://github.com/HedvigInsurance/android) via the `umbrella.yml` workflow. That round-trip takes ~25 minutes, which is too slow for an inner loop. For local development you can swap it for an XCFramework you build yourself — no permanent project changes.

**Prerequisites**

Check out the android repo as a sibling of this one. The directories must be named exactly `android` and `ugglan`:

```
<parent>/
├── android/
└── ugglan/   ← you are here
```

**Use a local build**

```sh
scripts/use-local-umbrella.sh
```

This builds `HedvigShared.xcframework` from your android checkout, writes a gitignored marker file (`.local-umbrella-path`) so Tuist picks up the local artifact, and re-runs `tuist generate`. After this, normal Xcode builds use your local Kotlin changes — only re-run the script when you've changed Kotlin code and want iOS to see it.

**Go back to the published package**

```sh
scripts/use-released-umbrella.sh
```

Removes the marker and regenerates against the version pinned in `Tuist/ProjectDescriptionHelpers/Project+DependenciesTemplate.swift`. Always run this before opening a PR — the marker is gitignored so PRs are unaffected, but you want your local build to match what CI builds.