import Foundation
import SwiftUI

@MainActor
public protocol URLOpener {
    func open(_ url: URL) async
}

extension Dependencies {
    public static var urlOpener: URLOpener {
        Dependencies.shared.resolve()
    }
}
