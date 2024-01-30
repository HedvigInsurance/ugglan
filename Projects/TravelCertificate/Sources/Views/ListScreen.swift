import Flow
import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

struct ListScreen: View {
    @PresentableStore var store: TravelInsuranceStore
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
                        hText(travelCertificate.valid ? "Active" : "Expired")
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
                        hButton.LargeButton(type: .secondary) {
                            let vc = TravelInsuranceFlowJourney.start()
                            let disposeBag = DisposeBag()
                            if let topVc = UIApplication.shared.getTopViewController() {
                                disposeBag += topVc.present(vc)
                            }
                        } content: {
                            hText("Create new certificate")
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
