import Apollo
import ExampleUtil
import Flow
import Form
import Foundation
import Home
import HomeTesting
import Payment
import Presentation
import SwiftUI
import TestingUtil
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct DebugView: View {
    @PresentableStore var store: DebugStore

    var body: some View {
        hForm {
            hSection {
                hRow {
                    hText("Home — Active")
                }
                .onTap {
                    store.send(.openHomeActive)
                }
                hRow {
                    hText("Home — Active in future")
                }
                .onTap {
                    store.send(.openHomeActiveInFuture)
                }
                hRow {
                    hText("Home — Pending switchable")
                }
                .onTap {
                    store.send(.openHomePending)
                }
                hRow {
                    hText("Home — Pending nonswitchable")
                }
                .onTap {
                    store.send(.openHomePendingNonswitchable)
                }
            }
            hSection {
                hRow {
                    hText("Home — With payment card")
                }
                .onTap {
                    store.send(.openHomePaymentCard)
                }
            }
            hSection {
                hRow {
                    hText("Home — With one renewal")
                }
                .onTap {
                    store.send(.openHomeOneRenewal)
                }
                hRow {
                    hText("Home — With multiple renewals, same date")
                }
                .onTap {
                    store.send(.openHomeMultipleRenewals)
                }
                hRow {
                    hText("Home — With multiple renewals, separate dates")
                }
                .onTap {
                    store.send(.openHomeMultipleRenewalsSeparateDates)
                }
            }
            hSection {
                hRow {
                    hText("Home — Terminated")
                }
                .onTap {
                    store.send(.openHomeTerminated)
                }
            }
        }
        .onAppear {
            let apolloClient = ApolloClient(
                networkTransport: MockNetworkTransport(body: JSONObject()),
                store: ApolloStore()
            )

            Dependencies.shared.add(module: Module { () -> ApolloClient in apolloClient })
        }
    }
}

func addDaysToDate(_ days: Int = 30) -> Date {
    let today = Date()

    var dateComponent = DateComponents()
    dateComponent.day = days
    dateComponent.hour = 0

    let futureDate = Calendar.current.date(byAdding: dateComponent, to: today)

    return futureDate ?? Date()
}

