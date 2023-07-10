import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct DatePickerScreen: View {
    @State private var dateOfOccurrence = Date()
    @PresentableStore var store: SubmitClaimStore
    private let type: ClaimsNavigationAction.DatePickerType
    private let buttonTitle: String
    private let maxDate: Date
    public init(
        type: ClaimsNavigationAction.DatePickerType
    ) {
        self.type = type
        let store: SubmitClaimStore = globalPresentableStoreContainer.get()
        self.maxDate = {
            switch type {
            case .setDateOfOccurrence:
                return store.state.dateOfOccurenceStep?.getMaxDate() ?? Date()
            case .setDateOfPurchase:
                return Date()
            }
        }()
        self.buttonTitle = {
            switch type {
            case .setDateOfOccurrence, .setDateOfPurchase:
                return L10n.generalSaveButton
            }
        }()
        self.dateOfOccurrence = min(maxDate, Date())
    }

    public var body: some View {
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
                .frame(height: 350)
                .padding([.leading, .trailing], 16)
                .padding([.top], 5)
                .background(Color.clear)
            }
            .sectionContainerStyle(.transparent)
            .introspectDatePicker { date in
                date.tintColor = .brandNew(.primaryText())
            }
        }
        .hFormAttachToBottom {
            VStack {
                LoadingButtonWithContent(SubmitClaimStore.self, .postDateOfOccurrenceAndLocation) {
                    let action: SubmitClaimsAction = {
                        switch type {
                        case .setDateOfOccurrence:
                            return .setNewDate(dateOfOccurrence: dateOfOccurrence.localDateString)
                        case .setDateOfPurchase:
                            return .setSingleItemPurchaseDate(purchaseDate: dateOfOccurrence)
                        }
                    }()
                    store.send(action)
                } content: {
                    hText(buttonTitle, style: .body)
                }
                .padding([.leading, .trailing], 16)
                LoadingButtonWithContent(
                    SubmitClaimStore.self,
                    .postDateOfOccurrenceAndLocation,
                    buttonAction: {
                        let action: SubmitClaimsAction = {
                            switch type {
                            case .setDateOfOccurrence:
                                return .setNewDate(dateOfOccurrence: nil)
                            case .setDateOfPurchase:
                                return .setSingleItemPurchaseDate(purchaseDate: nil)
                            }
                        }()
                        store.send(action)
                    },
                    content: {
                        hText(L10n.generalNotSure, style: .body)
                            .foregroundColor(hLabelColor.primary)
                    },
                    buttonStyleSelect: .textButton
                )
            }
        }
    }
}

struct DatePickerView_Previews: PreviewProvider {
    static var previews: some View {
        DatePickerScreen(type: .setDateOfPurchase)
    }
}
