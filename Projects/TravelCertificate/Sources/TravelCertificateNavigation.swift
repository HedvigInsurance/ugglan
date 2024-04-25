import Flow
import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

public class TravelCertificateNavigationViewModel: ObservableObject {
    public init() {}
}

struct TravelInsuranceSpecificationNavigationModel: Hashable {
    public var id: String?
    let specification: [TravelInsuranceContractSpecification]
}

enum TravelCertificateRouterActions: Hashable {
    case whoIsTravelling(specifiction: TravelInsuranceContractSpecification)
}

public struct TravelCertificateNavigation: View {
    @StateObject private var travelCertificateNavigationVm = TravelCertificateNavigationViewModel()
    @StateObject var router = Router()
    private var canCreateTravelInsurance: Bool
    private var infoButtonPlacement: ToolbarItemPlacement
    
    public init(
        canCreateTravelInsurance: Bool,
        infoButtonPlacement: ToolbarItemPlacement
    ) {
        self.canCreateTravelInsurance = canCreateTravelInsurance
        self.infoButtonPlacement = infoButtonPlacement
    }
    
    public var body: some View {
        RouterHost(router: router) { 
            showListScreen(
                canAddTravelInsurance: canCreateTravelInsurance,
                infoButtonPlacement: infoButtonPlacement
            )
            .routerDestination(for: TravelInsuranceSpecificationNavigationModel.self) { specificationModel in
                start(with: specificationModel.specification)
            }
            .routerDestination(for: TravelInsuranceContractSpecification.self) { specification in
                showStartDateScreen(specification: specification)
            }
            .routerDestination(for: TravelCertificateRouterActions.self) { action in
                switch action {
                case let .whoIsTravelling(specification):
                    showWhoIsTravelingScreen(specification: specification)
                }
            }
        }
    }

    private func showListScreen(
        canAddTravelInsurance: Bool,
        infoButtonPlacement: ToolbarItemPlacement
    ) -> some View {
        ListScreen(
            canAddTravelInsurance: canAddTravelInsurance,
            infoButtonPlacement: infoButtonPlacement
        )
        .configureTitle(L10n.TravelCertificate.cardTitle)
        .withDismissButton()
    }
    
    @ViewBuilder
    private func start(with specifications: [TravelInsuranceContractSpecification]) -> some View {
        if specifications.count > 1 {
            showContractsList(for: specifications)
        } else if let specification = specifications.first {
            showStartDateScreen(specification: specification)
        }
    }
    
        private func showContractsList(
            for specifications: [TravelInsuranceContractSpecification]
        ) -> some View {
            ContractsScreen(specifications: specifications)
            .addDismissFlow()
        }
    
        private func showStartDateScreen(
            specification: TravelInsuranceContractSpecification
//            style: PresentationStyle
        ) -> some View {
            let store: TravelInsuranceStore = globalPresentableStoreContainer.get()
            store.startDateViewModel = StartDateViewModel(specification: specification)
            return StartDateScreen(vm: store.startDateViewModel!)
            .addDismissFlow()
        }
    
        private func showWhoIsTravelingScreen(
            specification: TravelInsuranceContractSpecification
        ) -> some View {
            let store: TravelInsuranceStore = globalPresentableStoreContainer.get()
            store.whoIsTravelingViewModel = WhoIsTravelingViewModel(specification: specification)
    //        return HostingJourney(
    //            TravelInsuranceStore.self,
    //            rootView: 
            return WhoIsTravelingScreen(vm: store.whoIsTravelingViewModel!)
    //        ) { action in
    //            if case let .navigation(navigationAction) = action {
    //                if case .openProcessingScreen = navigationAction {
    //                    openProcessingScreen()
    //                }
    //            } else if case .dismissTravelInsuranceFlow = action {
    //                DismissJourney()
    //            }
    //        }
            .addDismissFlow()
        }
    
    
    //    static func getTravelCertificate() async throws -> TravelInsuranceSpecification {
    //        let disposeBag = DisposeBag()
    //        return try await withCheckedThrowingContinuation {
    //            (inCont: CheckedContinuation<TravelInsuranceSpecification, Error>) -> Void in
    //            let store: TravelInsuranceStore = globalPresentableStoreContainer.get()
    //            store.send(.getTravelCertificateSpecification)
    //            let disposable = store.onAction(.travelCertificateSpecificationSet) {
    //                if let travelInsuranceConfigs = store.state.travelInsuranceConfigs {
    //                    inCont.resume(returning: travelInsuranceConfigs)
    //                } else {
    //                    inCont.resume(throwing: NetworkError.badRequest(message: nil))
    //                }
    //            }
    //            disposeBag.add(disposable)
    //        }
    //    }
//
//    private static func openProcessingScreen() -> some JourneyPresentation {
//        HostingJourney(
//            TravelInsuranceStore.self,
//            rootView: TravelCertificateProcessingScreen()
//        ) { action in
//            if case let .navigation(navigationAction) = action {
//                if case .dismissCreateTravelCertificate = navigationAction {
//                    DismissJourney()
//                } else if case .goBack = navigationAction {
//                    PopJourney()
//                }
//            }
//        }
//        .hidesBackButton
//    }
//
//    private static func showDetails(for model: TravelCertificateModel) -> some JourneyPresentation {
//        //        let document = Document(url: model.url, title: model.title)
//        //        return Journey(
//        //            document,
//        //            style: .detented(.large)
//        //        )
//        //        .withDismissButton
//        return DismissJourney()
//    }
}

extension View {
    func addDismissFlow() -> some View {
        self.withDismissButton(
            title: L10n.General.areYouSure,
            message: L10n.Claims.Alert.body,
            confirmButton: L10n.General.yes,
            cancelButton: L10n.General.no
        )
    }
}
