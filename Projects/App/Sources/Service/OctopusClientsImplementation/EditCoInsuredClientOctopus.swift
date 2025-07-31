import EditCoInsured
import EditCoInsuredShared
import Foundation
import hCore
import hGraphQL

class EditCoInsuredClientOctopus: EditCoInsuredClient {
    @Inject var octopus: hOctopus

    public func sendMidtermChangeIntentCommit(commitId: String) async throws {
        let mutation = OctopusGraphQL.MidtermChangeIntentCommitMutation(intentId: commitId)
        let delayTask = Task {
            try await Task.sleep(nanoseconds: 3_000_000_000)
        }
        let clientTask = Task { @MainActor in
            let data = try await octopus.client.perform(mutation: mutation)
            if let error = data.midtermChangeIntentCommit.userError {
                return error.message
            }
            return nil
        }
        try await delayTask.value
        if let error = try await clientTask.value {
            throw EditCoInsuredError.serviceError(message: error)
        }
    }

    public func getPersonalInformation(SSN: String) async throws -> PersonalData? {
        let SSNInput = OctopusGraphQL.PersonalInformationInput(personalNumber: SSN)
        let query = OctopusGraphQL.PersonalInformationQuery(input: SSNInput)
        do {
            let data = try await octopus.client.fetch(
                query: query,
                cachePolicy: .fetchIgnoringCacheCompletely
            )
            guard let data = data.personalInformation else {
                throw EditCoInsuredError.missingSSN
            }

            let personalData = PersonalData(firstName: data.firstName, lastName: data.lastName)
            return personalData
        } catch let exception {
            if let exception = exception as? GraphQLError {
                switch exception {
                case .graphQLError:
                    throw EditCoInsuredError.serviceError(message: exception.localizedDescription)
                case .otherError:
                    throw EditCoInsuredError.otherError
                }
            } else if let exception = exception as? EditCoInsuredError {
                throw exception
            } else {
                throw EditCoInsuredError.otherError
            }
        }
    }

    public func sendIntent(contractId: String, coInsured: [CoInsuredModel]) async throws -> Intent {
        let coInsuredList = coInsured.map { coIn in
            OctopusGraphQL.CoInsuredInput(
                firstName: GraphQLNullable(optionalValue: coIn.firstName),
                lastName: GraphQLNullable(optionalValue: coIn.lastName),
                ssn: GraphQLNullable(optionalValue: coIn.formattedSSN),
                birthdate: GraphQLNullable(optionalValue: coIn.birthDate?.calculate10DigitBirthDate)
            )
        }
        let coinsuredInput = OctopusGraphQL.MidtermChangeIntentCreateInput(
            coInsuredInputs: GraphQLNullable(optionalValue: coInsuredList)
        )
        let mutation = OctopusGraphQL.MidtermChangeIntentCreateMutation(
            contractId: contractId,
            input: coinsuredInput
        )
        let data = try await octopus.client.perform(mutation: mutation).midtermChangeIntentCreate

        if let userError = data.userError {
            throw EditCoInsuredError.serviceError(message: userError.message ?? L10n.General.errorBody)
        }
        guard let intent = data.intent else {
            throw EditCoInsuredError.serviceError(message: L10n.General.errorBody)
        }
        return Intent(
            activationDate: intent.activationDate,
            currentPremium: .init(fragment: intent.currentPremium.fragments.moneyFragment),
            newPremium: .init(fragment: intent.newPremium.fragments.moneyFragment),
            id: intent.id,
            state: intent.state.rawValue
        )
    }
}
