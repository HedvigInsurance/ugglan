# hGraphQL

GraphQL networking layer: Apollo client setup (`hApollo` / `hOctopus`), the `.graphql` definitions for the Octopus
API, the generated Swift types, token storage and refresh, and request interceptors. Infrastructure only — no UI.

## Architecture
- Only App links hGraphQL. Its Octopus client implementations
  (`Projects/App/Sources/Service/OctopusClientsImplementation/`) execute queries through the Apollo client.
- `HeadersInterceptor` (via `NetworkInterceptorProvider`) attaches the bearer token and standard headers to every
  request and asks `TokenRefresher.shared` to refresh the access token when it is close to expiry.
- Tokens (`OAuthorizationToken`) are stored in the Keychain via `KeychainHelper`.

## GraphQL files
- Source `.graphql` files: `GraphQL/Octopus/<Feature>/` (not inside `Sources/`). Reusable fragments (money, icon,
  product variant, …) live in `GraphQL/Octopus/SharedFragments/`.
- Generated types: `Sources/Derived/GraphQL/Octopus/` — committed; regenerate with the Codegen tool
  (`scripts/post-checkout.sh`), never edit by hand.

## Dependencies
- Apollo, ApolloAPI, AutomaticLog, Environment, Logger. No Hedvig module dependencies.
- Depended on by: App only. Keep it that way: anything feature modules need (e.g. `DeleteAccountStatus`) belongs in
  hCore, so their SwiftUI previews don't link the generated GraphQL code.

## Gotchas
- App must wire up several mutable globals at startup: `forceLogoutHook` (asserts if left at the default),
  `TokenRefresher.shared.onRefresh` (→ `AuthenticationService.exchange(refreshToken:)`), `urlSessionTaskDeleage`
  (sic — typo in the name) and `graphQlLogger` (defaults to `DemoLogger`).
- `onRefresh` and `forceLogoutHook` are set at the very start of `didFinishLaunching`, before any request can reach
  `TokenRefresher` — keep that ordering (see the comment in `AppDelegate`).
- `GraphQL/Octopus/TerminiateContracts` is misspelled; renaming it changes the generated output paths.
- `ApolloClient.cache` is a static `InMemoryNormalizedCache`; there is no disk cache for GraphQL responses.
