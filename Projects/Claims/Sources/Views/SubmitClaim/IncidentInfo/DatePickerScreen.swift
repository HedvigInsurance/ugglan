import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct DatePickerScreen: View {
    @State private var dateOfOccurrence = Date()
    @PresentableStore var store: SubmitClaimStore
    private let type: ClaimsNavigationAction.DatePickerType
    public let title: String
    private let buttonTitle: String
    private let maxDate: Date
    public init(
        type: ClaimsNavigationAction.DatePickerType
    ) {
        self.type = type
        let store: SubmitClaimStore = globalPresentableStoreContainer.get()
        self.maxDate = {
            switch type {
            case .setDateOfOccurrence, .submitDateOfOccurence:
                return store.state.dateOfOccurenceStep?.getMaxDate() ?? Date()
            case .setDateOfPurchase:
                return Date()
            }
        }()
        self.title = {
            switch type {
            case .setDateOfOccurrence, .submitDateOfOccurence:
                return L10n.Claims.Incident.Screen.Date.Of.incident
            case .setDateOfPurchase:
                return L10n.Claims.Item.Screen.Date.Of.Purchase.button
            }
        }()

        self.buttonTitle = {
            switch type {
            case .setDateOfOccurrence, .setDateOfPurchase:
                return L10n.generalSaveButton
            case .submitDateOfOccurence:
                return L10n.generalContinueButton
            }
        }()
        self.dateOfOccurrence = min(maxDate, Date())
    }

    public var body: some View {
        LoadingViewWithContent(.postDateOfOccurrence) {
            hForm {
                hSection {
                    DatePicker(
                        L10n.Claims.Item.Screen.Date.Of.Incident.button,
                        selection: self.$dateOfOccurrence,
                        in: ...maxDate,
                        displayedComponents: [.date]
                    )
                    .environment(\.locale, Locale.init(identifier: Localization.Locale.currentLocale.rawValue))
                    .datePickerStyle(.graphical)
                    .padding([.leading, .trailing], 16)
                    .padding([.top], 5)
                }
            }
            .hFormAttachToBottom {
                VStack {
                    hButton.LargeButtonFilled {
                        let action: SubmitClaimsAction = {
                            switch type {
                            case .setDateOfOccurrence:
                                return .setNewDate(dateOfOccurrence: dateOfOccurrence.localDateString)
                            case .submitDateOfOccurence:
                                return .dateOfOccurrenceRequest(dateOfOccurrence: dateOfOccurrence)
                            case .setDateOfPurchase:
                                return .setSingleItemPurchaseDate(purchaseDate: dateOfOccurrence)
                            }
                        }()
                        store.send(action)
                    } content: {
                        hText(buttonTitle, style: .body)
                            .foregroundColor(hLabelColor.primary.inverted)
                    }
                    .padding([.leading, .trailing], 16)

                    hButton.LargeButtonText {
                        let action: SubmitClaimsAction = {
                            switch type {
                            case .setDateOfOccurrence:
                                return .setNewDate(dateOfOccurrence: nil)
                            case .submitDateOfOccurence:
                                return .dateOfOccurrenceRequest(dateOfOccurrence: nil)
                            case .setDateOfPurchase:
                                return .setSingleItemPurchaseDate(purchaseDate: nil)
                            }
                        }()
                        store.send(action)
                    } content: {
                        hText(L10n.generalNotSure, style: .body)
                            .foregroundColor(hLabelColor.primary)
                    }
                    .padding([.leading, .trailing], 16)
                }
            }
        }
    }
}

struct DatePickerView_Previews: PreviewProvider {
    static var previews: some View {
        DatePickerScreen(type: .setDateOfPurchase)
    }
}
