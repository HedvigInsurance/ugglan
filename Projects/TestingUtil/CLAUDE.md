# TestingUtil

Provides test helper utilities, currently focused on Apollo/GraphQL JSON merging.

## Key Files
- `Sources/CombineMultiple.swift` — `combineMultiple(_:)` function that merges an array of `JSONObject` dictionaries (right-biased)

## Dependencies
- Apollo, ApolloAPI, hCore

## Gotchas
- No `Project.swift` exists; likely defined implicitly by Tuist project generation helpers
- Very small module; single file with one public function
- The `combineMultiple` function is used for constructing mock GraphQL responses in tests by merging JSON fragments
