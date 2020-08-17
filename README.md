<img src="https://i.imgur.com/awvfy5Q.png" width="50" height="auto" />

Hedvig is a new approach to insurance currently available in Sweden and Norway, we belive in transparency hence we code in the open and publish all our source code here on Github, feel free to take a peek, if you are interested in working with us check out our [jobs page](https://join.hedvig.com).

# ugglan [![Build Status](https://app.bitrise.io/app/99ca525f2bb31deb/status.svg?token=Jdifn0M6-BB_sCWW3lzYdQ&branch=master)](https://app.bitrise.io/app/99ca525f2bb31deb)

🦉 It's just an insurance app for iOS

## Run the app

1. Install Xcode

   `get it from the Mac App Store`

2. Install tuist

   `bash <(curl -Ls https://install.tuist.io)`

3. Run tuist up

   `tuist up`

4. Run tuist focus

   `tuist focus`

## How to release

1. Create a tag in Git with the name `RELEASE-\(versionNumber)`
   if you want the release to have version `3.0.1` you for create a tag named `RELEASE-3.0.1`

2. Bitrise will create and upload the build to App Store connect

3. Create a GitHub release and add a description containing all commits included in the release, use the following command to retrieve the list:

   `git log --pretty=oneline RELEASE-\(previousVersionNumber)...RELEASE-\(versionNumber) --first-parent master`
   
4. Submit the release to review in App Store connect as usual
