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
    @State var isSaving: Bool = false

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
                            let ids = inception.correspondingQuotes.compactMap({ $0.id })

                            guard let firstId = ids.first else {
                                return nil
                            }

                            return selectedDatesMap[firstId] ?? inception.startDate?.localDateToDate
                        },
                        set: { newDate in
                            let ids = inception.correspondingQuotes.compactMap({ $0.id })

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
                ForEach(inceptions, id: \.correspondingQuote.id) { inception in
                    SingleStartDateSection(
                        date: Binding(
                            get: {
                                guard let id = inception.correspondingQuote.id else {
                                    return nil
                                }
                                return selectedDatesMap[id] ?? inception.startDate?.localDateToDate
                            },
                            set: { newDate in
                                guard let id = inception.correspondingQuote.id else {
                                    return
                                }
                                selectedDatesMap[id] = newDate
                            }
                        ),
                        title: quoteBundle.quoteFor(
                            id: inception.correspondingQuote.id
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
                hButton.LargeButtonFilled {
                    isSaving = true
                    selectedDatesMap.forEach { quoteId, date in
                        store.send(.updateStartDate(id: quoteId, startDate: date))
                    }
                } content: {
                    hText(L10n.generalSaveButton)
                }
            }
            .slideUpAppearAnimation()
            .hButtonIsLoading(isSaving)
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
                if case .setStartDate = action {
                    DismissJourney()
                }
            }
    }
}
