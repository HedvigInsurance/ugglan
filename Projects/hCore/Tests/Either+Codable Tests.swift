import XCTest
import Flow

class Either_Codable_Tests: XCTestCase {
    
    struct User: Codable, Equatable {
        let name: String
    }
    
    let either: Either<User, User> = .right(.init(name: "Tom"))

    func testEncoding() throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        guard let encodedUser = try? encoder.encode(either) else { XCTFail("bleeps"); return }
        
       let userJson = String(data: encodedUser, encoding: .utf8)
        
        XCTAssertEqual(userJson, "{\n  \"name\" : \"Tom\"\n}")
    }
    
    func testDecoding() throws {
        let decoder = JSONDecoder()
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        guard let encodedUser = try? encoder.encode(either) else { XCTFail("bleeps"); return }
        
        guard let decodedUser = try? decoder.decode(Either<User,User>.self, from: encodedUser) else { XCTFail("bleeps"); return }
        
        XCTAssertEqual(either, decodedUser)
    }
}
