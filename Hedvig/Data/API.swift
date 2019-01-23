//  This file was automatically generated and should not be edited.

import Apollo

public enum HedvigColor: RawRepresentable, Equatable, Hashable, Apollo.JSONDecodable, Apollo.JSONEncodable {
    public typealias RawValue = String
    case pink
    case turquoise
    case purple
    case darkPurple
    case blackPurple
    case darkGray
    case lightGray
    case white
    case black
    case offBlack
    case offWhite
    case green
    /// Auto generated constant for unknown enum values
    case __unknown(RawValue)

    public init?(rawValue: RawValue) {
        switch rawValue {
        case "Pink": self = .pink
        case "Turquoise": self = .turquoise
        case "Purple": self = .purple
        case "DarkPurple": self = .darkPurple
        case "BlackPurple": self = .blackPurple
        case "DarkGray": self = .darkGray
        case "LightGray": self = .lightGray
        case "White": self = .white
        case "Black": self = .black
        case "OffBlack": self = .offBlack
        case "OffWhite": self = .offWhite
        case "Green": self = .green
        default: self = .__unknown(rawValue)
        }
    }

    public var rawValue: RawValue {
        switch self {
        case .pink: return "Pink"
        case .turquoise: return "Turquoise"
        case .purple: return "Purple"
        case .darkPurple: return "DarkPurple"
        case .blackPurple: return "BlackPurple"
        case .darkGray: return "DarkGray"
        case .lightGray: return "LightGray"
        case .white: return "White"
        case .black: return "Black"
        case .offBlack: return "OffBlack"
        case .offWhite: return "OffWhite"
        case .green: return "Green"
        case let .__unknown(value): return value
        }
    }

    public static func == (lhs: HedvigColor, rhs: HedvigColor) -> Bool {
        switch (lhs, rhs) {
        case (.pink, .pink): return true
        case (.turquoise, .turquoise): return true
        case (.purple, .purple): return true
        case (.darkPurple, .darkPurple): return true
        case (.blackPurple, .blackPurple): return true
        case (.darkGray, .darkGray): return true
        case (.lightGray, .lightGray): return true
        case (.white, .white): return true
        case (.black, .black): return true
        case (.offBlack, .offBlack): return true
        case (.offWhite, .offWhite): return true
        case (.green, .green): return true
        case let (.__unknown(lhsValue), .__unknown(rhsValue)): return lhsValue == rhsValue
        default: return false
        }
    }
}

public struct CampaignInput: GraphQLMapConvertible {
    public var graphQLMap: GraphQLMap

    public init(source: Swift.Optional<String?> = nil, medium: Swift.Optional<String?> = nil, term: Swift.Optional<String?> = nil, content: Swift.Optional<String?> = nil, name: Swift.Optional<String?> = nil) {
        graphQLMap = ["source": source, "medium": medium, "term": term, "content": content, "name": name]
    }

    public var source: Swift.Optional<String?> {
        get {
            return graphQLMap["source"] as! Swift.Optional<String?>
        }
        set {
            graphQLMap.updateValue(newValue, forKey: "source")
        }
    }

    public var medium: Swift.Optional<String?> {
        get {
            return graphQLMap["medium"] as! Swift.Optional<String?>
        }
        set {
            graphQLMap.updateValue(newValue, forKey: "medium")
        }
    }

    public var term: Swift.Optional<String?> {
        get {
            return graphQLMap["term"] as! Swift.Optional<String?>
        }
        set {
            graphQLMap.updateValue(newValue, forKey: "term")
        }
    }

    public var content: Swift.Optional<String?> {
        get {
            return graphQLMap["content"] as! Swift.Optional<String?>
        }
        set {
            graphQLMap.updateValue(newValue, forKey: "content")
        }
    }

    public var name: Swift.Optional<String?> {
        get {
            return graphQLMap["name"] as! Swift.Optional<String?>
        }
        set {
            graphQLMap.updateValue(newValue, forKey: "name")
        }
    }
}

public final class ProfileQuery: GraphQLQuery {
    public let operationDefinition =
        "query Profile {\n  member {\n    __typename\n    firstName\n    lastName\n  }\n  insurance {\n    __typename\n    address\n    certificateUrl\n  }\n  cashback {\n    __typename\n    name\n    imageUrl\n  }\n  insurance {\n    __typename\n    monthlyCost\n  }\n}"

