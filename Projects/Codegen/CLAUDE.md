# Codegen

macOS command-line tool that downloads the GraphQL schema from the Octopus API and generates Swift code using Apollo Codegen. Targets macOS only.

## Key Files
- `Sources/Codegen/CustomCodegenScript.swift` — Main entry point (`@main`); downloads schema via introspection, cleans derived data, runs Apollo code generation
- `Project.swift` — Tuist project config; declares a macOS app target with ApolloCodegenLib and ArgumentParser dependencies

## Dependencies
- ApolloCodegenLib, ArgumentParser (Swift packages; no internal module dependencies)

## Gotchas
- This is a **macOS app** target, not an iOS framework; it will not appear in iOS builds
- Schema endpoint is hardcoded to `https://apollo-router.dev.hedvigit.com/` (dev environment)
- Generated code goes into each module's `Sources/Derived/GraphQL/` directory
- `findAllGraphQLFolders` scans the repo root to locate all GraphQL output directories
- Has its own Xcode project (`Codegen.xcodeproj`) and workspace, separate from the main Tuist-managed workspace
