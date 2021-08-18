import Flow
import Foundation

internal struct MultiActionStoreable {
    // Initializer from store
    init?(
        storeKey: String,
        value: String
    ) {
        let substrings = storeKey.multiActionKeySubStrings()
        guard substrings.count == 3 else { return nil }
        baseKey = substrings[0]
        index = Int(substrings[1])
        componentKey = substrings[2]

        let valueStrings = value.multiActionValueSubStrings()
        inputValue = valueStrings.first ?? ""
    }

    // Initializer from form
    init(
        actionKey: String,
        value: String,
        componentKey: String,
        index: Int
    ) {
        baseKey = actionKey
        inputValue = value
        self.componentKey = componentKey
        self.index = index
    }

    var baseKey: String
    var index: Int?
    var componentKey: String
    var inputValue: String

    var isLabel: Bool {
        componentKey.contains("Label")
    }

    var storeKey: String { baseKey + "[\(String(index ?? 0))]" + componentKey }
}

extension EmbarkStore {
    func addMultiActionItems(
        actionKey: String,
        componentValues: [[String: String]],
        completion: @escaping () -> Void
    ) {
        let newStoreables = componentValues.enumerated()
            .flatMap { index, element in
                element.map { component in
                    MultiActionStoreable(
                        actionKey: actionKey,
                        value: component.value,
                        componentKey: component.key,
                        index: index
                    )
                }
            }

        newStoreables.forEach { setValue(key: $0.storeKey, value: $0.inputValue) }

        completion()
    }

    func getMultiActionItems(actionKey: String) -> [MultiActionStoreable] {
        let values = getAllValues()

        return values.filter { (key, _) -> Bool in key.contains(actionKey) }
            .compactMap { MultiActionStoreable(storeKey: $0.key, value: $0.value) }
    }

    func getComponentValues(actionKey: String, data: MultiActionData) -> [[String: MultiActionValue]] {
        let values = getPrefilledMultiActionItems(actionKey: actionKey)

        let clusteredByIndex = Dictionary(grouping: values, by: { $0.index })

        let mappedValues =
            clusteredByIndex.mapValues { storeables in
                Dictionary(uniqueKeysWithValues: storeables.map { ($0.componentKey, $0.zip(with: data)) })
            }
            .values

        return Array(mappedValues)
    }

    func getPrefilledMultiActionItems(actionKey: String) -> [MultiActionStoreable] {
        let values = prefill

        return values.filter { (key, _) -> Bool in key.contains(actionKey) }
            .compactMap { MultiActionStoreable(storeKey: $0.key, value: $0.value) }
    }
}

extension String {
    fileprivate func multiActionKeySubStrings() -> [String] {
        let characterSet = CharacterSet(charactersIn: "[]")
        return components(separatedBy: characterSet)
    }

    fileprivate func multiActionValueSubStrings() -> [String] {
        let characterSet = CharacterSet(charactersIn: ",")
        return components(separatedBy: characterSet)
    }
}
