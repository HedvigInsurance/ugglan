import Apollo
import hCore
import hGraphQL
import Home

public extension JSONObject {
    static func makePayInMethodStatus(_ status: GraphQL.PayinMethodStatus) -> JSONObject {
        GraphQL.PayInMethodStatusQuery.Data(payinMethodStatus: status).jsonObject
    }
}
