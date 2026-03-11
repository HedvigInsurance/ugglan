import Foundation
import SwiftUI
import hCore
import hCoreUI

private struct ChangeAddonCoordinator: ViewModifier {
    let service = AddonsService()

    @Binding fileprivate var input: ChangeAddonInput?
    @Binding fileprivate var options: DetentPresentationOption

    @State private var offerInput: AddonOfferWithSelectedItems?
    @State private var deflect: AddonDeflect?
    @State private var multipleContractsInput: ChangeAddonInput?

    public func body(content: Content) -> some View {
        content
            .modally(item: $multipleContractsInput, options: $options) { ChangeAddonNavigation(input: $0) }
            .modally(item: $offerInput, options: $options) { offerInput in
                ChangeAddonNavigation(offerInput)
            }
            .detent(item: $deflect) { DeflectView(deflect: $0) }
            .onChange(of: input) { input in
                guard let input, let contractInfos = input.contractInfos else { return }

                if contractInfos.count > 1 {
                    multipleContractsInput = input
                    self.input = nil
                    return
                }

                Task {
                    do {
                        if let contractInfo = contractInfos.first {
                            let data = try await service.getAddonOffer(
                                contractInfo: contractInfo,
                                source: input.addonSource
                            )

                            switch data {
                            case .deflect(let deflect): self.deflect = deflect
                            case .offer(let offer):
                                let cost: ItemCost? = try await {
                                    if (offer.offeredAddons.count == 1) {
                                        let cost = try await service.getAddonOfferCost(
                                            quoteId: offer.quote.quoteId,
                                            addonIds: Set(offer.offeredAddons.map(\.id))
                                        )
                                        return cost
                                    }
                                    return nil
                                }()
                                print(
                                    "OFFER \(offer.offeredAddons), preselected is \(input.preselectedAddonTitle ?? "") and cost is \(cost)"
                                )
                                self.offerInput = .init(
                                    offer: offer,
                                    preselectedAddonTitle: input.preselectedAddonTitle,
                                    cost: cost
                                )
                            }
                            self.input = nil
                        }
                    } catch {
                        self.input = nil
                        Toasts.shared.displayToastBar(toast: .init(type: .error, text: error.localizedDescription))
                    }
                }
            }
    }
}

extension AddonOffer {
    var offeredAddons: [AddonOfferQuote] {
        switch self.quote.addonOfferContent {
        case .selectable(let s): s.quotes
        case .toggleable(let t): t.quotes
        }
    }
}

extension View {
    public func handleAddons(
        input: Binding<ChangeAddonInput?>,
        options: Binding<DetentPresentationOption> = .constant(.alwaysOpenOnTop)
    ) -> some View {
        modifier(ChangeAddonCoordinator(input: input, options: options))
    }
}
