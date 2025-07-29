import Combine
import Foundation
import SwiftUI
import hCoreUI

@MainActor
public class CoInusuredInputViewModel: ObservableObject {
    @Published var personalData: PersonalData
    @Published var noSSN = false
    @Published var SSNError: String?
    @Published var nameFetchedFromSSN: Bool = false
    @Published var isLoading: Bool = false
    @Published var intentViewState: ProcessingState = .success
    @Published var enterManually: Bool = false
    @Published var showInfoForMissingSSN = false
    @Published var SSN: String
    @Published var birthday: String
    @Published var type: CoInsuredInputType?
    @Published var actionType: CoInsuredAction
    let contractId: String
    let coInsuredModel: CoInsuredModel
    var editCoInsuredService = EditCoInsuredService()

    func showErrorView(inputError: String?) -> Bool {
        return SSNError ?? inputError != nil
    }

    var cancellables = Set<AnyCancellable>()
    init(
        coInsuredModel: CoInsuredModel,
        actionType: CoInsuredAction,
        contractId: String
    ) {
        self.coInsuredModel = coInsuredModel
        self.personalData = PersonalData(
            firstName: coInsuredModel.firstName ?? "",
            lastName: coInsuredModel.lastName ?? ""
        )
        self.SSN = coInsuredModel.SSN ?? ""
        self.birthday = coInsuredModel.birthDate ?? ""
        self.actionType = actionType
        self.contractId = contractId
        if !(coInsuredModel.birthDate ?? "").isEmpty {
            noSSN = true
            enterManually = true
        }

        if !(coInsuredModel.SSN ?? "").isEmpty {
            nameFetchedFromSSN = true
        }
    }

    func setUpPreviousValue() -> CoInsuredModel {
        let hasSSN = SSN != ""
        noSSN = hasSSN ? false : true
        return CoInsuredModel(
            firstName: personalData.firstName,
            lastName: personalData.lastName,
            SSN: hasSSN ? SSN : nil,
            birthDate: !hasSSN ? birthday : nil,
            needsMissingInfo: false
        )
    }

    @MainActor
    func getNameFromSSN(SSN: String) async {
        withAnimation {
            self.SSNError = nil
            self.isLoading = true
        }
        do {
            let data = try await editCoInsuredService.getPersonalInformation(SSN: SSN)
            withAnimation {
                if let data = data {
                    self.personalData = data
                    self.nameFetchedFromSSN = true
                }
            }
        } catch let exception {
            if let exception = exception as? EditCoInsuredError {
                switch exception {
                case .missingSSN:
                    withAnimation {
                        self.noSSN = true
                        self.enterManually = true
                        self.showInfoForMissingSSN = true
                    }
                case .otherError, .serviceError:
                    self.enterManually = false
                    withAnimation {
                        self.SSNError = exception.localizedDescription
                    }
                }
            } else {
                withAnimation {
                    self.SSNError = exception.localizedDescription
                }
            }
        }
        withAnimation {
            self.isLoading = false
        }
    }
}
