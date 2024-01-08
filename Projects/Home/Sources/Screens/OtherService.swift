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
                                if claim.layout.emergency?.isAlert ?? false {
                                    hText(claim.displayTitle, style: .title3)
                                        .foregroundColor(getTextColor(claim: claim))
                                        .colorScheme(.dark)
                                } else {
                                    hText(claim.displayTitle, style: .title3)
                                        .foregroundColor(getTextColor(claim: claim))
                                }
                            }
                            .withChevronAccessory
                            .onTap {
                                if claim.id == CommonClaim.chat().id {
                                    store.send(.openFreeTextChat)
                                } else if claim.id == CommonClaim.moving().id {
                                    store.send(.openMovingFlow)
                                } else if claim.id == CommonClaim.travelInsurance().id {
                                    Task {
                                        do {
                                            _ = try await TravelInsuranceFlowJourney.getTravelCertificate()
                                            store.send(.openTravelInsurance)
                                        } catch _ {
                                            //TODO: ERROR
                                        }
                                    }
                                } else if claim.layout.titleAndBulletPoint == nil {
                                    store.send(.openEmergency)
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
                    hButton.LargeButton(type: .ghost) {
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

    @hColorBuilder
    func getTextColor(claim: CommonClaim) -> some hColor {
        if claim.layout.emergency?.isAlert ?? false {
            hTextColor.negative
        } else {
            hTextColor.primary
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
            } else if case .openEmergency = action {
                DismissJourney()
            } else if case let .openCommonClaimDetail(claim, fromOtherService) = action {
                if fromOtherService {
                    CommonClaimDetail.journey(claim: claim)
                        .withJourneyDismissButton
                        .configureTitle(claim.displayTitle)
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
