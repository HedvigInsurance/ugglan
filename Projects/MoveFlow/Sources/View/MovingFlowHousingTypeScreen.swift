import PresentableStore
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct MovingFlowHousingTypeScreen: View {
    @ObservedObject var vm = MovingFlowHousingTypeViewModel()
    @EnvironmentObject var router: Router
    @ObservedObject var movingFlowNavigationVm: MovingFlowNavigationViewModel

    init(
        movingFlowNavigationVm: MovingFlowNavigationViewModel
    ) {
        self.movingFlowNavigationVm = movingFlowNavigationVm
    }

    public var body: some View {
        ProcessingStateView(
            loadingViewText: L10n.embarkLoading,
            state: $movingFlowNavigationVm.viewState
        )
        .hCustomSuccessView {
            hForm {}
                .hFormTitle(
                    title: .init(
                        .small,
                        .heading2,
                        L10n.movingEmbarkTitle,
                        alignment: .leading
                    ),
                    subTitle: .init(
                        .small,
                        .heading2,
                        L10n.changeAddressSelectHousingTypeTitle
                    )
                )
                .hFormAttachToBottom {
                    hSection {
                        VStack(spacing: 16) {
                            VStack(spacing: 4) {
                                ForEach(HousingType.allCases, id: \.self) { type in
                                    hRadioField(
                                        id: type.rawValue,
                                        leftView: {
                                            hText(type.title, style: .heading2)
                                                .asAnyView
                                        },
                                        selected: $vm.selectedHousingType
                                    )
                                }
                            }
                            .accessibilityHint(L10n.voiceoverOptionSelected + (vm.selectedHousingType ?? ""))

                            if let days = movingFlowNavigationVm.selectedHomeAddress?.oldAddressCoverageDurationDays {
                                InfoCard(text: L10n.changeAddressCoverageInfoText(days), type: .info)
                            }
                            hButton.LargeButton(type: .primary) {
                                continuePressed()
                            } content: {
                                hText(L10n.generalContinueButton, style: .body1)
                            }
                            .accessibilityHint(L10n.voiceoverOptionSelected + (vm.selectedHousingType ?? ""))
                        }
                    }
                    .sectionContainerStyle(.transparent)
                }
                .hStateViewButtonConfig(
                    .init(
                        actionButton: .init(
                            buttonTitle: L10n.openChat,
                            buttonAction: {
                                NotificationCenter.default.post(name: .openChat, object: ChatType.newConversation)
                            }
                        ),
                        dismissButton: nil
                    )
                )
        }
        .hStateViewButtonConfig(errorButtons)
    }

    private var errorButtons: StateViewButtonConfig {
        .init(
            actionButton: .init(
                buttonTitle: L10n.openChat,
                buttonAction: {
                    NotificationCenter.default.post(name: .openChat, object: ChatType.newConversation)
                }
            ),
            dismissButton: nil
        )
    }

    func continuePressed() {
        let housingType = HousingType(rawValue: vm.selectedHousingType ?? "")
        movingFlowNavigationVm.addressInputModel.selectedHousingType = housingType ?? .apartment

        if let housingType {
            router.push(housingType)
        }
    }
}

struct MovingFlowTypeOfHome_Previews: PreviewProvider {
    static var previews: some View {
        Dependencies.shared.add(module: Module { () -> MoveFlowClient in MoveFlowClientDemo() })
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })
        Localization.Locale.currentLocale.send(.sv_SE)
        return MovingFlowHousingTypeScreen(movingFlowNavigationVm: .init())
    }
}

@MainActor
class MovingFlowHousingTypeViewModel: ObservableObject {
    @Published var selectedHousingType: String? = HousingType.apartment.rawValue
    init() {}
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
            return .init(describing: MovingFlowAddressScreen.self)
        case .rental:
            return .init(describing: MovingFlowAddressScreen.self)
        case .house:
            return .init(describing: MovingFlowAddressScreen.self)
        }
    }

}
