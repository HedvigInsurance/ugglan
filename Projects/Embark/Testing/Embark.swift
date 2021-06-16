import Foundation
import hGraphQL
import Embark


public struct EmbarkTestingData {
    func readEmbarkData() -> GraphQL.EmbarkStoryQuery.Data? {
        if let path = Bundle.main.path(forResource: "EmbarkData", ofType: "json") {
            let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let jsonResult = try? JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as? [String:Any]
            
            let embarkData = GraphQL.EmbarkStoryQuery.Data(unsafeResultMap: jsonResult!)
            
            return embarkData
        } else {
            return nil
        }
    }
    
    func setupTestData() {
        let data = readEmbarkData()
        
    }
}
