import Foundation
import SwiftUI

@MainActor
public protocol URLOpener {
    @discardableResult
    func open(_ url: URL) async -> Bool
}

extension Dependencies {
    public static var urlOpener: URLOpener {
        Dependencies.shared.resolve()
    }
}
