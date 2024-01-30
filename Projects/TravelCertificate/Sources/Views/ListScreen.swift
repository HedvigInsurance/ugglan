import Flow
import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

struct ListScreen: View {
    @PresentableStore var store: TravelInsuranceStore
    let canAddTravelInsurance: Bool
    init(canAddTravelInsurance: Bool) {
        self.canAddTravelInsurance = canAddTravelInsurance
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
                                let vc = TravelInsuranceFlowJourney.start()
                                let disposeBag = DisposeBag()
                                if let topVc = UIApplication.shared.getTopViewController() {
                                    disposeBag += topVc.present(vc)
                                }
                            } content: {
                                hText(L10n.TravelCertificate.createNewCertificate)
                            }
                        }
                    }
                    .padding(.vertical, 16)
                }
            }
            .trackLoading(TravelInsuranceStore.self, action: .getTravelInsurancesList)
        }
        .sectionContainerStyle(.transparent)
        .presentableStoreLensAnimation(.default)
        .onAppear {
            store.send(.getTravelInsruancesList)
        }

    }
}
