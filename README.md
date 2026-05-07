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

If you never edit Kotlin, you can ignore this section — run [post-checkout.sh](scripts/post-checkout.sh), build, and ship as normal. Xcode pulls `HedvigShared` automatically from a Swift Package and `scripts/post-build-action.sh` handles the rest. The setup below is for the inner loop when you *are* iterating on shared Kotlin code from the sibling [`android/`](https://github.com/HedvigInsurance/android) repo.

### How HedvigShared is wired

```
android/                                  ugglan/
└─ app/umbrella  ──gradle──>  HedvigShared.framework  ──linker──>  CoreDependencies.framework
   (Kotlin code)              (static archive,                     (carries the Kotlin
                               wrapper not in .app bundle)          symbols at runtime)
```

- **`umbrella`** is the Gradle module on the android side that exposes Kotlin code to iOS. Its build product, **`HedvigShared.framework`**, is what iOS imports.
- The framework is `isStatic = true`, so its archive is **statically linked into `CoreDependencies.framework`** at workspace build time — that's where the Kotlin code actually lives at runtime. The `HedvigShared.framework` wrapper itself is a build-time linker artifact and is removed from the `.app` bundle by `post-build-action.sh`.
- **Released mode** (default): `HedvigShared.framework` comes from a published Swift Package built by [`umbrella.yml`](https://github.com/HedvigInsurance/android/blob/develop/.github/workflows/umbrella.yml) — round-tripping a Kotlin change through CI takes ~25 minutes.
- **Local mode**: a Tuist toggle + a gradle pre-build phase rebuilds the framework from your sibling `android/` checkout on every Xcode build, ~5–10s per Kotlin change.

### Local mode

Check out the android repo as a sibling. The directories must be named exactly `android` and `ugglan`:

```
<parent>/
├── android/
└── ugglan/   ← you are here
```

**Switch to local mode** (close Xcode first):

```sh
scripts/use-local-umbrella.sh
```

Then `open Ugglan.xcworkspace` and build. Edit Kotlin, hit ⌘R; iOS picks it up.

**Switch back to the published package** before opening a PR:

```sh
scripts/use-released-umbrella.sh
```

Both scripts wipe Ugglan's DerivedData (mixing artifacts from both modes silently corrupts signatures) and refuse to run if Xcode is open. Run `scripts/umbrella-status.sh` to see which mode you're currently in.

`scripts/post-build-action.sh` does the iOS-side surgery that makes both modes work — removes the static `HedvigShared.framework` from the bundle, lifts `compose-resources/` to the right path for `Bundle.main`, re-signs the app. Read the comments in the script if you ever debug an install error or a `MissingResourceException`.