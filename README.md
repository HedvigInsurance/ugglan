# ugglan [![Build Status](https://app.bitrise.io/app/99ca525f2bb31deb/status.svg?token=Jdifn0M6-BB_sCWW3lzYdQ&branch=master)](https://app.bitrise.io/app/99ca525f2bb31deb)

🦉The next iOS for Hedvig

This is the main repository for the up and coming iOS app for Hedvig, this repository will eventually replace [app](https://github.com/HedvigInsurance/app).

## Run the app

1. Install XCode

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

`carthage update --platform iOS`

8. Add aliases to your bash/zsh config

   1. open ~/.bashrc or ~/.zshrc

   2. put this into that file:

   `alias graphql="sh scripts/generate-apollo-files.sh" alias graphqlSchema="sh scripts/update-graphql-schema.sh" alias translations="sh scripts/update-translations.sh" alias assets="swiftgen"`

9. Install Apollo CLI

`npm install -g apollo`

10. Run file generation scripts

`graphqlSchema graphql translations assets`

11. Add Google Services plist

`Obtain a Google Services plist from firebase and add it to the "Src" folder.`

11. Generate Xcode project

`struct generate`

12. Open the projext

`open project.xcodeproj`

13. run it!! 🏃🏻‍♂️

`press cmd + r`

## Concepts

### Viewables

A viewable makes it possible to write isolated code that generates a structure of views following the component-principle.
