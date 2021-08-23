import Flow
import Foundation
import Presentation
import hCore
import hGraphQL
import Apollo

extension String { var floatValue: Float { Float(self) ?? 0 } }

public struct EmbarkStoryState: Codable {
    var kvs: KeyValueStore = .init()
    var passageHistory: [hEmbarkPassage] = []
    var currentPassage: hEmbarkPassage?
    var passages: [hEmbarkPassage] = []
    var animationDirection: Bool = true
    var story: hEmbarkStory?
    var externalRedirect: ExternalRedirectLocation?
}

public struct EmbarkNewState: StateProtocol {
    public init() {}
    
    var currentStory: EmbarkStoryState = .init(currentPassage: nil, story: nil)
    var stories: [String: EmbarkStoryState] = [:]
}

public enum EmbarkActions: ActionProtocol {
    // Store
    case restart
    case removeRevision
    case createRevision
    case setComputeValues(values: [String: String])
    case setValue(key: String?, value: String?)
    
    // Passage
    case next(passage: String, pushHistoryEntry: Bool)
    case goBack
    case fetchStory(id: String)
    case setStory(story: hEmbarkStory)
    
    #if compiler(<5.5)
    public func encode(to encoder: Encoder) throws {
        #warning("Waiting for automatic codable conformance from Swift 5.5, remove this when we have upgraded XCode")
        fatalError()
    }
    
    public init(
        from decoder: Decoder
    ) throws {
        #warning("Waiting for automatic codable conformance from Swift 5.5, remove this when we have upgraded XCode")
        fatalError()
    }
    #endif
}

public final class EmbarkStateStore: StateStore<EmbarkNewState, EmbarkActions> {
    @Inject var client: ApolloClient
    @Inject var store: ApolloStore
    
    public override func effects(
        _ getState: () -> EmbarkNewState,
        _ action: EmbarkActions
    ) -> FiniteSignal<EmbarkActions>? {
        switch action {
        case .fetchStory(let id):
            return client.fetchEmbarkStory(name: id, locale: Localization.Locale.currentLocale.code)
                .map { story in
                    .setStory(story: story)
                }.valueThenEndSignal
        default: return nil
        }
    }
    
    public override func reduce(_ state: EmbarkNewState, _ action: EmbarkActions) -> EmbarkNewState {
        var newState = state
        
        switch action {
        
        case .restart:
            newState.currentStory.kvs = .init()
        case .removeRevision:
            newState.currentStory.kvs.removeLastRevision()
        case .createRevision:
            newState.currentStory.kvs.createRevision()
        case .setComputeValues(let values):
            newState.currentStory.kvs.computedValues = values
        case .setValue(let key, let value):
            newState.currentStory.kvs.setValue(key: key, value: value)
        case .next(let passage, let pushHistoryEntry):
            let nextPassage = self.passage(for: passage, currentStory: newState.currentStory)
            newState.currentStory.currentPassage = nextPassage
            if pushHistoryEntry, let nextPassage = nextPassage  {
                newState.currentStory.passageHistory.append(nextPassage)
            }
            if let externalRedirect = nextPassage?.externalRedirect?.location {
                newState.currentStory.externalRedirect = externalRedirect
            }
        case .goBack:
            if let _ = newState.currentStory.passageHistory.last {
                newState.currentStory.currentPassage = newState.currentStory.passageHistory.popLast()
            }
        case .fetchStory:
            break
        case .setStory(let story):
            newState.currentStory.story = story
            newState.currentStory.passages = story.passages
            newState.currentStory.currentPassage = story.initialPassage
        }
        return newState
    }
    
    private func passage(for name: String, currentStory: EmbarkStoryState) -> hEmbarkPassage? {
        if let newPassage = currentStory.passages.first(where: { name == $0.name }) {
            
            if let redirectedPassage = handleRedirects(passage: newPassage, currentStory: currentStory) {
                return redirectedPassage
            } else {
                return newPassage
            }
        }
        
        return nil
    }
    
    private func handleRedirects(passage: hEmbarkPassage, currentStory: EmbarkStoryState) -> hEmbarkPassage? {
        return passage.redirects
            .map { redirect in currentStory.kvs.shouldRedirectTo(redirect: redirect) }
            .map { redirectTo in
                currentStory.passages.first(where: { passage -> Bool in passage.name == redirectTo })
            }
            .compactMap { $0 }.first
    }
}

class KeyValueStore: Codable {
    
    enum CodingKeys: CodingKey {
        case prefill, revisions, queue, computedValues
    }
    
    public required init() {
        prefill = [:]
        revisions = [[:]]
        queue = [:]
        computedValues = [:]
    }
    
