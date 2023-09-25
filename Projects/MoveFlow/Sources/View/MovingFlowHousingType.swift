import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct MovingFlowHousingTypeView: View {
    @ObservedObject var vm = MovingFlowHousingTypeViewModel()

    public var body: some View {

        LoadingViewWithState(
            MoveFlowStore.self,
            .fetchMoveIntent
        ) {
            hForm {}
                .hFormTitle(.standard, .title1, L10n.changeAddressSelectHousingTypeTitle)
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
        store.send(.setHousingType(with: HousingType(rawValue: selectedHousingType ?? "") ?? .apartmant))
        store.send(.navigation(action: .openAddressFillScreen))
    }
}

public enum HousingType: String, CaseIterable, Codable, Equatable, Hashable {
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

    var asMoveApartmentSubType: OctopusGraphQL.MoveApartmentSubType {
        switch self {
        case .apartmant:
            return .own
        case .rental:
            return .rent
        case .house:
            return .own
        }
    }
}
