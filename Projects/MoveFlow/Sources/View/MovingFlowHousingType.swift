import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct MovingFlowHousingTypeView: View {
    @ObservedObject var vm = MovingFlowHousingTypeViewModel()

    public var body: some View {

        LoadingViewWithState(
            MoveFlowStore.self,
            .fetchMoveIntent
        ) {
            hForm {}
                .hFormTitle(.standard, .title3, L10n.changeAddressSelectHousingTypeTitle)
                .hFormAttachToBottom {
                    hSection {
                        VStack(spacing: 16) {
                            VStack(spacing: 4) {
                                ForEach(HousingType.allCases, id: \.self) { type in
                                    hRadioField(
                                        id: type.rawValue,
                                        content: {
                                            hText(type.title, style: .standardLarge)
                                        },
                                        selected: $vm.selectedHousingType
                                    )
                                }
                            }
                            InfoCard(text: L10n.changeAddressCoverageInfoText, type: .info)
                            hButton.LargeButton(type: .primary) {
                                vm.continuePressed()
                            } content: {
                                hText(L10n.generalContinueButton, style: .body)
                            }
                            .padding(.bottom, 16)
                        }
                    }
                    .sectionContainerStyle(.transparent)
                }
        } onLoading: {
            DotsActivityIndicator(.standard).useDarkColor
        } onError: { error in
            MovingFlowFailure(error: error)
        }
    }
}

struct MovingFlowTypeOfHome_Previews: PreviewProvider {
    static var previews: some View {
        MovingFlowHousingTypeView()
    }
}

class MovingFlowHousingTypeViewModel: ObservableObject {
    @PresentableStore var store: MoveFlowStore
    @Published var selectedHousingType: String? = HousingType.apartmant.rawValue

    init() {
        store.send(.getMoveIntent)
    }

    func continuePressed() {
        store.send(.navigation(action: .openAddressFillScreen))
    }
}

enum HousingType: String, CaseIterable {
    case apartmant
    case rental
    case house

    var title: String {
        switch self {
        case .apartmant:
            return L10n.changeAddressApartmentOwnLabel
        case .rental:
            return L10n.changeAddressApartmentRentLabel
        case .house:
            return L10n.changeAddressVillaLabel
        }
    }
}
