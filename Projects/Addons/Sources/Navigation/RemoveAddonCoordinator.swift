import Foundation
import SwiftUI
import hCore
import hCoreUI

private struct RemoveAddonCoordinator: ViewModifier {
    let service = AddonsService()

    @Binding fileprivate var input: RemoveAddonInput?

    @State private var offerInput: AddonRemoveOfferWithSelectedItems?

    public func body(content: Content) -> some View {
        content
            .modally(item: $offerInput) { offerInput in
                RemoveAddonNavigation(offerInput)
            }
            .onChange(of: input) { input in
                if let input = input {
                    Task {
                        do {
                            let data = try await service.getAddonRemoveOffer(config: input.contractInfo)
                            let selectedAddons = data.removableAddons.filter {
                                input.preselectedAddons.contains($0.displayTitle)
                            }
                            let selectedAddonIds = Set(selectedAddons.map(\.id))
                            let cost: ItemCost? = try await {
                                if selectedAddonIds.count == data.removableAddons.count {
                                    let cost = try await service.getAddonRemoveOfferCost(
                                        contractId: input.contractInfo.contractId,
                                        addonIds: selectedAddonIds
                                    )
                                    return cost
                                }
                                return nil
                            }()
                            self.offerInput = .init(offer: data, preselectedAddons: selectedAddonIds, cost: cost)
                            self.input = nil
                        } catch {
                            self.input = nil
                            Toasts.shared.displayToastBar(toast: .init(type: .error, text: error.localizedDescription))
                        }
                    }
                }
            }
    }
}

extension View {
    public func handleRemoveAddons(
        input: Binding<RemoveAddonInput?>
    ) -> some View {
        modifier(RemoveAddonCoordinator(input: input))
    }
}
