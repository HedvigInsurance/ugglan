# Codegen

macOS command-line tool (`CustomCodegenScript`, `@main`) that downloads the Octopus GraphQL schema via introspection
and generates Swift types with Apollo Codegen. Run via `scripts/codegen.sh` (also part of `scripts/post-checkout.sh`).

## Dependencies
- ApolloCodegenLib, ArgumentParser (Swift packages; no internal module dependencies)

## Gotchas
- This is a **macOS app** target, not an iOS framework, with its own committed `Codegen.xcodeproj` outside the main
  workspace; `scripts/codegen.sh` builds and runs it with `xcodebuild`.
- The schema endpoint is hardcoded to `https://apollo-router.dev.hedvigit.com/` (dev environment), so output follows
  the live dev schema.
- Input is `Projects/hGraphQL/GraphQL/Octopus/`; output goes to `Projects/hGraphQL/Sources/Derived/GraphQL/Octopus/`.
  Before generating, it deletes `Sources/Derived/GraphQL/` in every module under `Projects/`.
