# ugglan [![Build Status](https://app.bitrise.io/app/99ca525f2bb31deb/status.svg?token=Jdifn0M6-BB_sCWW3lzYdQ&branch=master)](https://app.bitrise.io/app/99ca525f2bb31deb)

🦉Hedvig's nice insurance app for iOS

## Run the app

1. Install Xcode

   `get it from the Mac App Store`

2. Install Carthage

   `brew install carthage`

3. Install Struct

   `sudo gem install struct`

4. Install Swiftformat

   `brew install swiftformat`

5. Install Swiftgen

   `brew install swiftgen`

6. Install Swiftlint

   `brew install swiftlint`

7. Install dependencies

   `carthage bootstrap --platform iOS`

8. Install translations CLI

   `curl -o /usr/local/bin/swiftTranslationsCodegen "https://raw.githubusercontent.com/HedvigInsurance/swift-translations-codegen/master/main.swift?$(date +%s)" && chmod +x /usr/local/bin/swiftTranslationsCodegen`

9. Add aliases to your bash/zsh config

   1. open ~/.bashrc or ~/.zshrc

   2. put this into that file:

   `alias graphql="sh scripts/generate-apollo-files.sh" alias graphqlSchema="sh scripts/update-graphql-schema.sh" alias translations="swiftTranslationsCodegen --projects '[App, IOS]' --destination 'Src/Assets/Localization/Localization.swift'" alias assets="swiftgen"`

10. Install Apollo CLI

   `npm install -g apollo`

11. Run file generation scripts

   `graphqlSchema graphql translations assets`

12. Generate Xcode project

   `struct generate`

13. Open the projext

   `open test.xcodeproj`

14. run it!! 🏃🏻‍♂️

   `press cmd + r`

## How to release

1. Create a tag in Git with the name `RELEASE-\(versionNumber)`
   if you want the release to have version `3.0.1` you for create a tag named `RELEASE-3.0.1`

2. Bitrise will create and upload the build to App Store connect

3. Create a GitHub release and add a description containing all commits included in the release, use the following command to retrieve the list:

   `git log --pretty=oneline RELEASE-\(previousVersionNumber)...RELEASE-\(versionNumber) --first-parent master`
   
4. Submit the release to review in App Store connect as usual
