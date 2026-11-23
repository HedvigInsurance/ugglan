---
name: add-service
description: Add a GraphQL-backed client to a feature module end to end — .graphql file and codegen, the @MainActor client protocol, the @Log service wrapper, the demo client, the Octopus implementation in App, registration in all three DI blocks, and test mocks. Use when a feature needs a new backend call or a new client protocol.
---

# Add a GraphQL-backed service

Every client is a triple: protocol (feature module) + demo (feature module) + Octopus implementation (App). Missing any
part, or one of the three DI registrations, only shows up at runtime as an `@Inject` fatalError. Work through these
steps in order; skip the ones that already exist (e.g. adding a method to an existing client).

`<Feature>` is the Core module when the feature is split (`AddonsCore`), otherwise the feature module (`Payment`).

## 1. Query or mutation

- Add `Projects/hGraphQL/GraphQL/Octopus/<Feature>/<Name>.graphql`. Reuse fragments from `SharedFragments/` or the
  feature folder instead of re-selecting the same fields.
- Regenerate: `scripts/codegen.sh` (builds and runs the Codegen app against the dev schema). Output lands in
  `Projects/hGraphQL/Sources/Derived/`; commit it. If you can't reach the schema, say so rather than hand-writing
  generated types.
- Generated types are `OctopusGraphQL.<Name>Query` / `OctopusGraphQL.<Name>Mutation`.

## 2. Client protocol — `<Feature>/Sources/Service/Protocols/<Name>Client.swift`

```swift
@MainActor
public protocol <Name>Client: Sendable {
    func getThing(id: String) async throws -> Thing
}
```

Use the module's own model types in signatures, never generated GraphQL types: feature modules (and hCore) don't
depend on hGraphQL, so previews and tests don't link generated code.

## 3. Service wrapper — `<Feature>/Sources/Service/<Name>Service.swift`

```swift
@MainActor public class <Name>Service {
    @Inject var client: <Name>Client

    public init() {}

    @Log
    public func getThing(id: String) async throws -> Thing {
        try await client.getThing(id: id)
    }
}
```

- `@Log` (AutomaticLog) logs calls and errors. Use `@Log(masked: ["phone"])` for personal data.
- Don't put `Task { [weak self] in … }` inside an `@Log` / `@LogAll` body: it crashes the compiler. Move that code
  into an extension without the macro.
- ViewModels call the service, not the client.

## 4. Demo client — `<Feature>/Sources/Service/DemoImplementation/<Name>ClientDemo.swift`

`public class <Name>ClientDemo: <Name>Client` returning realistic data (add `await delay(...)` for loading states).
Previews and demo mode use it.

## 5. Octopus implementation — `Projects/App/Sources/Service/OctopusClientsImplementation/<Name>ClientOctopus.swift`

```swift
class <Name>ClientOctopus: <Name>Client {
    @Inject private var octopus: hOctopus

    func getThing(id: String) async throws -> Thing {
        let data = try await octopus.client.fetch(query: OctopusGraphQL.ThingQuery(id: id))
        return Thing(fragment: data.thing.fragments.thingFragment)
    }
}
```

- Mutations: `try await octopus.client.mutation(mutation: ...)` returns optional data. Unwrap it and throw on `nil`.
- GraphQL → model conversions live in App (an extension next to the client, or in `hCoreModels+Octopus.swift` for
  hCore models), never in the feature module.

## 6. Register in `Projects/App/Sources/AppDelegate+DI.swift`

There are three blocks, and the client must be in every one it applies to:
1. **Demo mode** (`if ugglanStore.isDemoMode`): create `<Name>ClientDemo()` with the other demo clients, then
   `Dependencies.shared.add(module: Module { () -> <Name>Client in ... })`.
2. **`case .staging:`** and 3. **`case .production, .custom:`**: create `<Name>ClientOctopus()` once before the
   `switch`, then register it in both cases.

Afterwards check the protocol name appears the expected number of times:
`grep -c '<Name>Client in' Projects/App/Sources/AppDelegate+DI.swift` should print 3.

## 7. Tests

Add a factory to the module's `Tests/MockData.swift` and a mock client that records `events`, following
`.claude/rules/testing.md`. Test the service and the ViewModels that use it. `@test-agent` can generate these.

## 8. Finish

- If the module's `Project.swift` gained a dependency, run `scripts/generate.sh` and commit the generated projects.
- Update the module's `CLAUDE.md` if the new client changes its architecture or entry points.
- Build the `Ugglan` scheme to verify everything compiles.
