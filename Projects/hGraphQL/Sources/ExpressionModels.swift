import Apollo
import Flow
import Foundation

public enum ExpressionTypename: String, Codable {
	case unary, binary, multiple
}

public struct Expression: Codable {
	internal init(
		type: ExpressionType,
		typename: ExpressionTypename,
		key: String? = nil,
		value: String? = nil,
		text: String? = nil,
		passedExpressionKey: String? = nil,
		passedExpressionValue: String? = nil,
		subExpressions: [SubExpression]? = nil,
		to: String? = nil
	) {
		self.type = type
		self.typename = typename
		self.key = key
		self.value = value
		self.text = text
		self.passedExpressionKey = passedExpressionKey
		self.passedExpressionValue = passedExpressionValue
		self.subExpressions = subExpressions
		self.to = to
	}

	public var type: ExpressionType
	public var typename: ExpressionTypename
	public var key, value: String?
	public var text: String?
	public var passedExpressionKey, passedExpressionValue: String?
	public var subExpressions: [SubExpression]?
	public var to: String?
}

public struct SubExpression: Codable {
	public var key: String?
	public var value: String?
	public var text: String?
	public var type: ExpressionType
	public var typename: ExpressionTypename
	public var subExpressions: [SubExpression]? = nil

	public init?(
		subExpression: GraphQL.BasicExpressionFragment
	) {
		if let expression = subExpression.asEmbarkExpressionUnary {
			self.key = nil
			self.value = nil
			self.text = expression.text
			self.typename = .unary
			self.type = .init(rawValue: expression.expressionUnaryType.rawValue) ?? .unknown
		} else if let expression = subExpression.asEmbarkExpressionBinary {
			self.key = expression.key
			self.value = expression.value
			self.text = expression.text
			self.typename = .binary
			self.type = .init(rawValue: expression.expressionBinaryType.rawValue) ?? .unknown
		} else {
			return nil
		}
	}

	public init?(
		subExpression: GraphQL.ExpressionFragment
	) {
		if let expression = subExpression.asEmbarkExpressionUnary {
			self.key = nil
			self.value = nil
			self.text = expression.text
			self.typename = .unary
			self.type = .init(rawValue: expression.expressionUnaryType.rawValue) ?? .unknown
		} else if let expression = subExpression.asEmbarkExpressionBinary {
			self.key = expression.key
			self.value = expression.value
			self.text = expression.text
			self.typename = .binary
			self.type = .init(rawValue: expression.expressionBinaryType.rawValue) ?? .unknown
		} else if let expression = subExpression.asEmbarkExpressionMultiple {
			self.key = nil
			self.value = nil
			self.text = expression.text
			self.typename = .multiple
			self.type = .init(rawValue: expression.expressionMultipleType.rawValue) ?? .unknown
			self.subExpressions = expression.subExpressions.compactMap {
				if let subExpression = $0.asEmbarkExpressionMultiple {
					return SubExpression.init(
						subExpression: subExpression.fragments.basicExpressionFragment
					)
				} else {
					return nil
				}
			}
		} else {
			return nil
		}
	}
}

public enum ExpressionType: String, Codable {
	case and = "AND"
	case or = "OR"
	case equals = "EQUALS"
	case moreThan = "MORE_THAN"
	case moreThanOrEquals = "MORE_THAN_OR_EQUALS"
	case lessThan = "LESS_THAN"
	case lessThanOrEquals = "LESS_THAN_OR_EQUALS"
	case notEquals = "NOT_EQUALS"
	case always = "ALWAYS"
	case unknown = "UNKNOWN"
}

public struct hEmbarkRedirect: Codable {
	public let expression: Expression?
	public init(
		redirect: GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Redirect
	) {
		if let unary = redirect.asEmbarkRedirectUnaryExpression, unary.unaryType == .always {
			expression = .init(
				type: .always,
				typename: .unary,
				key: nil,
				value: nil,
				text: nil,
				passedExpressionKey: unary.passedExpressionKey,
				passedExpressionValue: unary.passedExpressionValue,
				subExpressions: nil,
				to: unary.to
			)
		} else if let binary = redirect.asEmbarkRedirectBinaryExpression {
			expression = .init(
				type: (.init(rawValue: binary.binaryType.rawValue) ?? .and),
				typename: .binary,
				key: binary.key,
				value: binary.value,
				text: nil,
				passedExpressionKey: binary.passedExpressionKey,
				passedExpressionValue: binary.passedExpressionValue,
				subExpressions: nil
			)
		} else if let multiple = redirect.asEmbarkRedirectMultipleExpressions {
			expression = .init(
				type: .init(rawValue: multiple.multipleType.rawValue) ?? .and,
				typename: .multiple,
				key: nil,
				value: nil,
				text: nil,
				passedExpressionKey: multiple.passedExpressionKey,
				passedExpressionValue: multiple.passedExpressionValue,
				subExpressions: multiple.subExpressions.compactMap {
					if let subExpression = $0.asEmbarkExpressionMultiple {
						return SubExpression.init(
							subExpression: subExpression.fragments.basicExpressionFragment
						)
					} else {
						return nil
					}
				}
			)
		} else {
			expression = nil
		}
	}
}
