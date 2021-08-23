import Apollo
import Flow
import Foundation

struct GraphQLError: Error { var errors: [Error] }

extension ApolloClient {
	public func fetchEmbarkStory(name: String, locale: String) -> Future<hEmbarkStory> {
		Future<hEmbarkStory> { completion in
			let cancellable = self.fetch(
				query:
					GraphQL.EmbarkStoryQuery(
						name: name,
						locale: locale
					),
				cachePolicy: .returnCacheDataElseFetch,
				contextIdentifier: nil,
				queue: .main
			) { result in
				switch result {
				case let .success(result):
					if let story = result.data?.embarkStory {
						completion(.success(hEmbarkStory(story: story)))
					} else if let errors = result.errors {
						completion(.failure(GraphQLError(errors: errors)))
					} else {
						fatalError("Invalid GraphQL state")
					}
				case let .failure(error):
					print(error)
				}
			}

			return Disposer { cancellable.cancel() }
		}
	}
}

public struct hEmbarkStory: Codable {
	public let id: String
	public let passages: [hEmbarkPassage]
	public let initialPassage: hEmbarkPassage?

	public init(
		story: GraphQL.EmbarkStoryQuery.Data.EmbarkStory
	) {
		self.id = story.id
		self.passages = story.passages.map { .init(passage: $0) }
		self.initialPassage = story.passages.first(where: { $0.name == story.startPassage })
			.map { .init(passage: $0) }
	}
}

public struct hEmbarkPassage: Codable {
	public let name: String
	public let redirects: [hEmbarkRedirect]
	public let externalRedirect: hEmbarkExternalRedirect?
	init(
		passage: GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage
	) {
		name = passage.name
		redirects = passage.redirects.map { .init(redirect: $0) }
		if let location = passage.externalRedirect?.data.location {
			externalRedirect = .init(location: .init(rawValue: location.rawValue))
		} else {
			externalRedirect = nil
		}
	}
}

public enum ExternalRedirectLocation: String, Codable {
	case mailingList = "MailingList"
	case offer = "Offer"
	case close = "Close"
	case chat = "Chat"
}

public struct hEmbarkExternalRedirect: Codable {
	public let location: ExternalRedirectLocation?
}

