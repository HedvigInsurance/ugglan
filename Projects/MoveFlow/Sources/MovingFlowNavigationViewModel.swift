import Chat
import Combine
import Presentation
import SwiftUI
import hCore
import hCoreUI

struct ExtraBuildingTypeNavigationModel: Identifiable, Equatable {
    public var id: String?
    var extraBuildingType: ExtraBuildingType?
}

public class MovingFlowNavigationViewModel: ObservableObject {
    public init() {}

    @Published public var isChatPresented = false
    @Published var isAddExtraBuildingPresented = false
    @Published public var document: Document? = nil
}

enum MovingFlowRouterWithHiddenBackButtonActions {
    case processing
}

enum MovingFlowRouterActions {
    case confirm
    case houseFill
}

public struct MovingFlowNavigation: View {
    @StateObject private var movingFlowVm = MovingFlowNavigationViewModel()
    @StateObject var router = Router()
    @State var cancellable: AnyCancellable?
    @Binding var isFlowPresented: Bool
    @State var isBuildingTypePickerPresented: ExtraBuildingTypeNavigationModel?

    public init(
        isFlowPresented: Binding<Bool>
    ) {
        self._isFlowPresented = isFlowPresented
    }

    public var body: some View {
        RouterHost(router: router) {
            openSelectHousingScreen()
                .routerDestination(for: HousingType.self) { housingType in
                    openApartmentFillScreen()
                }
                .routerDestination(for: MovingFlowRouterWithHiddenBackButtonActions.self, options: .hidesBackButton) {
                    action in
                    switch action {
                    case .processing:
                        openProcessingView()
                    }
                }
                .routerDestination(for: MovingFlowRouterActions.self) { action in
                    switch action {
                    case .confirm:
                        openConfirmScreen()
                    case .houseFill:
                        openHouseFillScreen()
                    }
                }
        }
        .environmentObject(movingFlowVm)
        .onAppear {
            let store: MoveFlowStore = globalPresentableStoreContainer.get()
            cancellable = store.actionSignal.publisher.sink { _ in
            } receiveValue: { action in
                switch action {
                case .navigation(.openConfirmScreen):
                    router.push(MovingFlowRouterActions.confirm)
                default:
                    break
                }
            }
        }
        .detent(presented: $movingFlowVm.isAddExtraBuildingPresented, style: .height) {
            MovingFlowAddExtraBuildingView(isBuildingTypePickerPresented: $isBuildingTypePickerPresented)
                .detent(item: $isBuildingTypePickerPresented, style: .height) { extraBuildingType in
                    openTypeOfBuildingPicker(for: extraBuildingType.extraBuildingType)
                }
                .environmentObject(movingFlowVm)
                .navigationTitle(L10n.changeAddressAddBuilding)
                .embededInNavigation(options: [.navigationType(type: .large)])
        }
        .fullScreenCover(
            isPresented: $movingFlowVm.isChatPresented
        ) {
            ChatScreen(vm: .init(topicType: nil))
                .navigationTitle(L10n.chatTitle)
                .withDismissButton()
                .embededInNavigation(options: [.navigationType(type: .large)])
        }
        .detent(
            item: $movingFlowVm.document,
            style: .large
        ) { document in
            NavigationStack {
                PDFPreview(document: .init(url: document.url, title: document.title))
            }
        }
    }

    func openSelectHousingScreen() -> some View {
        MovingFlowHousingTypeView(onDismiss: {
            isFlowPresented = false
        })
        .withDismissButton()
    }

    func openApartmentFillScreen() -> some View {
        let store: MoveFlowStore = globalPresentableStoreContainer.get()
        return MovingFlowAddressView(vm: store.addressInputModel).withDismissButton()
    }

    func openHouseFillScreen() -> some View {
        let store: MoveFlowStore = globalPresentableStoreContainer.get()
        return MovingFlowHouseView(vm: store.houseInformationInputModel).withDismissButton()
    }

    func openConfirmScreen() -> some View {
        MovingFlowConfirm()
            .navigationTitle(L10n.changeAddressSummaryTitle)
            .withDismissButton()
    }

    func openProcessingView() -> some View {
        MovingFlowProcessingView(
            onSuccessButtonAction: {
                isFlowPresented = false
            },
            onErrorButtonAction: {
                router.pop()
            }
        )
    }

    func openTypeOfBuildingPicker(for currentlySelected: ExtraBuildingType?) -> some View {
        CheckboxPickerScreen<ExtraBuildingType>(
            items: {
                let store: MoveFlowStore = globalPresentableStoreContainer.get()
                return store.state.movingFlowModel?.extraBuildingTypes
                    .compactMap({ (object: $0, displayName: .init(title: $0.translatedValue)) }) ?? []
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
                    isBuildingTypePickerPresented = nil
                    if let object = selected.0 {
                        store.send(.setExtraBuildingType(with: object))
                    }
                }
            },
            onCancel: {
                isBuildingTypePickerPresented = nil
            },
            singleSelect: true
        )
        .navigationTitle(L10n.changeAddressExtraBuildingContainerTitle)
        .embededInNavigation(options: [.navigationType(type: .large)])
    }
}
