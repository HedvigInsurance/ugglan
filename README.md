<img src="https://i.imgur.com/awvfy5Q.png" width="50" height="auto" />

Hedvig is a new approach to insurance currently available in Sweden, Norway and Denmark, we belive in transparency hence we code in the open and publish all our source code here on Github, feel free to take a peek, if you are interested in working with us check out our [jobs page](https://jobs.lever.co/hedvig).

# ugglan ![WorkspaceTests](https://github.com/HedvigInsurance/ugglan/workflows/WorkspaceTests/badge.svg) ![WorkspaceApps](https://github.com/HedvigInsurance/ugglan/workflows/WorkspaceApps/badge.svg) 

🦉 It's just an insurance app for iOS

## Run the app

1. Install Xcode

   `get it from the Mac App Store`

2. Install tuist

   `bash <(curl -Ls https://install.tuist.io)`

3. Run tuist up

   `tuist up`

4. Run tuist generate

   `tuist generate`
   
5. Open workspace

   `open Ugglan.xcworkspace`

## Provision new devices

1. Add device UDID to devices.txt
2. `fastlane ios provision`
3. Trigger new build for latest commit on `main` by clicking `re-run` in Github Actions
   
## Formatting

We use swift-format for formatting, it's ran on all staged files automatically in a pre-commit hook.

1. Install githooks
   
   sh `scripts/githooks.sh`
   
2. Install swift-format
   
   sh `scripts/install-swift-format.sh`
   
## How to release

Before release making sure you `Cancel` any pending releases on App Store Connect.

1. Go to `Actions` -> `ProductionDeploy`

2. Click `Run workflow`

3. Enter desired App Store version number

4. Click `Run workflow`

5. Wait for the build to complete and get processed by App Store Connect


