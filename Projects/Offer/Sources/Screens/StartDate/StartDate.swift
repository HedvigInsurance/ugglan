import Flow
import Form
import Foundation
import Presentation
import SwiftUI
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct StartDate {
    @PresentableStore var store: OfferStore
    @State var selectedDatesMap: [String: Date?] = [:]

    let quoteBundle: QuoteBundle

    var title: String {
        switch quoteBundle.appConfiguration.startDateTerminology {
        case .accessDate:
            return L10n.offerSetAccessDate
        case .startDate:
            return L10n.offerSetStartDate
        case .unknown:
            return ""
        }
    }
}

extension StartDate: View {
    var body: some View {
        hForm {
            switch quoteBundle.inception {
            case let .concurrent(inception):
                SingleStartDateSection(
                    date: Binding(
                        get: {
                            let ids = inception.correspondingQuotes

                            guard let firstId = ids.first else {
                                return nil
                            }

                            return selectedDatesMap[firstId] ?? inception.startDate?.localDateToDate
                        },
                        set: { newDate in
                            let ids = inception.correspondingQuotes

                            ids.forEach { id in
                                selectedDatesMap[id] = newDate
                            }
                        }
                    ),
                    title: nil,
                    switchingActivated: inception.currentInsurer?.switchable
                        ?? false,
                    initiallyCollapsed: inception.startDate?.localDateToDate == nil
                )
            case let .independent(inceptions):
                ForEach(inceptions, id: \.correspondingQuoteId) { inception in
                    SingleStartDateSection(
                        date: Binding(
                            get: {
                                let id = inception.correspondingQuoteId
                                return selectedDatesMap[id] ?? inception.startDate?.localDateToDate
                            },
                            set: { newDate in
                                let id = inception.correspondingQuoteId
                                selectedDatesMap[id] = newDate
                            }
                        ),
                        title: quoteBundle.quoteFor(
                            id: inception.correspondingQuoteId
                        )?
                        .displayName,
                        switchingActivated: inception.currentInsurer?.switchable
                            ?? false,
                        initiallyCollapsed: inceptions.count > 1
                    )
                }
            case .unknown:
                EmptyView()
            }
        }
        .hFormAttachToBottom {
            hFormBottomAttachedBackground {
                hButton.LargeButtonPrimary {
                    store.send(.updateStartDates(dateMap: selectedDatesMap))
                } content: {
                    hText(L10n.generalSaveButton)
                }
            }
            .slideUpAppearAnimation()
            .modifier(StartDateLoading())
        }
    }
}

extension StartDate {
    var journey: some JourneyPresentation {
        HostingJourney(rootView: self)
            .setStyle(.detented(.large))
            .configureTitle(title)
            .withDismissButton
            .startDateErrorAlert
            .onAction(OfferStore.self) { action in
                if case .setStartDates = action {
                    DismissJourney()
                } else if case .setOfferBundle = action {
                    DismissJourney()
                } else if case .setQuoteCart = action {
                    DismissJourney()
                }
            }
    }
}
