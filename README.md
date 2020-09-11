<img src="https://i.imgur.com/awvfy5Q.png" width="50" height="auto" />

Hedvig is a new approach to insurance currently available in Sweden and Norway, we belive in transparency hence we code in the open and publish all our source code here on Github, feel free to take a peek, if you are interested in working with us check out our [jobs page](https://join.hedvig.com).

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

## How to release

1. Go to `Actions` -> `ProductionDeploy` ([link](https://github.com/HedvigInsurance/ugglan/actions?query=workflow%3AProductionDeploy))

2. Click `Run workflow`

3. Enter desired App Store version number

4. Click `Run workflow`

5. Wait for the build to complete and upload to App Store Connect


