import Foundation
import SwiftUI

extension View {
    public func routerDestination<D, C>(for data: D.Type, @ViewBuilder destination: @escaping (D) -> C) -> some View
    where D: Hashable, C: View {
        modifier(RouterDestinationModifier(for: data, destination: destination))
    }
}

private struct RouterDestinationModifier<D, C>: ViewModifier where D: Hashable, C: View {
    @EnvironmentObject var router: Router

    @ViewBuilder
    var destination: (D) -> C
    init(for data: D.Type, destination: @escaping (D) -> C) {
        self.destination = destination
    }
    func body(content: Content) -> some View {
        content
            .onAppear { [weak router] in
                router?.builders["\(D.self)"] = { item in
                    return AnyView(destination(item as! D))
                }
            }
    }
}
