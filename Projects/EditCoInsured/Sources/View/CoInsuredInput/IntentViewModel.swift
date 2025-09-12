import Foundation
import SwiftUI
import hCore
import hCoreUI

@MainActor
public class IntentViewModel: ObservableObject {
    @Published var intent = Intent(
        activationDate: "",
        currentTotalCost: .init(gross: .sek(0), net: .sek(0)),
        newTotalCost: .init(gross: .sek(0), net: .sek(0)),
        id: "",
        newCostBreakdown: []
    )
    @Published var isLoading: Bool = false
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var nameFetchedFromSSN: Bool = false
    @Published var enterManually: Bool = false
    @Published var errorMessageForInput: String?
    @Published var errorMessageForCoinsuredList: String?
    @Published var viewState: ProcessingState = .loading {
        didSet {
            invalidateDetents()
        }
    }

    var fullName: String {
        firstName + " " + lastName
    }

    var service = EditCoInsuredService()

    var showErrorViewForCoInsuredList: Bool {
        errorMessageForCoinsuredList != nil
    }

    var showErrorViewForCoInsuredInput: Bool {
        errorMessageForInput != nil
    }

    public var showPriceBreakdown: Bool {
        intent.newTotalCost.net != intent.currentTotalCost.net
    }

    var contractId: String?

    @MainActor
    func getIntent(contractId: String, origin: GetIntentOrigin, coInsured: [CoInsuredModel]) async {
        self.contractId = contractId
        withAnimation {
            self.isLoading = true
            self.errorMessageForInput = nil
            self.errorMessageForCoinsuredList = nil
            self.viewState = .loading
        }
        do {
            let data = try await service.sendIntent(contractId: contractId, coInsured: coInsured)
            withAnimation {
                self.intent = data
                self.viewState = .success
            }
        } catch let exception {
            withAnimation {
                switch origin {
                case .coinsuredSelectList:
                    self.errorMessageForCoinsuredList = exception.localizedDescription
                    self.viewState = .error(errorMessage: errorMessageForCoinsuredList ?? L10n.generalError)
                case .coinsuredInput:
                    self.errorMessageForInput = exception.localizedDescription
                    self.viewState = .error(errorMessage: errorMessageForInput ?? L10n.generalError)
                }
            }
        }
        withAnimation {
            self.isLoading = false
        }
    }

    enum GetIntentOrigin {
        case coinsuredSelectList
        case coinsuredInput
    }

    @MainActor
    func performCoInsuredChanges(commitId: String) async {
        withAnimation {
            viewState = .loading
            self.isLoading = true
        }
        do {
            try await service.sendMidtermChangeIntentCommit(commitId: commitId)
            withAnimation {
                self.viewState = .success
            }
            AskForRating().askForReview()
        } catch let exception {
            withAnimation {
                viewState = .error(errorMessage: exception.localizedDescription)
            }
        }
        withAnimation {
            self.isLoading = false
        }
    }

    private func invalidateDetents() {
        if #available(iOS 16.0, *) {
            for i in 1...4 {
                Task {
                    try await Task.sleep(nanoseconds: UInt64(i * 100_000_000))
                    UIApplication.shared.getTopViewController()?.sheetPresentationController?
                        .animateChanges {
                            UIApplication.shared.getTopViewController()?.sheetPresentationController?
                                .invalidateDetents()
                        }
                }
            }
        }
    }
}