    public init() {}

    public struct Data: GraphQLSelectionSet {
        public static let possibleTypes = ["Query"]

        public static let selections: [GraphQLSelection] = [
            GraphQLField("member", type: .nonNull(.object(Member.selections))),
            GraphQLField("insurance", type: .nonNull(.object(Insurance.selections))),
            GraphQLField("cashback", type: .nonNull(.object(Cashback.selections))),
            GraphQLField("insurance", type: .nonNull(.object(Insurance.selections))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
            resultMap = unsafeResultMap
        }

        public init(member: Member, insurance: Insurance, cashback: Cashback) {
            self.init(unsafeResultMap: ["__typename": "Query", "member": member.resultMap, "insurance": insurance.resultMap, "cashback": cashback.resultMap])
        }

        public var member: Member {
            get {
                return Member(unsafeResultMap: resultMap["member"]! as! ResultMap)
            }
            set {
                resultMap.updateValue(newValue.resultMap, forKey: "member")
            }
        }

        public var insurance: Insurance {
            get {
                return Insurance(unsafeResultMap: resultMap["insurance"]! as! ResultMap)
            }
            set {
                resultMap.updateValue(newValue.resultMap, forKey: "insurance")
            }
        }

        public var cashback: Cashback {
            get {
                return Cashback(unsafeResultMap: resultMap["cashback"]! as! ResultMap)
            }
            set {
                resultMap.updateValue(newValue.resultMap, forKey: "cashback")
            }
        }

        public struct Member: GraphQLSelectionSet {
            public static let possibleTypes = ["Member"]

            public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("firstName", type: .scalar(String.self)),
                GraphQLField("lastName", type: .scalar(String.self)),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
                resultMap = unsafeResultMap
            }

            public init(firstName: String? = nil, lastName: String? = nil) {
                self.init(unsafeResultMap: ["__typename": "Member", "firstName": firstName, "lastName": lastName])
            }

            public var __typename: String {
                get {
                    return resultMap["__typename"]! as! String
                }
                set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                }
            }

            public var firstName: String? {
                get {
                    return resultMap["firstName"] as? String
                }
                set {
                    resultMap.updateValue(newValue, forKey: "firstName")
                }
            }

            public var lastName: String? {
                get {
                    return resultMap["lastName"] as? String
                }
                set {
                    resultMap.updateValue(newValue, forKey: "lastName")
                }
            }
        }

        public struct Insurance: GraphQLSelectionSet {
            public static let possibleTypes = ["Insurance"]

            public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("address", type: .scalar(String.self)),
                GraphQLField("certificateUrl", type: .scalar(String.self)),
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("monthlyCost", type: .scalar(Int.self)),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
                resultMap = unsafeResultMap
            }

            public init(address: String? = nil, certificateUrl: String? = nil, monthlyCost: Int? = nil) {
                self.init(unsafeResultMap: ["__typename": "Insurance", "address": address, "certificateUrl": certificateUrl, "monthlyCost": monthlyCost])
            }

            public var __typename: String {
                get {
                    return resultMap["__typename"]! as! String
                }
                set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                }
            }

            public var address: String? {
                get {
                    return resultMap["address"] as? String
                }
                set {
                    resultMap.updateValue(newValue, forKey: "address")
                }
            }

            public var certificateUrl: String? {
                get {
                    return resultMap["certificateUrl"] as? String
                }
                set {
                    resultMap.updateValue(newValue, forKey: "certificateUrl")
                }
            }

            public var monthlyCost: Int? {
                get {
                    return resultMap["monthlyCost"] as? Int
                }
                set {
                    resultMap.updateValue(newValue, forKey: "monthlyCost")
                }
            }
        }

        public struct Cashback: GraphQLSelectionSet {
            public static let possibleTypes = ["Cashback"]

            public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("name", type: .scalar(String.self)),
                GraphQLField("imageUrl", type: .scalar(String.self)),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
                resultMap = unsafeResultMap
            }

            public init(name: String? = nil, imageUrl: String? = nil) {
                self.init(unsafeResultMap: ["__typename": "Cashback", "name": name, "imageUrl": imageUrl])
            }

            public var __typename: String {
                get {
                    return resultMap["__typename"]! as! String
                }
                set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                }
            }

            public var name: String? {
                get {
                    return resultMap["name"] as? String
                }
                set {
                    resultMap.updateValue(newValue, forKey: "name")
                }
            }

            public var imageUrl: String? {
                get {
                    return resultMap["imageUrl"] as? String
                }
                set {
                    resultMap.updateValue(newValue, forKey: "imageUrl")
                }
            }
        }
    }
}

