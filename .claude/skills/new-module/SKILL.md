---
name: new-module
description: Create a new feature module or split an existing one into <Name>Core (UI-free models, client protocol, service, demo) and <Name>UI (views, navigation, ViewModels) — Tuist manifests, App wiring, regeneration, moving code and tests, and updating every CLAUDE.md that mentions it. Use when adding a module or doing a Core/UI split like the Addons, Contracts or MoveFlow splits.
---

# Create or split a module

Recent splits to copy from: `git show --stat b40b03a44` (MoveFlow), `f22b86c5f` (Contracts), `c246f1f52`
(ChangeTier). Look at one first; it shows every file a split touches.

Don't use `tuist scaffold framework`: its template is outdated (it puts GraphQL in the module and adds no
dependencies). Copy the `Project.swift` of an existing Core/UI pair instead.

## 1. Manifests

`Projects/<Name>Core/Project.swift` (no SwiftUI, no hCoreUI, no hGraphQL):
```swift
let project = Project.framework(
    name: "<Name>Core",
    targets: Set([.framework]),          // add .tests if Core gets its own tests
    projects: ["hCore"],                 // plus other *Core modules it needs
    sdks: []
)
```

`Projects/<Name>UI/Project.swift`:
```swift
let project = Project.framework(
    name: "<Name>UI",
    targets: Set([.framework, .tests]),
    projects: ["hCore", "hCoreUI", "<Name>Core"],
    dependencies: ["CoreDependencies"],
    sdks: []
)
```

For a split, `git mv Projects/<Name> Projects/<Name>UI` first so history follows, then create Core.

Add both to the dependency list in `Projects/App/Project.swift`, next to the other modules:
`.project(target: "<Name>Core", path: .relativeToRoot("Projects/<Name>Core"))`. The workspace picks up `Projects/*`
on its own.

## 2. Move code (splits)

- To Core: models, `Service/Protocols/`, the `@Log` service wrapper, `Service/DemoImplementation/`, and any logic
  without UI. Make what UI and App use `public`, including memberwise `init`s.
- Stays in UI: views, navigation, ViewModels, anything importing SwiftUI/hCoreUI.
- Tests move with the code they test. If both targets need the same mocks, don't duplicate them: pass
  `sharedTestSources: ["Projects/<Name>Core/Tests/MockData.swift"]` to the UI target's `Project.framework` (see
  ChangeTierUI).
- Update imports everywhere the old module was used: `git grep -l 'import <Name>$'` across `Projects/`, including
  App's `OctopusClientsImplementation/` (clients now import `<Name>Core`) and `AppDelegate+DI.swift`.
- Every module that used it: replace it in their `Project.swift` with Core, UI or both, depending on what they import.

## 3. Regenerate and verify

```bash
scripts/generate.sh        # not bare `tuist generate`: this also normalizes schemes
```
Commit the generated `*.xcodeproj/project.xcproj`, `Ugglan.xcworkspace` and `Ugglan-Workspace.xcscheme` changes. The
`Verify generated files` CI job fails if they're stale. Don't commit a generation made in local-umbrella mode or with
`TUIST_ENABLE_REVEAL=1` (the pre-commit hook rejects it).

Build the `Ugglan` scheme, then run the new test targets (see `@test-agent` for the commands).

A split leaves the old `Projects/<Name>/` folder on disk with untracked `xcuserdata`. Delete it locally so Xcode
stops listing it.

## 4. Docs

- `Projects/<Name>Core/CLAUDE.md`: short. UI-free scope, what's here, dependencies, gotchas.
- `Projects/<Name>UI/CLAUDE.md` (renamed from the old doc): architecture, entry points, dependencies, gotchas.
- Root `CLAUDE.md` module index: replace the old row with Core and UI rows.
- Docs of modules that depend on it: update their dependency lines, and "Depended on by" in the new docs.
- Run `scripts/check-claude-docs.py`; it fails CI if a doc still names a moved or deleted file.
