import SwiftUI
import hCore
import hCoreUI

struct MovingFlowSelectContractScreen: View {
    @ObservedObject private var navigationVm: MovingFlowNavigationViewModel
    private let itemPickerConfig: ItemConfig<MoveAddress>

    init(
        navigationVm: MovingFlowNavigationViewModel,
        router: Router
    ) {
        self.navigationVm = navigationVm
        itemPickerConfig = .init(
            items: {
                let currentHomeAddresses =
                    navigationVm.moveConfigurationModel?.currentHomeAddresses
                    .map {
                        (
                            object: $0,
                            displayName: ItemModel(
                                title: $0.displayTitle,
                                subTitle: $0.displaySubtitle
                            )
                        )
                    } ?? []

                return currentHomeAddresses
            }(),
            preSelectedItems: {
                if let preSelected = navigationVm.moveConfigurationModel?.currentHomeAddresses
                    .first(where: { $0 == navigationVm.selectedHomeAddress })
                {
                    return [preSelected]
                }
                return []
            },
            onSelected: { [weak navigationVm, weak router] selected in
                if let selectedQuote = selected.first?.0 {
                    navigationVm?.selectedHomeAddress = selectedQuote
                    router?.push(MovingFlowRouterActions.housing)
                }
            },
            buttonText: L10n.generalContinueButton
        )
    }

    var body: some View {
        ItemPickerScreen(
            config: itemPickerConfig
        )
        .hFieldSize(.small)
        .hItemPickerAttributes([.singleSelect, .attachToBottom, .disableIfNoneSelected])
        .hFormTitle(
            title: .init(.small, .heading2, L10n.movingEmbarkTitle, alignment: .leading),
            subTitle: .init(.small, .heading2, L10n.movingFlowBody)
        )
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> MoveFlowClient in MoveFlowClientDemo() })
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    let navigationVm = MovingFlowNavigationViewModel()
    let router = Router()
    return MovingFlowSelectContractScreen(navigationVm: navigationVm, router: router)
}
