import Foundation
import SwiftUI

@MainActor
public protocol URLOpener {
    func open(_ url: URL)
}

public class DefaultURLOpener: URLOpener {
    public init() {}
    public func open(_ url: URL) {
        log.info("Opening URL: \(url.absoluteString)", error: nil, attributes: nil)
        UIApplication.shared.open(url)
    }
}

extension Dependencies {
    public static var urlOpener: URLOpener {
        Dependencies.shared.resolve()
    }
}
