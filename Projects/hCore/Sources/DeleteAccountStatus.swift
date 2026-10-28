import Disk
import Foundation

/// Remembers, on disk, which members have requested account deletion. Moved out of hGraphQL (it was an
/// `ApolloClient` extension) so modules can use it without linking the GraphQL layer; the storage key is unchanged.
public enum DeleteAccountStatus {
    private static let storageKey = "deleteRequestedMembers"

    public static func save(for memberId: String) {
        var members = membersWithDeleteRequests()
        members.insert(memberId)
        try? Disk.save(members, to: .applicationSupport, as: storageKey)
    }

    public static func remove(for memberId: String) {
        var members = membersWithDeleteRequests()
        members.remove(memberId)
        try? Disk.save(members, to: .applicationSupport, as: storageKey)
    }

    public static func isRequested(for memberId: String) -> Bool {
        membersWithDeleteRequests().contains(memberId)
    }

    private static func membersWithDeleteRequests() -> Set<String> {
        let memberIds = try? Disk.retrieve(storageKey, from: .applicationSupport, as: Set<String>.self)
        return memberIds ?? []
    }
}
