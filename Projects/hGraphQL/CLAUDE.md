# hGraphQL

The foundational GraphQL networking layer for the app. Contains the Apollo client setup, all `.graphql` query/mutation/fragment definitions for the Octopus API, generated Swift types from those definitions, token management, and request interceptors.

## Architecture
- Pattern: Infrastructure module, not a feature module. No ViewModels or UI.
- Key services: `ApolloClient` setup (`hApollo`, `hOctopus`), `TokenRefresher` (singleton), `HeadersInterceptor`, `NetworkInterceptorProvider`
- Data flow: Feature modules import hGraphQL (indirectly, via hCore) and use the Apollo client to execute queries/mutations. The `HeadersInterceptor` attaches auth tokens and standard headers to every request. `TokenRefresher` handles automatic access token refresh before requests when the token is near expiry.

## Key Files
- Apollo client setup: `ApolloClient.swift` in `Sources/ApolloClient.swift` -- creates the Octopus client, manages token storage/retrieval via Keychain, handles headers
- Token model: `OAuthorizationToken` in `Sources/OAuthorizationToken.swift`
- Token DTO: `AuthorizationTokenDto` in `Sources/Models/AuthorizationTokenDto.swift`
- Token refresh: `TokenRefresher` in `Sources/TokenRefresher.swift` -- singleton that checks token expiry and coordinates refresh
- Request interceptor: `HeadersInterceptor` in `Sources/HeadersInterceptor.swift` -- injects auth bearer token and triggers token refresh
- Interceptor provider: `NetworkInterceptorProvider` in `Sources/NetworkInterceptorProvider.swift`
- Force logout hook: `ForceLogoutHook` in `Sources/ForceLogoutHook.swift` -- global closure called when refresh token expires
- Keychain: `KeychainHelper` in `Sources/KeychainHelper.swift`
- Logger: `Log.swift` in `Sources/Log.swift` -- global `graphQlLogger` variable
- GraphQL nullable helper: `GraphQLNullable.swift` in `Sources/GraphQLNullable.swift`

## GraphQL File Organization
- Source `.graphql` files: `GraphQL/Octopus/<Feature>/` (NOT inside `Sources/`)
- Feature directories include: Addons, Campaign, ChangeTier, Chat, Claims, Contracts, CrossSell, EditStakeholders, Forever, Home, InsuranceEvidence, MoveFlow, Payments, Profile, SharedFragments, SubmitClaimChat, TerminiateContracts, TravelCertificate, Ugglan
- SharedFragments: `GraphQL/Octopus/SharedFragments/` contains reusable fragments (MoneyFragment, IconFragment, ProductVariantFragment, etc.)
- Generated Swift types: `Sources/Derived/GraphQL/Octopus/` -- organized into `Fragments/`, `Operations/Queries/`, `Operations/Mutations/`, and `Schema/`
- Codegen output is committed to the repository under `Sources/Derived/`

## Dependencies
- Imports: Apollo, ApolloWebSocket, ApolloAPI, Disk, Environment, Logger
- No Hedvig module dependencies (this is a leaf dependency)
- Depended on by: hCore (which re-exports it to all feature modules)

## Navigation
- Not applicable. This is an infrastructure module with no UI or navigation.

## Gotchas
- The `forceLogoutHook` is a mutable global closure (`Sources/ForceLogoutHook.swift`) that must be set by the App at startup. If not set, it triggers an `assertionFailure`.
- `TokenRefresher.onRefresh` is an optional closure that must be wired up externally (typically to `AuthenticationService.exchange(refreshToken:)`).
- `urlSessionTaskDeleage` (note: typo in the variable name, missing "t" in "delegate") is a global mutable closure for overriding the URLSession task delegate.
- The `TerminiateContracts` directory under `GraphQL/Octopus/` has a typo (should be "TerminateContracts").
- `ApolloClient.cache` is a static `InMemoryNormalizedCache` shared across the app. There is no disk-based cache for GraphQL responses.
- `graphQlLogger` in `Log.swift` is initialized with a `DemoLogger()` and must be replaced at app startup for production logging.