public final class MyInfoQuery: GraphQLQuery {
    public let operationDefinition =
        "query MyInfo {\n  member {\n    __typename\n    firstName\n    lastName\n    email\n  }\n}"

    public init() {}

    public struct Data: GraphQLSelectionSet {
        public static let possibleTypes = ["Query"]

        public static let selections: [GraphQLSelection] = [
            GraphQLField("member", type: .nonNull(.object(Member.selections))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
            resultMap = unsafeResultMap
        }

        public init(member: Member) {
            self.init(unsafeResultMap: ["__typename": "Query", "member": member.resultMap])
        }

        public var member: Member {
            get {
                return Member(unsafeResultMap: resultMap["member"]! as! ResultMap)
            }
            set {
                resultMap.updateValue(newValue.resultMap, forKey: "member")
            }
        }

        public struct Member: GraphQLSelectionSet {
            public static let possibleTypes = ["Member"]

            public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("firstName", type: .scalar(String.self)),
                GraphQLField("lastName", type: .scalar(String.self)),
                GraphQLField("email", type: .scalar(String.self)),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
                resultMap = unsafeResultMap
            }

            public init(firstName: String? = nil, lastName: String? = nil, email: String? = nil) {
                self.init(unsafeResultMap: ["__typename": "Member", "firstName": firstName, "lastName": lastName, "email": email])
            }

            public var __typename: String {
                get {
                    return resultMap["__typename"]! as! String
                }
                set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                }
            }

            public var firstName: String? {
                get {
                    return resultMap["firstName"] as? String
                }
                set {
                    resultMap.updateValue(newValue, forKey: "firstName")
                }
            }

            public var lastName: String? {
                get {
                    return resultMap["lastName"] as? String
                }
                set {
                    resultMap.updateValue(newValue, forKey: "lastName")
                }
            }

            public var email: String? {
                get {
                    return resultMap["email"] as? String
                }
                set {
                    resultMap.updateValue(newValue, forKey: "email")
                }
            }
        }
    }
}

public final class TranslationsQuery: GraphQLQuery {
    public let operationDefinition =
        "query Translations($code: String) {\n  languages(where: {code: $code}) {\n    __typename\n    translations(where: {project: App}) {\n      __typename\n      key {\n        __typename\n        value\n      }\n      text\n    }\n  }\n}"

    public var code: String?

    public init(code: String? = nil) {
        self.code = code
    }

    public var variables: GraphQLMap? {
        return ["code": code]
    }

    public struct Data: GraphQLSelectionSet {
        public static let possibleTypes = ["Query"]

        public static let selections: [GraphQLSelection] = [
            GraphQLField("languages", arguments: ["where": ["code": GraphQLVariable("code")]], type: .nonNull(.list(.object(Language.selections)))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
            resultMap = unsafeResultMap
        }

        public init(languages: [Language?]) {
            self.init(unsafeResultMap: ["__typename": "Query", "languages": languages.map { (value: Language?) -> ResultMap? in value.flatMap { (value: Language) -> ResultMap in value.resultMap } }])
        }

        public var languages: [Language?] {
            get {
                return (resultMap["languages"] as! [ResultMap?]).map { (value: ResultMap?) -> Language? in value.flatMap { (value: ResultMap) -> Language in Language(unsafeResultMap: value) } }
            }
            set {
                resultMap.updateValue(newValue.map { (value: Language?) -> ResultMap? in value.flatMap { (value: Language) -> ResultMap in value.resultMap } }, forKey: "languages")
            }
        }

        public struct Language: GraphQLSelectionSet {
            public static let possibleTypes = ["Language"]

            public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("translations", arguments: ["where": ["project": "App"]], type: .list(.nonNull(.object(Translation.selections)))),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
                resultMap = unsafeResultMap
            }

            public init(translations: [Translation]? = nil) {
                self.init(unsafeResultMap: ["__typename": "Language", "translations": translations.flatMap { (value: [Translation]) -> [ResultMap] in value.map { (value: Translation) -> ResultMap in value.resultMap } }])
            }

            public var __typename: String {
                get {
                    return resultMap["__typename"]! as! String
                }
                set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                }
            }

