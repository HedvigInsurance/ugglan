import EditCoInsuredShared
import Foundation
import SwiftUI
import hCore
import hCoreUI

struct RemoveCoInsuredScreen: View {
    @ObservedObject var vm: InsuredPeopleNewScreenModel
    @EnvironmentObject private var editCoInsuredNavigation: EditCoInsuredNavigationViewModel
    @EnvironmentObject private var router: Router

    var body: some View {
        hForm {
            VStack(spacing: 0) {
                let nbOfMissingoInsured =
                    vm.config.numberOfMissingCoInsuredWithoutTermination - vm.coInsuredDeleted.count
                let hasContentBelow = nbOfMissingoInsured > 0

                hSection {
                    hRow {
                        ContractOwnerField(
                            hasContentBelow: hasContentBelow,
                            config: vm.config
                        )
                    }
                    .verticalPadding(0)
                    .padding(.top, .padding16)
                }

                hSection {
                    ForEach(0..<nbOfMissingoInsured, id: \.self) { missingCoInsured in
                        hRow {
                            CoInsuredField(
                                accessoryView: accessoryView(.init()),
                                title: L10n.contractCoinsured,
                                subTitle: L10n.contractNoInformation
                            )
                        }
                        if missingCoInsured < nbOfMissingoInsured - 1 {
                            hRowDivider()
                        }
                    }
                }
            }
            .hWithoutHorizontalPadding([.row])
            .sectionContainerStyle(.transparent)
        }
        .hFormAttachToBottom {
            VStack(spacing: 8) {
                if vm.coInsuredAdded.count > 0 || vm.coInsuredDeleted.count > 0 {
                    ConfirmChangesView(editCoInsuredNavigation: editCoInsuredNavigation)
                }
                hSection {
                    CancelButton()
                }
                .sectionContainerStyle(.transparent)
            }
        }
    }

    @ViewBuilder
    func accessoryView(_ coInsuredModel: CoInsuredModel) -> some View {
        Image(uiImage: hCoreUIAssets.closeSmall.image)
            .foregroundColor(hTextColor.Opaque.secondary)
            .onTapGesture {
                editCoInsuredNavigation.coInsuredInputModel = .init(
                    actionType: .delete,
                    coInsuredModel: coInsuredModel,
                    title: L10n.contractRemoveCoinsuredConfirmation,
                    contractId: vm.config.contractId
                )
            }
    }
}
