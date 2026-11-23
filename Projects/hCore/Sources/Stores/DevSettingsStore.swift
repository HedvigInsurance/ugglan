import AppStateContainer
import Foundation
import Observation

/// Developer-only settings surfaced in the Ugglan build's profile tab.
/// Persistence survives logout — `AppDelegate.clearData()` excludes this store
/// when clearing the app state container.
@MainActor
@PersistableStore
@Observable
public final class DevSettingsStore: AppStore {
    public private(set) var isSubmitClaimAnimationsEnabled: Bool = true
    /// Shows the voice claim POC without the `enable_voice_claim_submission` Unleash flag.
    public private(set) var isVoiceClaimForced: Bool = false

    public init() {}

    public func setSubmitClaimAnimationsEnabled(_ enabled: Bool) {
        isSubmitClaimAnimationsEnabled = enabled
    }

    public func setVoiceClaimForced(_ forced: Bool) {
        isVoiceClaimForced = forced
    }
}
