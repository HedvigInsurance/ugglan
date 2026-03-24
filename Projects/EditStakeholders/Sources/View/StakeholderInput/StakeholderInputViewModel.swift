import Combine
import Foundation
import SwiftUI
import hCoreUI

@MainActor
public class StakeholderInputViewModel: ObservableObject {
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
    @Published var type: StakeholderInputType?
    @Published var actionType: StakeholderAction
    let contractId: String
    let stakeholderModel: Stakeholder
    var editStakeholdersService = EditStakeholdersService()

    func showErrorView(inputError: String?) -> Bool {
        SSNError ?? inputError != nil
    }

    init(
        stakeholderModel: Stakeholder,
        actionType: StakeholderAction,
        contractId: String
    ) {
        self.stakeholderModel = stakeholderModel
        personalData = PersonalData(
            firstName: stakeholderModel.firstName ?? "",
            lastName: stakeholderModel.lastName ?? ""
        )
        SSN = stakeholderModel.SSN ?? ""
        birthday = stakeholderModel.birthDate ?? ""
        self.actionType = actionType
        self.contractId = contractId
        if !(stakeholderModel.birthDate ?? "").isEmpty {
            noSSN = true
            enterManually = true
        }

        if !(stakeholderModel.SSN ?? "").isEmpty {
            nameFetchedFromSSN = true
        }
    }

    @MainActor
    func getNameFromSSN(SSN: String) async {
        withAnimation {
            self.SSNError = nil
            self.isLoading = true
        }
        do {
            let data = try await editStakeholdersService.getPersonalInformation(SSN: SSN)
            withAnimation {
                if let data = data {
                    self.personalData = data
                    self.nameFetchedFromSSN = true
                }
            }
        } catch let exception {
            if let exception = exception as? EditStakeholdersError {
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
