//  This file was automatically generated and should not be edited.

import Apollo

public struct ChatResponseTextInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(globalId: GraphQLID, body: ChatResponseBodyTextInput) {
    graphQLMap = ["globalId": globalId, "body": body]
  }

  public var globalId: GraphQLID {
    get {
      return graphQLMap["globalId"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "globalId")
    }
  }

  public var body: ChatResponseBodyTextInput {
    get {
      return graphQLMap["body"] as! ChatResponseBodyTextInput
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "body")
    }
  }
}

public struct ChatResponseBodyTextInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(text: String) {
    graphQLMap = ["text": text]
  }

  public var text: String {
    get {
      return graphQLMap["text"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "text")
    }
  }
}

public enum MessageBodyChoicesLinkView: RawRepresentable, Equatable, Hashable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case offer
  case dashboard
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "OFFER": self = .offer
      case "DASHBOARD": self = .dashboard
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .offer: return "OFFER"
      case .dashboard: return "DASHBOARD"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: MessageBodyChoicesLinkView, rhs: MessageBodyChoicesLinkView) -> Bool {
    switch (lhs, rhs) {
      case (.offer, .offer): return true
      case (.dashboard, .dashboard): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
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

public struct ChatResponseSingleSelectInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(globalId: GraphQLID, body: ChatResponseBodySingleSelectInput) {
    graphQLMap = ["globalId": globalId, "body": body]
  }

  public var globalId: GraphQLID {
    get {
      return graphQLMap["globalId"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "globalId")
    }
  }

  public var body: ChatResponseBodySingleSelectInput {
    get {
      return graphQLMap["body"] as! ChatResponseBodySingleSelectInput
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "body")
    }
  }
}

public struct ChatResponseBodySingleSelectInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(selectedValue: GraphQLID) {
    graphQLMap = ["selectedValue": selectedValue]
  }

  public var selectedValue: GraphQLID {
    get {
      return graphQLMap["selectedValue"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "selectedValue")
    }
  }
}

public final class MessagesQuery: GraphQLQuery {
  public let operationDefinition =
    "query messages {\n  messages {\n    __typename\n    globalId\n    header {\n      __typename\n      messageId\n      editAllowed\n      shouldRequestPushNotifications\n      timeStamp\n      richTextChatCompatible\n      fromMyself\n    }\n    body {\n      __typename\n      ...MessageBodyCoreFragment\n    }\n  }\n}"

