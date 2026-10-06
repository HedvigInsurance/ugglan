import Foundation

struct DismissedOngoingQuotesTracker {
    static let storageKey = "DismissedOngoingQuotes.quoteIds"
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func dismissedIds(forMember memberId: String) -> Set<String> {
        Set(dismissedIdsByMember()[memberId] ?? [])
    }

    func dismiss(quoteId: String, forMember memberId: String) {
        var idsByMember = dismissedIdsByMember()
        var ids = idsByMember[memberId] ?? []
        guard !ids.contains(quoteId) else { return }
        ids.append(quoteId)
        idsByMember[memberId] = ids
        guard let encoded = try? JSONEncoder().encode(idsByMember) else { return }
        userDefaults.set(encoded, forKey: Self.storageKey)
    }

    private func dismissedIdsByMember() -> [String: [String]] {
        guard let data = userDefaults.data(forKey: Self.storageKey),
            let idsByMember = try? JSONDecoder().decode([String: [String]].self, from: data)
        else {
            return [:]
        }
        return idsByMember
    }
}
