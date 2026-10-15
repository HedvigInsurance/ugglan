import AppStateContainer
import Foundation
import Observation

@MainActor
@PersistableStore
@Observable
final class UgglanStore: AppStore {
    var isDemoMode: Bool = false
    init() {}
}
