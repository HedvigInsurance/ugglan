import Foundation
import SwiftUI

extension View {
    public func routerDestination<D, C>(
        for data: D.Type,
        options: RouterDestionationOptions = [],
        @ViewBuilder destination: @escaping (D) -> C
    ) -> some View
    where D: Hashable, C: View {
        modifier(RouterDestinationModifier(for: data, options: options, destination: destination))
    }
}

private struct RouterDestinationModifier<D, C>: ViewModifier where D: Hashable, C: View {
    let options: RouterDestionationOptions

    @ViewBuilder
    var destination: (D) -> C
    init(for _: D.Type, options: RouterDestionationOptions, destination: @escaping (D) -> C) {
        self.destination = destination
        self.options = options
    }

    func body(content: Content) -> some View {
        content
            .navigationDestination(for: D.self) { item in
                destination(item)
                    .modifier(
                        NavigationStackDestinationOptionsModifier(
                            options: options,
                            trackingName: (item as? TrackingViewNameProtocol)?.nameForTracking,
                            navigationTitle: (item as? NavigationTitleProtocol)?.navigationTitle
                        )
                    )
            }
    }
}
