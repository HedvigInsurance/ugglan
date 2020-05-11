// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public enum EmbarkExpressionTypeUnary: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case always
  case never
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "ALWAYS": self = .always
      case "NEVER": self = .never
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .always: return "ALWAYS"
      case .never: return "NEVER"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: EmbarkExpressionTypeUnary, rhs: EmbarkExpressionTypeUnary) -> Bool {
    switch (lhs, rhs) {
      case (.always, .always): return true
      case (.never, .never): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [EmbarkExpressionTypeUnary] {
    return [
      .always,
      .never,
    ]
  }
}

public enum EmbarkExpressionTypeBinary: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case equals
  case notEquals
  case moreThan
  case lessThan
  case moreThanOrEquals
  case lessThanOrEquals
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "EQUALS": self = .equals
      case "NOT_EQUALS": self = .notEquals
      case "MORE_THAN": self = .moreThan
      case "LESS_THAN": self = .lessThan
      case "MORE_THAN_OR_EQUALS": self = .moreThanOrEquals
      case "LESS_THAN_OR_EQUALS": self = .lessThanOrEquals
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .equals: return "EQUALS"
      case .notEquals: return "NOT_EQUALS"
      case .moreThan: return "MORE_THAN"
      case .lessThan: return "LESS_THAN"
      case .moreThanOrEquals: return "MORE_THAN_OR_EQUALS"
      case .lessThanOrEquals: return "LESS_THAN_OR_EQUALS"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: EmbarkExpressionTypeBinary, rhs: EmbarkExpressionTypeBinary) -> Bool {
    switch (lhs, rhs) {
      case (.equals, .equals): return true
      case (.notEquals, .notEquals): return true
      case (.moreThan, .moreThan): return true
      case (.lessThan, .lessThan): return true
      case (.moreThanOrEquals, .moreThanOrEquals): return true
      case (.lessThanOrEquals, .lessThanOrEquals): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [EmbarkExpressionTypeBinary] {
    return [
      .equals,
      .notEquals,
      .moreThan,
      .lessThan,
      .moreThanOrEquals,
      .lessThanOrEquals,
    ]
  }
}

public enum EmbarkExpressionTypeMultiple: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case and
  case or
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "AND": self = .and
      case "OR": self = .or
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .and: return "AND"
      case .or: return "OR"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: EmbarkExpressionTypeMultiple, rhs: EmbarkExpressionTypeMultiple) -> Bool {
    switch (lhs, rhs) {
      case (.and, .and): return true
      case (.or, .or): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [EmbarkExpressionTypeMultiple] {
    return [
      .and,
      .or,
    ]
  }
}

public final class EmbarkStoryQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query EmbarkStory($name: String!) {
      embarkStory(name: $name) {
        __typename
        id
        startPassage
        name
        passages {
          __typename
          id
          name
          response {
            __typename
            ...ResponseFragment
          }
          messages {
            __typename
            ...MessageFragment
          }
          action {
            __typename
            ... on EmbarkActionCore {
              component
            }
            ... on EmbarkTextAction {
              component
              textActionData: data {
                __typename
                key
                placeholder
                link {
                  __typename
                  ...EmbarkLinkFragment
                }
              }
            }
            ... on EmbarkNumberAction {
              component
              numberActionData: data {
                __typename
                key
                placeholder
                unit
                maxValue
                minValue
                link {
                  __typename
                  ...EmbarkLinkFragment
                }
              }
            }
            ... on EmbarkSelectAction {
              component
              selectActionData: data {
                __typename
                options {
                  __typename
                  keys
                  values
                  link {
                    __typename
                    ...EmbarkLinkFragment
                  }
                }
              }
            }
          }
        }
      }
    }
    """

  public let operationName: String = "EmbarkStory"

  public var queryDocument: String { return operationDefinition.appending(ResponseFragment.fragmentDefinition).appending(MessageFragment.fragmentDefinition).appending(ExpressionFragment.fragmentDefinition).appending(BasicExpressionFragment.fragmentDefinition).appending(EmbarkLinkFragment.fragmentDefinition) }

  public var name: String

  public init(name: String) {
    self.name = name
  }

  public var variables: GraphQLMap? {
    return ["name": name]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("embarkStory", arguments: ["name": GraphQLVariable("name")], type: .object(EmbarkStory.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(embarkStory: EmbarkStory? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "embarkStory": embarkStory.flatMap { (value: EmbarkStory) -> ResultMap in value.resultMap }])
    }

    public var embarkStory: EmbarkStory? {
      get {
        return (resultMap["embarkStory"] as? ResultMap).flatMap { EmbarkStory(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "embarkStory")
      }
    }

    public struct EmbarkStory: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["EmbarkStory"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(String.self))),
        GraphQLField("startPassage", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("passages", type: .nonNull(.list(.nonNull(.object(Passage.selections))))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: String, startPassage: String, name: String, passages: [Passage]) {
        self.init(unsafeResultMap: ["__typename": "EmbarkStory", "id": id, "startPassage": startPassage, "name": name, "passages": passages.map { (value: Passage) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: String {
        get {
          return resultMap["id"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      public var startPassage: String {
        get {
          return resultMap["startPassage"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "startPassage")
        }
      }

      public var name: String {
        get {
          return resultMap["name"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
        }
      }

      public var passages: [Passage] {
        get {
          return (resultMap["passages"] as! [ResultMap]).map { (value: ResultMap) -> Passage in Passage(unsafeResultMap: value) }
        }
        set {
          resultMap.updateValue(newValue.map { (value: Passage) -> ResultMap in value.resultMap }, forKey: "passages")
        }
      }

      public struct Passage: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["EmbarkPassage"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("response", type: .nonNull(.object(Response.selections))),
          GraphQLField("messages", type: .nonNull(.list(.nonNull(.object(Message.selections))))),
          GraphQLField("action", type: .object(Action.selections)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: String, name: String, response: Response, messages: [Message], action: Action? = nil) {
          self.init(unsafeResultMap: ["__typename": "EmbarkPassage", "id": id, "name": name, "response": response.resultMap, "messages": messages.map { (value: Message) -> ResultMap in value.resultMap }, "action": action.flatMap { (value: Action) -> ResultMap in value.resultMap }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: String {
          get {
            return resultMap["id"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }

        public var name: String {
          get {
            return resultMap["name"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "name")
          }
        }

        public var response: Response {
          get {
            return Response(unsafeResultMap: resultMap["response"]! as! ResultMap)
          }
          set {
            resultMap.updateValue(newValue.resultMap, forKey: "response")
          }
        }

        public var messages: [Message] {
          get {
            return (resultMap["messages"] as! [ResultMap]).map { (value: ResultMap) -> Message in Message(unsafeResultMap: value) }
          }
          set {
            resultMap.updateValue(newValue.map { (value: Message) -> ResultMap in value.resultMap }, forKey: "messages")
          }
        }

        public var action: Action? {
          get {
            return (resultMap["action"] as? ResultMap).flatMap { Action(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "action")
          }
        }

        public struct Response: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["EmbarkGroupedResponse", "EmbarkResponseExpression", "EmbarkMessage"]

          public static let selections: [GraphQLSelection] = [
            GraphQLTypeCase(
              variants: ["EmbarkMessage": AsEmbarkMessage.selections, "EmbarkGroupedResponse": AsEmbarkGroupedResponse.selections],
              default: [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              ]
            )
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public static func makeEmbarkResponseExpression() -> Response {
            return Response(unsafeResultMap: ["__typename": "EmbarkResponseExpression"])
          }

          public static func makeEmbarkMessage(text: String, expressions: [AsEmbarkMessage.Expression]) -> Response {
            return Response(unsafeResultMap: ["__typename": "EmbarkMessage", "text": text, "expressions": expressions.map { (value: AsEmbarkMessage.Expression) -> ResultMap in value.resultMap }])
          }

          public static func makeEmbarkGroupedResponse(component: String, items: [AsEmbarkGroupedResponse.Item], title: AsEmbarkGroupedResponse.Title) -> Response {
            return Response(unsafeResultMap: ["__typename": "EmbarkGroupedResponse", "component": component, "items": items.map { (value: AsEmbarkGroupedResponse.Item) -> ResultMap in value.resultMap }, "title": title.resultMap])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public struct Fragments {
            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var responseFragment: ResponseFragment {
              get {
                return ResponseFragment(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }

          public var asEmbarkMessage: AsEmbarkMessage? {
            get {
              if !AsEmbarkMessage.possibleTypes.contains(__typename) { return nil }
              return AsEmbarkMessage(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap = newValue.resultMap
            }
          }

          public struct AsEmbarkMessage: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["EmbarkMessage"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("text", type: .nonNull(.scalar(String.self))),
              GraphQLField("expressions", type: .nonNull(.list(.nonNull(.object(Expression.selections))))),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(text: String, expressions: [Expression]) {
              self.init(unsafeResultMap: ["__typename": "EmbarkMessage", "text": text, "expressions": expressions.map { (value: Expression) -> ResultMap in value.resultMap }])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
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

            public var expressions: [Expression] {
              get {
                return (resultMap["expressions"] as! [ResultMap]).map { (value: ResultMap) -> Expression in Expression(unsafeResultMap: value) }
              }
              set {
                resultMap.updateValue(newValue.map { (value: Expression) -> ResultMap in value.resultMap }, forKey: "expressions")
              }
            }

            public var fragments: Fragments {
              get {
                return Fragments(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public struct Fragments {
              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public var responseFragment: ResponseFragment {
                get {
                  return ResponseFragment(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
              }

              public var messageFragment: MessageFragment {
                get {
                  return MessageFragment(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
              }
            }

            public struct Expression: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["EmbarkExpressionUnary", "EmbarkExpressionBinary", "EmbarkExpressionMultiple"]

              public static let selections: [GraphQLSelection] = [
                GraphQLTypeCase(
                  variants: ["EmbarkExpressionUnary": AsEmbarkExpressionUnary.selections, "EmbarkExpressionBinary": AsEmbarkExpressionBinary.selections, "EmbarkExpressionMultiple": AsEmbarkExpressionMultiple.selections],
                  default: [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  ]
                )
              ]

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public static func makeEmbarkExpressionUnary(expressionUnaryType: EmbarkExpressionTypeUnary, text: String? = nil) -> Expression {
                return Expression(unsafeResultMap: ["__typename": "EmbarkExpressionUnary", "expressionUnaryType": expressionUnaryType, "text": text])
              }

              public static func makeEmbarkExpressionBinary(expressionBinaryType: EmbarkExpressionTypeBinary, key: String, value: String, text: String? = nil) -> Expression {
                return Expression(unsafeResultMap: ["__typename": "EmbarkExpressionBinary", "expressionBinaryType": expressionBinaryType, "key": key, "value": value, "text": text])
              }

              public static func makeEmbarkExpressionMultiple(expressionMultipleType: EmbarkExpressionTypeMultiple, text: String? = nil, subExpressions: [AsEmbarkExpressionMultiple.SubExpression]) -> Expression {
                return Expression(unsafeResultMap: ["__typename": "EmbarkExpressionMultiple", "expressionMultipleType": expressionMultipleType, "text": text, "subExpressions": subExpressions.map { (value: AsEmbarkExpressionMultiple.SubExpression) -> ResultMap in value.resultMap }])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var fragments: Fragments {
                get {
                  return Fragments(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
              }

              public struct Fragments {
                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public var expressionFragment: ExpressionFragment {
                  get {
                    return ExpressionFragment(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }

                public var basicExpressionFragment: BasicExpressionFragment {
                  get {
                    return BasicExpressionFragment(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }
              }

              public var asEmbarkExpressionUnary: AsEmbarkExpressionUnary? {
                get {
                  if !AsEmbarkExpressionUnary.possibleTypes.contains(__typename) { return nil }
                  return AsEmbarkExpressionUnary(unsafeResultMap: resultMap)
                }
                set {
                  guard let newValue = newValue else { return }
                  resultMap = newValue.resultMap
                }
              }

              public struct AsEmbarkExpressionUnary: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["EmbarkExpressionUnary"]

                public static let selections: [GraphQLSelection] = [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("type", alias: "expressionUnaryType", type: .nonNull(.scalar(EmbarkExpressionTypeUnary.self))),
                  GraphQLField("text", type: .scalar(String.self)),
                ]

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(expressionUnaryType: EmbarkExpressionTypeUnary, text: String? = nil) {
                  self.init(unsafeResultMap: ["__typename": "EmbarkExpressionUnary", "expressionUnaryType": expressionUnaryType, "text": text])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                public var expressionUnaryType: EmbarkExpressionTypeUnary {
                  get {
                    return resultMap["expressionUnaryType"]! as! EmbarkExpressionTypeUnary
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "expressionUnaryType")
                  }
                }

                public var text: String? {
                  get {
                    return resultMap["text"] as? String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "text")
                  }
                }

                public var fragments: Fragments {
                  get {
                    return Fragments(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }

                public struct Fragments {
                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public var expressionFragment: ExpressionFragment {
                    get {
                      return ExpressionFragment(unsafeResultMap: resultMap)
                    }
                    set {
                      resultMap += newValue.resultMap
                    }
                  }

                  public var basicExpressionFragment: BasicExpressionFragment {
                    get {
                      return BasicExpressionFragment(unsafeResultMap: resultMap)
                    }
                    set {
                      resultMap += newValue.resultMap
                    }
                  }
                }
              }

              public var asEmbarkExpressionBinary: AsEmbarkExpressionBinary? {
                get {
                  if !AsEmbarkExpressionBinary.possibleTypes.contains(__typename) { return nil }
                  return AsEmbarkExpressionBinary(unsafeResultMap: resultMap)
                }
                set {
                  guard let newValue = newValue else { return }
                  resultMap = newValue.resultMap
                }
              }

              public struct AsEmbarkExpressionBinary: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["EmbarkExpressionBinary"]

                public static let selections: [GraphQLSelection] = [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("type", alias: "expressionBinaryType", type: .nonNull(.scalar(EmbarkExpressionTypeBinary.self))),
                  GraphQLField("key", type: .nonNull(.scalar(String.self))),
                  GraphQLField("value", type: .nonNull(.scalar(String.self))),
                  GraphQLField("text", type: .scalar(String.self)),
                ]

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(expressionBinaryType: EmbarkExpressionTypeBinary, key: String, value: String, text: String? = nil) {
                  self.init(unsafeResultMap: ["__typename": "EmbarkExpressionBinary", "expressionBinaryType": expressionBinaryType, "key": key, "value": value, "text": text])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                public var expressionBinaryType: EmbarkExpressionTypeBinary {
                  get {
                    return resultMap["expressionBinaryType"]! as! EmbarkExpressionTypeBinary
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "expressionBinaryType")
                  }
                }

                public var key: String {
                  get {
                    return resultMap["key"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "key")
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

                public var text: String? {
                  get {
                    return resultMap["text"] as? String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "text")
                  }
                }

                public var fragments: Fragments {
                  get {
                    return Fragments(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }

                public struct Fragments {
                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public var expressionFragment: ExpressionFragment {
                    get {
                      return ExpressionFragment(unsafeResultMap: resultMap)
                    }
                    set {
                      resultMap += newValue.resultMap
                    }
                  }

                  public var basicExpressionFragment: BasicExpressionFragment {
                    get {
                      return BasicExpressionFragment(unsafeResultMap: resultMap)
                    }
                    set {
                      resultMap += newValue.resultMap
                    }
                  }
                }
              }

              public var asEmbarkExpressionMultiple: AsEmbarkExpressionMultiple? {
                get {
                  if !AsEmbarkExpressionMultiple.possibleTypes.contains(__typename) { return nil }
                  return AsEmbarkExpressionMultiple(unsafeResultMap: resultMap)
                }
                set {
                  guard let newValue = newValue else { return }
                  resultMap = newValue.resultMap
                }
              }

              public struct AsEmbarkExpressionMultiple: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["EmbarkExpressionMultiple"]

                public static let selections: [GraphQLSelection] = [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("type", alias: "expressionMultipleType", type: .nonNull(.scalar(EmbarkExpressionTypeMultiple.self))),
                  GraphQLField("text", type: .scalar(String.self)),
                  GraphQLField("subExpressions", type: .nonNull(.list(.nonNull(.object(SubExpression.selections))))),
                ]

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(expressionMultipleType: EmbarkExpressionTypeMultiple, text: String? = nil, subExpressions: [SubExpression]) {
                  self.init(unsafeResultMap: ["__typename": "EmbarkExpressionMultiple", "expressionMultipleType": expressionMultipleType, "text": text, "subExpressions": subExpressions.map { (value: SubExpression) -> ResultMap in value.resultMap }])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                public var expressionMultipleType: EmbarkExpressionTypeMultiple {
                  get {
                    return resultMap["expressionMultipleType"]! as! EmbarkExpressionTypeMultiple
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "expressionMultipleType")
                  }
                }

                public var text: String? {
                  get {
                    return resultMap["text"] as? String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "text")
                  }
                }

                public var subExpressions: [SubExpression] {
                  get {
                    return (resultMap["subExpressions"] as! [ResultMap]).map { (value: ResultMap) -> SubExpression in SubExpression(unsafeResultMap: value) }
                  }
                  set {
                    resultMap.updateValue(newValue.map { (value: SubExpression) -> ResultMap in value.resultMap }, forKey: "subExpressions")
                  }
                }

                public var fragments: Fragments {
                  get {
                    return Fragments(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }

                public struct Fragments {
                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public var expressionFragment: ExpressionFragment {
                    get {
                      return ExpressionFragment(unsafeResultMap: resultMap)
                    }
                    set {
                      resultMap += newValue.resultMap
                    }
                  }

                  public var basicExpressionFragment: BasicExpressionFragment {
                    get {
                      return BasicExpressionFragment(unsafeResultMap: resultMap)
                    }
                    set {
                      resultMap += newValue.resultMap
                    }
                  }
                }

                public struct SubExpression: GraphQLSelectionSet {
                  public static let possibleTypes: [String] = ["EmbarkExpressionUnary", "EmbarkExpressionBinary", "EmbarkExpressionMultiple"]

                  public static let selections: [GraphQLSelection] = [
                    GraphQLTypeCase(
                      variants: ["EmbarkExpressionUnary": AsEmbarkExpressionUnary.selections, "EmbarkExpressionBinary": AsEmbarkExpressionBinary.selections],
                      default: [
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                      ]
                    )
                  ]

                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public static func makeEmbarkExpressionMultiple() -> SubExpression {
                    return SubExpression(unsafeResultMap: ["__typename": "EmbarkExpressionMultiple"])
                  }

                  public static func makeEmbarkExpressionUnary(expressionUnaryType: EmbarkExpressionTypeUnary, text: String? = nil) -> SubExpression {
                    return SubExpression(unsafeResultMap: ["__typename": "EmbarkExpressionUnary", "expressionUnaryType": expressionUnaryType, "text": text])
                  }

                  public static func makeEmbarkExpressionBinary(expressionBinaryType: EmbarkExpressionTypeBinary, key: String, value: String, text: String? = nil) -> SubExpression {
                    return SubExpression(unsafeResultMap: ["__typename": "EmbarkExpressionBinary", "expressionBinaryType": expressionBinaryType, "key": key, "value": value, "text": text])
                  }

                  public var __typename: String {
                    get {
                      return resultMap["__typename"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "__typename")
                    }
                  }

                  public var fragments: Fragments {
                    get {
                      return Fragments(unsafeResultMap: resultMap)
                    }
                    set {
                      resultMap += newValue.resultMap
                    }
                  }

                  public struct Fragments {
                    public private(set) var resultMap: ResultMap

                    public init(unsafeResultMap: ResultMap) {
                      self.resultMap = unsafeResultMap
                    }

                    public var basicExpressionFragment: BasicExpressionFragment {
                      get {
                        return BasicExpressionFragment(unsafeResultMap: resultMap)
                      }
                      set {
                        resultMap += newValue.resultMap
                      }
                    }
                  }

                  public var asEmbarkExpressionUnary: AsEmbarkExpressionUnary? {
                    get {
                      if !AsEmbarkExpressionUnary.possibleTypes.contains(__typename) { return nil }
                      return AsEmbarkExpressionUnary(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap = newValue.resultMap
                    }
                  }

                  public struct AsEmbarkExpressionUnary: GraphQLSelectionSet {
                    public static let possibleTypes: [String] = ["EmbarkExpressionUnary"]

                    public static let selections: [GraphQLSelection] = [
                      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                      GraphQLField("type", alias: "expressionUnaryType", type: .nonNull(.scalar(EmbarkExpressionTypeUnary.self))),
                      GraphQLField("text", type: .scalar(String.self)),
                    ]

                    public private(set) var resultMap: ResultMap

                    public init(unsafeResultMap: ResultMap) {
                      self.resultMap = unsafeResultMap
                    }

                    public init(expressionUnaryType: EmbarkExpressionTypeUnary, text: String? = nil) {
                      self.init(unsafeResultMap: ["__typename": "EmbarkExpressionUnary", "expressionUnaryType": expressionUnaryType, "text": text])
                    }

                    public var __typename: String {
                      get {
                        return resultMap["__typename"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "__typename")
                      }
                    }

                    public var expressionUnaryType: EmbarkExpressionTypeUnary {
                      get {
                        return resultMap["expressionUnaryType"]! as! EmbarkExpressionTypeUnary
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "expressionUnaryType")
                      }
                    }

                    public var text: String? {
                      get {
                        return resultMap["text"] as? String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "text")
                      }
                    }

                    public var fragments: Fragments {
                      get {
                        return Fragments(unsafeResultMap: resultMap)
                      }
                      set {
                        resultMap += newValue.resultMap
                      }
                    }

                    public struct Fragments {
                      public private(set) var resultMap: ResultMap

                      public init(unsafeResultMap: ResultMap) {
                        self.resultMap = unsafeResultMap
                      }

                      public var basicExpressionFragment: BasicExpressionFragment {
                        get {
                          return BasicExpressionFragment(unsafeResultMap: resultMap)
                        }
                        set {
                          resultMap += newValue.resultMap
                        }
                      }
                    }
                  }

                  public var asEmbarkExpressionBinary: AsEmbarkExpressionBinary? {
                    get {
                      if !AsEmbarkExpressionBinary.possibleTypes.contains(__typename) { return nil }
                      return AsEmbarkExpressionBinary(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap = newValue.resultMap
                    }
                  }

                  public struct AsEmbarkExpressionBinary: GraphQLSelectionSet {
                    public static let possibleTypes: [String] = ["EmbarkExpressionBinary"]

                    public static let selections: [GraphQLSelection] = [
                      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                      GraphQLField("type", alias: "expressionBinaryType", type: .nonNull(.scalar(EmbarkExpressionTypeBinary.self))),
                      GraphQLField("key", type: .nonNull(.scalar(String.self))),
                      GraphQLField("value", type: .nonNull(.scalar(String.self))),
                      GraphQLField("text", type: .scalar(String.self)),
                    ]

                    public private(set) var resultMap: ResultMap

                    public init(unsafeResultMap: ResultMap) {
                      self.resultMap = unsafeResultMap
                    }

                    public init(expressionBinaryType: EmbarkExpressionTypeBinary, key: String, value: String, text: String? = nil) {
                      self.init(unsafeResultMap: ["__typename": "EmbarkExpressionBinary", "expressionBinaryType": expressionBinaryType, "key": key, "value": value, "text": text])
                    }

                    public var __typename: String {
                      get {
                        return resultMap["__typename"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "__typename")
                      }
                    }

                    public var expressionBinaryType: EmbarkExpressionTypeBinary {
                      get {
                        return resultMap["expressionBinaryType"]! as! EmbarkExpressionTypeBinary
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "expressionBinaryType")
                      }
                    }

                    public var key: String {
                      get {
                        return resultMap["key"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "key")
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

                    public var text: String? {
                      get {
                        return resultMap["text"] as? String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "text")
                      }
                    }

                    public var fragments: Fragments {
                      get {
                        return Fragments(unsafeResultMap: resultMap)
                      }
                      set {
                        resultMap += newValue.resultMap
                      }
                    }

                    public struct Fragments {
                      public private(set) var resultMap: ResultMap

                      public init(unsafeResultMap: ResultMap) {
                        self.resultMap = unsafeResultMap
                      }

                      public var basicExpressionFragment: BasicExpressionFragment {
                        get {
                          return BasicExpressionFragment(unsafeResultMap: resultMap)
                        }
                        set {
                          resultMap += newValue.resultMap
                        }
                      }
                    }
                  }
                }
              }
            }
          }

          public var asEmbarkGroupedResponse: AsEmbarkGroupedResponse? {
            get {
              if !AsEmbarkGroupedResponse.possibleTypes.contains(__typename) { return nil }
              return AsEmbarkGroupedResponse(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap = newValue.resultMap
            }
          }

          public struct AsEmbarkGroupedResponse: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["EmbarkGroupedResponse"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("component", type: .nonNull(.scalar(String.self))),
              GraphQLField("items", type: .nonNull(.list(.nonNull(.object(Item.selections))))),
              GraphQLField("title", type: .nonNull(.object(Title.selections))),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(component: String, items: [Item], title: Title) {
              self.init(unsafeResultMap: ["__typename": "EmbarkGroupedResponse", "component": component, "items": items.map { (value: Item) -> ResultMap in value.resultMap }, "title": title.resultMap])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var component: String {
              get {
                return resultMap["component"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "component")
              }
            }

            public var items: [Item] {
              get {
                return (resultMap["items"] as! [ResultMap]).map { (value: ResultMap) -> Item in Item(unsafeResultMap: value) }
              }
              set {
                resultMap.updateValue(newValue.map { (value: Item) -> ResultMap in value.resultMap }, forKey: "items")
              }
            }

            public var title: Title {
              get {
                return Title(unsafeResultMap: resultMap["title"]! as! ResultMap)
              }
              set {
                resultMap.updateValue(newValue.resultMap, forKey: "title")
              }
            }

            public var fragments: Fragments {
              get {
                return Fragments(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public struct Fragments {
              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public var responseFragment: ResponseFragment {
                get {
                  return ResponseFragment(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
              }
            }

            public struct Item: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["EmbarkMessage"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("text", type: .nonNull(.scalar(String.self))),
                GraphQLField("expressions", type: .nonNull(.list(.nonNull(.object(Expression.selections))))),
              ]

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(text: String, expressions: [Expression]) {
                self.init(unsafeResultMap: ["__typename": "EmbarkMessage", "text": text, "expressions": expressions.map { (value: Expression) -> ResultMap in value.resultMap }])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
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

              public var expressions: [Expression] {
                get {
                  return (resultMap["expressions"] as! [ResultMap]).map { (value: ResultMap) -> Expression in Expression(unsafeResultMap: value) }
                }
                set {
                  resultMap.updateValue(newValue.map { (value: Expression) -> ResultMap in value.resultMap }, forKey: "expressions")
                }
              }

              public var fragments: Fragments {
                get {
                  return Fragments(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
              }

              public struct Fragments {
                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public var messageFragment: MessageFragment {
                  get {
                    return MessageFragment(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }
              }

              public struct Expression: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["EmbarkExpressionUnary", "EmbarkExpressionBinary", "EmbarkExpressionMultiple"]

                public static let selections: [GraphQLSelection] = [
                  GraphQLTypeCase(
                    variants: ["EmbarkExpressionUnary": AsEmbarkExpressionUnary.selections, "EmbarkExpressionBinary": AsEmbarkExpressionBinary.selections, "EmbarkExpressionMultiple": AsEmbarkExpressionMultiple.selections],
                    default: [
                      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    ]
                  )
                ]

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public static func makeEmbarkExpressionUnary(expressionUnaryType: EmbarkExpressionTypeUnary, text: String? = nil) -> Expression {
                  return Expression(unsafeResultMap: ["__typename": "EmbarkExpressionUnary", "expressionUnaryType": expressionUnaryType, "text": text])
                }

                public static func makeEmbarkExpressionBinary(expressionBinaryType: EmbarkExpressionTypeBinary, key: String, value: String, text: String? = nil) -> Expression {
                  return Expression(unsafeResultMap: ["__typename": "EmbarkExpressionBinary", "expressionBinaryType": expressionBinaryType, "key": key, "value": value, "text": text])
                }

                public static func makeEmbarkExpressionMultiple(expressionMultipleType: EmbarkExpressionTypeMultiple, text: String? = nil, subExpressions: [AsEmbarkExpressionMultiple.SubExpression]) -> Expression {
                  return Expression(unsafeResultMap: ["__typename": "EmbarkExpressionMultiple", "expressionMultipleType": expressionMultipleType, "text": text, "subExpressions": subExpressions.map { (value: AsEmbarkExpressionMultiple.SubExpression) -> ResultMap in value.resultMap }])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                public var fragments: Fragments {
                  get {
                    return Fragments(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }

                public struct Fragments {
                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public var expressionFragment: ExpressionFragment {
                    get {
                      return ExpressionFragment(unsafeResultMap: resultMap)
                    }
                    set {
                      resultMap += newValue.resultMap
                    }
                  }

                  public var basicExpressionFragment: BasicExpressionFragment {
                    get {
                      return BasicExpressionFragment(unsafeResultMap: resultMap)
                    }
                    set {
                      resultMap += newValue.resultMap
                    }
                  }
                }

                public var asEmbarkExpressionUnary: AsEmbarkExpressionUnary? {
                  get {
                    if !AsEmbarkExpressionUnary.possibleTypes.contains(__typename) { return nil }
                    return AsEmbarkExpressionUnary(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap = newValue.resultMap
                  }
                }

                public struct AsEmbarkExpressionUnary: GraphQLSelectionSet {
                  public static let possibleTypes: [String] = ["EmbarkExpressionUnary"]

                  public static let selections: [GraphQLSelection] = [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("type", alias: "expressionUnaryType", type: .nonNull(.scalar(EmbarkExpressionTypeUnary.self))),
                    GraphQLField("text", type: .scalar(String.self)),
                  ]

                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public init(expressionUnaryType: EmbarkExpressionTypeUnary, text: String? = nil) {
                    self.init(unsafeResultMap: ["__typename": "EmbarkExpressionUnary", "expressionUnaryType": expressionUnaryType, "text": text])
                  }

                  public var __typename: String {
                    get {
                      return resultMap["__typename"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "__typename")
                    }
                  }

                  public var expressionUnaryType: EmbarkExpressionTypeUnary {
                    get {
                      return resultMap["expressionUnaryType"]! as! EmbarkExpressionTypeUnary
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "expressionUnaryType")
                    }
                  }

                  public var text: String? {
                    get {
                      return resultMap["text"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "text")
                    }
                  }

                  public var fragments: Fragments {
                    get {
                      return Fragments(unsafeResultMap: resultMap)
                    }
                    set {
                      resultMap += newValue.resultMap
                    }
                  }

                  public struct Fragments {
                    public private(set) var resultMap: ResultMap

                    public init(unsafeResultMap: ResultMap) {
                      self.resultMap = unsafeResultMap
                    }

                    public var expressionFragment: ExpressionFragment {
                      get {
                        return ExpressionFragment(unsafeResultMap: resultMap)
                      }
                      set {
                        resultMap += newValue.resultMap
                      }
                    }

                    public var basicExpressionFragment: BasicExpressionFragment {
                      get {
                        return BasicExpressionFragment(unsafeResultMap: resultMap)
                      }
                      set {
                        resultMap += newValue.resultMap
                      }
                    }
                  }
                }

                public var asEmbarkExpressionBinary: AsEmbarkExpressionBinary? {
                  get {
                    if !AsEmbarkExpressionBinary.possibleTypes.contains(__typename) { return nil }
                    return AsEmbarkExpressionBinary(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap = newValue.resultMap
                  }
                }

                public struct AsEmbarkExpressionBinary: GraphQLSelectionSet {
                  public static let possibleTypes: [String] = ["EmbarkExpressionBinary"]

                  public static let selections: [GraphQLSelection] = [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("type", alias: "expressionBinaryType", type: .nonNull(.scalar(EmbarkExpressionTypeBinary.self))),
                    GraphQLField("key", type: .nonNull(.scalar(String.self))),
                    GraphQLField("value", type: .nonNull(.scalar(String.self))),
                    GraphQLField("text", type: .scalar(String.self)),
                  ]

                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public init(expressionBinaryType: EmbarkExpressionTypeBinary, key: String, value: String, text: String? = nil) {
                    self.init(unsafeResultMap: ["__typename": "EmbarkExpressionBinary", "expressionBinaryType": expressionBinaryType, "key": key, "value": value, "text": text])
                  }

                  public var __typename: String {
                    get {
                      return resultMap["__typename"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "__typename")
                    }
                  }

                  public var expressionBinaryType: EmbarkExpressionTypeBinary {
                    get {
                      return resultMap["expressionBinaryType"]! as! EmbarkExpressionTypeBinary
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "expressionBinaryType")
                    }
                  }

                  public var key: String {
                    get {
                      return resultMap["key"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "key")
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

                  public var text: String? {
                    get {
                      return resultMap["text"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "text")
                    }
                  }

                  public var fragments: Fragments {
                    get {
                      return Fragments(unsafeResultMap: resultMap)
                    }
                    set {
                      resultMap += newValue.resultMap
                    }
                  }

                  public struct Fragments {
                    public private(set) var resultMap: ResultMap

                    public init(unsafeResultMap: ResultMap) {
                      self.resultMap = unsafeResultMap
                    }

                    public var expressionFragment: ExpressionFragment {
                      get {
                        return ExpressionFragment(unsafeResultMap: resultMap)
                      }
                      set {
                        resultMap += newValue.resultMap
                      }
                    }

                    public var basicExpressionFragment: BasicExpressionFragment {
                      get {
                        return BasicExpressionFragment(unsafeResultMap: resultMap)
                      }
                      set {
                        resultMap += newValue.resultMap
                      }
                    }
                  }
                }

                public var asEmbarkExpressionMultiple: AsEmbarkExpressionMultiple? {
                  get {
                    if !AsEmbarkExpressionMultiple.possibleTypes.contains(__typename) { return nil }
                    return AsEmbarkExpressionMultiple(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap = newValue.resultMap
                  }
                }

                public struct AsEmbarkExpressionMultiple: GraphQLSelectionSet {
                  public static let possibleTypes: [String] = ["EmbarkExpressionMultiple"]

                  public static let selections: [GraphQLSelection] = [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("type", alias: "expressionMultipleType", type: .nonNull(.scalar(EmbarkExpressionTypeMultiple.self))),
                    GraphQLField("text", type: .scalar(String.self)),
                    GraphQLField("subExpressions", type: .nonNull(.list(.nonNull(.object(SubExpression.selections))))),
                  ]

                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public init(expressionMultipleType: EmbarkExpressionTypeMultiple, text: String? = nil, subExpressions: [SubExpression]) {
                    self.init(unsafeResultMap: ["__typename": "EmbarkExpressionMultiple", "expressionMultipleType": expressionMultipleType, "text": text, "subExpressions": subExpressions.map { (value: SubExpression) -> ResultMap in value.resultMap }])
                  }

                  public var __typename: String {
                    get {
                      return resultMap["__typename"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "__typename")
                    }
                  }

                  public var expressionMultipleType: EmbarkExpressionTypeMultiple {
                    get {
                      return resultMap["expressionMultipleType"]! as! EmbarkExpressionTypeMultiple
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "expressionMultipleType")
                    }
                  }

                  public var text: String? {
                    get {
                      return resultMap["text"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "text")
                    }
                  }

                  public var subExpressions: [SubExpression] {
                    get {
                      return (resultMap["subExpressions"] as! [ResultMap]).map { (value: ResultMap) -> SubExpression in SubExpression(unsafeResultMap: value) }
                    }
                    set {
                      resultMap.updateValue(newValue.map { (value: SubExpression) -> ResultMap in value.resultMap }, forKey: "subExpressions")
                    }
                  }

                  public var fragments: Fragments {
                    get {
                      return Fragments(unsafeResultMap: resultMap)
                    }
                    set {
                      resultMap += newValue.resultMap
                    }
                  }

                  public struct Fragments {
                    public private(set) var resultMap: ResultMap

                    public init(unsafeResultMap: ResultMap) {
                      self.resultMap = unsafeResultMap
                    }

                    public var expressionFragment: ExpressionFragment {
                      get {
                        return ExpressionFragment(unsafeResultMap: resultMap)
                      }
                      set {
                        resultMap += newValue.resultMap
                      }
                    }

                    public var basicExpressionFragment: BasicExpressionFragment {
                      get {
                        return BasicExpressionFragment(unsafeResultMap: resultMap)
                      }
                      set {
                        resultMap += newValue.resultMap
                      }
                    }
                  }

                  public struct SubExpression: GraphQLSelectionSet {
                    public static let possibleTypes: [String] = ["EmbarkExpressionUnary", "EmbarkExpressionBinary", "EmbarkExpressionMultiple"]

                    public static let selections: [GraphQLSelection] = [
                      GraphQLTypeCase(
                        variants: ["EmbarkExpressionUnary": AsEmbarkExpressionUnary.selections, "EmbarkExpressionBinary": AsEmbarkExpressionBinary.selections],
                        default: [
                          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        ]
                      )
                    ]

                    public private(set) var resultMap: ResultMap

                    public init(unsafeResultMap: ResultMap) {
                      self.resultMap = unsafeResultMap
                    }

                    public static func makeEmbarkExpressionMultiple() -> SubExpression {
                      return SubExpression(unsafeResultMap: ["__typename": "EmbarkExpressionMultiple"])
                    }

                    public static func makeEmbarkExpressionUnary(expressionUnaryType: EmbarkExpressionTypeUnary, text: String? = nil) -> SubExpression {
                      return SubExpression(unsafeResultMap: ["__typename": "EmbarkExpressionUnary", "expressionUnaryType": expressionUnaryType, "text": text])
                    }

                    public static func makeEmbarkExpressionBinary(expressionBinaryType: EmbarkExpressionTypeBinary, key: String, value: String, text: String? = nil) -> SubExpression {
                      return SubExpression(unsafeResultMap: ["__typename": "EmbarkExpressionBinary", "expressionBinaryType": expressionBinaryType, "key": key, "value": value, "text": text])
                    }

                    public var __typename: String {
                      get {
                        return resultMap["__typename"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "__typename")
                      }
                    }

                    public var fragments: Fragments {
                      get {
                        return Fragments(unsafeResultMap: resultMap)
                      }
                      set {
                        resultMap += newValue.resultMap
                      }
                    }

                    public struct Fragments {
                      public private(set) var resultMap: ResultMap

                      public init(unsafeResultMap: ResultMap) {
                        self.resultMap = unsafeResultMap
                      }

                      public var basicExpressionFragment: BasicExpressionFragment {
                        get {
                          return BasicExpressionFragment(unsafeResultMap: resultMap)
                        }
                        set {
                          resultMap += newValue.resultMap
                        }
                      }
                    }

                    public var asEmbarkExpressionUnary: AsEmbarkExpressionUnary? {
                      get {
                        if !AsEmbarkExpressionUnary.possibleTypes.contains(__typename) { return nil }
                        return AsEmbarkExpressionUnary(unsafeResultMap: resultMap)
                      }
                      set {
                        guard let newValue = newValue else { return }
                        resultMap = newValue.resultMap
                      }
                    }

                    public struct AsEmbarkExpressionUnary: GraphQLSelectionSet {
                      public static let possibleTypes: [String] = ["EmbarkExpressionUnary"]

                      public static let selections: [GraphQLSelection] = [
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("type", alias: "expressionUnaryType", type: .nonNull(.scalar(EmbarkExpressionTypeUnary.self))),
                        GraphQLField("text", type: .scalar(String.self)),
                      ]

                      public private(set) var resultMap: ResultMap

                      public init(unsafeResultMap: ResultMap) {
                        self.resultMap = unsafeResultMap
                      }

                      public init(expressionUnaryType: EmbarkExpressionTypeUnary, text: String? = nil) {
                        self.init(unsafeResultMap: ["__typename": "EmbarkExpressionUnary", "expressionUnaryType": expressionUnaryType, "text": text])
                      }

                      public var __typename: String {
                        get {
                          return resultMap["__typename"]! as! String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "__typename")
                        }
                      }

                      public var expressionUnaryType: EmbarkExpressionTypeUnary {
                        get {
                          return resultMap["expressionUnaryType"]! as! EmbarkExpressionTypeUnary
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "expressionUnaryType")
                        }
                      }

                      public var text: String? {
                        get {
                          return resultMap["text"] as? String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "text")
                        }
                      }

                      public var fragments: Fragments {
                        get {
                          return Fragments(unsafeResultMap: resultMap)
                        }
                        set {
                          resultMap += newValue.resultMap
                        }
                      }

                      public struct Fragments {
                        public private(set) var resultMap: ResultMap

                        public init(unsafeResultMap: ResultMap) {
                          self.resultMap = unsafeResultMap
                        }

                        public var basicExpressionFragment: BasicExpressionFragment {
                          get {
                            return BasicExpressionFragment(unsafeResultMap: resultMap)
                          }
                          set {
                            resultMap += newValue.resultMap
                          }
                        }
                      }
                    }

                    public var asEmbarkExpressionBinary: AsEmbarkExpressionBinary? {
                      get {
                        if !AsEmbarkExpressionBinary.possibleTypes.contains(__typename) { return nil }
                        return AsEmbarkExpressionBinary(unsafeResultMap: resultMap)
                      }
                      set {
                        guard let newValue = newValue else { return }
                        resultMap = newValue.resultMap
                      }
                    }

                    public struct AsEmbarkExpressionBinary: GraphQLSelectionSet {
                      public static let possibleTypes: [String] = ["EmbarkExpressionBinary"]

                      public static let selections: [GraphQLSelection] = [
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("type", alias: "expressionBinaryType", type: .nonNull(.scalar(EmbarkExpressionTypeBinary.self))),
                        GraphQLField("key", type: .nonNull(.scalar(String.self))),
                        GraphQLField("value", type: .nonNull(.scalar(String.self))),
                        GraphQLField("text", type: .scalar(String.self)),
                      ]

                      public private(set) var resultMap: ResultMap

                      public init(unsafeResultMap: ResultMap) {
                        self.resultMap = unsafeResultMap
                      }

                      public init(expressionBinaryType: EmbarkExpressionTypeBinary, key: String, value: String, text: String? = nil) {
                        self.init(unsafeResultMap: ["__typename": "EmbarkExpressionBinary", "expressionBinaryType": expressionBinaryType, "key": key, "value": value, "text": text])
                      }

                      public var __typename: String {
                        get {
                          return resultMap["__typename"]! as! String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "__typename")
                        }
                      }

                      public var expressionBinaryType: EmbarkExpressionTypeBinary {
                        get {
                          return resultMap["expressionBinaryType"]! as! EmbarkExpressionTypeBinary
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "expressionBinaryType")
                        }
                      }

                      public var key: String {
                        get {
                          return resultMap["key"]! as! String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "key")
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

                      public var text: String? {
                        get {
                          return resultMap["text"] as? String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "text")
                        }
                      }

                      public var fragments: Fragments {
                        get {
                          return Fragments(unsafeResultMap: resultMap)
                        }
                        set {
                          resultMap += newValue.resultMap
                        }
                      }

                      public struct Fragments {
                        public private(set) var resultMap: ResultMap

                        public init(unsafeResultMap: ResultMap) {
                          self.resultMap = unsafeResultMap
                        }

                        public var basicExpressionFragment: BasicExpressionFragment {
                          get {
                            return BasicExpressionFragment(unsafeResultMap: resultMap)
                          }
                          set {
                            resultMap += newValue.resultMap
                          }
                        }
                      }
                    }
                  }
                }
              }
            }

            public struct Title: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["EmbarkResponseExpression"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("text", type: .nonNull(.scalar(String.self))),
              ]

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(text: String) {
                self.init(unsafeResultMap: ["__typename": "EmbarkResponseExpression", "text": text])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
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
            }
          }
        }

        public struct Message: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["EmbarkMessage"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("text", type: .nonNull(.scalar(String.self))),
            GraphQLField("expressions", type: .nonNull(.list(.nonNull(.object(Expression.selections))))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(text: String, expressions: [Expression]) {
            self.init(unsafeResultMap: ["__typename": "EmbarkMessage", "text": text, "expressions": expressions.map { (value: Expression) -> ResultMap in value.resultMap }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
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

          public var expressions: [Expression] {
            get {
              return (resultMap["expressions"] as! [ResultMap]).map { (value: ResultMap) -> Expression in Expression(unsafeResultMap: value) }
            }
            set {
              resultMap.updateValue(newValue.map { (value: Expression) -> ResultMap in value.resultMap }, forKey: "expressions")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public struct Fragments {
            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var messageFragment: MessageFragment {
              get {
                return MessageFragment(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }

          public struct Expression: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["EmbarkExpressionUnary", "EmbarkExpressionBinary", "EmbarkExpressionMultiple"]

            public static let selections: [GraphQLSelection] = [
              GraphQLTypeCase(
                variants: ["EmbarkExpressionUnary": AsEmbarkExpressionUnary.selections, "EmbarkExpressionBinary": AsEmbarkExpressionBinary.selections, "EmbarkExpressionMultiple": AsEmbarkExpressionMultiple.selections],
                default: [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                ]
              )
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public static func makeEmbarkExpressionUnary(expressionUnaryType: EmbarkExpressionTypeUnary, text: String? = nil) -> Expression {
              return Expression(unsafeResultMap: ["__typename": "EmbarkExpressionUnary", "expressionUnaryType": expressionUnaryType, "text": text])
            }

            public static func makeEmbarkExpressionBinary(expressionBinaryType: EmbarkExpressionTypeBinary, key: String, value: String, text: String? = nil) -> Expression {
              return Expression(unsafeResultMap: ["__typename": "EmbarkExpressionBinary", "expressionBinaryType": expressionBinaryType, "key": key, "value": value, "text": text])
            }

            public static func makeEmbarkExpressionMultiple(expressionMultipleType: EmbarkExpressionTypeMultiple, text: String? = nil, subExpressions: [AsEmbarkExpressionMultiple.SubExpression]) -> Expression {
              return Expression(unsafeResultMap: ["__typename": "EmbarkExpressionMultiple", "expressionMultipleType": expressionMultipleType, "text": text, "subExpressions": subExpressions.map { (value: AsEmbarkExpressionMultiple.SubExpression) -> ResultMap in value.resultMap }])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var fragments: Fragments {
              get {
                return Fragments(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public struct Fragments {
              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public var expressionFragment: ExpressionFragment {
                get {
                  return ExpressionFragment(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
              }

              public var basicExpressionFragment: BasicExpressionFragment {
                get {
                  return BasicExpressionFragment(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
              }
            }

            public var asEmbarkExpressionUnary: AsEmbarkExpressionUnary? {
              get {
                if !AsEmbarkExpressionUnary.possibleTypes.contains(__typename) { return nil }
                return AsEmbarkExpressionUnary(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap = newValue.resultMap
              }
            }

            public struct AsEmbarkExpressionUnary: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["EmbarkExpressionUnary"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("type", alias: "expressionUnaryType", type: .nonNull(.scalar(EmbarkExpressionTypeUnary.self))),
                GraphQLField("text", type: .scalar(String.self)),
              ]

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(expressionUnaryType: EmbarkExpressionTypeUnary, text: String? = nil) {
                self.init(unsafeResultMap: ["__typename": "EmbarkExpressionUnary", "expressionUnaryType": expressionUnaryType, "text": text])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var expressionUnaryType: EmbarkExpressionTypeUnary {
                get {
                  return resultMap["expressionUnaryType"]! as! EmbarkExpressionTypeUnary
                }
                set {
                  resultMap.updateValue(newValue, forKey: "expressionUnaryType")
                }
              }

              public var text: String? {
                get {
                  return resultMap["text"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "text")
                }
              }

              public var fragments: Fragments {
                get {
                  return Fragments(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
              }

              public struct Fragments {
                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public var expressionFragment: ExpressionFragment {
                  get {
                    return ExpressionFragment(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }

                public var basicExpressionFragment: BasicExpressionFragment {
                  get {
                    return BasicExpressionFragment(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }
              }
            }

            public var asEmbarkExpressionBinary: AsEmbarkExpressionBinary? {
              get {
                if !AsEmbarkExpressionBinary.possibleTypes.contains(__typename) { return nil }
                return AsEmbarkExpressionBinary(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap = newValue.resultMap
              }
            }

            public struct AsEmbarkExpressionBinary: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["EmbarkExpressionBinary"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("type", alias: "expressionBinaryType", type: .nonNull(.scalar(EmbarkExpressionTypeBinary.self))),
                GraphQLField("key", type: .nonNull(.scalar(String.self))),
                GraphQLField("value", type: .nonNull(.scalar(String.self))),
                GraphQLField("text", type: .scalar(String.self)),
              ]

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(expressionBinaryType: EmbarkExpressionTypeBinary, key: String, value: String, text: String? = nil) {
                self.init(unsafeResultMap: ["__typename": "EmbarkExpressionBinary", "expressionBinaryType": expressionBinaryType, "key": key, "value": value, "text": text])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var expressionBinaryType: EmbarkExpressionTypeBinary {
                get {
                  return resultMap["expressionBinaryType"]! as! EmbarkExpressionTypeBinary
                }
                set {
                  resultMap.updateValue(newValue, forKey: "expressionBinaryType")
                }
              }

              public var key: String {
                get {
                  return resultMap["key"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "key")
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

              public var text: String? {
                get {
                  return resultMap["text"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "text")
                }
              }

              public var fragments: Fragments {
                get {
                  return Fragments(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
              }

              public struct Fragments {
                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public var expressionFragment: ExpressionFragment {
                  get {
                    return ExpressionFragment(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }

                public var basicExpressionFragment: BasicExpressionFragment {
                  get {
                    return BasicExpressionFragment(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }
              }
            }

            public var asEmbarkExpressionMultiple: AsEmbarkExpressionMultiple? {
              get {
                if !AsEmbarkExpressionMultiple.possibleTypes.contains(__typename) { return nil }
                return AsEmbarkExpressionMultiple(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap = newValue.resultMap
              }
            }

            public struct AsEmbarkExpressionMultiple: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["EmbarkExpressionMultiple"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("type", alias: "expressionMultipleType", type: .nonNull(.scalar(EmbarkExpressionTypeMultiple.self))),
                GraphQLField("text", type: .scalar(String.self)),
                GraphQLField("subExpressions", type: .nonNull(.list(.nonNull(.object(SubExpression.selections))))),
              ]

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(expressionMultipleType: EmbarkExpressionTypeMultiple, text: String? = nil, subExpressions: [SubExpression]) {
                self.init(unsafeResultMap: ["__typename": "EmbarkExpressionMultiple", "expressionMultipleType": expressionMultipleType, "text": text, "subExpressions": subExpressions.map { (value: SubExpression) -> ResultMap in value.resultMap }])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var expressionMultipleType: EmbarkExpressionTypeMultiple {
                get {
                  return resultMap["expressionMultipleType"]! as! EmbarkExpressionTypeMultiple
                }
                set {
                  resultMap.updateValue(newValue, forKey: "expressionMultipleType")
                }
              }

              public var text: String? {
                get {
                  return resultMap["text"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "text")
                }
              }

              public var subExpressions: [SubExpression] {
                get {
                  return (resultMap["subExpressions"] as! [ResultMap]).map { (value: ResultMap) -> SubExpression in SubExpression(unsafeResultMap: value) }
                }
                set {
                  resultMap.updateValue(newValue.map { (value: SubExpression) -> ResultMap in value.resultMap }, forKey: "subExpressions")
                }
              }

              public var fragments: Fragments {
                get {
                  return Fragments(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
              }

              public struct Fragments {
                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public var expressionFragment: ExpressionFragment {
                  get {
                    return ExpressionFragment(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }

                public var basicExpressionFragment: BasicExpressionFragment {
                  get {
                    return BasicExpressionFragment(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }
              }

              public struct SubExpression: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["EmbarkExpressionUnary", "EmbarkExpressionBinary", "EmbarkExpressionMultiple"]

                public static let selections: [GraphQLSelection] = [
                  GraphQLTypeCase(
                    variants: ["EmbarkExpressionUnary": AsEmbarkExpressionUnary.selections, "EmbarkExpressionBinary": AsEmbarkExpressionBinary.selections],
                    default: [
                      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    ]
                  )
                ]

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public static func makeEmbarkExpressionMultiple() -> SubExpression {
                  return SubExpression(unsafeResultMap: ["__typename": "EmbarkExpressionMultiple"])
                }

                public static func makeEmbarkExpressionUnary(expressionUnaryType: EmbarkExpressionTypeUnary, text: String? = nil) -> SubExpression {
                  return SubExpression(unsafeResultMap: ["__typename": "EmbarkExpressionUnary", "expressionUnaryType": expressionUnaryType, "text": text])
                }

                public static func makeEmbarkExpressionBinary(expressionBinaryType: EmbarkExpressionTypeBinary, key: String, value: String, text: String? = nil) -> SubExpression {
                  return SubExpression(unsafeResultMap: ["__typename": "EmbarkExpressionBinary", "expressionBinaryType": expressionBinaryType, "key": key, "value": value, "text": text])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                public var fragments: Fragments {
                  get {
                    return Fragments(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }

                public struct Fragments {
                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public var basicExpressionFragment: BasicExpressionFragment {
                    get {
                      return BasicExpressionFragment(unsafeResultMap: resultMap)
                    }
                    set {
                      resultMap += newValue.resultMap
                    }
                  }
                }

                public var asEmbarkExpressionUnary: AsEmbarkExpressionUnary? {
                  get {
                    if !AsEmbarkExpressionUnary.possibleTypes.contains(__typename) { return nil }
                    return AsEmbarkExpressionUnary(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap = newValue.resultMap
                  }
                }

                public struct AsEmbarkExpressionUnary: GraphQLSelectionSet {
                  public static let possibleTypes: [String] = ["EmbarkExpressionUnary"]

                  public static let selections: [GraphQLSelection] = [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("type", alias: "expressionUnaryType", type: .nonNull(.scalar(EmbarkExpressionTypeUnary.self))),
                    GraphQLField("text", type: .scalar(String.self)),
                  ]

                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public init(expressionUnaryType: EmbarkExpressionTypeUnary, text: String? = nil) {
                    self.init(unsafeResultMap: ["__typename": "EmbarkExpressionUnary", "expressionUnaryType": expressionUnaryType, "text": text])
                  }

                  public var __typename: String {
                    get {
                      return resultMap["__typename"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "__typename")
                    }
                  }

                  public var expressionUnaryType: EmbarkExpressionTypeUnary {
                    get {
                      return resultMap["expressionUnaryType"]! as! EmbarkExpressionTypeUnary
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "expressionUnaryType")
                    }
                  }

                  public var text: String? {
                    get {
                      return resultMap["text"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "text")
                    }
                  }

                  public var fragments: Fragments {
                    get {
                      return Fragments(unsafeResultMap: resultMap)
                    }
                    set {
                      resultMap += newValue.resultMap
                    }
                  }

                  public struct Fragments {
                    public private(set) var resultMap: ResultMap

                    public init(unsafeResultMap: ResultMap) {
                      self.resultMap = unsafeResultMap
                    }

                    public var basicExpressionFragment: BasicExpressionFragment {
                      get {
                        return BasicExpressionFragment(unsafeResultMap: resultMap)
                      }
                      set {
                        resultMap += newValue.resultMap
                      }
                    }
                  }
                }

                public var asEmbarkExpressionBinary: AsEmbarkExpressionBinary? {
                  get {
                    if !AsEmbarkExpressionBinary.possibleTypes.contains(__typename) { return nil }
                    return AsEmbarkExpressionBinary(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap = newValue.resultMap
                  }
                }

                public struct AsEmbarkExpressionBinary: GraphQLSelectionSet {
                  public static let possibleTypes: [String] = ["EmbarkExpressionBinary"]

                  public static let selections: [GraphQLSelection] = [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("type", alias: "expressionBinaryType", type: .nonNull(.scalar(EmbarkExpressionTypeBinary.self))),
                    GraphQLField("key", type: .nonNull(.scalar(String.self))),
                    GraphQLField("value", type: .nonNull(.scalar(String.self))),
                    GraphQLField("text", type: .scalar(String.self)),
                  ]

                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public init(expressionBinaryType: EmbarkExpressionTypeBinary, key: String, value: String, text: String? = nil) {
                    self.init(unsafeResultMap: ["__typename": "EmbarkExpressionBinary", "expressionBinaryType": expressionBinaryType, "key": key, "value": value, "text": text])
                  }

                  public var __typename: String {
                    get {
                      return resultMap["__typename"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "__typename")
                    }
                  }

                  public var expressionBinaryType: EmbarkExpressionTypeBinary {
                    get {
                      return resultMap["expressionBinaryType"]! as! EmbarkExpressionTypeBinary
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "expressionBinaryType")
                    }
                  }

                  public var key: String {
                    get {
                      return resultMap["key"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "key")
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

                  public var text: String? {
                    get {
                      return resultMap["text"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "text")
                    }
                  }

                  public var fragments: Fragments {
                    get {
                      return Fragments(unsafeResultMap: resultMap)
                    }
                    set {
                      resultMap += newValue.resultMap
                    }
                  }

                  public struct Fragments {
                    public private(set) var resultMap: ResultMap

                    public init(unsafeResultMap: ResultMap) {
                      self.resultMap = unsafeResultMap
                    }

                    public var basicExpressionFragment: BasicExpressionFragment {
                      get {
                        return BasicExpressionFragment(unsafeResultMap: resultMap)
                      }
                      set {
                        resultMap += newValue.resultMap
                      }
                    }
                  }
                }
              }
            }
          }
        }

        public struct Action: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["EmbarkExternalInsuranceProviderAction", "EmbarkPreviousInsuranceProviderAction", "EmbarkNumberActionSet", "EmbarkTextActionSet", "EmbarkTextAction", "EmbarkSelectAction", "EmbarkNumberAction", "EmbarkMultiAction"]

          public static let selections: [GraphQLSelection] = [
            GraphQLTypeCase(
              variants: ["EmbarkTextAction": AsEmbarkTextAction.selections, "EmbarkNumberAction": AsEmbarkNumberAction.selections, "EmbarkSelectAction": AsEmbarkSelectAction.selections],
              default: [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("component", type: .nonNull(.scalar(String.self))),
              ]
            )
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public static func makeEmbarkExternalInsuranceProviderAction(component: String) -> Action {
            return Action(unsafeResultMap: ["__typename": "EmbarkExternalInsuranceProviderAction", "component": component])
          }

          public static func makeEmbarkPreviousInsuranceProviderAction(component: String) -> Action {
            return Action(unsafeResultMap: ["__typename": "EmbarkPreviousInsuranceProviderAction", "component": component])
          }

          public static func makeEmbarkNumberActionSet(component: String) -> Action {
            return Action(unsafeResultMap: ["__typename": "EmbarkNumberActionSet", "component": component])
          }

          public static func makeEmbarkTextActionSet(component: String) -> Action {
            return Action(unsafeResultMap: ["__typename": "EmbarkTextActionSet", "component": component])
          }

          public static func makeEmbarkMultiAction(component: String) -> Action {
            return Action(unsafeResultMap: ["__typename": "EmbarkMultiAction", "component": component])
          }

          public static func makeEmbarkTextAction(component: String, textActionData: AsEmbarkTextAction.TextActionDatum) -> Action {
            return Action(unsafeResultMap: ["__typename": "EmbarkTextAction", "component": component, "textActionData": textActionData.resultMap])
          }

          public static func makeEmbarkNumberAction(component: String, numberActionData: AsEmbarkNumberAction.NumberActionDatum) -> Action {
            return Action(unsafeResultMap: ["__typename": "EmbarkNumberAction", "component": component, "numberActionData": numberActionData.resultMap])
          }

          public static func makeEmbarkSelectAction(component: String, selectActionData: AsEmbarkSelectAction.SelectActionDatum) -> Action {
            return Action(unsafeResultMap: ["__typename": "EmbarkSelectAction", "component": component, "selectActionData": selectActionData.resultMap])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var component: String {
            get {
              return resultMap["component"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "component")
            }
          }

          public var asEmbarkTextAction: AsEmbarkTextAction? {
            get {
              if !AsEmbarkTextAction.possibleTypes.contains(__typename) { return nil }
              return AsEmbarkTextAction(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap = newValue.resultMap
            }
          }

          public struct AsEmbarkTextAction: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["EmbarkTextAction"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("component", type: .nonNull(.scalar(String.self))),
              GraphQLField("component", type: .nonNull(.scalar(String.self))),
              GraphQLField("data", alias: "textActionData", type: .nonNull(.object(TextActionDatum.selections))),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(component: String, textActionData: TextActionDatum) {
              self.init(unsafeResultMap: ["__typename": "EmbarkTextAction", "component": component, "textActionData": textActionData.resultMap])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var component: String {
              get {
                return resultMap["component"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "component")
              }
            }

            public var textActionData: TextActionDatum {
              get {
                return TextActionDatum(unsafeResultMap: resultMap["textActionData"]! as! ResultMap)
              }
              set {
                resultMap.updateValue(newValue.resultMap, forKey: "textActionData")
              }
            }

            public struct TextActionDatum: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["EmbarkTextActionData"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("key", type: .nonNull(.scalar(String.self))),
                GraphQLField("placeholder", type: .nonNull(.scalar(String.self))),
                GraphQLField("link", type: .nonNull(.object(Link.selections))),
              ]

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(key: String, placeholder: String, link: Link) {
                self.init(unsafeResultMap: ["__typename": "EmbarkTextActionData", "key": key, "placeholder": placeholder, "link": link.resultMap])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var key: String {
                get {
                  return resultMap["key"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "key")
                }
              }

              public var placeholder: String {
                get {
                  return resultMap["placeholder"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "placeholder")
                }
              }

              public var link: Link {
                get {
                  return Link(unsafeResultMap: resultMap["link"]! as! ResultMap)
                }
                set {
                  resultMap.updateValue(newValue.resultMap, forKey: "link")
                }
              }

              public struct Link: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["EmbarkLink"]

                public static let selections: [GraphQLSelection] = [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("name", type: .nonNull(.scalar(String.self))),
                  GraphQLField("label", type: .nonNull(.scalar(String.self))),
                ]

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(name: String, label: String) {
                  self.init(unsafeResultMap: ["__typename": "EmbarkLink", "name": name, "label": label])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                public var name: String {
                  get {
                    return resultMap["name"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "name")
                  }
                }

                public var label: String {
                  get {
                    return resultMap["label"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "label")
                  }
                }

                public var fragments: Fragments {
                  get {
                    return Fragments(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }

                public struct Fragments {
                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public var embarkLinkFragment: EmbarkLinkFragment {
                    get {
                      return EmbarkLinkFragment(unsafeResultMap: resultMap)
                    }
                    set {
                      resultMap += newValue.resultMap
                    }
                  }
                }
              }
            }
          }

          public var asEmbarkNumberAction: AsEmbarkNumberAction? {
            get {
              if !AsEmbarkNumberAction.possibleTypes.contains(__typename) { return nil }
              return AsEmbarkNumberAction(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap = newValue.resultMap
            }
          }

          public struct AsEmbarkNumberAction: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["EmbarkNumberAction"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("component", type: .nonNull(.scalar(String.self))),
              GraphQLField("component", type: .nonNull(.scalar(String.self))),
              GraphQLField("data", alias: "numberActionData", type: .nonNull(.object(NumberActionDatum.selections))),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(component: String, numberActionData: NumberActionDatum) {
              self.init(unsafeResultMap: ["__typename": "EmbarkNumberAction", "component": component, "numberActionData": numberActionData.resultMap])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var component: String {
              get {
                return resultMap["component"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "component")
              }
            }

            public var numberActionData: NumberActionDatum {
              get {
                return NumberActionDatum(unsafeResultMap: resultMap["numberActionData"]! as! ResultMap)
              }
              set {
                resultMap.updateValue(newValue.resultMap, forKey: "numberActionData")
              }
            }

            public struct NumberActionDatum: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["EmbarkNumberActionData"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("key", type: .nonNull(.scalar(String.self))),
                GraphQLField("placeholder", type: .nonNull(.scalar(String.self))),
                GraphQLField("unit", type: .scalar(String.self)),
                GraphQLField("maxValue", type: .scalar(Int.self)),
                GraphQLField("minValue", type: .scalar(Int.self)),
                GraphQLField("link", type: .nonNull(.object(Link.selections))),
              ]

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(key: String, placeholder: String, unit: String? = nil, maxValue: Int? = nil, minValue: Int? = nil, link: Link) {
                self.init(unsafeResultMap: ["__typename": "EmbarkNumberActionData", "key": key, "placeholder": placeholder, "unit": unit, "maxValue": maxValue, "minValue": minValue, "link": link.resultMap])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var key: String {
                get {
                  return resultMap["key"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "key")
                }
              }

              public var placeholder: String {
                get {
                  return resultMap["placeholder"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "placeholder")
                }
              }

              public var unit: String? {
                get {
                  return resultMap["unit"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "unit")
                }
              }

              public var maxValue: Int? {
                get {
                  return resultMap["maxValue"] as? Int
                }
                set {
                  resultMap.updateValue(newValue, forKey: "maxValue")
                }
              }

              public var minValue: Int? {
                get {
                  return resultMap["minValue"] as? Int
                }
                set {
                  resultMap.updateValue(newValue, forKey: "minValue")
                }
              }

              public var link: Link {
                get {
                  return Link(unsafeResultMap: resultMap["link"]! as! ResultMap)
                }
                set {
                  resultMap.updateValue(newValue.resultMap, forKey: "link")
                }
              }

              public struct Link: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["EmbarkLink"]

                public static let selections: [GraphQLSelection] = [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("name", type: .nonNull(.scalar(String.self))),
                  GraphQLField("label", type: .nonNull(.scalar(String.self))),
                ]

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(name: String, label: String) {
                  self.init(unsafeResultMap: ["__typename": "EmbarkLink", "name": name, "label": label])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                public var name: String {
                  get {
                    return resultMap["name"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "name")
                  }
                }

                public var label: String {
                  get {
                    return resultMap["label"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "label")
                  }
                }

                public var fragments: Fragments {
                  get {
                    return Fragments(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }

                public struct Fragments {
                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public var embarkLinkFragment: EmbarkLinkFragment {
                    get {
                      return EmbarkLinkFragment(unsafeResultMap: resultMap)
                    }
                    set {
                      resultMap += newValue.resultMap
                    }
                  }
                }
              }
            }
          }

          public var asEmbarkSelectAction: AsEmbarkSelectAction? {
            get {
              if !AsEmbarkSelectAction.possibleTypes.contains(__typename) { return nil }
              return AsEmbarkSelectAction(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap = newValue.resultMap
            }
          }

          public struct AsEmbarkSelectAction: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["EmbarkSelectAction"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("component", type: .nonNull(.scalar(String.self))),
              GraphQLField("component", type: .nonNull(.scalar(String.self))),
              GraphQLField("data", alias: "selectActionData", type: .nonNull(.object(SelectActionDatum.selections))),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(component: String, selectActionData: SelectActionDatum) {
              self.init(unsafeResultMap: ["__typename": "EmbarkSelectAction", "component": component, "selectActionData": selectActionData.resultMap])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var component: String {
              get {
                return resultMap["component"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "component")
              }
            }

            public var selectActionData: SelectActionDatum {
              get {
                return SelectActionDatum(unsafeResultMap: resultMap["selectActionData"]! as! ResultMap)
              }
              set {
                resultMap.updateValue(newValue.resultMap, forKey: "selectActionData")
              }
            }

            public struct SelectActionDatum: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["EmbarkSelectActionData"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("options", type: .nonNull(.list(.nonNull(.object(Option.selections))))),
              ]

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(options: [Option]) {
                self.init(unsafeResultMap: ["__typename": "EmbarkSelectActionData", "options": options.map { (value: Option) -> ResultMap in value.resultMap }])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var options: [Option] {
                get {
                  return (resultMap["options"] as! [ResultMap]).map { (value: ResultMap) -> Option in Option(unsafeResultMap: value) }
                }
                set {
                  resultMap.updateValue(newValue.map { (value: Option) -> ResultMap in value.resultMap }, forKey: "options")
                }
              }

              public struct Option: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["EmbarkSelectActionOption"]

                public static let selections: [GraphQLSelection] = [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("keys", type: .nonNull(.list(.nonNull(.scalar(String.self))))),
                  GraphQLField("values", type: .nonNull(.list(.nonNull(.scalar(String.self))))),
                  GraphQLField("link", type: .nonNull(.object(Link.selections))),
                ]

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(keys: [String], values: [String], link: Link) {
                  self.init(unsafeResultMap: ["__typename": "EmbarkSelectActionOption", "keys": keys, "values": values, "link": link.resultMap])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                public var keys: [String] {
                  get {
                    return resultMap["keys"]! as! [String]
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "keys")
                  }
                }

                public var values: [String] {
                  get {
                    return resultMap["values"]! as! [String]
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "values")
                  }
                }

                public var link: Link {
                  get {
                    return Link(unsafeResultMap: resultMap["link"]! as! ResultMap)
                  }
                  set {
                    resultMap.updateValue(newValue.resultMap, forKey: "link")
                  }
                }

                public struct Link: GraphQLSelectionSet {
                  public static let possibleTypes: [String] = ["EmbarkLink"]

                  public static let selections: [GraphQLSelection] = [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("name", type: .nonNull(.scalar(String.self))),
                    GraphQLField("label", type: .nonNull(.scalar(String.self))),
                  ]

                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public init(name: String, label: String) {
                    self.init(unsafeResultMap: ["__typename": "EmbarkLink", "name": name, "label": label])
                  }

                  public var __typename: String {
                    get {
                      return resultMap["__typename"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "__typename")
                    }
                  }

                  public var name: String {
                    get {
                      return resultMap["name"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "name")
                    }
                  }

                  public var label: String {
                    get {
                      return resultMap["label"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "label")
                    }
                  }

                  public var fragments: Fragments {
                    get {
                      return Fragments(unsafeResultMap: resultMap)
                    }
                    set {
                      resultMap += newValue.resultMap
                    }
                  }

                  public struct Fragments {
                    public private(set) var resultMap: ResultMap

                    public init(unsafeResultMap: ResultMap) {
                      self.resultMap = unsafeResultMap
                    }

                    public var embarkLinkFragment: EmbarkLinkFragment {
                      get {
                        return EmbarkLinkFragment(unsafeResultMap: resultMap)
                      }
                      set {
                        resultMap += newValue.resultMap
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

public struct EmbarkLinkFragment: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment EmbarkLinkFragment on EmbarkLink {
      __typename
      name
      label
    }
    """

  public static let possibleTypes: [String] = ["EmbarkLink"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("name", type: .nonNull(.scalar(String.self))),
    GraphQLField("label", type: .nonNull(.scalar(String.self))),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(name: String, label: String) {
    self.init(unsafeResultMap: ["__typename": "EmbarkLink", "name": name, "label": label])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var name: String {
    get {
      return resultMap["name"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "name")
    }
  }

  public var label: String {
    get {
      return resultMap["label"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "label")
    }
  }
}

public struct MessageFragment: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment MessageFragment on EmbarkMessage {
      __typename
      text
      expressions {
        __typename
        ...ExpressionFragment
      }
    }
    """

  public static let possibleTypes: [String] = ["EmbarkMessage"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("text", type: .nonNull(.scalar(String.self))),
    GraphQLField("expressions", type: .nonNull(.list(.nonNull(.object(Expression.selections))))),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(text: String, expressions: [Expression]) {
    self.init(unsafeResultMap: ["__typename": "EmbarkMessage", "text": text, "expressions": expressions.map { (value: Expression) -> ResultMap in value.resultMap }])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
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

  public var expressions: [Expression] {
    get {
      return (resultMap["expressions"] as! [ResultMap]).map { (value: ResultMap) -> Expression in Expression(unsafeResultMap: value) }
    }
    set {
      resultMap.updateValue(newValue.map { (value: Expression) -> ResultMap in value.resultMap }, forKey: "expressions")
    }
  }

  public struct Expression: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["EmbarkExpressionUnary", "EmbarkExpressionBinary", "EmbarkExpressionMultiple"]

    public static let selections: [GraphQLSelection] = [
      GraphQLTypeCase(
        variants: ["EmbarkExpressionUnary": AsEmbarkExpressionUnary.selections, "EmbarkExpressionBinary": AsEmbarkExpressionBinary.selections, "EmbarkExpressionMultiple": AsEmbarkExpressionMultiple.selections],
        default: [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        ]
      )
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public static func makeEmbarkExpressionUnary(expressionUnaryType: EmbarkExpressionTypeUnary, text: String? = nil) -> Expression {
      return Expression(unsafeResultMap: ["__typename": "EmbarkExpressionUnary", "expressionUnaryType": expressionUnaryType, "text": text])
    }

    public static func makeEmbarkExpressionBinary(expressionBinaryType: EmbarkExpressionTypeBinary, key: String, value: String, text: String? = nil) -> Expression {
      return Expression(unsafeResultMap: ["__typename": "EmbarkExpressionBinary", "expressionBinaryType": expressionBinaryType, "key": key, "value": value, "text": text])
    }

    public static func makeEmbarkExpressionMultiple(expressionMultipleType: EmbarkExpressionTypeMultiple, text: String? = nil, subExpressions: [AsEmbarkExpressionMultiple.SubExpression]) -> Expression {
      return Expression(unsafeResultMap: ["__typename": "EmbarkExpressionMultiple", "expressionMultipleType": expressionMultipleType, "text": text, "subExpressions": subExpressions.map { (value: AsEmbarkExpressionMultiple.SubExpression) -> ResultMap in value.resultMap }])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var fragments: Fragments {
      get {
        return Fragments(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }

    public struct Fragments {
      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var expressionFragment: ExpressionFragment {
        get {
          return ExpressionFragment(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public var basicExpressionFragment: BasicExpressionFragment {
        get {
          return BasicExpressionFragment(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }
    }

    public var asEmbarkExpressionUnary: AsEmbarkExpressionUnary? {
      get {
        if !AsEmbarkExpressionUnary.possibleTypes.contains(__typename) { return nil }
        return AsEmbarkExpressionUnary(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsEmbarkExpressionUnary: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["EmbarkExpressionUnary"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("type", alias: "expressionUnaryType", type: .nonNull(.scalar(EmbarkExpressionTypeUnary.self))),
        GraphQLField("text", type: .scalar(String.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(expressionUnaryType: EmbarkExpressionTypeUnary, text: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "EmbarkExpressionUnary", "expressionUnaryType": expressionUnaryType, "text": text])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var expressionUnaryType: EmbarkExpressionTypeUnary {
        get {
          return resultMap["expressionUnaryType"]! as! EmbarkExpressionTypeUnary
        }
        set {
          resultMap.updateValue(newValue, forKey: "expressionUnaryType")
        }
      }

      public var text: String? {
        get {
          return resultMap["text"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "text")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var expressionFragment: ExpressionFragment {
          get {
            return ExpressionFragment(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public var basicExpressionFragment: BasicExpressionFragment {
          get {
            return BasicExpressionFragment(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }

    public var asEmbarkExpressionBinary: AsEmbarkExpressionBinary? {
      get {
        if !AsEmbarkExpressionBinary.possibleTypes.contains(__typename) { return nil }
        return AsEmbarkExpressionBinary(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsEmbarkExpressionBinary: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["EmbarkExpressionBinary"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("type", alias: "expressionBinaryType", type: .nonNull(.scalar(EmbarkExpressionTypeBinary.self))),
        GraphQLField("key", type: .nonNull(.scalar(String.self))),
        GraphQLField("value", type: .nonNull(.scalar(String.self))),
        GraphQLField("text", type: .scalar(String.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(expressionBinaryType: EmbarkExpressionTypeBinary, key: String, value: String, text: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "EmbarkExpressionBinary", "expressionBinaryType": expressionBinaryType, "key": key, "value": value, "text": text])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var expressionBinaryType: EmbarkExpressionTypeBinary {
        get {
          return resultMap["expressionBinaryType"]! as! EmbarkExpressionTypeBinary
        }
        set {
          resultMap.updateValue(newValue, forKey: "expressionBinaryType")
        }
      }

      public var key: String {
        get {
          return resultMap["key"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "key")
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

      public var text: String? {
        get {
          return resultMap["text"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "text")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var expressionFragment: ExpressionFragment {
          get {
            return ExpressionFragment(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public var basicExpressionFragment: BasicExpressionFragment {
          get {
            return BasicExpressionFragment(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }

    public var asEmbarkExpressionMultiple: AsEmbarkExpressionMultiple? {
      get {
        if !AsEmbarkExpressionMultiple.possibleTypes.contains(__typename) { return nil }
        return AsEmbarkExpressionMultiple(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsEmbarkExpressionMultiple: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["EmbarkExpressionMultiple"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("type", alias: "expressionMultipleType", type: .nonNull(.scalar(EmbarkExpressionTypeMultiple.self))),
        GraphQLField("text", type: .scalar(String.self)),
        GraphQLField("subExpressions", type: .nonNull(.list(.nonNull(.object(SubExpression.selections))))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(expressionMultipleType: EmbarkExpressionTypeMultiple, text: String? = nil, subExpressions: [SubExpression]) {
        self.init(unsafeResultMap: ["__typename": "EmbarkExpressionMultiple", "expressionMultipleType": expressionMultipleType, "text": text, "subExpressions": subExpressions.map { (value: SubExpression) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var expressionMultipleType: EmbarkExpressionTypeMultiple {
        get {
          return resultMap["expressionMultipleType"]! as! EmbarkExpressionTypeMultiple
        }
        set {
          resultMap.updateValue(newValue, forKey: "expressionMultipleType")
        }
      }

      public var text: String? {
        get {
          return resultMap["text"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "text")
        }
      }

      public var subExpressions: [SubExpression] {
        get {
          return (resultMap["subExpressions"] as! [ResultMap]).map { (value: ResultMap) -> SubExpression in SubExpression(unsafeResultMap: value) }
        }
        set {
          resultMap.updateValue(newValue.map { (value: SubExpression) -> ResultMap in value.resultMap }, forKey: "subExpressions")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var expressionFragment: ExpressionFragment {
          get {
            return ExpressionFragment(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public var basicExpressionFragment: BasicExpressionFragment {
          get {
            return BasicExpressionFragment(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }

      public struct SubExpression: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["EmbarkExpressionUnary", "EmbarkExpressionBinary", "EmbarkExpressionMultiple"]

        public static let selections: [GraphQLSelection] = [
          GraphQLTypeCase(
            variants: ["EmbarkExpressionUnary": AsEmbarkExpressionUnary.selections, "EmbarkExpressionBinary": AsEmbarkExpressionBinary.selections],
            default: [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            ]
          )
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public static func makeEmbarkExpressionMultiple() -> SubExpression {
          return SubExpression(unsafeResultMap: ["__typename": "EmbarkExpressionMultiple"])
        }

        public static func makeEmbarkExpressionUnary(expressionUnaryType: EmbarkExpressionTypeUnary, text: String? = nil) -> SubExpression {
          return SubExpression(unsafeResultMap: ["__typename": "EmbarkExpressionUnary", "expressionUnaryType": expressionUnaryType, "text": text])
        }

        public static func makeEmbarkExpressionBinary(expressionBinaryType: EmbarkExpressionTypeBinary, key: String, value: String, text: String? = nil) -> SubExpression {
          return SubExpression(unsafeResultMap: ["__typename": "EmbarkExpressionBinary", "expressionBinaryType": expressionBinaryType, "key": key, "value": value, "text": text])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var basicExpressionFragment: BasicExpressionFragment {
            get {
              return BasicExpressionFragment(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }

        public var asEmbarkExpressionUnary: AsEmbarkExpressionUnary? {
          get {
            if !AsEmbarkExpressionUnary.possibleTypes.contains(__typename) { return nil }
            return AsEmbarkExpressionUnary(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsEmbarkExpressionUnary: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["EmbarkExpressionUnary"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("type", alias: "expressionUnaryType", type: .nonNull(.scalar(EmbarkExpressionTypeUnary.self))),
            GraphQLField("text", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(expressionUnaryType: EmbarkExpressionTypeUnary, text: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "EmbarkExpressionUnary", "expressionUnaryType": expressionUnaryType, "text": text])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var expressionUnaryType: EmbarkExpressionTypeUnary {
            get {
              return resultMap["expressionUnaryType"]! as! EmbarkExpressionTypeUnary
            }
            set {
              resultMap.updateValue(newValue, forKey: "expressionUnaryType")
            }
          }

          public var text: String? {
            get {
              return resultMap["text"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "text")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public struct Fragments {
            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var basicExpressionFragment: BasicExpressionFragment {
              get {
                return BasicExpressionFragment(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }
        }

        public var asEmbarkExpressionBinary: AsEmbarkExpressionBinary? {
          get {
            if !AsEmbarkExpressionBinary.possibleTypes.contains(__typename) { return nil }
            return AsEmbarkExpressionBinary(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsEmbarkExpressionBinary: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["EmbarkExpressionBinary"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("type", alias: "expressionBinaryType", type: .nonNull(.scalar(EmbarkExpressionTypeBinary.self))),
            GraphQLField("key", type: .nonNull(.scalar(String.self))),
            GraphQLField("value", type: .nonNull(.scalar(String.self))),
            GraphQLField("text", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(expressionBinaryType: EmbarkExpressionTypeBinary, key: String, value: String, text: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "EmbarkExpressionBinary", "expressionBinaryType": expressionBinaryType, "key": key, "value": value, "text": text])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var expressionBinaryType: EmbarkExpressionTypeBinary {
            get {
              return resultMap["expressionBinaryType"]! as! EmbarkExpressionTypeBinary
            }
            set {
              resultMap.updateValue(newValue, forKey: "expressionBinaryType")
            }
          }

          public var key: String {
            get {
              return resultMap["key"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "key")
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

          public var text: String? {
            get {
              return resultMap["text"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "text")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public struct Fragments {
            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var basicExpressionFragment: BasicExpressionFragment {
              get {
                return BasicExpressionFragment(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }
        }
      }
    }
  }
}

public struct BasicExpressionFragment: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment BasicExpressionFragment on EmbarkExpression {
      __typename
      ... on EmbarkExpressionUnary {
        expressionUnaryType: type
        text
      }
      ... on EmbarkExpressionBinary {
        expressionBinaryType: type
        key
        value
        text
      }
    }
    """

  public static let possibleTypes: [String] = ["EmbarkExpressionUnary", "EmbarkExpressionBinary", "EmbarkExpressionMultiple"]

  public static let selections: [GraphQLSelection] = [
    GraphQLTypeCase(
      variants: ["EmbarkExpressionUnary": AsEmbarkExpressionUnary.selections, "EmbarkExpressionBinary": AsEmbarkExpressionBinary.selections],
      default: [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      ]
    )
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public static func makeEmbarkExpressionMultiple() -> BasicExpressionFragment {
    return BasicExpressionFragment(unsafeResultMap: ["__typename": "EmbarkExpressionMultiple"])
  }

  public static func makeEmbarkExpressionUnary(expressionUnaryType: EmbarkExpressionTypeUnary, text: String? = nil) -> BasicExpressionFragment {
    return BasicExpressionFragment(unsafeResultMap: ["__typename": "EmbarkExpressionUnary", "expressionUnaryType": expressionUnaryType, "text": text])
  }

  public static func makeEmbarkExpressionBinary(expressionBinaryType: EmbarkExpressionTypeBinary, key: String, value: String, text: String? = nil) -> BasicExpressionFragment {
    return BasicExpressionFragment(unsafeResultMap: ["__typename": "EmbarkExpressionBinary", "expressionBinaryType": expressionBinaryType, "key": key, "value": value, "text": text])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var asEmbarkExpressionUnary: AsEmbarkExpressionUnary? {
    get {
      if !AsEmbarkExpressionUnary.possibleTypes.contains(__typename) { return nil }
      return AsEmbarkExpressionUnary(unsafeResultMap: resultMap)
    }
    set {
      guard let newValue = newValue else { return }
      resultMap = newValue.resultMap
    }
  }

  public struct AsEmbarkExpressionUnary: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["EmbarkExpressionUnary"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("type", alias: "expressionUnaryType", type: .nonNull(.scalar(EmbarkExpressionTypeUnary.self))),
      GraphQLField("text", type: .scalar(String.self)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(expressionUnaryType: EmbarkExpressionTypeUnary, text: String? = nil) {
      self.init(unsafeResultMap: ["__typename": "EmbarkExpressionUnary", "expressionUnaryType": expressionUnaryType, "text": text])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var expressionUnaryType: EmbarkExpressionTypeUnary {
      get {
        return resultMap["expressionUnaryType"]! as! EmbarkExpressionTypeUnary
      }
      set {
        resultMap.updateValue(newValue, forKey: "expressionUnaryType")
      }
    }

    public var text: String? {
      get {
        return resultMap["text"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "text")
      }
    }
  }

  public var asEmbarkExpressionBinary: AsEmbarkExpressionBinary? {
    get {
      if !AsEmbarkExpressionBinary.possibleTypes.contains(__typename) { return nil }
      return AsEmbarkExpressionBinary(unsafeResultMap: resultMap)
    }
    set {
      guard let newValue = newValue else { return }
      resultMap = newValue.resultMap
    }
  }

  public struct AsEmbarkExpressionBinary: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["EmbarkExpressionBinary"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("type", alias: "expressionBinaryType", type: .nonNull(.scalar(EmbarkExpressionTypeBinary.self))),
      GraphQLField("key", type: .nonNull(.scalar(String.self))),
      GraphQLField("value", type: .nonNull(.scalar(String.self))),
      GraphQLField("text", type: .scalar(String.self)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(expressionBinaryType: EmbarkExpressionTypeBinary, key: String, value: String, text: String? = nil) {
      self.init(unsafeResultMap: ["__typename": "EmbarkExpressionBinary", "expressionBinaryType": expressionBinaryType, "key": key, "value": value, "text": text])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var expressionBinaryType: EmbarkExpressionTypeBinary {
      get {
        return resultMap["expressionBinaryType"]! as! EmbarkExpressionTypeBinary
      }
      set {
        resultMap.updateValue(newValue, forKey: "expressionBinaryType")
      }
    }

    public var key: String {
      get {
        return resultMap["key"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "key")
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

    public var text: String? {
      get {
        return resultMap["text"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "text")
      }
    }
  }
}

public struct ExpressionFragment: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment ExpressionFragment on EmbarkExpression {
      __typename
      ...BasicExpressionFragment
      ... on EmbarkExpressionMultiple {
        expressionMultipleType: type
        text
        subExpressions {
          __typename
          ...BasicExpressionFragment
        }
      }
    }
    """

  public static let possibleTypes: [String] = ["EmbarkExpressionUnary", "EmbarkExpressionBinary", "EmbarkExpressionMultiple"]

  public static let selections: [GraphQLSelection] = [
    GraphQLTypeCase(
      variants: ["EmbarkExpressionUnary": AsEmbarkExpressionUnary.selections, "EmbarkExpressionBinary": AsEmbarkExpressionBinary.selections, "EmbarkExpressionMultiple": AsEmbarkExpressionMultiple.selections],
      default: [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      ]
    )
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public static func makeEmbarkExpressionUnary(expressionUnaryType: EmbarkExpressionTypeUnary, text: String? = nil) -> ExpressionFragment {
    return ExpressionFragment(unsafeResultMap: ["__typename": "EmbarkExpressionUnary", "expressionUnaryType": expressionUnaryType, "text": text])
  }

  public static func makeEmbarkExpressionBinary(expressionBinaryType: EmbarkExpressionTypeBinary, key: String, value: String, text: String? = nil) -> ExpressionFragment {
    return ExpressionFragment(unsafeResultMap: ["__typename": "EmbarkExpressionBinary", "expressionBinaryType": expressionBinaryType, "key": key, "value": value, "text": text])
  }

  public static func makeEmbarkExpressionMultiple(expressionMultipleType: EmbarkExpressionTypeMultiple, text: String? = nil, subExpressions: [AsEmbarkExpressionMultiple.SubExpression]) -> ExpressionFragment {
    return ExpressionFragment(unsafeResultMap: ["__typename": "EmbarkExpressionMultiple", "expressionMultipleType": expressionMultipleType, "text": text, "subExpressions": subExpressions.map { (value: AsEmbarkExpressionMultiple.SubExpression) -> ResultMap in value.resultMap }])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var fragments: Fragments {
    get {
      return Fragments(unsafeResultMap: resultMap)
    }
    set {
      resultMap += newValue.resultMap
    }
  }

  public struct Fragments {
    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public var basicExpressionFragment: BasicExpressionFragment {
      get {
        return BasicExpressionFragment(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }
  }

  public var asEmbarkExpressionUnary: AsEmbarkExpressionUnary? {
    get {
      if !AsEmbarkExpressionUnary.possibleTypes.contains(__typename) { return nil }
      return AsEmbarkExpressionUnary(unsafeResultMap: resultMap)
    }
    set {
      guard let newValue = newValue else { return }
      resultMap = newValue.resultMap
    }
  }

  public struct AsEmbarkExpressionUnary: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["EmbarkExpressionUnary"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("type", alias: "expressionUnaryType", type: .nonNull(.scalar(EmbarkExpressionTypeUnary.self))),
      GraphQLField("text", type: .scalar(String.self)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(expressionUnaryType: EmbarkExpressionTypeUnary, text: String? = nil) {
      self.init(unsafeResultMap: ["__typename": "EmbarkExpressionUnary", "expressionUnaryType": expressionUnaryType, "text": text])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var expressionUnaryType: EmbarkExpressionTypeUnary {
      get {
        return resultMap["expressionUnaryType"]! as! EmbarkExpressionTypeUnary
      }
      set {
        resultMap.updateValue(newValue, forKey: "expressionUnaryType")
      }
    }

    public var text: String? {
      get {
        return resultMap["text"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "text")
      }
    }

    public var fragments: Fragments {
      get {
        return Fragments(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }

    public struct Fragments {
      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var basicExpressionFragment: BasicExpressionFragment {
        get {
          return BasicExpressionFragment(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }
    }
  }

  public var asEmbarkExpressionBinary: AsEmbarkExpressionBinary? {
    get {
      if !AsEmbarkExpressionBinary.possibleTypes.contains(__typename) { return nil }
      return AsEmbarkExpressionBinary(unsafeResultMap: resultMap)
    }
    set {
      guard let newValue = newValue else { return }
      resultMap = newValue.resultMap
    }
  }

  public struct AsEmbarkExpressionBinary: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["EmbarkExpressionBinary"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("type", alias: "expressionBinaryType", type: .nonNull(.scalar(EmbarkExpressionTypeBinary.self))),
      GraphQLField("key", type: .nonNull(.scalar(String.self))),
      GraphQLField("value", type: .nonNull(.scalar(String.self))),
      GraphQLField("text", type: .scalar(String.self)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(expressionBinaryType: EmbarkExpressionTypeBinary, key: String, value: String, text: String? = nil) {
      self.init(unsafeResultMap: ["__typename": "EmbarkExpressionBinary", "expressionBinaryType": expressionBinaryType, "key": key, "value": value, "text": text])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var expressionBinaryType: EmbarkExpressionTypeBinary {
      get {
        return resultMap["expressionBinaryType"]! as! EmbarkExpressionTypeBinary
      }
      set {
        resultMap.updateValue(newValue, forKey: "expressionBinaryType")
      }
    }

    public var key: String {
      get {
        return resultMap["key"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "key")
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

    public var text: String? {
      get {
        return resultMap["text"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "text")
      }
    }

    public var fragments: Fragments {
      get {
        return Fragments(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }

    public struct Fragments {
      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var basicExpressionFragment: BasicExpressionFragment {
        get {
          return BasicExpressionFragment(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }
    }
  }

  public var asEmbarkExpressionMultiple: AsEmbarkExpressionMultiple? {
    get {
      if !AsEmbarkExpressionMultiple.possibleTypes.contains(__typename) { return nil }
      return AsEmbarkExpressionMultiple(unsafeResultMap: resultMap)
    }
    set {
      guard let newValue = newValue else { return }
      resultMap = newValue.resultMap
    }
  }

  public struct AsEmbarkExpressionMultiple: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["EmbarkExpressionMultiple"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("type", alias: "expressionMultipleType", type: .nonNull(.scalar(EmbarkExpressionTypeMultiple.self))),
      GraphQLField("text", type: .scalar(String.self)),
      GraphQLField("subExpressions", type: .nonNull(.list(.nonNull(.object(SubExpression.selections))))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(expressionMultipleType: EmbarkExpressionTypeMultiple, text: String? = nil, subExpressions: [SubExpression]) {
      self.init(unsafeResultMap: ["__typename": "EmbarkExpressionMultiple", "expressionMultipleType": expressionMultipleType, "text": text, "subExpressions": subExpressions.map { (value: SubExpression) -> ResultMap in value.resultMap }])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var expressionMultipleType: EmbarkExpressionTypeMultiple {
      get {
        return resultMap["expressionMultipleType"]! as! EmbarkExpressionTypeMultiple
      }
      set {
        resultMap.updateValue(newValue, forKey: "expressionMultipleType")
      }
    }

    public var text: String? {
      get {
        return resultMap["text"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "text")
      }
    }

    public var subExpressions: [SubExpression] {
      get {
        return (resultMap["subExpressions"] as! [ResultMap]).map { (value: ResultMap) -> SubExpression in SubExpression(unsafeResultMap: value) }
      }
      set {
        resultMap.updateValue(newValue.map { (value: SubExpression) -> ResultMap in value.resultMap }, forKey: "subExpressions")
      }
    }

    public var fragments: Fragments {
      get {
        return Fragments(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }

    public struct Fragments {
      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var basicExpressionFragment: BasicExpressionFragment {
        get {
          return BasicExpressionFragment(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }
    }

    public struct SubExpression: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["EmbarkExpressionUnary", "EmbarkExpressionBinary", "EmbarkExpressionMultiple"]

      public static let selections: [GraphQLSelection] = [
        GraphQLTypeCase(
          variants: ["EmbarkExpressionUnary": AsEmbarkExpressionUnary.selections, "EmbarkExpressionBinary": AsEmbarkExpressionBinary.selections],
          default: [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          ]
        )
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeEmbarkExpressionMultiple() -> SubExpression {
        return SubExpression(unsafeResultMap: ["__typename": "EmbarkExpressionMultiple"])
      }

      public static func makeEmbarkExpressionUnary(expressionUnaryType: EmbarkExpressionTypeUnary, text: String? = nil) -> SubExpression {
        return SubExpression(unsafeResultMap: ["__typename": "EmbarkExpressionUnary", "expressionUnaryType": expressionUnaryType, "text": text])
      }

      public static func makeEmbarkExpressionBinary(expressionBinaryType: EmbarkExpressionTypeBinary, key: String, value: String, text: String? = nil) -> SubExpression {
        return SubExpression(unsafeResultMap: ["__typename": "EmbarkExpressionBinary", "expressionBinaryType": expressionBinaryType, "key": key, "value": value, "text": text])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var basicExpressionFragment: BasicExpressionFragment {
          get {
            return BasicExpressionFragment(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }

      public var asEmbarkExpressionUnary: AsEmbarkExpressionUnary? {
        get {
          if !AsEmbarkExpressionUnary.possibleTypes.contains(__typename) { return nil }
          return AsEmbarkExpressionUnary(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap = newValue.resultMap
        }
      }

      public struct AsEmbarkExpressionUnary: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["EmbarkExpressionUnary"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("type", alias: "expressionUnaryType", type: .nonNull(.scalar(EmbarkExpressionTypeUnary.self))),
          GraphQLField("text", type: .scalar(String.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(expressionUnaryType: EmbarkExpressionTypeUnary, text: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "EmbarkExpressionUnary", "expressionUnaryType": expressionUnaryType, "text": text])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var expressionUnaryType: EmbarkExpressionTypeUnary {
          get {
            return resultMap["expressionUnaryType"]! as! EmbarkExpressionTypeUnary
          }
          set {
            resultMap.updateValue(newValue, forKey: "expressionUnaryType")
          }
        }

        public var text: String? {
          get {
            return resultMap["text"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "text")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var basicExpressionFragment: BasicExpressionFragment {
            get {
              return BasicExpressionFragment(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }
      }

      public var asEmbarkExpressionBinary: AsEmbarkExpressionBinary? {
        get {
          if !AsEmbarkExpressionBinary.possibleTypes.contains(__typename) { return nil }
          return AsEmbarkExpressionBinary(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap = newValue.resultMap
        }
      }

      public struct AsEmbarkExpressionBinary: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["EmbarkExpressionBinary"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("type", alias: "expressionBinaryType", type: .nonNull(.scalar(EmbarkExpressionTypeBinary.self))),
          GraphQLField("key", type: .nonNull(.scalar(String.self))),
          GraphQLField("value", type: .nonNull(.scalar(String.self))),
          GraphQLField("text", type: .scalar(String.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(expressionBinaryType: EmbarkExpressionTypeBinary, key: String, value: String, text: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "EmbarkExpressionBinary", "expressionBinaryType": expressionBinaryType, "key": key, "value": value, "text": text])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var expressionBinaryType: EmbarkExpressionTypeBinary {
          get {
            return resultMap["expressionBinaryType"]! as! EmbarkExpressionTypeBinary
          }
          set {
            resultMap.updateValue(newValue, forKey: "expressionBinaryType")
          }
        }

        public var key: String {
          get {
            return resultMap["key"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "key")
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

        public var text: String? {
          get {
            return resultMap["text"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "text")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var basicExpressionFragment: BasicExpressionFragment {
            get {
              return BasicExpressionFragment(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }
      }
    }
  }
}

public struct ResponseFragment: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment ResponseFragment on EmbarkResponse {
      __typename
      ... on EmbarkMessage {
        ...MessageFragment
      }
      ... on EmbarkGroupedResponse {
        component
        items {
          __typename
          ...MessageFragment
        }
        title {
          __typename
          text
        }
      }
    }
    """

  public static let possibleTypes: [String] = ["EmbarkGroupedResponse", "EmbarkResponseExpression", "EmbarkMessage"]

  public static let selections: [GraphQLSelection] = [
    GraphQLTypeCase(
      variants: ["EmbarkMessage": AsEmbarkMessage.selections, "EmbarkGroupedResponse": AsEmbarkGroupedResponse.selections],
      default: [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      ]
    )
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public static func makeEmbarkResponseExpression() -> ResponseFragment {
    return ResponseFragment(unsafeResultMap: ["__typename": "EmbarkResponseExpression"])
  }

  public static func makeEmbarkMessage(text: String, expressions: [AsEmbarkMessage.Expression]) -> ResponseFragment {
    return ResponseFragment(unsafeResultMap: ["__typename": "EmbarkMessage", "text": text, "expressions": expressions.map { (value: AsEmbarkMessage.Expression) -> ResultMap in value.resultMap }])
  }

  public static func makeEmbarkGroupedResponse(component: String, items: [AsEmbarkGroupedResponse.Item], title: AsEmbarkGroupedResponse.Title) -> ResponseFragment {
    return ResponseFragment(unsafeResultMap: ["__typename": "EmbarkGroupedResponse", "component": component, "items": items.map { (value: AsEmbarkGroupedResponse.Item) -> ResultMap in value.resultMap }, "title": title.resultMap])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var asEmbarkMessage: AsEmbarkMessage? {
    get {
      if !AsEmbarkMessage.possibleTypes.contains(__typename) { return nil }
      return AsEmbarkMessage(unsafeResultMap: resultMap)
    }
    set {
      guard let newValue = newValue else { return }
      resultMap = newValue.resultMap
    }
  }

  public struct AsEmbarkMessage: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["EmbarkMessage"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("text", type: .nonNull(.scalar(String.self))),
      GraphQLField("expressions", type: .nonNull(.list(.nonNull(.object(Expression.selections))))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(text: String, expressions: [Expression]) {
      self.init(unsafeResultMap: ["__typename": "EmbarkMessage", "text": text, "expressions": expressions.map { (value: Expression) -> ResultMap in value.resultMap }])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
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

    public var expressions: [Expression] {
      get {
        return (resultMap["expressions"] as! [ResultMap]).map { (value: ResultMap) -> Expression in Expression(unsafeResultMap: value) }
      }
      set {
        resultMap.updateValue(newValue.map { (value: Expression) -> ResultMap in value.resultMap }, forKey: "expressions")
      }
    }

    public var fragments: Fragments {
      get {
        return Fragments(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }

    public struct Fragments {
      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var messageFragment: MessageFragment {
        get {
          return MessageFragment(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }
    }

    public struct Expression: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["EmbarkExpressionUnary", "EmbarkExpressionBinary", "EmbarkExpressionMultiple"]

      public static let selections: [GraphQLSelection] = [
        GraphQLTypeCase(
          variants: ["EmbarkExpressionUnary": AsEmbarkExpressionUnary.selections, "EmbarkExpressionBinary": AsEmbarkExpressionBinary.selections, "EmbarkExpressionMultiple": AsEmbarkExpressionMultiple.selections],
          default: [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          ]
        )
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeEmbarkExpressionUnary(expressionUnaryType: EmbarkExpressionTypeUnary, text: String? = nil) -> Expression {
        return Expression(unsafeResultMap: ["__typename": "EmbarkExpressionUnary", "expressionUnaryType": expressionUnaryType, "text": text])
      }

      public static func makeEmbarkExpressionBinary(expressionBinaryType: EmbarkExpressionTypeBinary, key: String, value: String, text: String? = nil) -> Expression {
        return Expression(unsafeResultMap: ["__typename": "EmbarkExpressionBinary", "expressionBinaryType": expressionBinaryType, "key": key, "value": value, "text": text])
      }

      public static func makeEmbarkExpressionMultiple(expressionMultipleType: EmbarkExpressionTypeMultiple, text: String? = nil, subExpressions: [AsEmbarkExpressionMultiple.SubExpression]) -> Expression {
        return Expression(unsafeResultMap: ["__typename": "EmbarkExpressionMultiple", "expressionMultipleType": expressionMultipleType, "text": text, "subExpressions": subExpressions.map { (value: AsEmbarkExpressionMultiple.SubExpression) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var expressionFragment: ExpressionFragment {
          get {
            return ExpressionFragment(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public var basicExpressionFragment: BasicExpressionFragment {
          get {
            return BasicExpressionFragment(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }

      public var asEmbarkExpressionUnary: AsEmbarkExpressionUnary? {
        get {
          if !AsEmbarkExpressionUnary.possibleTypes.contains(__typename) { return nil }
          return AsEmbarkExpressionUnary(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap = newValue.resultMap
        }
      }

      public struct AsEmbarkExpressionUnary: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["EmbarkExpressionUnary"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("type", alias: "expressionUnaryType", type: .nonNull(.scalar(EmbarkExpressionTypeUnary.self))),
          GraphQLField("text", type: .scalar(String.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(expressionUnaryType: EmbarkExpressionTypeUnary, text: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "EmbarkExpressionUnary", "expressionUnaryType": expressionUnaryType, "text": text])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var expressionUnaryType: EmbarkExpressionTypeUnary {
          get {
            return resultMap["expressionUnaryType"]! as! EmbarkExpressionTypeUnary
          }
          set {
            resultMap.updateValue(newValue, forKey: "expressionUnaryType")
          }
        }

        public var text: String? {
          get {
            return resultMap["text"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "text")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var expressionFragment: ExpressionFragment {
            get {
              return ExpressionFragment(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public var basicExpressionFragment: BasicExpressionFragment {
            get {
              return BasicExpressionFragment(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }
      }

      public var asEmbarkExpressionBinary: AsEmbarkExpressionBinary? {
        get {
          if !AsEmbarkExpressionBinary.possibleTypes.contains(__typename) { return nil }
          return AsEmbarkExpressionBinary(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap = newValue.resultMap
        }
      }

      public struct AsEmbarkExpressionBinary: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["EmbarkExpressionBinary"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("type", alias: "expressionBinaryType", type: .nonNull(.scalar(EmbarkExpressionTypeBinary.self))),
          GraphQLField("key", type: .nonNull(.scalar(String.self))),
          GraphQLField("value", type: .nonNull(.scalar(String.self))),
          GraphQLField("text", type: .scalar(String.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(expressionBinaryType: EmbarkExpressionTypeBinary, key: String, value: String, text: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "EmbarkExpressionBinary", "expressionBinaryType": expressionBinaryType, "key": key, "value": value, "text": text])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var expressionBinaryType: EmbarkExpressionTypeBinary {
          get {
            return resultMap["expressionBinaryType"]! as! EmbarkExpressionTypeBinary
          }
          set {
            resultMap.updateValue(newValue, forKey: "expressionBinaryType")
          }
        }

        public var key: String {
          get {
            return resultMap["key"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "key")
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

        public var text: String? {
          get {
            return resultMap["text"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "text")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var expressionFragment: ExpressionFragment {
            get {
              return ExpressionFragment(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public var basicExpressionFragment: BasicExpressionFragment {
            get {
              return BasicExpressionFragment(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }
      }

      public var asEmbarkExpressionMultiple: AsEmbarkExpressionMultiple? {
        get {
          if !AsEmbarkExpressionMultiple.possibleTypes.contains(__typename) { return nil }
          return AsEmbarkExpressionMultiple(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap = newValue.resultMap
        }
      }

      public struct AsEmbarkExpressionMultiple: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["EmbarkExpressionMultiple"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("type", alias: "expressionMultipleType", type: .nonNull(.scalar(EmbarkExpressionTypeMultiple.self))),
          GraphQLField("text", type: .scalar(String.self)),
          GraphQLField("subExpressions", type: .nonNull(.list(.nonNull(.object(SubExpression.selections))))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(expressionMultipleType: EmbarkExpressionTypeMultiple, text: String? = nil, subExpressions: [SubExpression]) {
          self.init(unsafeResultMap: ["__typename": "EmbarkExpressionMultiple", "expressionMultipleType": expressionMultipleType, "text": text, "subExpressions": subExpressions.map { (value: SubExpression) -> ResultMap in value.resultMap }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var expressionMultipleType: EmbarkExpressionTypeMultiple {
          get {
            return resultMap["expressionMultipleType"]! as! EmbarkExpressionTypeMultiple
          }
          set {
            resultMap.updateValue(newValue, forKey: "expressionMultipleType")
          }
        }

        public var text: String? {
          get {
            return resultMap["text"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "text")
          }
        }

        public var subExpressions: [SubExpression] {
          get {
            return (resultMap["subExpressions"] as! [ResultMap]).map { (value: ResultMap) -> SubExpression in SubExpression(unsafeResultMap: value) }
          }
          set {
            resultMap.updateValue(newValue.map { (value: SubExpression) -> ResultMap in value.resultMap }, forKey: "subExpressions")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var expressionFragment: ExpressionFragment {
            get {
              return ExpressionFragment(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public var basicExpressionFragment: BasicExpressionFragment {
            get {
              return BasicExpressionFragment(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }

        public struct SubExpression: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["EmbarkExpressionUnary", "EmbarkExpressionBinary", "EmbarkExpressionMultiple"]

          public static let selections: [GraphQLSelection] = [
            GraphQLTypeCase(
              variants: ["EmbarkExpressionUnary": AsEmbarkExpressionUnary.selections, "EmbarkExpressionBinary": AsEmbarkExpressionBinary.selections],
              default: [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              ]
            )
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public static func makeEmbarkExpressionMultiple() -> SubExpression {
            return SubExpression(unsafeResultMap: ["__typename": "EmbarkExpressionMultiple"])
          }

          public static func makeEmbarkExpressionUnary(expressionUnaryType: EmbarkExpressionTypeUnary, text: String? = nil) -> SubExpression {
            return SubExpression(unsafeResultMap: ["__typename": "EmbarkExpressionUnary", "expressionUnaryType": expressionUnaryType, "text": text])
          }

          public static func makeEmbarkExpressionBinary(expressionBinaryType: EmbarkExpressionTypeBinary, key: String, value: String, text: String? = nil) -> SubExpression {
            return SubExpression(unsafeResultMap: ["__typename": "EmbarkExpressionBinary", "expressionBinaryType": expressionBinaryType, "key": key, "value": value, "text": text])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public struct Fragments {
            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var basicExpressionFragment: BasicExpressionFragment {
              get {
                return BasicExpressionFragment(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }

          public var asEmbarkExpressionUnary: AsEmbarkExpressionUnary? {
            get {
              if !AsEmbarkExpressionUnary.possibleTypes.contains(__typename) { return nil }
              return AsEmbarkExpressionUnary(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap = newValue.resultMap
            }
          }

          public struct AsEmbarkExpressionUnary: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["EmbarkExpressionUnary"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("type", alias: "expressionUnaryType", type: .nonNull(.scalar(EmbarkExpressionTypeUnary.self))),
              GraphQLField("text", type: .scalar(String.self)),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(expressionUnaryType: EmbarkExpressionTypeUnary, text: String? = nil) {
              self.init(unsafeResultMap: ["__typename": "EmbarkExpressionUnary", "expressionUnaryType": expressionUnaryType, "text": text])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var expressionUnaryType: EmbarkExpressionTypeUnary {
              get {
                return resultMap["expressionUnaryType"]! as! EmbarkExpressionTypeUnary
              }
              set {
                resultMap.updateValue(newValue, forKey: "expressionUnaryType")
              }
            }

            public var text: String? {
              get {
                return resultMap["text"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "text")
              }
            }

            public var fragments: Fragments {
              get {
                return Fragments(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public struct Fragments {
              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public var basicExpressionFragment: BasicExpressionFragment {
                get {
                  return BasicExpressionFragment(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
              }
            }
          }

          public var asEmbarkExpressionBinary: AsEmbarkExpressionBinary? {
            get {
              if !AsEmbarkExpressionBinary.possibleTypes.contains(__typename) { return nil }
              return AsEmbarkExpressionBinary(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap = newValue.resultMap
            }
          }

          public struct AsEmbarkExpressionBinary: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["EmbarkExpressionBinary"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("type", alias: "expressionBinaryType", type: .nonNull(.scalar(EmbarkExpressionTypeBinary.self))),
              GraphQLField("key", type: .nonNull(.scalar(String.self))),
              GraphQLField("value", type: .nonNull(.scalar(String.self))),
              GraphQLField("text", type: .scalar(String.self)),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(expressionBinaryType: EmbarkExpressionTypeBinary, key: String, value: String, text: String? = nil) {
              self.init(unsafeResultMap: ["__typename": "EmbarkExpressionBinary", "expressionBinaryType": expressionBinaryType, "key": key, "value": value, "text": text])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var expressionBinaryType: EmbarkExpressionTypeBinary {
              get {
                return resultMap["expressionBinaryType"]! as! EmbarkExpressionTypeBinary
              }
              set {
                resultMap.updateValue(newValue, forKey: "expressionBinaryType")
              }
            }

            public var key: String {
              get {
                return resultMap["key"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "key")
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

            public var text: String? {
              get {
                return resultMap["text"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "text")
              }
            }

            public var fragments: Fragments {
              get {
                return Fragments(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public struct Fragments {
              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public var basicExpressionFragment: BasicExpressionFragment {
                get {
                  return BasicExpressionFragment(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
              }
            }
          }
        }
      }
    }
  }

  public var asEmbarkGroupedResponse: AsEmbarkGroupedResponse? {
    get {
      if !AsEmbarkGroupedResponse.possibleTypes.contains(__typename) { return nil }
      return AsEmbarkGroupedResponse(unsafeResultMap: resultMap)
    }
    set {
      guard let newValue = newValue else { return }
      resultMap = newValue.resultMap
    }
  }

  public struct AsEmbarkGroupedResponse: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["EmbarkGroupedResponse"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("component", type: .nonNull(.scalar(String.self))),
      GraphQLField("items", type: .nonNull(.list(.nonNull(.object(Item.selections))))),
      GraphQLField("title", type: .nonNull(.object(Title.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(component: String, items: [Item], title: Title) {
      self.init(unsafeResultMap: ["__typename": "EmbarkGroupedResponse", "component": component, "items": items.map { (value: Item) -> ResultMap in value.resultMap }, "title": title.resultMap])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var component: String {
      get {
        return resultMap["component"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "component")
      }
    }

    public var items: [Item] {
      get {
        return (resultMap["items"] as! [ResultMap]).map { (value: ResultMap) -> Item in Item(unsafeResultMap: value) }
      }
      set {
        resultMap.updateValue(newValue.map { (value: Item) -> ResultMap in value.resultMap }, forKey: "items")
      }
    }

    public var title: Title {
      get {
        return Title(unsafeResultMap: resultMap["title"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "title")
      }
    }

    public struct Item: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["EmbarkMessage"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("text", type: .nonNull(.scalar(String.self))),
        GraphQLField("expressions", type: .nonNull(.list(.nonNull(.object(Expression.selections))))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(text: String, expressions: [Expression]) {
        self.init(unsafeResultMap: ["__typename": "EmbarkMessage", "text": text, "expressions": expressions.map { (value: Expression) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
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

      public var expressions: [Expression] {
        get {
          return (resultMap["expressions"] as! [ResultMap]).map { (value: ResultMap) -> Expression in Expression(unsafeResultMap: value) }
        }
        set {
          resultMap.updateValue(newValue.map { (value: Expression) -> ResultMap in value.resultMap }, forKey: "expressions")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var messageFragment: MessageFragment {
          get {
            return MessageFragment(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }

      public struct Expression: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["EmbarkExpressionUnary", "EmbarkExpressionBinary", "EmbarkExpressionMultiple"]

        public static let selections: [GraphQLSelection] = [
          GraphQLTypeCase(
            variants: ["EmbarkExpressionUnary": AsEmbarkExpressionUnary.selections, "EmbarkExpressionBinary": AsEmbarkExpressionBinary.selections, "EmbarkExpressionMultiple": AsEmbarkExpressionMultiple.selections],
            default: [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            ]
          )
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public static func makeEmbarkExpressionUnary(expressionUnaryType: EmbarkExpressionTypeUnary, text: String? = nil) -> Expression {
          return Expression(unsafeResultMap: ["__typename": "EmbarkExpressionUnary", "expressionUnaryType": expressionUnaryType, "text": text])
        }

        public static func makeEmbarkExpressionBinary(expressionBinaryType: EmbarkExpressionTypeBinary, key: String, value: String, text: String? = nil) -> Expression {
          return Expression(unsafeResultMap: ["__typename": "EmbarkExpressionBinary", "expressionBinaryType": expressionBinaryType, "key": key, "value": value, "text": text])
        }

        public static func makeEmbarkExpressionMultiple(expressionMultipleType: EmbarkExpressionTypeMultiple, text: String? = nil, subExpressions: [AsEmbarkExpressionMultiple.SubExpression]) -> Expression {
          return Expression(unsafeResultMap: ["__typename": "EmbarkExpressionMultiple", "expressionMultipleType": expressionMultipleType, "text": text, "subExpressions": subExpressions.map { (value: AsEmbarkExpressionMultiple.SubExpression) -> ResultMap in value.resultMap }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var expressionFragment: ExpressionFragment {
            get {
              return ExpressionFragment(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public var basicExpressionFragment: BasicExpressionFragment {
            get {
              return BasicExpressionFragment(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }

        public var asEmbarkExpressionUnary: AsEmbarkExpressionUnary? {
          get {
            if !AsEmbarkExpressionUnary.possibleTypes.contains(__typename) { return nil }
            return AsEmbarkExpressionUnary(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsEmbarkExpressionUnary: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["EmbarkExpressionUnary"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("type", alias: "expressionUnaryType", type: .nonNull(.scalar(EmbarkExpressionTypeUnary.self))),
            GraphQLField("text", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(expressionUnaryType: EmbarkExpressionTypeUnary, text: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "EmbarkExpressionUnary", "expressionUnaryType": expressionUnaryType, "text": text])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var expressionUnaryType: EmbarkExpressionTypeUnary {
            get {
              return resultMap["expressionUnaryType"]! as! EmbarkExpressionTypeUnary
            }
            set {
              resultMap.updateValue(newValue, forKey: "expressionUnaryType")
            }
          }

          public var text: String? {
            get {
              return resultMap["text"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "text")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public struct Fragments {
            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var expressionFragment: ExpressionFragment {
              get {
                return ExpressionFragment(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public var basicExpressionFragment: BasicExpressionFragment {
              get {
                return BasicExpressionFragment(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }
        }

        public var asEmbarkExpressionBinary: AsEmbarkExpressionBinary? {
          get {
            if !AsEmbarkExpressionBinary.possibleTypes.contains(__typename) { return nil }
            return AsEmbarkExpressionBinary(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsEmbarkExpressionBinary: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["EmbarkExpressionBinary"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("type", alias: "expressionBinaryType", type: .nonNull(.scalar(EmbarkExpressionTypeBinary.self))),
            GraphQLField("key", type: .nonNull(.scalar(String.self))),
            GraphQLField("value", type: .nonNull(.scalar(String.self))),
            GraphQLField("text", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(expressionBinaryType: EmbarkExpressionTypeBinary, key: String, value: String, text: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "EmbarkExpressionBinary", "expressionBinaryType": expressionBinaryType, "key": key, "value": value, "text": text])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var expressionBinaryType: EmbarkExpressionTypeBinary {
            get {
              return resultMap["expressionBinaryType"]! as! EmbarkExpressionTypeBinary
            }
            set {
              resultMap.updateValue(newValue, forKey: "expressionBinaryType")
            }
          }

          public var key: String {
            get {
              return resultMap["key"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "key")
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

          public var text: String? {
            get {
              return resultMap["text"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "text")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public struct Fragments {
            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var expressionFragment: ExpressionFragment {
              get {
                return ExpressionFragment(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public var basicExpressionFragment: BasicExpressionFragment {
              get {
                return BasicExpressionFragment(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }
        }

        public var asEmbarkExpressionMultiple: AsEmbarkExpressionMultiple? {
          get {
            if !AsEmbarkExpressionMultiple.possibleTypes.contains(__typename) { return nil }
            return AsEmbarkExpressionMultiple(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsEmbarkExpressionMultiple: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["EmbarkExpressionMultiple"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("type", alias: "expressionMultipleType", type: .nonNull(.scalar(EmbarkExpressionTypeMultiple.self))),
            GraphQLField("text", type: .scalar(String.self)),
            GraphQLField("subExpressions", type: .nonNull(.list(.nonNull(.object(SubExpression.selections))))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(expressionMultipleType: EmbarkExpressionTypeMultiple, text: String? = nil, subExpressions: [SubExpression]) {
            self.init(unsafeResultMap: ["__typename": "EmbarkExpressionMultiple", "expressionMultipleType": expressionMultipleType, "text": text, "subExpressions": subExpressions.map { (value: SubExpression) -> ResultMap in value.resultMap }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var expressionMultipleType: EmbarkExpressionTypeMultiple {
            get {
              return resultMap["expressionMultipleType"]! as! EmbarkExpressionTypeMultiple
            }
            set {
              resultMap.updateValue(newValue, forKey: "expressionMultipleType")
            }
          }

          public var text: String? {
            get {
              return resultMap["text"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "text")
            }
          }

          public var subExpressions: [SubExpression] {
            get {
              return (resultMap["subExpressions"] as! [ResultMap]).map { (value: ResultMap) -> SubExpression in SubExpression(unsafeResultMap: value) }
            }
            set {
              resultMap.updateValue(newValue.map { (value: SubExpression) -> ResultMap in value.resultMap }, forKey: "subExpressions")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public struct Fragments {
            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var expressionFragment: ExpressionFragment {
              get {
                return ExpressionFragment(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public var basicExpressionFragment: BasicExpressionFragment {
              get {
                return BasicExpressionFragment(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }

          public struct SubExpression: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["EmbarkExpressionUnary", "EmbarkExpressionBinary", "EmbarkExpressionMultiple"]

            public static let selections: [GraphQLSelection] = [
              GraphQLTypeCase(
                variants: ["EmbarkExpressionUnary": AsEmbarkExpressionUnary.selections, "EmbarkExpressionBinary": AsEmbarkExpressionBinary.selections],
                default: [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                ]
              )
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public static func makeEmbarkExpressionMultiple() -> SubExpression {
              return SubExpression(unsafeResultMap: ["__typename": "EmbarkExpressionMultiple"])
            }

            public static func makeEmbarkExpressionUnary(expressionUnaryType: EmbarkExpressionTypeUnary, text: String? = nil) -> SubExpression {
              return SubExpression(unsafeResultMap: ["__typename": "EmbarkExpressionUnary", "expressionUnaryType": expressionUnaryType, "text": text])
            }

            public static func makeEmbarkExpressionBinary(expressionBinaryType: EmbarkExpressionTypeBinary, key: String, value: String, text: String? = nil) -> SubExpression {
              return SubExpression(unsafeResultMap: ["__typename": "EmbarkExpressionBinary", "expressionBinaryType": expressionBinaryType, "key": key, "value": value, "text": text])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var fragments: Fragments {
              get {
                return Fragments(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public struct Fragments {
              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public var basicExpressionFragment: BasicExpressionFragment {
                get {
                  return BasicExpressionFragment(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
              }
            }

            public var asEmbarkExpressionUnary: AsEmbarkExpressionUnary? {
              get {
                if !AsEmbarkExpressionUnary.possibleTypes.contains(__typename) { return nil }
                return AsEmbarkExpressionUnary(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap = newValue.resultMap
              }
            }

            public struct AsEmbarkExpressionUnary: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["EmbarkExpressionUnary"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("type", alias: "expressionUnaryType", type: .nonNull(.scalar(EmbarkExpressionTypeUnary.self))),
                GraphQLField("text", type: .scalar(String.self)),
              ]

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(expressionUnaryType: EmbarkExpressionTypeUnary, text: String? = nil) {
                self.init(unsafeResultMap: ["__typename": "EmbarkExpressionUnary", "expressionUnaryType": expressionUnaryType, "text": text])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var expressionUnaryType: EmbarkExpressionTypeUnary {
                get {
                  return resultMap["expressionUnaryType"]! as! EmbarkExpressionTypeUnary
                }
                set {
                  resultMap.updateValue(newValue, forKey: "expressionUnaryType")
                }
              }

              public var text: String? {
                get {
                  return resultMap["text"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "text")
                }
              }

              public var fragments: Fragments {
                get {
                  return Fragments(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
              }

              public struct Fragments {
                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public var basicExpressionFragment: BasicExpressionFragment {
                  get {
                    return BasicExpressionFragment(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }
              }
            }

            public var asEmbarkExpressionBinary: AsEmbarkExpressionBinary? {
              get {
                if !AsEmbarkExpressionBinary.possibleTypes.contains(__typename) { return nil }
                return AsEmbarkExpressionBinary(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap = newValue.resultMap
              }
            }

            public struct AsEmbarkExpressionBinary: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["EmbarkExpressionBinary"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("type", alias: "expressionBinaryType", type: .nonNull(.scalar(EmbarkExpressionTypeBinary.self))),
                GraphQLField("key", type: .nonNull(.scalar(String.self))),
                GraphQLField("value", type: .nonNull(.scalar(String.self))),
                GraphQLField("text", type: .scalar(String.self)),
              ]

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(expressionBinaryType: EmbarkExpressionTypeBinary, key: String, value: String, text: String? = nil) {
                self.init(unsafeResultMap: ["__typename": "EmbarkExpressionBinary", "expressionBinaryType": expressionBinaryType, "key": key, "value": value, "text": text])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var expressionBinaryType: EmbarkExpressionTypeBinary {
                get {
                  return resultMap["expressionBinaryType"]! as! EmbarkExpressionTypeBinary
                }
                set {
                  resultMap.updateValue(newValue, forKey: "expressionBinaryType")
                }
              }

              public var key: String {
                get {
                  return resultMap["key"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "key")
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

              public var text: String? {
                get {
                  return resultMap["text"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "text")
                }
              }

              public var fragments: Fragments {
                get {
                  return Fragments(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
              }

              public struct Fragments {
                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public var basicExpressionFragment: BasicExpressionFragment {
                  get {
                    return BasicExpressionFragment(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }
              }
            }
          }
        }
      }
    }

    public struct Title: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["EmbarkResponseExpression"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("text", type: .nonNull(.scalar(String.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(text: String) {
        self.init(unsafeResultMap: ["__typename": "EmbarkResponseExpression", "text": text])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
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
    }
  }
}
