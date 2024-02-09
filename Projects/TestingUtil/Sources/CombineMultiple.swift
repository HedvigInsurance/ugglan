import Apollo
import ApolloAPI
import Foundation
import hCore

public func combineMultiple(_ jsonObjects: [JSONObject]) -> JSONObject {
    jsonObjects.reduce(JSONObject()) { result, jsonObject in result.merging(jsonObject, uniquingKeysWith: takeRight)
    }
}
