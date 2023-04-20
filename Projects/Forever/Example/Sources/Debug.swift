import Apollo
import ExampleUtil
import Flow
import Forever
import ForeverTesting
import Form
import Foundation
import Presentation
import SwiftUI
import TestingUtil
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct Debug: View {
    @PresentableStore var store: DebugStore

    var body: some View {
        hForm {
            hSection {
                hRow {
                    hText("Forever tab screen")
                }
                .onTap {
                    store.send(.openForever)
                }
                hRow {
                    hText("Info and terms screen")
                }
                .onTap {
                    store.send(.openInfoAndTerms)
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

extension Debug {
    static var journey: some JourneyPresentation {
        HostingJourney(
            rootView: Debug()
        )
        .configureTitle("Forever example")
        .onAction(DebugStore.self) { action in
            switch action {
            case .openForever:
                HostingJourney(
                    rootView: ForeverView()
                        .mockState(ForeverStore.self) { state in
                            var newState = state
                            newState.foreverData = .init(
                                grossAmount: MonetaryAmount(amount: "200.0", currency: "SEK"),
                                netAmount: MonetaryAmount(amount: "180.0", currency: "SEK"),
                                potentialDiscountAmount: MonetaryAmount(amount: "10.0", currency: "SEK"),
                                discountCode: "mock",
                                invitations: [
                                    ForeverInvitation(
                                        name: "Mock",
                                        state: .active,
                                        discount: MonetaryAmount(amount: "10.0", currency: "SEK"),
                                        invitedByOther: true
                                    ),
                                    ForeverInvitation(
                                        name: "Axel",
                                        state: .active,
                                        discount: MonetaryAmount(amount: "10.0", currency: "SEK"),
                                        invitedByOther: false
                                    ),
                                    ForeverInvitation(name: "Karin", state: .pending, invitedByOther: false),
                                    ForeverInvitation(name: "Sam", state: .terminated, invitedByOther: false),
                                ]
                            )
                            return newState
                        }
                )
                .configureTitle("Forever")
            case .openInfoAndTerms:
                HostingJourney(
                    rootView: InfoAndTermsView(potentialDiscount: "10 kr"),
                    style: .modally()
                )
            }
        }
    }
}
