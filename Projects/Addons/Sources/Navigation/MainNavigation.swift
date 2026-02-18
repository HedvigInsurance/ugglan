import Foundation
import SwiftUI
import hCore
import hCoreUI

public struct NavigationModifier: ViewModifier {
    let service = AddonsService()

    @Binding fileprivate var input: ChangeAddonInput?
    @State private var offer: AddonOffer?
    @State private var deflect: AddonDeflect?
    @State private var multipleContractsInput: ChangeAddonInput?

    public func body(content: Content) -> some View {
        content
            .modally(item: $multipleContractsInput) { input in ChangeAddonNavigation(input: input) }
            .modally(item: $offer) { offer in ChangeAddonNavigation(offer: offer) }
            .detent(item: $deflect) { deflect in
                DeflectView(deflect: deflect, onDismiss: { self.deflect = nil })
            }
            .onChange(of: input) { input in
                guard let input, let configs = input.contractConfigs else { return }

                if configs.count > 1 {
                    multipleContractsInput = input
                    self.input = nil
                    return
                }

                Task {
                    do {
                        if let config = configs.first {
                            let data = try await service.getAddonOffer(config: config, source: input.addonSource)
                            withAnimation {
                                deflect = .init(
                                    contractId: config.contractId,
                                    pageTitle: "Du behöver en högre skyddnivå",
                                    pageDescription: """
                                        Våra tilläggsförsäkringar går inte att
                                        kombinera med trafikförsäkring. Välj en
                                        högre skyddsnivå för att fortsätta.
                                        """,
                                    type: .upgradeTier
                                )
                                //                                switch data {
                                //                                case .deflect(let deflect): self.deflect = deflect
                                //                                case .offer(let offer): self.offer = offer
                                //                                }

                                self.input = nil
                            }
                        }
                    } catch {
                        Toasts.shared.displayToastBar(toast: .init(type: .error, text: error.localizedDescription))
                    }
                }
            }
    }
}

extension View {
    public func handleAddons(input: Binding<ChangeAddonInput?>) -> some View {
        modifier(NavigationModifier(input: input))
    }
}