extension DebugView {
    static var journey: some JourneyPresentation {
        HostingJourney(
            rootView: DebugView()
        )
        .configureTitle("Home debug")
        .onAction(DebugStore.self) { action in
            switch action {
            case .openHomeActive:
                HostingJourney(
                    rootView: HomeSwiftUI(statusCard: {
                        EmptyView()
                    })
                    .mockState(HomeStore.self) { state in
                        var newState = state

                        newState.memberStateData = .init(state: .active, name: "Mock")

                        return newState
                    }
                )
            case .openHomeActiveInFuture:
                HostingJourney(
                    rootView: HomeSwiftUI(statusCard: {
                        EmptyView()
                    })
                    .mockState(HomeStore.self) { state in
                        var newState = state

                        newState.memberStateData = .init(state: .future, name: "Mock")
                        newState.futureStatus = .activeInFuture(inceptionDate: Date().localDateString ?? "")
                        return newState
                    }
                )
            case .openHomePending:
                HostingJourney(
                    rootView: HomeSwiftUI(statusCard: {
                        EmptyView()
                    })
                    .mockState(HomeStore.self) { state in
                        var newState = state

                        newState.memberStateData = .init(state: .future, name: "Mock")
                        newState.futureStatus = .pendingSwitchable
                        return newState
                    }
                )
            case .openHomePendingNonswitchable:
                HostingJourney(
                    rootView: HomeSwiftUI(statusCard: {
                        EmptyView()
                    })
                    .mockState(HomeStore.self) { state in
                        var newState = state

                        newState.memberStateData = .init(state: .future, name: "Mock")
                        newState.futureStatus = .pendingNonswitchable
                        return newState
                    }
                )
            case .openHomePaymentCard:
                HostingJourney(
                    rootView: HomeSwiftUI(statusCard: {
                        ConnectPaymentCardView()
                            .mockState(PaymentStore.self) { state in
                                var newState = state
                                newState.paymentStatus = .needsSetup

                                return newState
                            }
                    })
                    .mockState(HomeStore.self) { state in
                        var newState = state

                        newState.memberStateData = .init(state: .active, name: "Mock")
                        return newState
                    }
                )
            case .openHomeOneRenewal:
                HostingJourney(
                    rootView: HomeSwiftUI(statusCard: {
                        RenewalCardView()
                    })
                    .mockState(HomeStore.self) { state in
                        var newState = state

                        newState.memberStateData = .init(state: .active, name: "Mock")
                        newState.contracts = [
                            .init(
                                contract: .init(
                                    displayName: "Home insurance",
                                    status: .makeActiveStatus(),
                                    upcomingRenewal: .init(
                                        renewalDate: addDaysToDate().localDateString ?? "",
                                        draftCertificateUrl:
                                            "https://cdn.hedvig.com/info/se/sv/forsakringsvillkor-hyresratt-2020-08-v2.pdf"
                                    )
                                )
                            )
                        ]

                        return newState
                    }
                )
            case .openHomeMultipleRenewals:
                HostingJourney(
                    rootView: HomeSwiftUI(statusCard: {
                        RenewalCardView()
                    })
                    .mockState(HomeStore.self) { state in
                        var newState = state

                        newState.memberStateData = .init(state: .active, name: "Mock")
                        newState.contracts = [
                            .init(
                                contract: .init(
                                    displayName: "Home insurance",
                                    status: .makeActiveStatus(),
                                    upcomingRenewal: .init(
                                        renewalDate: addDaysToDate().localDateString ?? "",
                                        draftCertificateUrl:
                                            "https://cdn.hedvig.com/info/se/sv/forsakringsvillkor-hyresratt-2020-08-v2.pdf"
                                    )
                                )
                            ),
                            .init(
                                contract: .init(
                                    displayName: "Travel insurance",
                                    status: .makeActiveStatus(),
                                    upcomingRenewal: .init(
                                        renewalDate: addDaysToDate().localDateString ?? "",
                                        draftCertificateUrl:
                                            "https://cdn.hedvig.com/info/se/sv/forsakringsvillkor-hyresratt-2020-08-v2.pdf"
                                    )
                                )
                            ),
                        ]

                        return newState
                    }
                )
            case .openHomeMultipleRenewalsSeparateDates:
                HostingJourney(
                    rootView: HomeSwiftUI(statusCard: {
                        RenewalCardView()
                    })
                    .mockState(HomeStore.self) { state in
                        var newState = state

                        newState.memberStateData = .init(state: .active, name: "Mock")
                        newState.contracts = [
                            .init(
                                contract: .init(
                                    displayName: "Home insurance",
                                    status: .makeActiveStatus(),
                                    upcomingRenewal: .init(
                                        renewalDate: addDaysToDate().localDateString ?? "",
                                        draftCertificateUrl:
                                            "https://cdn.hedvig.com/info/se/sv/forsakringsvillkor-hyresratt-2020-08-v2.pdf"
                                    )
                                )
                            ),
                            .init(
                                contract: .init(
                                    displayName: "Travel insurance",
                                    status: .makeActiveStatus(),
                                    upcomingRenewal: .init(
                                        renewalDate: addDaysToDate(20).localDateString ?? "",
                                        draftCertificateUrl:
                                            "https://cdn.hedvig.com/info/se/sv/forsakringsvillkor-hyresratt-2020-08-v2.pdf"
                                    )
                                )
                            ),
                        ]

                        return newState
                    }
                )
            case .openHomeTerminated:
                HostingJourney(
                    rootView: HomeSwiftUI(statusCard: {
                        EmptyView()
                    })
                    .mockState(HomeStore.self) { state in
                        var newState = state

                        newState.memberStateData = .init(state: .terminated, name: "Mock")

                        return newState
                    }
                )
            }
        }
    }
}
