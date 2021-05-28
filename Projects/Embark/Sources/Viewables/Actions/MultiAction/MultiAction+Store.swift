import Flow
import Foundation

internal struct MultiActionStoreable {
    // Initializer from store
    init(storeKey: String, value: String) {
        let substrings = storeKey.multiActionKeySubStrings()
        baseKey = substrings[0]
        index = Int(substrings[1])
        componentKey = substrings[2]

        let valueStrings = value.multiActionValueSubStrings()
        inputValue = valueStrings.first ?? ""
        displayValue = valueStrings.last
    }

    // Initializer from form
    init(actionKey: String, value: String, componentKey: String, index: Int, displayValue: String?) {
        baseKey = actionKey
        inputValue = value
        self.componentKey = componentKey
        self.index = index
        self.displayValue = displayValue
    }

    var baseKey: String
    var index: Int?
    var componentKey: String
    var inputValue: String
    var displayValue: String?

    var storeKey: String {
        baseKey + "[\(String(index ?? 0))]" + componentKey
    }
}

internal extension EmbarkStore {
    func addMultiActionItems(actionKey: String, componentValues: [[String: MultiActionValue]], completion: @escaping () -> Void) {
        let newStoreables = componentValues.enumerated().flatMap { index, element in
            element.map { component in
                MultiActionStoreable(
                    actionKey: actionKey,
                    value: component.value.inputValue,
                    componentKey: component.key,
                    index: index,
                    displayValue: component.value.displayValue
                )
            }
        }

        newStoreables.forEach {
            setValue(key: $0.storeKey, value: $0.inputValue)
        }

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

    func multiActionValueSubStrings() -> [String] {
        let characterSet = CharacterSet(charactersIn: ",")
        return components(separatedBy: characterSet)
    }
}
