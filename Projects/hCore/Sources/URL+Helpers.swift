import Foundation

extension URL {
    public init?(
        string: String?
    ) {
        guard let string = string, let url = URL(string: string) else { return nil }

        self = url
    }
}
