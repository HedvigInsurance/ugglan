import Chat
import Foundation
import PresentableStore

extension HomeStore {
    func getChatStore() -> ChatStore {
        globalPresentableStoreContainer.get()
    }
}
