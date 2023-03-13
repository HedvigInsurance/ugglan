import Apollo
import Home
import hCore
import hGraphQL

extension JSONObject {
    public static func makePayInMethodStatus(_ status: GiraffeGraphQL.PayinMethodStatus) -> JSONObject {
        GiraffeGraphQL.PayInMethodStatusQuery.Data(payinMethodStatus: status).jsonObject
    }
}