    public required init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        prefill = try container.decode([String: String].self, forKey: .prefill)
        revisions = try container.decode([[String: String]].self, forKey: .revisions)
        queue = try container.decode([String: String].self, forKey: .queue)
        computedValues = try container.decode([String: String].self, forKey: .computedValues)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(prefill, forKey: .prefill)
        try container.encode(revisions, forKey: .revisions)
        try container.encode(queue, forKey: .queue)
        try container.encode(computedValues, forKey: .computedValues)
    }
    
    var prefill: [String: String]
    var revisions: [[String: String]]
    var queue: [String: String]
    var computedValues: [String: String]
    
    func setValue(key: String?, value: String?) {
        if let key = key, let value = value {
            guard let arraySymbolRegex = try? NSRegularExpression(pattern: "[\\[\\]]") else { return }
            let keyRange = NSRange(location: 0, length: key.utf16.count)
            let valueRange = NSRange(location: 0, length: value.utf16.count)
            
            // handling for array based keys and values
            if arraySymbolRegex.firstMatch(in: key, options: [], range: keyRange) != nil,
               arraySymbolRegex.firstMatch(in: value, options: [], range: valueRange) != nil
            {
                var mutableValue = String(value)
                mutableValue.removeFirst()
                mutableValue.removeLast()
                let values = mutableValue.split(separator: ",")
                
                var mutableKey = String(key)
                mutableKey.removeFirst()
                mutableKey.removeLast()
                mutableKey.split(separator: ",").enumerated()
                    .forEach { arg in let (offset, key) = arg
                        setValue(key: String(key), value: String(values[offset]))
                    }
            } else {
                prefill[key] = value
                queue[key] = value
            }
        }
    }
    
    public func getAllValues() -> [String: String] {
        let mappedComputedValues = computedValues.compactMapValues { value in parseComputedExpression(value) }
        
        return mappedComputedValues.merging(revisions.last ?? [:], uniquingKeysWith: takeLeft)
    }
    
    private func parseComputedExpression(_ expression: String) -> String? {
        expression.tokens.expression?.evaluate(store: self)
    }
    
    private func arrayRegexFor(key: String) -> String {
        return "\(key)\\[[0-9]+\\]$"
    }
    
    func getValues(key: String, includeQueue: Bool = false) -> [String]? {
        if let computedExpression = computedValues[key] {
            return [parseComputedExpression(computedExpression)].compactMap { $0 }
        }
        
        if let store = revisions.last {
            let storeWithQueue = includeQueue ? queue.merging(store, uniquingKeysWith: takeLeft) : store
            
            let filteredStore = storeWithQueue.filter { (innerKey, value) in
                innerKey.range(of: arrayRegexFor(key: key), options: .regularExpression) != nil
            }
            
            if !filteredStore.isEmpty {
                return Array(filteredStore.values)
            }
            
            if let value = storeWithQueue[key] {
                return [value]
            }
        }
        
        return nil
    }
    
    func getValue(key: String, includeQueue: Bool = false) -> String? {
        return getValues(key: key, includeQueue: includeQueue)?.first
    }
    
    func getValueWithNull(key: String) -> String {
        getValue(key: key) ?? "null"
    }
    
    func getPrefillValue(key: String) -> String? { prefill[key] }
    
    func createRevision() {
        guard let store = revisions.last else { return }
        
        var storeCopy = store
        
        queue.forEach { key, value in storeCopy[key] = value
            queue.removeValue(forKey: key)
        }
        
        revisions.append(storeCopy)
        
        print("COMMITED NEW REVISION:", revisions.last ?? "missing revision")
    }
    
    func removeLastRevision() {
        if revisions.count > 1 {
            revisions.removeLast()
            print("POPPING LAST REVISION, NEW STORE:", revisions.last ?? "missing revision")
        }
    }
    
    func passes(expression: GraphQL.BasicExpressionFragment) -> Bool {
        if let binaryExpression = expression.asEmbarkExpressionBinary {
            switch binaryExpression.expressionBinaryType {
            case .equals: return getValue(key: binaryExpression.key) == binaryExpression.value
            case .lessThan:
                if let storeFloat = getValue(key: binaryExpression.key)?.floatValue {
                    return storeFloat < binaryExpression.value.floatValue
                }
                
                return false
            case .lessThanOrEquals:
                if let storeFloat = getValue(key: binaryExpression.key)?.floatValue {
                    return storeFloat <= binaryExpression.value.floatValue
                }
                
                return false
            case .moreThan:
                if let storeFloat = getValue(key: binaryExpression.key)?.floatValue {
                    return storeFloat > binaryExpression.value.floatValue
                }
                
                return false
            case .moreThanOrEquals:
                if let storeFloat = getValue(key: binaryExpression.key)?.floatValue {
                    return storeFloat >= binaryExpression.value.floatValue
                }
                
                return false
            case .notEquals: return getValue(key: binaryExpression.key) != binaryExpression.value
            case .__unknown: return false
            }
        }
        
        if let unaryExpression = expression.asEmbarkExpressionUnary {
            switch unaryExpression.expressionUnaryType {
            case .always: return true
            case .never: return false
            case .__unknown: return false
            }
        }
        
        return false
    }
    
    func passes(expression: SubExpression) -> Bool {
        switch (expression.typename, expression.type) {
        case (.unary, .always):
            return true
        case (.binary, .equals):
            return getValue(key: expression.key ?? "") == expression.value
        case (.binary, .lessThan):
            if let storeFloat = getValue(key: expression.key ?? "")?.floatValue {
                return storeFloat < (expression.value ?? "").floatValue
            }
            
            return false
        case (.binary, .lessThanOrEquals):
            if let storeFloat = getValue(key: expression.key ?? "")?.floatValue {
                return storeFloat <= (expression.value ?? "").floatValue
            }
        case (.binary, .moreThan):
            if let storeFloat = getValue(key: expression.key ?? "")?.floatValue {
                return storeFloat > (expression.value ?? "").floatValue
            }
        case (.binary, .moreThanOrEquals):
            if let storeFloat = getValue(key: expression.key ?? "")?.floatValue {
                return storeFloat >= (expression.value ?? "").floatValue
            }
        case (.binary, .notEquals):
            return getValue(key: expression.key ?? "") != expression.value
        case (.multiple, .and):
            return !(expression.subExpressions?
                        .compactMap { subExpression -> Bool in
                            self.passes(expression: subExpression)
                        }
                        .contains(false) ?? false)
        case (.multiple, .or):
            return !(expression.subExpressions?
                        .compactMap { subExpression -> Bool in
                            self.passes(expression: subExpression)
                        }
                        .contains(true) ?? false)
        default:
            return false
        }
    }
    
    func shouldRedirectTo(redirect: hEmbarkRedirect) -> String? {
        guard let expression = redirect.expression else {
            return nil
        }
        
        switch expression.typename {
        case .unary:
            if expression.type == .always { return expression.to }
        case .binary:
            guard let key = expression.key,
                  let value = expression.value else { return nil }
            switch expression.type {
            case .equals:
                if getValueWithNull(key: key) == expression.value {
                    return expression.to
                }
            case .lessThan:
                if let storeFloat = getValue(key: key)?.floatValue,
                   storeFloat < value.floatValue
                {
                    return expression.to
                }
                
            case .lessThanOrEquals:
                if let storeFloat = getValue(key: key)?.floatValue,
                   storeFloat <= value.floatValue
                {
                    return expression.to
                }
            case .moreThan:
                if let storeFloat = getValue(key: key)?.floatValue,
                   storeFloat > value.floatValue
                {
                    return expression.to
                }
            case .moreThanOrEquals:
                if let storeFloat = getValue(key: key)?.floatValue,
                   storeFloat >= value.floatValue
                {
                    return expression.to
                }
                
            case .notEquals:
                if getValueWithNull(key: key) != value {
                    return expression.to
                }
            case .unknown: break
            default: break
            }
        case .multiple:
            guard let subExpressions = expression.subExpressions else { break }
            
            switch expression.type {
            case .and:
                if subExpressions
                    .map({ subExpression -> Bool in
                        self.passes(expression: subExpression)
                    })
                    .allSatisfy({ passes in passes })
                {
                    return expression.to
                }
            case .or:
                if subExpressions
                    .map({ subExpression -> Bool in
                        self.passes(expression: subExpression)
                    })
                    .contains(true)
                {
                    return expression.to
                }
            case .unknown: break
            default: break
            }
        }
        
        return nil
    }
}
extension KeyValueStore: Equatable {
    static func == (lhs: KeyValueStore, rhs: KeyValueStore) -> Bool {
        return lhs.revisions == rhs.revisions
    }
}

extension EmbarkStoryState: Equatable {
    public static func == (lhs: EmbarkStoryState, rhs: EmbarkStoryState) -> Bool {
        return lhs.story == rhs.story
    }
}

extension hEmbarkStory: Equatable {
    public static func == (lhs: hEmbarkStory, rhs: hEmbarkStory) -> Bool {
        return lhs.id == rhs.id
    }
}
