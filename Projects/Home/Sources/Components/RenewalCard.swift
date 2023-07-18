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
                    InfoCard(
                        text: L10n.dashboardMultipleRenewalsPrompterBody(
                            dateComponents(from: renewalDate).day ?? 0
                        ),
                        type: .info
                    )
                    .buttons([
                        .init(
                            buttonTitle: L10n.dashboardMultipleRenewalsPrompterButton,
                            buttonAction: {
                                showMultipleAlert = true
                            }
                        )
                    ])
                    .actionSheet(isPresented: $showMultipleAlert) {
                        ActionSheet(
                            title: Text(L10n.dashboardMultipleRenewalsPrompterButton),
                            buttons: buildSheetButtons(contracts: contracts)
                        )
                    }
                } else {
                    VStack(spacing: 16) {
                        ForEach(contracts, id: \.displayName) { contract in
                            let renewalDate = contract.upcomingRenewal?.renewalDate?.localDateToDate ?? Date()
                            InfoCard(
                                text: L10n.dashboardMultipleRenewalsPrompterBody(
                                    dateComponents(from: renewalDate).day ?? 0
                                ),
                                type: .info
                            )
                            .buttons([
                                .init(
                                    buttonTitle: L10n.dashboardMultipleRenewalsPrompterButton,
                                    buttonAction: {
                                        openDocument(contract)
                                    }
                                )
                            ])
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
struct RenewalCardView_Previews: PreviewProvider {
    @PresentableStore static var store: HomeStore

    static var previews: some View {
        Localization.Locale.currentLocale = .en_SE
        return RenewalCardView()
            .onAppear {
                let state = MemberStateData(state: .active, name: "NAME")
                let girafeContract = GiraffeGraphQL.HomeQuery.Data.Contract(
                    displayName: "CONTRACT NAME",
                    status: .makeDeletedStatus(),
                    upcomingRenewal: GiraffeGraphQL.HomeQuery.Data.Contract.UpcomingRenewal(
                        renewalDate: "2023-10-10",
                        draftCertificateUrl: "https://www.google.com"
                    )
                )
                let contract = Home.Contract(contract: girafeContract)
                store.send(.setMemberContractState(state: state, contracts: [contract]))
            }
    }
}
