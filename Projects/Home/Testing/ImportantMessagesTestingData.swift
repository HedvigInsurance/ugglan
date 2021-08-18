import Apollo
import Home
import hCore
import hGraphQL

extension JSONObject {
  public static func makeImportantMessages() -> JSONObject {
    GraphQL.ImportantMessagesQuery
      .Data(importantMessages: [
        .init(id: "mock", message: "Mock important message", link: "https://www.hedvig.com")
      ])
      .jsonObject
  }
}
