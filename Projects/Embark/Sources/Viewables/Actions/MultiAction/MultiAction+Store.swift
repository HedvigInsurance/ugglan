import Flow
import Foundation

internal struct MultiActionStoreable {
    // Initializer from store
    init(storeKey: String, value: String) {
        let substrings = storeKey.multiActionKeySubStrings()
        baseKey = substrings[0]
        index = Int(substrings[1])
        componentKey = substrings[2]
        self.value = value
    }

    // Initializer from form
    init(actionKey: String, value: String, componentKey: String, index: Int) {
        baseKey = actionKey
        self.value = value
        self.componentKey = componentKey
        self.index = index
    }

    var baseKey: String
    var index: Int?
    var componentKey: String
    var value: String

    var storeKey: String {
        baseKey + "[\(String(index ?? 0))]" + componentKey
    }
}

internal extension EmbarkStore {
    func addMultiActionItem(actionKey: String, componentValues: [String: String], completion: @escaping () -> Void) {
        let currentItems = getMultiActionItems(actionKey: actionKey)
        let nextIndex = currentItems.isEmpty ? 0 : (currentItems.count - 1)

        let newStoreables = componentValues.map { MultiActionStoreable(actionKey: actionKey, value: $0.value, componentKey: $0.key, index: nextIndex) }

        newStoreables.forEach { storeable in
            setValue(key: storeable.storeKey, value: storeable.value)
        }

        createRevision()

        completion()
    }

    func getMultiActionItems(actionKey: String) -> [MultiActionStoreable] {
        let values = getAllValues()

        return values
            .filter { (key, _) -> Bool in
                key.contains(actionKey)
            }
            .map {
                MultiActionStoreable(storeKey: $0.key, value: $0.value)
            }
    }
}

private extension String {
    func multiActionKeySubStrings() -> [String] {
        let characterSet = CharacterSet(charactersIn: "[]")
        return components(separatedBy: characterSet)
    }
}
