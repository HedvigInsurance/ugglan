import Foundation
import SwiftUI
import hCore
import hCoreUI

public struct NavigationModifier: ViewModifier {
    let service = AddonsService()

    @Binding fileprivate var addonInput: ChangeAddonInput?
    @State private var offer: AddonOffer? = nil
    @State private var deflect: Bool? = nil

    public func body(content: Content) -> some View {
        content
            .onChange(of: addonInput) { input in
                guard let input else {
                    offer = nil
                    deflect = nil
                    return
                }
                Task {
                    let data = try await service.getAddonOffer(contractId: input.id)
                }
            }
    }
}

extension View {
    public func handleAddons(@Binding addonInput: ChangeAddonInput?) -> some View {
        modifier(NavigationModifier(addonInput: $addonInput))
    }
}
