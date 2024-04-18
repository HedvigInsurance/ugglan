import Combine
import Foundation
import SwiftUI

public struct RouterLink<Content, Destination>: View where Content: View, Destination: View {
    @EnvironmentObject var router: Router
    var destination: () -> Destination
    var content: () -> Content

    /// Creates a navigation link that presents the destination view.
    /// - Parameters:
    ///   - destination: A view for the navigation link to present.
    ///   - content: A view builder to produce a content describing the `destination`
    ///    to present.
    public init(
        @ViewBuilder destination: @escaping () -> Destination,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.destination = destination
        self.content = content
    }

    public var body: some View {
        content()
            .onTapGesture {
                _ = router.push(view: destination())
            }
    }
}