            public var translations: [Translation]? {
                get {
                    return (resultMap["translations"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Translation] in value.map { (value: ResultMap) -> Translation in Translation(unsafeResultMap: value) } }
                }
                set {
                    resultMap.updateValue(newValue.flatMap { (value: [Translation]) -> [ResultMap] in value.map { (value: Translation) -> ResultMap in value.resultMap } }, forKey: "translations")
                }
            }

            public struct Translation: GraphQLSelectionSet {
                public static let possibleTypes = ["Translation"]

                public static let selections: [GraphQLSelection] = [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("key", type: .object(Key.selections)),
                    GraphQLField("text", type: .nonNull(.scalar(String.self))),
                ]

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                    resultMap = unsafeResultMap
                }

                public init(key: Key? = nil, text: String) {
                    self.init(unsafeResultMap: ["__typename": "Translation", "key": key.flatMap { (value: Key) -> ResultMap in value.resultMap }, "text": text])
                }

                public var __typename: String {
                    get {
                        return resultMap["__typename"]! as! String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "__typename")
                    }
                }

                public var key: Key? {
                    get {
                        return (resultMap["key"] as? ResultMap).flatMap { Key(unsafeResultMap: $0) }
                    }
                    set {
                        resultMap.updateValue(newValue?.resultMap, forKey: "key")
                    }
                }

                public var text: String {
                    get {
                        return resultMap["text"]! as! String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "text")
                    }
                }

                public struct Key: GraphQLSelectionSet {
                    public static let possibleTypes = ["Key"]

                    public static let selections: [GraphQLSelection] = [
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("value", type: .nonNull(.scalar(String.self))),
                    ]

                    public private(set) var resultMap: ResultMap

                    public init(unsafeResultMap: ResultMap) {
                        resultMap = unsafeResultMap
                    }

                    public init(value: String) {
                        self.init(unsafeResultMap: ["__typename": "Key", "value": value])
                    }

                    public var __typename: String {
                        get {
                            return resultMap["__typename"]! as! String
                        }
                        set {
                            resultMap.updateValue(newValue, forKey: "__typename")
                        }
                    }

                    public var value: String {
                        get {
                            return resultMap["value"]! as! String
                        }
                        set {
                            resultMap.updateValue(newValue, forKey: "value")
                        }
                    }
                }
            }
        }
    }
}

public final class MarketingStoriesQuery: GraphQLQuery {
    public let operationDefinition =
        "query MarketingStories {\n  marketingStories(orderBy: importance_ASC) {\n    __typename\n    id\n    asset {\n      __typename\n      mimeType\n      url\n    }\n    duration\n    backgroundColor\n  }\n}"

    public init() {}

    public struct Data: GraphQLSelectionSet {
        public static let possibleTypes = ["Query"]

