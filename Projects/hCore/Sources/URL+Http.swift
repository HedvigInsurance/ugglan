import Foundation

extension URL {
    public var isHTTP: Bool {
        scheme == "http" || scheme == "https"
    }
}