//public enum MessageExpression: Codable {
//    case unary(MessageUnaryExpression)
//    case binary(MessageBinaryExpression)
//    case multiple(MessageMultipleExpression)
//}
//
//public enum Expression: Codable {
//    case unary(UnaryExpression)
//    case binary(BinaryExpression)
//    case multiple(MultipleExpression)
//}
//
//public struct MessageUnaryExpression: Codable {
//
//}
//
//public struct MessageBinaryExpression: Codable {
//
//}
//
//public struct MessageMultipleExpression: Codable {
//
//}
//
//public struct UnaryExpression: Codable {
//    public var to: String
//    public var always: Bool
//    public var passedExpressionKey: String?
//    public var passedExpressionValue: String?
//}
//
//public enum BinaryType: String, Codable {
//    public init?(rawValue: RawValue) {
//        switch rawValue {
//        case "EQUALS": self = .equals
//        case "NOT_EQUALS": self = .notEquals
//        case "MORE_THAN": self = .moreThan
//        case "LESS_THAN": self = .lessThan
//        case "MORE_THAN_OR_EQUALS": self = .moreThanOrEquals
//        case "LESS_THAN_OR_EQUALS": self = .lessThanOrEquals
//        default: self = .unknown
//        }
//    }
//    case equals, lessThan, moreThan, lessThanOrEquals, moreThanOrEquals, notEquals, unknown
//}
//
//public struct BinaryExpression: Codable {
//    public var to: String
//    public var key: String
//    public var binaryType: BinaryType
//    public var value: String
//    public var passedExpressionKey: String?
//    public var passedExpressionValue: String?
//}
//
//public enum MultipleType: String, Codable {
//
//    public init?(rawValue: RawValue) {
//        switch rawValue {
//        case "AND": self = .and
//        case "OR": self = .or
//        default: self = .unknown
//        }
//    }
//
//    case and, or, unknown
//}
//
//public struct MultipleExpression: Codable {
//    init(multiple: GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Redirect.AsEmbarkRedirectMultipleExpressions) {
//        to = multiple.to
//        multipleType = .init(rawValue: multiple.multipleType.rawValue) ?? .unknown
//        passedExpressionKey = multiple.passedExpressionKey
//        passedExpressionValue = multiple.passedExpressionValue
//        subExpressions = multiple.subExpressions.map { .init(subExpression: $0) }
//    }
//
//    public var to: String
//    public var multipleType: MultipleType
//    public var passedExpressionKey: String?
//    public var passedExpressionValue: String?
//    public var subExpressions: [SubExpression] = []
//}
//
//public struct SubExpression: Codable {
//    init(subExpression: GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Redirect.AsEmbarkRedirectMultipleExpressions.SubExpression) {
//        if let _ = subExpression.asEmbarkExpressionUnary {
//            expression = .unary(.init())
//        } else if let _ = subExpression.asEmbarkExpressionBinary {
//            expression = .binary(.init())
//        } else if let _ = subExpression.asEmbarkExpressionMultiple {
//            expression = .multiple(.init())
//        } else {
//            expression = nil
//        }
//    }
//    public var expression: MessageExpression?
//}
//
//public struct hEmbarkRedirect: Codable {
//    public let expression: Expression?
//    public init(redirect: GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Redirect) {
//        if let unary = redirect.asEmbarkRedirectUnaryExpression {
//            expression = .unary(.init(to: unary.to, always: unary.unaryType == .always, passedExpressionKey: unary.passedExpressionKey, passedExpressionValue: unary.passedExpressionValue))
//        } else if let binary = redirect.asEmbarkRedirectBinaryExpression {
//            expression = .binary(.init(to: binary.to, key: binary.key, binaryType: .init(rawValue: binary.binaryType.rawValue) ?? .unknown, value: binary.value, passedExpressionKey: binary.passedExpressionKey, passedExpressionValue: binary.passedExpressionValue))
//        } else if let multiple = redirect.asEmbarkRedirectMultipleExpressions {
//            expression = .multiple(.init(multiple: multiple))
//        } else {
//            expression = nil
//        }
//    }
//}
//
//extension MessageExpression {
//    enum CodingKeys: CodingKey {
//        case unary, binary, multiple
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//
//        switch self {
//        case .unary(let expression):
//            try container.encode(expression, forKey: .unary)
//        case .binary(let expression):
//            try container.encode(expression, forKey: .binary)
//        case .multiple(let expression):
//            try container.encode(expression, forKey: .multiple)
//        }
//    }
//
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//
//        guard let key = container.allKeys.first else { throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Cant decode"))}
//
//        switch key {
//        case .unary:
//            self = .unary(try container.decode(MessageUnaryExpression.self, forKey: .unary))
//        case .binary:
//            self = .binary(try container.decode(MessageBinaryExpression.self, forKey: .binary))
//        case .multiple:
//            self = .multiple(try container.decode(MessageMultipleExpression.self, forKey: .multiple))
//        }
//    }
//}
//
//extension Expression {
//    enum CodingKeys: CodingKey {
//        case unary, binary, multiple
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//
//        switch self {
//        case .unary(let expression):
//            try container.encode(expression, forKey: .unary)
//        case .binary(let expression):
//            try container.encode(expression, forKey: .binary)
//        case .multiple(let expression):
//            try container.encode(expression, forKey: .multiple)
//        }
//    }
//
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//
//        guard let key = container.allKeys.first else { throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Cant decode"))}
//
//        switch key {
//        case .unary:
//            self = .unary(try container.decode(UnaryExpression.self, forKey: .unary))
//        case .binary:
//            self = .binary(try container.decode(BinaryExpression.self, forKey: .binary))
//        case .multiple:
//            self = .multiple(try container.decode(MultipleExpression.self, forKey: .multiple))
//        }
//    }
//}
