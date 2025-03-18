import SwiftUI
import hCore
import hCoreUI

struct MovingFlowSelectContractScreen: View {
    @ObservedObject private var navigationVm: MovingFlowNavigationViewModel
    @EnvironmentObject var router: Router

    init(
        navigationVm: MovingFlowNavigationViewModel
    ) {
        self.navigationVm = navigationVm
    }

    var body: some View {
        ItemPickerScreen<MoveAddress>(
            config: .init(
                items: {
                    let currentHomeAddresses =
                        navigationVm.moveConfigurationModel?.currentHomeAddresses
                        .map({
                            (
                                object: $0,
                                displayName: ItemModel(
                                    title: $0.displayTitle,
                                    subTitle: $0.displaySubtitle
                                )
                            )
                        }) ?? []

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
                onSelected: { selected in
                    if let selectedQuote = selected.first?.0 {
                        navigationVm.selectedHomeAddress = selectedQuote
                        router.push(MovingFlowRouterActions.housing)
                    }
                },
                singleSelect: true,
                attachToBottom: true,
                disableIfNoneSelected: true,
                hButtonText: L10n.generalContinueButton,
                fieldSize: .small
            )
        )
        .hFormTitle(
            title: .init(.small, .heading2, L10n.movingEmbarkTitle, alignment: .leading),
            subTitle: .init(.small, .heading2, L10n.movingFlowBody)
        )
        .withDismissButton()
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> MoveFlowClient in MoveFlowClientDemo() })
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    let navigationVm = MovingFlowNavigationViewModel()
    return MovingFlowSelectContractScreen(navigationVm: navigationVm)
}
