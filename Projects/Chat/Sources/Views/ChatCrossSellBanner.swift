import CrossSell
import SwiftUI
import hCore
import hCoreUI

struct ChatCrossSellBanner: View {
    let vm: ChatCrossSellViewModel

    var body: some View {
        InfoCard(title: vm.title, text: vm.subtitle, type: .campaign)
            .buttons([
                // Captured weakly: the configs are stored in the SwiftUI environment, which
                // outlives a body evaluation, and must not pin the view model.
                .init(
                    buttonTitle: vm.dismissTitle,
                    buttonAction: { [weak vm] in
                        Task { await vm?.dismiss() }
                    }
                ),
                .init(
                    buttonTitle: vm.openTitle,
                    buttonAction: { [weak vm] in
                        Task { await vm?.open() }
                    }
                ),
            ])
            .onCrossSellShown { [weak vm] in vm?.offerWasShown() }
    }
}
