import hCore

extension PowerOfAttorneyLevel {
    // TODO: Localize via Lokalise
    var displayName: String {
        switch self {
        case .full: "Full"
        case .partial: "Limited"
        }
    }
}
