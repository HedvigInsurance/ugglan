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
    @EnvironmentObject var router: Router
    let options: RouterDestionationOptions

    @ViewBuilder
    var destination: (D) -> C
    init(for _: D.Type, options: RouterDestionationOptions, destination: @escaping (D) -> C) {
        self.destination = destination
        self.options = options
    }

    func body(content: Content) -> some View {
        content
            .onAppear { [weak router] in
                router?.builders["\(D.self)"] = .init(
                    builder: { item in
                        let view = destination(item as! D)
                        return AnyView(view)
                    },
                    options: options
                )
            }
    }
}
