import Apollo
import Flow
import Foundation
import Presentation
import SnapKit
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct RenewalCardView: View {
    @PresentableStore var store: HomeStore
    @State private var showMultipleAlert = false
    @State private var showFailedToOpenUrlAlert = false

    public init() {}

    private func buildSheetButtons(contracts: [Contract]) -> [ActionSheet.Button] {
        var buttons = contracts.map { contract in
            ActionSheet.Button.default(Text(contract.displayName)) {
                openDocument(contract)
            }
        }
        buttons.append(ActionSheet.Button.cancel())
        return buttons
    }

    private func dateComponents(from renewalDate: Date) -> DateComponents {
        return Calendar.current.dateComponents(
            [.day],
            from: Date(),
            to: renewalDate
        )
    }

    private func openDocument(_ contract: Contract) {
        if let draftCertificateUrl = contract.upcomingRenewal?.draftCertificateUrl,
            let url = URL(string: draftCertificateUrl)
        {
            store.send(.openDocument(contractURL: url))
        } else {
            showFailedToOpenUrlAlert = true
        }
    }

    public var body: some View {
        VStack {
            PresentableStoreLens(
                HomeStore.self,
                getter: { state in
                    state.upcomingRenewalContracts
                }
            ) { contracts in
                if contracts.count > 1,
                    contracts.allSatisfy({ contract in
                        contract.upcomingRenewal?.renewalDate == contracts.first?.upcomingRenewal?.renewalDate
                    }), let renewalDate = contracts.first?.upcomingRenewal?.renewalDate?.localDateToDate
                {
                    hCard(
                        titleIcon: hCoreUIAssets.document.image,
                        title: L10n.dashboardMultipleRenewalsPrompterTitle,
                        bodyText: L10n.dashboardMultipleRenewalsPrompterBody(
                            dateComponents(from: renewalDate).day ?? 0
                        ),
                        backgroundColor: hTintColor.lavenderTwo
                    ) {
                        hButton.SmallButtonOutlined {
                            showMultipleAlert = true
                        } content: {
                            L10n.dashboardMultipleRenewalsPrompterButton.hText()
                        }
                        .actionSheet(isPresented: $showMultipleAlert) {
                            ActionSheet(
                                title: Text(L10n.dashboardMultipleRenewalsPrompterButton),
                                buttons: buildSheetButtons(contracts: contracts)
                            )
                        }
                    }
                } else {
                    VStack(spacing: 16) {
                        ForEach(contracts, id: \.displayName) { contract in
                            let renewalDate = contract.upcomingRenewal?.renewalDate?.localDateToDate ?? Date()
                            hCard(
                                titleIcon: hCoreUIAssets.document.image,
                                title: L10n.dashboardRenewalPrompterTitle(
                                    contract.displayName.lowercased()
                                ),
                                bodyText: L10n.dashboardRenewalPrompterBody(
                                    dateComponents(from: renewalDate).day ?? 0
                                ),
                                backgroundColor: hTintColor.lavenderTwo
                            ) {
                                hButton.SmallButtonOutlined {
                                    openDocument(contract)
                                } content: {
                                    L10n.dashboardRenewalPrompterBodyButton.hText()
                                }
                            }
                        }
                    }
                }
            }
            .alert(isPresented: $showFailedToOpenUrlAlert) {
                Alert(
                    title: Text("Failed to open new insurance terms"),
                    message: Text("Try again, or write to us in the chat."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .presentableStoreLensAnimation(.default)
    }
}
