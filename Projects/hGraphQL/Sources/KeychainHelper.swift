import Foundation

final class KeychainHelper {
    
    static let standard = KeychainHelper()
    private init() {}
    private let kSecAttrAccount: String = "hedvig"
    
    // MARK: - Public methods
    ///  Saves value in keychain
    /// - Parameters:
    ///   - item: Object of type `Codable` that needs to be entried to keychain
    ///   - key: Key with which the object has to be saved
    func save<T>(_ item: T, key: String) where T : Codable {
        do {
            let data = try JSONEncoder().encode(item)
            save(data, key: key)
        } catch {
            assertionFailure("Fail to encode item for keychain: \(error)")
        }
    }
    
    /// Reads value from the keychain
    /// - Parameters:
    ///   - key: Key which has to be queried
    ///   - type: Transforms the data from keychain to this required type T which has to be a `Codable`
    /// - Returns: Object from the keychain of the type specified
    func read<T>(key: String, type: T.Type) -> T? where T : Codable {
        guard let data = read(key: key) else {
            return nil
        }
        
        do {
            let item = try JSONDecoder().decode(type, from: data)
            return item
        } catch {
            assertionFailure("Fail to decode item for keychain: \(error)")
            return nil
        }
    }
    
    /// Deletes key from the keychain
    /// - Parameter key: Specifies key which has to be removed from the keychain
    func delete(key: String) {
        let query = [
            kSecAttrService: key,
            kSecAttrAccount: kSecAttrAccount,
            kSecClass: kSecClassGenericPassword,
        ] as CFDictionary
        SecItemDelete(query)
    }
    
    // MARK: - Private methods
    private func save(_ data: Data, key: String) {
        let query = [
            kSecValueData: data,
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: key,
            kSecAttrAccount: kSecAttrAccount,
        ] as CFDictionary
        
        let status = SecItemAdd(query, nil)
        
        switch status {
        case errSecSuccess:
            break
        case errSecDuplicateItem:
            // Item already exist, update it.
            let query = [
                kSecAttrService: key,
                kSecAttrAccount: kSecAttrAccount,
                kSecClass: kSecClassGenericPassword,
            ] as CFDictionary

            let attributesToUpdate = [kSecValueData: data] as CFDictionary
            SecItemUpdate(query, attributesToUpdate)
        default:
            // Type "security error -{OSStatus}" in terminal for details of the error
            print("Failed to save token with OSStatus: \(status)")
        }
    }
    
    private func read(key: String) -> Data? {
        let query = [
            kSecAttrService: key,
            kSecAttrAccount: kSecAttrAccount,
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true
        ] as CFDictionary
        
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        
        return (result as? Data)
    }
}
