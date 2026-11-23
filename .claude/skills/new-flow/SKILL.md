---
name: new-flow
description: Build a new multi-screen feature flow the way this repo does it — a `.handleX(input:)` coordinator modifier as the entry point, a navigation ViewModel owning a NavigationRouter, a route enum with tracking names, hNavigationStack, detents and modals, then hooking it into App. Use when adding a new flow or screen sequence, or when asked how flows are presented.
---

# Build a feature flow

Reference implementations: `Projects/AddonsUI/Sources/Navigation/` (`RemoveAddonCoordinator` +
`RemoveAddonNavigation`) and `Projects/Onboarding/Sources/Navigation/`. Read one before starting; match it, not this
outline, where they differ.

## 1. Entry point: a coordinator modifier

Flows start through a `ViewModifier` exposed as `View.handle<Flow>(...)`, so any screen can launch them by setting a
binding. Nobody calls the navigation view directly.

```swift
private struct <Flow>Coordinator: ViewModifier {
    @Binding var input: <Flow>Input?
    @State private var loaded: <Flow>Data?        // what the flow needs once fetched

    func body(content: Content) -> some View {
        content
            .modally(item: $loaded) { data in <Flow>Navigation(data) }   // or .detent(item:...)
            .onChange(of: input) { _, input in
                guard let input else { return }
                Task {
                    do { loaded = try await service.load(input) } catch {
                        Toasts.shared.displayToastBar(toast: .init(type: .error, text: error.localizedDescription))
                    }
                    self.input = nil
                }
            }
    }
}

extension View {
    public func handle<Flow>(input: Binding<<Flow>Input?>) -> some View {
        modifier(<Flow>Coordinator(input: input))
    }
}
```

If the flow can open from anywhere in the logged-in app, apply it in
`Projects/App/Sources/Navigation/LoggedInNavigation+Presentations.swift` next to `.handleAddons(...)` and add the
binding to `LoggedInNavigationViewModel`. Otherwise apply it on the screen that launches it.

## 2. Navigation ViewModel and routes

```swift
@MainActor
@Observable
final class <Flow>NavigationViewModel {
    let router = NavigationRouter()
    // child ViewModels and presentation state (isProcessingPresented, sheet items, …)
}

enum <Flow>Route: Hashable, TrackingViewNameProtocol {
    case summary
    var nameForTracking: String {
        switch self {
        case .summary: .init(describing: <Flow>SummaryScreen.self)
        }
    }
}
```

`NavigationRouter.push` only accepts `Hashable & TrackingViewNameProtocol`. Every route and every presented root
needs a tracking name: analytics screen views depend on it.

## 3. Navigation view

```swift
public struct <Flow>Navigation: View {
    @State private var vm: <Flow>NavigationViewModel

    public var body: some View {
        hNavigationStack(router: vm.router, options: [.extendedNavigationWidth], tracking: <Flow>Tracking.root) {
            <Flow>Screen()
                .routerDestination(for: <Flow>Route.self) { route in
                    switch route {
                    case .summary: <Flow>SummaryScreen().navigationTitle(L10n....)
                    }
                }
        }
        .environment(vm)
    }
}
```

- Screens get the navigation VM with `@Environment(<Flow>NavigationViewModel.self)` and the router with
  `@Environment(NavigationRouter.self)`. Push with `router.push(<Flow>Route.summary)`; finish with `router.dismiss()`.
- Bottom sheets: `.detent(item:)` or `.detent(presented:)`. Never use SwiftUI `.sheet`.
- Full screen: `.modally(...)`. A modal root that needs a nav bar is wrapped with
  `.withDismissButton()` **then** `.embededInNavigation(tracking: ...)`, in that order.
- A screen with a text field inside a sheet gets `.releasesKeyboardRetentionOnDeinit()`. Otherwise iOS 26 keeps the
  whole flow's view and VM graph alive after dismissal.
- To embed the flow in another flow's stack, take an optional `NavigationRouter` and only create your own
  `hNavigationStack` when it's `nil` (see `ChangeTierNavigation`).

## 4. Screens

`hForm` + `hSection` + `hRow`, `hText`, `hButton`; strings from `L10n`; components from
`.claude/rules/design-system.md`. ViewModels are `@MainActor @Observable` and call the module's service, not the client.
Loading and error states use `ProcessingStateView` / `GenericErrorView` / `.trackErrorState` like neighbouring screens.

## 5. Finish

- Run `@accessibility-agent` on the new screens. The edit hook already runs the mechanical checks.
- Run `@test-agent` for the ViewModels. Add a deallocation test for the navigation VM if it holds subscriptions or
  `Task`s (see `OnboardingNavigationRetainTests`).
- Add the entry point to the module's `CLAUDE.md` under "Entry points".
- Check it renders: build, and use `RenderPreview` or run the app in demo mode.
