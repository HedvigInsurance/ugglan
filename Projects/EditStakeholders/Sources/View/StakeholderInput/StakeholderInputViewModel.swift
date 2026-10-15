import Combine
import Foundation
import SwiftUI
import hCore
import hCoreUI

@MainActor
@Observable
public class StakeholderInputViewModel {
    var personalData: PersonalData
    var noSSN = false
    var SSNError: String?
    var nameFetchedFromSSN: Bool = false
    var isLoading: Bool = false
    var intentViewState: ProcessingState = .success
    var enterManually: Bool = false
    var showInfoForMissingSSN = false
    var SSN: String
    var birthday: String
    var type: StakeholderInputType?
    var actionType: StakeholderAction
    let contractId: String
    let stakeholderModel: Stakeholder
    @ObservationIgnored var editStakeholdersService = EditStakeholdersService()

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
            let data = try await editStakeholdersService.fetchPersonalInformation(SSN: SSN)
            withAnimation {
                if let data = data {
                    self.personalData = data
                    self.nameFetchedFromSSN = true
                }
            }
        } catch EditStakeholdersError.missingSSN {
            withAnimation {
                self.noSSN = true
                self.enterManually = true
                self.showInfoForMissingSSN = true
            }
        } catch {
            self.enterManually = false
            withAnimation {
                self.SSNError = error.localizedDescription
            }
        }
        withAnimation {
            self.isLoading = false
        }
    }
}
