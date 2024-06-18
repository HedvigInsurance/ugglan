import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct MovingFlowHousingTypeView: View {
    @StateObject var vm = MovingFlowHousingTypeViewModel()
    @EnvironmentObject var router: Router
    @EnvironmentObject var movingFlowNavigationVm: MovingFlowNavigationViewModel

    public var body: some View {
        LoadingViewWithState(
            MoveFlowStore.self,
            .fetchMoveIntent
        ) {
            hForm {}
                .hFormTitle(title: .init(.standard, .title1, L10n.changeAddressSelectHousingTypeTitle))
                .hFormAttachToBottom {
                    hSection {
                        VStack(spacing: 16) {
                            VStack(spacing: 4) {
                                ForEach(HousingType.allCases, id: \.self) { type in
                                    hRadioField(
                                        id: type.rawValue,
                                        content: {
                                            hText(type.title, style: .heading2)
                                        },
                                        selected: $vm.selectedHousingType
                                    )
                                }
                            }
                            InfoCard(text: L10n.changeAddressCoverageInfoText, type: .info)
                            hButton.LargeButton(type: .primary) {
                                continuePressed()
                            } content: {
                                hText(L10n.generalContinueButton, style: .body1)
                            }
                            .padding(.bottom, 16)
                        }
                    }
                    .sectionContainerStyle(.transparent)
                }
        } onLoading: {
            DotsActivityIndicator(.standard).useDarkColor
        } onError: { error in
            ZStack {
                BackgroundView().ignoresSafeArea()
                GenericErrorView(
                    description: error,
                    buttons: .init(
                        actionButton: .init(
                            buttonTitle: L10n.openChat,
                            buttonAction: {
                                NotificationCenter.default.post(name: .openChat, object: nil)
                            }
                        ),
                        dismissButton: nil
                    )
                )
                .hWithoutTitle
                VStack {
                    Spacer()
                    hButton.LargeButton(type: .ghost) {
                        router.dismiss()
                    } content: {
                        hText(L10n.generalCancelButton)
                    }
                }
            }
        }
    }

    func continuePressed() {
        let housingType = HousingType(rawValue: vm.selectedHousingType ?? "")
        vm.store.send(.setHousingType(with: housingType ?? .apartment))

        if let housingType {
            router.push(housingType)
        }
    }
}

struct MovingFlowTypeOfHome_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale = .nb_NO
        return MovingFlowHousingTypeView()
    }
}

class MovingFlowHousingTypeViewModel: ObservableObject {
    @PresentableStore var store: MoveFlowStore
    @Published var selectedHousingType: String? = HousingType.apartment.rawValue

    init() {
        store.send(.getMoveIntent)
    }
}

public enum HousingType: String, CaseIterable, Codable, Equatable, Hashable {
    case apartment
    case rental
    case house

    var title: String {
        switch self {
        case .apartment:
            return L10n.changeAddressApartmentOwnLabel
        case .rental:
            return L10n.changeAddressApartmentRentLabel
        case .house:
            return L10n.changeAddressVillaLabel
        }
    }

    var asMoveApartmentSubType: GraphQLEnum<OctopusGraphQL.MoveApartmentSubType> {
        switch self {
        case .apartment:
            return GraphQLEnum<OctopusGraphQL.MoveApartmentSubType>(.own)
        case .rental:
            return GraphQLEnum<OctopusGraphQL.MoveApartmentSubType>(.rent)
        case .house:
            return GraphQLEnum<OctopusGraphQL.MoveApartmentSubType>(.own)
        }
    }
}

extension HousingType: TrackingViewNameProtocol {
    public var nameForTracking: String {
        switch self {
        case .apartment:
            return .init(describing: MovingFlowAddressView.self)
        case .rental:
            return .init(describing: MovingFlowAddressView.self)
        case .house:
            return .init(describing: MovingFlowAddressView.self)
        }
    }

}
