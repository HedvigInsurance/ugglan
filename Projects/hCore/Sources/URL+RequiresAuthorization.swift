import Foundation

extension URL {
    public var requiresAuthorization: Bool {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return false }
        return components.queryItems?
            .contains(where: { $0.name == "requiresAuthorization" && $0.value == "true" }) ?? false
    }
}
