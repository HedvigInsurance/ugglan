# AGENTS.md

## Workspace
This repo uses Tuist. Build and test from `Ugglan.xcworkspace`, not from individual project `.xcodeproj` files.

If workspace files seem stale, regenerate with:
- `scripts/post-checkout.sh`
- or `tuist generate`

## Testing
For `TerminateContracts`, use the workspace:

`xcodebuild test -workspace Ugglan.xcworkspace -scheme TerminateContracts -destination 'id=<SIMULATOR_UDID>' -only-testing:TerminateContractsTests/DeflectScreenContentTests`

A verified example on this machine was:

`xcodebuild test -workspace Ugglan.xcworkspace -scheme TerminateContracts -destination 'id=A0B3E165-14BD-48D6-87EE-EC019BC5B08A' -only-testing:TerminateContractsTests/DeflectScreenContentTests`

## Notes
Running tests against `Projects/TerminateContracts/TerminateContracts.xcodeproj` can fail with missing module dependencies such as `hCore`, `hCoreUI`, `Environment`, `AutomaticLog`, and `SwiftUIIntrospect`. Use the workspace instead.
