import Presentation
import SwiftUI
import TravelCertificate
import hCore
import hCoreUI
import hGraphQL

struct OtherService: View {
    @PresentableStore var store: HomeStore
    var body: some View {
        PresentableStoreLens(
            HomeStore.self,
            getter: { state in
                state.allCommonClaims
            }
        ) { otherServices in
            hForm {
                VStack(spacing: 4) {
                    ForEach(otherServices, id: \.id) { claim in
                        hSection {
                            hRow {
                                hText(claim.displayTitle, style: .title3)
                            }
                            .withChevronAccessory
                            .onTap {
                                if claim.id == CommonClaim.chat.id {
                                    store.send(.openFreeTextChat)
                                } else if claim.id == CommonClaim.moving.id {
                                    store.send(.openMovingFlow)
                                } else if claim.id == CommonClaim.travelInsurance.id {
                                    do {
                                        Task {
                                            let data = try await TravelInsuranceFlowJourney.getTravelCertificate()
                                            store.send(.openTravelInsurance)
                                        }
                                    } catch let _ {
                                        //TODO: ERROR
                                    }
                                } else {
                                    store.send(.openCommonClaimDetail(commonClaim: claim, fromOtherServices: true))
                                }
                            }
                        }
                        .sectionContainerStyle((claim.layout.emergency?.isAlert ?? false) ? .alert : .opaque)
                    }
                }
            }
            .hDisableScroll
            .hFormAttachToBottom {
                hSection {
                    hButton.LargeButtonGhost {
                        store.send(.dismissOtherServices)
                    } content: {
                        hText(L10n.generalCloseButton)
                    }

                }
                .sectionContainerStyle(.transparent)
                .padding(.vertical, 16)
            }
        }
    }
}

struct OtherService_Previews: PreviewProvider {
    static var previews: some View {
        OtherService()
    }
}

extension OtherService {
    static var journey: some JourneyPresentation {
        HostingJourney(
            HomeStore.self,
            rootView: OtherService(),
            style: .detented(.scrollViewContentSize),
            options: [.largeNavigationBar, .blurredBackground]
        ) { action in
            if case .openFreeTextChat = action {
                DismissJourney()
            } else if case .openMovingFlow = action {
                DismissJourney()
            } else if case .openTravelInsurance = action {
                DismissJourney()
            } else if case let .openCommonClaimDetail(claim, fromOtherService) = action {
                if fromOtherService {
                    Journey(
                        CommonClaimDetail(claim: claim),
                        style: .detented(.large, modally: false)
                    )
                    .withJourneyDismissButton
                }
            } else if case .dismissOtherServices = action {
                DismissJourney()
            }
        }
        .configureTitle(L10n.HomeTab.otherServices)
        .onAction(HomeStore.self) { action, pres in
            if case .startClaim = action {
                pres.bag.dispose()
            } else if case .openTravelInsurance = action {
                pres.bag.dispose()
            }
        }
    }
}
