import Apollo
import hCore
import hGraphQL
import Home

extension JSONObject {
	public static func makePayInMethodStatus(_ status: GraphQL.PayinMethodStatus) -> JSONObject {
		GraphQL.PayInMethodStatusQuery.Data(payinMethodStatus: status).jsonObject
	}
}