        public static let selections: [GraphQLSelection] = [
            GraphQLField("marketingStories", arguments: ["orderBy": "importance_ASC"], type: .nonNull(.list(.object(MarketingStory.selections)))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
            resultMap = unsafeResultMap
        }

        public init(marketingStories: [MarketingStory?]) {
            self.init(unsafeResultMap: ["__typename": "Query", "marketingStories": marketingStories.map { (value: MarketingStory?) -> ResultMap? in value.flatMap { (value: MarketingStory) -> ResultMap in value.resultMap } }])
        }

        public var marketingStories: [MarketingStory?] {
            get {
                return (resultMap["marketingStories"] as! [ResultMap?]).map { (value: ResultMap?) -> MarketingStory? in value.flatMap { (value: ResultMap) -> MarketingStory in MarketingStory(unsafeResultMap: value) } }
            }
            set {
                resultMap.updateValue(newValue.map { (value: MarketingStory?) -> ResultMap? in value.flatMap { (value: MarketingStory) -> ResultMap in value.resultMap } }, forKey: "marketingStories")
            }
        }

        public struct MarketingStory: GraphQLSelectionSet {
            public static let possibleTypes = ["MarketingStory"]

            public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
                GraphQLField("asset", type: .object(Asset.selections)),
                GraphQLField("duration", type: .scalar(Double.self)),
                GraphQLField("backgroundColor", type: .nonNull(.scalar(HedvigColor.self))),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
                resultMap = unsafeResultMap
            }

            public init(id: GraphQLID, asset: Asset? = nil, duration: Double? = nil, backgroundColor: HedvigColor) {
                self.init(unsafeResultMap: ["__typename": "MarketingStory", "id": id, "asset": asset.flatMap { (value: Asset) -> ResultMap in value.resultMap }, "duration": duration, "backgroundColor": backgroundColor])
            }

            public var __typename: String {
                get {
                    return resultMap["__typename"]! as! String
                }
                set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                }
            }

            public var id: GraphQLID {
                get {
                    return resultMap["id"]! as! GraphQLID
                }
                set {
                    resultMap.updateValue(newValue, forKey: "id")
                }
            }

            public var asset: Asset? {
                get {
                    return (resultMap["asset"] as? ResultMap).flatMap { Asset(unsafeResultMap: $0) }
                }
                set {
                    resultMap.updateValue(newValue?.resultMap, forKey: "asset")
                }
            }

            public var duration: Double? {
                get {
                    return resultMap["duration"] as? Double
                }
                set {
                    resultMap.updateValue(newValue, forKey: "duration")
                }
            }

            public var backgroundColor: HedvigColor {
                get {
                    return resultMap["backgroundColor"]! as! HedvigColor
                }
                set {
                    resultMap.updateValue(newValue, forKey: "backgroundColor")
                }
            }

            public struct Asset: GraphQLSelectionSet {
                public static let possibleTypes = ["Asset"]

                public static let selections: [GraphQLSelection] = [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("mimeType", type: .scalar(String.self)),
                    GraphQLField("url", type: .nonNull(.scalar(String.self))),
                ]

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                    resultMap = unsafeResultMap
                }

                public init(mimeType: String? = nil, url: String) {
                    self.init(unsafeResultMap: ["__typename": "Asset", "mimeType": mimeType, "url": url])
                }

                public var __typename: String {
                    get {
                        return resultMap["__typename"]! as! String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "__typename")
                    }
                }

                public var mimeType: String? {
                    get {
                        return resultMap["mimeType"] as? String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "mimeType")
                    }
                }

                /// Get the url for the asset with provided transformations applied.
                public var url: String {
                    get {
                        return resultMap["url"]! as! String
                    }
                    set {
                        resultMap.updateValue(newValue, forKey: "url")
                    }
                }
            }
        }
    }
}

public final class CreateSessionMutation: GraphQLMutation {
    public let operationDefinition =
        "mutation CreateSession($campaign: CampaignInput, $trackingId: UUID) {\n  createSession(campaign: $campaign, trackingId: $trackingId)\n}"

    public var campaign: CampaignInput?
    public var trackingId: String?

    public init(campaign: CampaignInput? = nil, trackingId: String? = nil) {
        self.campaign = campaign
        self.trackingId = trackingId
    }

    public var variables: GraphQLMap? {
        return ["campaign": campaign, "trackingId": trackingId]
    }

    public struct Data: GraphQLSelectionSet {
        public static let possibleTypes = ["Mutation"]

        public static let selections: [GraphQLSelection] = [
            GraphQLField("createSession", arguments: ["campaign": GraphQLVariable("campaign"), "trackingId": GraphQLVariable("trackingId")], type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
            resultMap = unsafeResultMap
        }

        public init(createSession: String) {
            self.init(unsafeResultMap: ["__typename": "Mutation", "createSession": createSession])
        }

        public var createSession: String {
            get {
                return resultMap["createSession"]! as! String
            }
            set {
                resultMap.updateValue(newValue, forKey: "createSession")
            }
        }
    }
}
