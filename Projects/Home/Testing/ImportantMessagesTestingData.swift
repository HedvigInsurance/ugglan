import Apollo
import hCore
import hGraphQL
import Home

extension JSONObject {
	public static func makeImportantMessages() -> JSONObject {
		GraphQL.ImportantMessagesQuery
			.Data(importantMessages: [
				.init(id: "mock", message: "Mock important message", link: "https://www.hedvig.com")
			])
			.jsonObject
	}
}
