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
                hSection(list) { element in
                    hRow {
                        hText(element.date.displayDateDDMMMFormat)
                        Spacer()
                        hText("Active")
                    }
                    .withChevronAccessory
                }
                .withoutHorizontalPadding
                .sectionContainerStyle(.transparent)
            }
            .trackLoading(TravelInsuranceStore.self, action: .getTravelInsurancesList)
        }
        .presentableStoreLensAnimation(.default)

    }
}
