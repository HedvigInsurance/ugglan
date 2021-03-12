import Apollo
import hCore
import hGraphQL
import Home

public extension JSONObject {
    static func makeImportantMessages() -> JSONObject {
        GraphQL.ImportantMessagesQuery.Data(importantMessages: [
            .init(id: "mock", message: "Mock important message", link: "https://www.hedvig.com"),
        ]).jsonObject
    }
}
