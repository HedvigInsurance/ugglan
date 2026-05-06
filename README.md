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

Production consumes `HedvigShared.xcframework` (multi-slice) as a Swift Package published from the [Android repo](https://github.com/HedvigInsurance/android) by the `umbrella.yml` workflow — ~25 minutes per round-trip, too slow for an inner loop. Local mode swaps that for a single-slice `.framework` that Xcode rebuilds on every build, matching whatever architecture/SDK/configuration is selected. Production cycle stays unchanged; CI is unaffected.

**Prerequisites**

Check out the android repo as a sibling of this one. The directories must be named exactly `android` and `ugglan`:

```
<parent>/
├── android/
└── ugglan/   ← you are here
```

**Switch to local mode**

```sh
scripts/use-local-umbrella.sh
```

Creates a gitignored marker file (`.local-umbrella-path`) and re-runs `tuist generate`. From now on, every time you build Ugglan in Xcode, a pre-build phase on `CoreDependencies` invokes `./gradlew :umbrella:embedAndSignAppleFrameworkForXcode` in `../android` and drops the freshly-built `HedvigShared.framework` into `${BUILT_PRODUCTS_DIR}`. Edit Kotlin, hit ⌘R; iOS sees your changes.

**Switch back to the published package**

```sh
scripts/use-released-umbrella.sh
```

Removes the marker and regenerates against the version pinned in `Tuist/ProjectDescriptionHelpers/Project+DependenciesTemplate.swift`. Always run this before opening a PR — the marker is gitignored so PRs are unaffected, but your local build should match what CI builds.

**About `scripts/post-build-action.sh`**

This script runs as a post-build phase on the Ugglan target and copies frameworks into the app bundle. Local mode introduces an additional concern: Compose Multiplatform's resource reader uses `Bundle.main` and looks for resources at `<App>.app/compose-resources/composeResources/...`, but in our Tuist multi-target setup gradle's output ends up bundled inside `CoreDependencies.framework/compose-resources/` (Xcode's standard "Copy Bundle Resources" phase sweeps it up there). The script lifts that directory out to the app-bundle root so `Bundle.main` can find it. If you ever see `MissingResourceException` for a path under `Ugglan.app/compose-resources/...`, this copy is what's responsible.