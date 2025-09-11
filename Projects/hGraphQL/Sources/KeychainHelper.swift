import Foundation

@MainActor
public final class KeychainHelper {
    static let standard = KeychainHelper()
    private init() {}
    private let account: String = "hedvig"

    // MARK: - Public methods

    ///  Saves value in keychain
    /// - Parameters:
    ///   - item: Object of type `Codable` that needs to be entried to keychain
    ///   - key: Key with which the object has to be saved
    public func save<T>(_ item: T, key: String) where T: Codable {
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
    public func read<T>(key: String, type: T.Type) async throws -> T? where T: Codable {
        guard let data = try read(key: key) else {
            return nil
        }

        do {
            let item = try JSONDecoder().decode(type, from: data)
            return item
        } catch {
            return nil
        }
    }

    /// Deletes key from the keychain
    /// - Parameter key: Specifies key which has to be removed from the keychain
    public func delete(key: String) async {
        let query =
            [
                kSecAttrService: key,
                kSecAttrAccount: account,
                kSecClass: kSecClassGenericPassword,
            ] as CFDictionary
        SecItemDelete(query)
    }

    // MARK: - Private methods

    private func save(_ data: Data, key: String) {
        let query =
            [
                kSecValueData: data,
                kSecClass: kSecClassGenericPassword,
                kSecAttrService: key,
                kSecAttrAccount: account,
                kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock,
            ] as CFDictionary

        let status = SecItemAdd(query, nil)

        switch status {
        case errSecSuccess:
            break
        case errSecDuplicateItem:
            // Item already exist, update it.
            let query =
                [
                    kSecAttrService: key,
                    kSecAttrAccount: account,
                    kSecClass: kSecClassGenericPassword,
                ] as CFDictionary

            let attributesToUpdate = [kSecValueData: data] as CFDictionary
            SecItemUpdate(query, attributesToUpdate)
        default:
            // Fire "security error -{OSStatus}" in terminal for details of the error
            graphQlLogger.error("Failed to save token with OSStatus: \(status)", error: nil, attributes: nil)
        }
    }

    private func read(key: String) throws -> Data? {
        let query =
            [
                kSecAttrService: key,
                kSecAttrAccount: account,
                kSecClass: kSecClassGenericPassword,
                kSecReturnData: true,
            ] as CFDictionary

        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)
        switch status {
        case errSecSuccess:
            let data = result as! Data
            return data
        case errSecItemNotFound:
            return nil
        default:
            if let errMsg = SecCopyErrorMessageString(status, nil) as? String {
                graphQlLogger.info(
                    "Access token refresh missing token EXCEPTION",
                    error: NSError(domain: errMsg, code: 1000),
                    attributes: nil
                )
            } else {
                graphQlLogger.info("Access token refresh missing token EXCEPTION", error: nil, attributes: nil)
            }
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
        }
    }
}
