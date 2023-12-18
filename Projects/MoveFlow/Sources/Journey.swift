import Foundation
import Presentation
import hCore
import hCoreUI
import hGraphQL

public struct MovingFlowJourneyNew {

    public static func startMovingFlow<ResultJourney: JourneyPresentation>(
        @JourneyBuilder resultJourney: @escaping (_ result: MovingFlowRedirectType) -> ResultJourney
    ) -> some JourneyPresentation {
        openSelectHousingScreen()
            .onAction(
                MoveFlowStore.self
            ) { action in
                if case let .navigation(navigationAction) = action {
                    if case .goToFreeTextChat = navigationAction {
                        resultJourney(.chat)
                    }
                }
            }
    }

    @JourneyBuilder
    static func getMovingFlowScreen(for action: MoveFlowAction) -> some JourneyPresentation {
        if case let .navigation(navigationAction) = action {
            if case .openAddressFillScreen = navigationAction {
                MovingFlowJourneyNew.openApartmentFillScreen()
            } else if case .openHouseFillScreen = navigationAction {
                MovingFlowJourneyNew.openHouseFillScreen()
            } else if case .openAddBuilding = navigationAction {
                MovingFlowJourneyNew.openAddExtraBuilding()
            } else if case .openConfirmScreen = navigationAction {
                MovingFlowJourneyNew.openConfirmScreen()
            } else if case .openProcessingView = navigationAction {
                MovingFlowJourneyNew.openProcessingView()
            } else if case .dismissMovingFlow = navigationAction {
                DismissJourney()
            } else if case .goBack = navigationAction {
                PopJourney()
            }
        }
    }

    static func openSelectHousingScreen() -> some JourneyPresentation {
        HostingJourney(
            MoveFlowStore.self,
            rootView: MovingFlowHousingTypeView(),
            style: .modally(presentationStyle: .fullScreen),
            options: [
                .defaults, .prefersLargeTitles(false), .largeTitleDisplayMode(.always),
            ]
        ) {
            action in
            getMovingFlowScreen(for: action).showsBackButton
        }
        .withJourneyDismissButton
    }

    static func openApartmentFillScreen() -> some JourneyPresentation {
        let store: MoveFlowStore = globalPresentableStoreContainer.get()
        return HostingJourney(
            MoveFlowStore.self,
            rootView: MovingFlowAddressView(vm: store.addressInputModel)
        ) {
            action in
            getMovingFlowScreen(for: action).showsBackButton
        }
        .withJourneyDismissButton
    }

    static func openHouseFillScreen() -> some JourneyPresentation {
        let store: MoveFlowStore = globalPresentableStoreContainer.get()
        return HostingJourney(
            MoveFlowStore.self,
            rootView: MovingFlowHouseView(vm: store.houseInformationInputModel)
        ) {
            action in
            getMovingFlowScreen(for: action).showsBackButton
        }
        .withJourneyDismissButton
    }

    static func openAddExtraBuilding() -> some JourneyPresentation {
        HostingJourney(
            MoveFlowStore.self,
            rootView: MovingFlowAddExtraBuildingView(),
            style: .detented(.scrollViewContentSize),
            options: [.largeNavigationBar]
        ) { action in
            if case .navigation(.dismissAddBuilding) = action {
                PopJourney()
            } else if case let .navigation(.openTypeOfBuilding(type)) = action {
                MovingFlowJourneyNew.openTypeOfBuildingPicker(for: type)
            } else {
                getMovingFlowScreen(for: action).showsBackButton
            }
        }
        .configureTitle(L10n.changeAddressAddBuilding)
    }

    static func openTypeOfBuildingPicker(for currentlySelected: ExtraBuildingType?) -> some JourneyPresentation {
        HostingJourney(
            MoveFlowStore.self,
            rootView: CheckboxPickerScreen<ExtraBuildingType>(
                items: {
                    let store: MoveFlowStore = globalPresentableStoreContainer.get()
                    return store.state.movingFlowModel?.extraBuildingTypes
                        .compactMap({ (object: $0, displayName: $0.translatedValue) }) ?? []
                }(),
                preSelectedItems: {
                    if let currentlySelected {
                        return [currentlySelected]
                    }
                    return []
                },
                onSelected: { selected in
                    let store: MoveFlowStore = globalPresentableStoreContainer.get()
                    if let selected = selected.first {
                        store.send(.navigation(action: .dismissTypeOfBuilding))
                        if let object = selected.0 {
                            store.send(.setExtraBuildingType(with: object))
                        }
                    }
                },
                onCancel: {
                    let store: MoveFlowStore = globalPresentableStoreContainer.get()
                    store.send(.navigation(action: .dismissTypeOfBuilding))
                },
                singleSelect: true
            ),
            style: .modally(presentationStyle: .fullScreen),
            options: [.largeNavigationBar, .blurredBackground]
        ) {
            action in
            if case .navigation(.dismissTypeOfBuilding) = action {
                PopJourney()
            } else {
                getMovingFlowScreen(for: action).showsBackButton
            }
        }
        .configureTitle(L10n.changeAddressExtraBuildingContainerTitle)
    }

    static func openConfirmScreen() -> some JourneyPresentation {
        HostingJourney(
            MoveFlowStore.self,
            rootView: MovingFlowConfirm()
        ) {
            action in
            if case let .navigation(.document(url, title)) = action {
                Journey(
                    Document(url: url, title: title),
                    style: .detented(.large)
                )
                .withDismissButton
            } else {
                getMovingFlowScreen(for: action).hidesBackButton
            }
        }
        .configureTitle(L10n.changeAddressSummaryTitle)
        .withJourneyDismissButton
    }

    static func openProcessingView() -> some JourneyPresentation {
        HostingJourney(
            MoveFlowStore.self,
            rootView: MovingFlowProcessingView()
        ) {
            action in
            getMovingFlowScreen(for: action).hidesBackButton
        }
    }
}

public enum MovingFlowRedirectType {
    case chat
}
