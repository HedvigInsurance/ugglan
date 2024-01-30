import Flow
import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

struct ListScreen: View {
    @PresentableStore var store: TravelInsuranceStore
    let canAddTravelInsurance: Bool
    let infoButtonPlacement: ToolbarItemPlacement
    init(
        canAddTravelInsurance: Bool,
        infoButtonPlacement: ToolbarItemPlacement
    ) {
        self.canAddTravelInsurance = canAddTravelInsurance
        self.infoButtonPlacement = infoButtonPlacement
    }
    public var body: some View {
        PresentableStoreLens(
            TravelInsuranceStore.self,
            getter: { state in
                state.travelInsuranceList
            }
        ) { list in
            hForm {
                hSection(list) { travelCertificate in
                    hRow {
                        hText(travelCertificate.date.displayDateDDMMMFormat)
                        Spacer()
                        hText(travelCertificate.valid ? L10n.TravelCertificate.active : L10n.TravelCertificate.expired)
                    }
                    .withChevronAccessory
                    .foregroundColor(travelCertificate.textColor)
                    .onTapGesture {
                        store.send(.navigation(.openDetails(for: travelCertificate)))
                    }
                }
                .withoutHorizontalPadding
            }
            .hFormAttachToBottom {
                hSection {
                    VStack(spacing: 16) {
                        InfoCard(text: L10n.TravelCertificate.startDateInfo(45), type: .info)
                        if canAddTravelInsurance {
                            hButton.LargeButton(type: .secondary) {
                                Task {
                                    do {
                                        _ = try await TravelInsuranceFlowJourney.getTravelCertificate()
                                        store.send(.navigation(.openCreateNew))
                                    } catch _ {

                                    }
                                }
                            } content: {
                                hText(L10n.TravelCertificate.createNewCertificate)
                            }
                        }
                    }
                    .padding(.vertical, 16)
                }
            }
            .toolbar {
                ToolbarItem(
                    placement: infoButtonPlacement
                ) {
                    InfoViewHolder(
                        title: L10n.TravelCertificate.Info.title,
                        description: L10n.TravelCertificate.Info.subtitle,
                        type: .navigation
                    )
                    .foregroundColor(hTextColor.primary)
                }
            }
        }
        .sectionContainerStyle(.transparent)
        .presentableStoreLensAnimation(.default)
        .onAppear {
            store.send(.getTravelInsruancesList)
        }

    }
}
