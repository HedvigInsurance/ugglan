import Chat
import Foundation
import StoreContainer

extension HomeStore {
    func getChatStore() -> ChatStore {
        globalPresentableStoreContainer.get()
    }
}
