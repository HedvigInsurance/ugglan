Hedvig is a new approach to insurance currently available in Sweden, Norway and Denmark, we belive in transparency hence we code in the open and publish all our source code here on Github, feel free to take a peek, if you are interested in working with us check out our [jobs page](https://www.hedvig.com/se/hedvig/karriar).


🦉 It's just an insurance app for iOS

## Run the app

1. Install Xcode

   `get it from the Mac App Store`

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

## Additional requirements
### .netrc file in root folder - you will need access to the hedvig authlib repository
`machine maven.pkg.github.com
`
`login <github-login>
`
`password <password>
`


`login` is your github login

`password` is token generated at [github](https://github.com/settings/tokens)

## Known issues

### Run post-checkout issue
This issue is related to the Xcode caching

`xcodebuild: error: Could not resolve package dependencies: failed downloading 'https://maven.pkg.github.com/HedvigInsurance/authlib/com/hedvig/authlib/authlib-kmmbridge/1.3.21-alpha-20240313135116/authlib-kmmbridge-1.3.21-alpha-20240313135116.zip' which is required by binary target 'authlib': badResponseStatusCode(401)`
###### Running this commands in the terminal should resolve it:
`rm -rf ~/Library/Caches/org.swift.swiftpm`

`rm -rf ~/Library/org.swift.swiftpm`

and deleting everything inside

/Users/youruser/Library/Developer/Xcode/DerivedData/
