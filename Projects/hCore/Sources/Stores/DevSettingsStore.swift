import AppStateContainer
import Foundation

/// Developer-only settings surfaced in the Ugglan build's profile tab.
/// Persistence survives logout — `AppDelegate.clearData()` excludes this store
/// when clearing the app state container.
@MainActor
@PersistableStore
public final class DevSettingsStore: AppStore {
    @Published public private(set) var isSubmitClaimAnimationsEnabled: Bool = true

    public init() {}

    public func setSubmitClaimAnimationsEnabled(_ enabled: Bool) {
        isSubmitClaimAnimationsEnabled = enabled
    }
}
