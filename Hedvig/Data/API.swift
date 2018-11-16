//  This file was automatically generated and should not be edited.

import Apollo

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