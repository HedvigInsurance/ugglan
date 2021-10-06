import Apollo
import Home
import hCore
import hGraphQL

extension JSONObject {
    public static func makePayInMethodStatus(_ status: GraphQL.PayinMethodStatus) -> JSONObject {
        GraphQL.PayInMethodStatusQuery.Data(payinMethodStatus: status).jsonObject
    }
}
