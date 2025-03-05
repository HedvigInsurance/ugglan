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
        ItemPickerScreen<MovingFlowQuote>(
            config: .init(
                items: {
                    let homeQuotes =
                        navigationVm.movingFlowVm?.potentialHomeQuotes
                        .map({
                            (
                                object: $0,
                                displayName: ItemModel(
                                    title: "",
                                    subTitle: ""
                                )
                            )
                        }) ?? []

                    let mtaQuotes =
                        navigationVm.movingFlowVm?.mtaQuotes
                        .map({
                            (
                                object: $0,
                                displayName: ItemModel(
                                    title: $0.displayName,
                                    subTitle: $0.exposureName
                                )
                            )
                        }) ?? []

                    return homeQuotes + mtaQuotes
                }(),
                onSelected: { selected in
                    if let selectedQuote = selected.first?.0 {
                        navigationVm.addressInputModel.moveFromAddressId = selectedQuote.id
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
