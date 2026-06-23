import AppStateContainer
import Foundation

@MainActor
@PersistableStore
final class UgglanStore: AppStore {
    @Published var isDemoMode: Bool = false
    init() {}
}