  public var queryDocument: String { return operationDefinition.appending(MessageBodyCoreFragment.fragmentDefinition) }

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("messages", type: .nonNull(.list(.object(Message.selections)))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(messages: [Message?]) {
      self.init(unsafeResultMap: ["__typename": "Query", "messages": messages.map { (value: Message?) -> ResultMap? in value.flatMap { (value: Message) -> ResultMap in value.resultMap } }])
    }

    public var messages: [Message?] {
      get {
        return (resultMap["messages"] as! [ResultMap?]).map { (value: ResultMap?) -> Message? in value.flatMap { (value: ResultMap) -> Message in Message(unsafeResultMap: value) } }
      }
      set {
        resultMap.updateValue(newValue.map { (value: Message?) -> ResultMap? in value.flatMap { (value: Message) -> ResultMap in value.resultMap } }, forKey: "messages")
      }
    }

    public struct Message: GraphQLSelectionSet {
      public static let possibleTypes = ["Message"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("globalId", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("header", type: .nonNull(.object(Header.selections))),
        GraphQLField("body", type: .nonNull(.object(Body.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(globalId: GraphQLID, header: Header, body: Body) {
        self.init(unsafeResultMap: ["__typename": "Message", "globalId": globalId, "header": header.resultMap, "body": body.resultMap])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var globalId: GraphQLID {
        get {
          return resultMap["globalId"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "globalId")
        }
      }

      public var header: Header {
        get {
          return Header(unsafeResultMap: resultMap["header"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "header")
        }
      }

      public var body: Body {
        get {
          return Body(unsafeResultMap: resultMap["body"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "body")
        }
      }

      public struct Header: GraphQLSelectionSet {
        public static let possibleTypes = ["MessageHeader"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("messageId", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("editAllowed", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("shouldRequestPushNotifications", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("timeStamp", type: .nonNull(.scalar(String.self))),
          GraphQLField("richTextChatCompatible", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("fromMyself", type: .nonNull(.scalar(Bool.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(messageId: GraphQLID, editAllowed: Bool, shouldRequestPushNotifications: Bool, timeStamp: String, richTextChatCompatible: Bool, fromMyself: Bool) {
          self.init(unsafeResultMap: ["__typename": "MessageHeader", "messageId": messageId, "editAllowed": editAllowed, "shouldRequestPushNotifications": shouldRequestPushNotifications, "timeStamp": timeStamp, "richTextChatCompatible": richTextChatCompatible, "fromMyself": fromMyself])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var messageId: GraphQLID {
          get {
            return resultMap["messageId"]! as! GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "messageId")
          }
        }

        public var editAllowed: Bool {
          get {
            return resultMap["editAllowed"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "editAllowed")
          }
        }

        public var shouldRequestPushNotifications: Bool {
          get {
            return resultMap["shouldRequestPushNotifications"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "shouldRequestPushNotifications")
          }
        }

        public var timeStamp: String {
          get {
            return resultMap["timeStamp"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "timeStamp")
          }
        }

        public var richTextChatCompatible: Bool {
          get {
            return resultMap["richTextChatCompatible"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "richTextChatCompatible")
          }
        }

        public var fromMyself: Bool {
          get {
            return resultMap["fromMyself"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "fromMyself")
          }
        }
      }

      public struct Body: GraphQLSelectionSet {
        public static let possibleTypes = ["MessageBodySingleSelect", "MessageBodyMultipleSelect", "MessageBodyText", "MessageBodyNumber", "MessageBodyAudio", "MessageBodyBankIdCollect", "MessageBodyFile", "MessageBodyParagraph", "MessageBodyUndefined"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(MessageBodyCoreFragment.self),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public static func makeMessageBodySingleSelect(text: String) -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodySingleSelect", "text": text])
        }

        public static func makeMessageBodyMultipleSelect(text: String) -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyMultipleSelect", "text": text])
        }

        public static func makeMessageBodyText(text: String) -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyText", "text": text])
        }

        public static func makeMessageBodyNumber(text: String) -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyNumber", "text": text])
        }

        public static func makeMessageBodyAudio(text: String) -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyAudio", "text": text])
        }

        public static func makeMessageBodyBankIdCollect(text: String) -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyBankIdCollect", "text": text])
        }

        public static func makeMessageBodyFile(text: String) -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyFile", "text": text])
        }

        public static func makeMessageBodyParagraph(text: String) -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyParagraph", "text": text])
        }

        public static func makeMessageBodyUndefined(text: String) -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyUndefined", "text": text])
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

          public var messageBodyCoreFragment: MessageBodyCoreFragment {
            get {
              return MessageBodyCoreFragment(unsafeResultMap: resultMap)
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

public final class SendChatTextResponseMutation: GraphQLMutation {
  public let operationDefinition =
    "mutation SendChatTextResponse($input: ChatResponseTextInput!) {\n  sendChatTextResponse(input: $input)\n}"

  public var input: ChatResponseTextInput

  public init(input: ChatResponseTextInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("sendChatTextResponse", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.scalar(Bool.self))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(sendChatTextResponse: Bool) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "sendChatTextResponse": sendChatTextResponse])
    }

    public var sendChatTextResponse: Bool {
      get {
        return resultMap["sendChatTextResponse"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "sendChatTextResponse")
      }
    }
  }
}

public final class CurrentChatResponseSubscription: GraphQLSubscription {
  public let operationDefinition =
    "subscription CurrentChatResponse {\n  currentChatResponse {\n    __typename\n    globalId\n    body {\n      __typename\n      ...MessageBodySingleSelectFragment\n    }\n  }\n}"

  public var queryDocument: String { return operationDefinition.appending(MessageBodySingleSelectFragment.fragmentDefinition).appending(MessageBodyChoicesUndefinedFragment.fragmentDefinition).appending(MessageBodyChoicesCoreFragment.fragmentDefinition).appending(MessageBodyChoicesSelectionFragment.fragmentDefinition).appending(MessageBodyChoicesLinkFragment.fragmentDefinition) }

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("currentChatResponse", type: .object(CurrentChatResponse.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(currentChatResponse: CurrentChatResponse? = nil) {
      self.init(unsafeResultMap: ["__typename": "Subscription", "currentChatResponse": currentChatResponse.flatMap { (value: CurrentChatResponse) -> ResultMap in value.resultMap }])
    }

    public var currentChatResponse: CurrentChatResponse? {
      get {
        return (resultMap["currentChatResponse"] as? ResultMap).flatMap { CurrentChatResponse(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "currentChatResponse")
      }
    }

    public struct CurrentChatResponse: GraphQLSelectionSet {
      public static let possibleTypes = ["ChatResponse"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("globalId", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("body", type: .object(Body.selections)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(globalId: GraphQLID, body: Body? = nil) {
        self.init(unsafeResultMap: ["__typename": "ChatResponse", "globalId": globalId, "body": body.flatMap { (value: Body) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var globalId: GraphQLID {
        get {
          return resultMap["globalId"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "globalId")
        }
      }

      public var body: Body? {
        get {
          return (resultMap["body"] as? ResultMap).flatMap { Body(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "body")
        }
      }

      public struct Body: GraphQLSelectionSet {
        public static let possibleTypes = ["MessageBodySingleSelect", "MessageBodyMultipleSelect", "MessageBodyText", "MessageBodyNumber", "MessageBodyAudio", "MessageBodyBankIdCollect", "MessageBodyFile", "MessageBodyParagraph", "MessageBodyUndefined"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(MessageBodySingleSelectFragment.self),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public static func makeMessageBodyMultipleSelect() -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyMultipleSelect"])
        }

        public static func makeMessageBodyText() -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyText"])
        }

        public static func makeMessageBodyNumber() -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyNumber"])
        }

        public static func makeMessageBodyAudio() -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyAudio"])
        }

        public static func makeMessageBodyBankIdCollect() -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyBankIdCollect"])
        }

        public static func makeMessageBodyFile() -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyFile"])
        }

        public static func makeMessageBodyParagraph() -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyParagraph"])
        }

        public static func makeMessageBodyUndefined() -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyUndefined"])
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

          public var messageBodySingleSelectFragment: MessageBodySingleSelectFragment? {
            get {
              if !MessageBodySingleSelectFragment.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
              return MessageBodySingleSelectFragment(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap += newValue.resultMap
            }
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
      self.resultMap = unsafeResultMap
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

public final class MessageSubscription: GraphQLSubscription {
  public let operationDefinition =
    "subscription message {\n  message {\n    __typename\n    globalId\n    header {\n      __typename\n      fromMyself\n    }\n    body {\n      __typename\n      ...SubscriptionMessageBodyCoreFragment\n    }\n  }\n}"

  public var queryDocument: String { return operationDefinition.appending(SubscriptionMessageBodyCoreFragment.fragmentDefinition) }

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("message", type: .object(Message.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(message: Message? = nil) {
      self.init(unsafeResultMap: ["__typename": "Subscription", "message": message.flatMap { (value: Message) -> ResultMap in value.resultMap }])
    }

    public var message: Message? {
      get {
        return (resultMap["message"] as? ResultMap).flatMap { Message(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "message")
      }
    }

    public struct Message: GraphQLSelectionSet {
      public static let possibleTypes = ["Message"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("globalId", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("header", type: .nonNull(.object(Header.selections))),
        GraphQLField("body", type: .nonNull(.object(Body.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(globalId: GraphQLID, header: Header, body: Body) {
        self.init(unsafeResultMap: ["__typename": "Message", "globalId": globalId, "header": header.resultMap, "body": body.resultMap])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var globalId: GraphQLID {
        get {
          return resultMap["globalId"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "globalId")
        }
      }

      public var header: Header {
        get {
          return Header(unsafeResultMap: resultMap["header"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "header")
        }
      }

      public var body: Body {
        get {
          return Body(unsafeResultMap: resultMap["body"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "body")
        }
      }

      public struct Header: GraphQLSelectionSet {
        public static let possibleTypes = ["MessageHeader"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("fromMyself", type: .nonNull(.scalar(Bool.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(fromMyself: Bool) {
          self.init(unsafeResultMap: ["__typename": "MessageHeader", "fromMyself": fromMyself])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var fromMyself: Bool {
          get {
            return resultMap["fromMyself"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "fromMyself")
          }
        }
      }

      public struct Body: GraphQLSelectionSet {
        public static let possibleTypes = ["MessageBodySingleSelect", "MessageBodyMultipleSelect", "MessageBodyText", "MessageBodyNumber", "MessageBodyAudio", "MessageBodyBankIdCollect", "MessageBodyFile", "MessageBodyParagraph", "MessageBodyUndefined"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(SubscriptionMessageBodyCoreFragment.self),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public static func makeMessageBodySingleSelect(text: String) -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodySingleSelect", "text": text])
        }

        public static func makeMessageBodyMultipleSelect(text: String) -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyMultipleSelect", "text": text])
        }

        public static func makeMessageBodyText(text: String) -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyText", "text": text])
        }

        public static func makeMessageBodyNumber(text: String) -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyNumber", "text": text])
        }

        public static func makeMessageBodyAudio(text: String) -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyAudio", "text": text])
        }

        public static func makeMessageBodyBankIdCollect(text: String) -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyBankIdCollect", "text": text])
        }

        public static func makeMessageBodyFile(text: String) -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyFile", "text": text])
        }

        public static func makeMessageBodyParagraph(text: String) -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyParagraph", "text": text])
        }

        public static func makeMessageBodyUndefined(text: String) -> Body {
          return Body(unsafeResultMap: ["__typename": "MessageBodyUndefined", "text": text])
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

          public var subscriptionMessageBodyCoreFragment: SubscriptionMessageBodyCoreFragment {
            get {
              return SubscriptionMessageBodyCoreFragment(unsafeResultMap: resultMap)
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

public final class SendChatSingleSelectResponseMutation: GraphQLMutation {
  public let operationDefinition =
    "mutation SendChatSingleSelectResponse($input: ChatResponseSingleSelectInput!) {\n  sendChatSingleSelectResponse(input: $input)\n}"

  public var input: ChatResponseSingleSelectInput

  public init(input: ChatResponseSingleSelectInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("sendChatSingleSelectResponse", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.scalar(Bool.self))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(sendChatSingleSelectResponse: Bool) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "sendChatSingleSelectResponse": sendChatSingleSelectResponse])
    }

    public var sendChatSingleSelectResponse: Bool {
      get {
        return resultMap["sendChatSingleSelectResponse"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "sendChatSingleSelectResponse")
      }
    }
  }
}

public struct MessageBodyCoreFragment: GraphQLFragment {
  public static let fragmentDefinition =
    "fragment MessageBodyCoreFragment on MessageBodyCore {\n  __typename\n  text\n}"

  public static let possibleTypes = ["MessageBodySingleSelect", "MessageBodyMultipleSelect", "MessageBodyText", "MessageBodyNumber", "MessageBodyAudio", "MessageBodyBankIdCollect", "MessageBodyFile", "MessageBodyParagraph", "MessageBodyUndefined"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("text", type: .nonNull(.scalar(String.self))),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public static func makeMessageBodySingleSelect(text: String) -> MessageBodyCoreFragment {
    return MessageBodyCoreFragment(unsafeResultMap: ["__typename": "MessageBodySingleSelect", "text": text])
  }

  public static func makeMessageBodyMultipleSelect(text: String) -> MessageBodyCoreFragment {
    return MessageBodyCoreFragment(unsafeResultMap: ["__typename": "MessageBodyMultipleSelect", "text": text])
  }

  public static func makeMessageBodyText(text: String) -> MessageBodyCoreFragment {
    return MessageBodyCoreFragment(unsafeResultMap: ["__typename": "MessageBodyText", "text": text])
  }

  public static func makeMessageBodyNumber(text: String) -> MessageBodyCoreFragment {
    return MessageBodyCoreFragment(unsafeResultMap: ["__typename": "MessageBodyNumber", "text": text])
  }

  public static func makeMessageBodyAudio(text: String) -> MessageBodyCoreFragment {
    return MessageBodyCoreFragment(unsafeResultMap: ["__typename": "MessageBodyAudio", "text": text])
  }

  public static func makeMessageBodyBankIdCollect(text: String) -> MessageBodyCoreFragment {
    return MessageBodyCoreFragment(unsafeResultMap: ["__typename": "MessageBodyBankIdCollect", "text": text])
  }

  public static func makeMessageBodyFile(text: String) -> MessageBodyCoreFragment {
    return MessageBodyCoreFragment(unsafeResultMap: ["__typename": "MessageBodyFile", "text": text])
  }

  public static func makeMessageBodyParagraph(text: String) -> MessageBodyCoreFragment {
    return MessageBodyCoreFragment(unsafeResultMap: ["__typename": "MessageBodyParagraph", "text": text])
  }

  public static func makeMessageBodyUndefined(text: String) -> MessageBodyCoreFragment {
    return MessageBodyCoreFragment(unsafeResultMap: ["__typename": "MessageBodyUndefined", "text": text])
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

public struct MessageBodyChoicesCoreFragment: GraphQLFragment {
  public static let fragmentDefinition =
    "fragment MessageBodyChoicesCoreFragment on MessageBodyChoicesCore {\n  __typename\n  type\n  value\n  text\n  selected\n}"

  public static let possibleTypes = ["MessageBodyChoicesUndefined", "MessageBodyChoicesSelection", "MessageBodyChoicesLink"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("type", type: .nonNull(.scalar(String.self))),
    GraphQLField("value", type: .nonNull(.scalar(String.self))),
    GraphQLField("text", type: .nonNull(.scalar(String.self))),
    GraphQLField("selected", type: .nonNull(.scalar(Bool.self))),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public static func makeMessageBodyChoicesUndefined(type: String, value: String, text: String, selected: Bool) -> MessageBodyChoicesCoreFragment {
    return MessageBodyChoicesCoreFragment(unsafeResultMap: ["__typename": "MessageBodyChoicesUndefined", "type": type, "value": value, "text": text, "selected": selected])
  }

  public static func makeMessageBodyChoicesSelection(type: String, value: String, text: String, selected: Bool) -> MessageBodyChoicesCoreFragment {
    return MessageBodyChoicesCoreFragment(unsafeResultMap: ["__typename": "MessageBodyChoicesSelection", "type": type, "value": value, "text": text, "selected": selected])
  }

  public static func makeMessageBodyChoicesLink(type: String, value: String, text: String, selected: Bool) -> MessageBodyChoicesCoreFragment {
    return MessageBodyChoicesCoreFragment(unsafeResultMap: ["__typename": "MessageBodyChoicesLink", "type": type, "value": value, "text": text, "selected": selected])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var type: String {
    get {
      return resultMap["type"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "type")
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

  public var text: String {
    get {
      return resultMap["text"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "text")
    }
  }

  public var selected: Bool {
    get {
      return resultMap["selected"]! as! Bool
    }
    set {
      resultMap.updateValue(newValue, forKey: "selected")
    }
  }
}

public struct MessageBodyChoicesLinkFragment: GraphQLFragment {
  public static let fragmentDefinition =
    "fragment MessageBodyChoicesLinkFragment on MessageBodyChoicesLink {\n  __typename\n  ...MessageBodyChoicesCoreFragment\n  view\n  appUrl\n}"

  public static let possibleTypes = ["MessageBodyChoicesLink"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLFragmentSpread(MessageBodyChoicesCoreFragment.self),
    GraphQLField("view", type: .scalar(MessageBodyChoicesLinkView.self)),
    GraphQLField("appUrl", type: .scalar(String.self)),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(type: String, value: String, text: String, selected: Bool, view: MessageBodyChoicesLinkView? = nil, appUrl: String? = nil) {
    self.init(unsafeResultMap: ["__typename": "MessageBodyChoicesLink", "type": type, "value": value, "text": text, "selected": selected, "view": view, "appUrl": appUrl])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var view: MessageBodyChoicesLinkView? {
    get {
      return resultMap["view"] as? MessageBodyChoicesLinkView
    }
    set {
      resultMap.updateValue(newValue, forKey: "view")
    }
  }

  public var appUrl: String? {
    get {
      return resultMap["appUrl"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "appUrl")
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

    public var messageBodyChoicesCoreFragment: MessageBodyChoicesCoreFragment {
      get {
        return MessageBodyChoicesCoreFragment(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }
  }
}

public struct MessageBodyChoicesSelectionFragment: GraphQLFragment {
  public static let fragmentDefinition =
    "fragment MessageBodyChoicesSelectionFragment on MessageBodyChoicesSelection {\n  __typename\n  ...MessageBodyChoicesCoreFragment\n  clearable\n}"

  public static let possibleTypes = ["MessageBodyChoicesSelection"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLFragmentSpread(MessageBodyChoicesCoreFragment.self),
    GraphQLField("clearable", type: .scalar(Bool.self)),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(type: String, value: String, text: String, selected: Bool, clearable: Bool? = nil) {
    self.init(unsafeResultMap: ["__typename": "MessageBodyChoicesSelection", "type": type, "value": value, "text": text, "selected": selected, "clearable": clearable])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var clearable: Bool? {
    get {
      return resultMap["clearable"] as? Bool
    }
    set {
      resultMap.updateValue(newValue, forKey: "clearable")
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

    public var messageBodyChoicesCoreFragment: MessageBodyChoicesCoreFragment {
      get {
        return MessageBodyChoicesCoreFragment(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }
  }
}

public struct MessageBodyChoicesUndefinedFragment: GraphQLFragment {
  public static let fragmentDefinition =
    "fragment MessageBodyChoicesUndefinedFragment on MessageBodyChoicesUndefined {\n  __typename\n  ...MessageBodyChoicesCoreFragment\n}"

  public static let possibleTypes = ["MessageBodyChoicesUndefined"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLFragmentSpread(MessageBodyChoicesCoreFragment.self),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(type: String, value: String, text: String, selected: Bool) {
    self.init(unsafeResultMap: ["__typename": "MessageBodyChoicesUndefined", "type": type, "value": value, "text": text, "selected": selected])
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

    public var messageBodyChoicesCoreFragment: MessageBodyChoicesCoreFragment {
      get {
        return MessageBodyChoicesCoreFragment(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }
  }
}

public struct MessageBodySingleSelectFragment: GraphQLFragment {
  public static let fragmentDefinition =
    "fragment MessageBodySingleSelectFragment on MessageBodySingleSelect {\n  __typename\n  type\n  id\n  text\n  choices {\n    __typename\n    ...MessageBodyChoicesUndefinedFragment\n    ...MessageBodyChoicesSelectionFragment\n    ...MessageBodyChoicesLinkFragment\n  }\n}"

  public static let possibleTypes = ["MessageBodySingleSelect"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("type", type: .nonNull(.scalar(String.self))),
    GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
    GraphQLField("text", type: .nonNull(.scalar(String.self))),
    GraphQLField("choices", type: .list(.object(Choice.selections))),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(type: String, id: GraphQLID, text: String, choices: [Choice?]? = nil) {
    self.init(unsafeResultMap: ["__typename": "MessageBodySingleSelect", "type": type, "id": id, "text": text, "choices": choices.flatMap { (value: [Choice?]) -> [ResultMap?] in value.map { (value: Choice?) -> ResultMap? in value.flatMap { (value: Choice) -> ResultMap in value.resultMap } } }])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var type: String {
    get {
      return resultMap["type"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "type")
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

  public var text: String {
    get {
      return resultMap["text"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "text")
    }
  }

  public var choices: [Choice?]? {
    get {
      return (resultMap["choices"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Choice?] in value.map { (value: ResultMap?) -> Choice? in value.flatMap { (value: ResultMap) -> Choice in Choice(unsafeResultMap: value) } } }
    }
    set {
      resultMap.updateValue(newValue.flatMap { (value: [Choice?]) -> [ResultMap?] in value.map { (value: Choice?) -> ResultMap? in value.flatMap { (value: Choice) -> ResultMap in value.resultMap } } }, forKey: "choices")
    }
  }

  public struct Choice: GraphQLSelectionSet {
    public static let possibleTypes = ["MessageBodyChoicesUndefined", "MessageBodyChoicesSelection", "MessageBodyChoicesLink"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLFragmentSpread(MessageBodyChoicesUndefinedFragment.self),
      GraphQLFragmentSpread(MessageBodyChoicesSelectionFragment.self),
      GraphQLFragmentSpread(MessageBodyChoicesLinkFragment.self),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public static func makeMessageBodyChoicesUndefined(type: String, value: String, text: String, selected: Bool) -> Choice {
      return Choice(unsafeResultMap: ["__typename": "MessageBodyChoicesUndefined", "type": type, "value": value, "text": text, "selected": selected])
    }

    public static func makeMessageBodyChoicesSelection(type: String, value: String, text: String, selected: Bool, clearable: Bool? = nil) -> Choice {
      return Choice(unsafeResultMap: ["__typename": "MessageBodyChoicesSelection", "type": type, "value": value, "text": text, "selected": selected, "clearable": clearable])
    }

    public static func makeMessageBodyChoicesLink(type: String, value: String, text: String, selected: Bool, view: MessageBodyChoicesLinkView? = nil, appUrl: String? = nil) -> Choice {
      return Choice(unsafeResultMap: ["__typename": "MessageBodyChoicesLink", "type": type, "value": value, "text": text, "selected": selected, "view": view, "appUrl": appUrl])
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

      public var messageBodyChoicesUndefinedFragment: MessageBodyChoicesUndefinedFragment? {
        get {
          if !MessageBodyChoicesUndefinedFragment.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
          return MessageBodyChoicesUndefinedFragment(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap += newValue.resultMap
        }
      }

      public var messageBodyChoicesSelectionFragment: MessageBodyChoicesSelectionFragment? {
        get {
          if !MessageBodyChoicesSelectionFragment.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
          return MessageBodyChoicesSelectionFragment(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap += newValue.resultMap
        }
      }

      public var messageBodyChoicesLinkFragment: MessageBodyChoicesLinkFragment? {
        get {
          if !MessageBodyChoicesLinkFragment.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
          return MessageBodyChoicesLinkFragment(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap += newValue.resultMap
        }
      }
    }
  }
}

public struct SubscriptionMessageBodyCoreFragment: GraphQLFragment {
  public static let fragmentDefinition =
    "fragment SubscriptionMessageBodyCoreFragment on MessageBodyCore {\n  __typename\n  text\n}"

  public static let possibleTypes = ["MessageBodySingleSelect", "MessageBodyMultipleSelect", "MessageBodyText", "MessageBodyNumber", "MessageBodyAudio", "MessageBodyBankIdCollect", "MessageBodyFile", "MessageBodyParagraph", "MessageBodyUndefined"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("text", type: .nonNull(.scalar(String.self))),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public static func makeMessageBodySingleSelect(text: String) -> SubscriptionMessageBodyCoreFragment {
    return SubscriptionMessageBodyCoreFragment(unsafeResultMap: ["__typename": "MessageBodySingleSelect", "text": text])
  }

  public static func makeMessageBodyMultipleSelect(text: String) -> SubscriptionMessageBodyCoreFragment {
    return SubscriptionMessageBodyCoreFragment(unsafeResultMap: ["__typename": "MessageBodyMultipleSelect", "text": text])
  }

  public static func makeMessageBodyText(text: String) -> SubscriptionMessageBodyCoreFragment {
    return SubscriptionMessageBodyCoreFragment(unsafeResultMap: ["__typename": "MessageBodyText", "text": text])
  }

  public static func makeMessageBodyNumber(text: String) -> SubscriptionMessageBodyCoreFragment {
    return SubscriptionMessageBodyCoreFragment(unsafeResultMap: ["__typename": "MessageBodyNumber", "text": text])
  }

  public static func makeMessageBodyAudio(text: String) -> SubscriptionMessageBodyCoreFragment {
    return SubscriptionMessageBodyCoreFragment(unsafeResultMap: ["__typename": "MessageBodyAudio", "text": text])
  }

  public static func makeMessageBodyBankIdCollect(text: String) -> SubscriptionMessageBodyCoreFragment {
    return SubscriptionMessageBodyCoreFragment(unsafeResultMap: ["__typename": "MessageBodyBankIdCollect", "text": text])
  }

  public static func makeMessageBodyFile(text: String) -> SubscriptionMessageBodyCoreFragment {
    return SubscriptionMessageBodyCoreFragment(unsafeResultMap: ["__typename": "MessageBodyFile", "text": text])
  }

  public static func makeMessageBodyParagraph(text: String) -> SubscriptionMessageBodyCoreFragment {
    return SubscriptionMessageBodyCoreFragment(unsafeResultMap: ["__typename": "MessageBodyParagraph", "text": text])
  }

  public static func makeMessageBodyUndefined(text: String) -> SubscriptionMessageBodyCoreFragment {
    return SubscriptionMessageBodyCoreFragment(unsafeResultMap: ["__typename": "MessageBodyUndefined", "text": text])
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