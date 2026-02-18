import Foundation
import SwiftUI
import hCore
import hCoreUI

public struct ChangeAddonCoordinator: ViewModifier {
    let service = AddonsService()

    @Binding fileprivate var input: ChangeAddonInput?
    @Binding fileprivate var options: DetentPresentationOption
    @State private var offer: AddonOffer?
    @State private var deflect: AddonDeflect?
    @State private var multipleContractsInput: ChangeAddonInput?

    public func body(content: Content) -> some View {
        content
            .modally(item: $multipleContractsInput, options: $options) { ChangeAddonNavigation(input: $0) }
            .modally(item: $offer, options: $options) { ChangeAddonNavigation(offer: $0) }
            .detent(item: $deflect) { DeflectView(deflect: $0, onDismiss: { deflect = nil }) }
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
                                switch data {
                                case .deflect(let deflect): self.deflect = deflect
                                case .offer(let offer): self.offer = offer
                                }

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
    public func handleAddons(
        input: Binding<ChangeAddonInput?>,
        options: Binding<DetentPresentationOption> = .constant(.alwaysOpenOnTop)
    ) -> some View {
        modifier(ChangeAddonCoordinator(input: input, options: options))
    }
}
