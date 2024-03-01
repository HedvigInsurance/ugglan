import Foundation
import hCore
import hGraphQL

public class EditCoInsuredServiceOctopus: EditCoInsuredService {
    @Inject var octopus: hOctopus
    public init() {}

    public func sendMidtermChangeIntentCommit(commitId: String) async throws {
        let mutation = OctopusGraphQL.MidtermChangeIntentCommitMutation(intentId: commitId)
        let data = try await octopus.client.perform(mutation: mutation)
        if let error = data.midtermChangeIntentCommit.userError {
            throw EditCoInsuredError.error(message: error.message ?? L10n.General.errorBody)
        }
    }

    public func getPersonalInformation(SSN: String) async throws -> PersonalData? {
        let SSNInput = OctopusGraphQL.PersonalInformationInput(personalNumber: SSN)
        let query = OctopusGraphQL.PersonalInformationQuery(input: SSNInput)
        let data = try await octopus.client.fetch(
            query: query,
            cachePolicy: .fetchIgnoringCacheCompletely
        )

        guard let data = data.personalInformation else {
            throw EditCoInsuredError.error(message: L10n.General.errorBody)
        }

        let personalData = PersonalData(firstName: data.firstName, lastName: data.lastName)
        return personalData
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
            throw EditCoInsuredError.error(message: userError.message ?? L10n.General.errorBody)
        }
        guard let intent = data.intent else {
            throw EditCoInsuredError.error(message: L10n.General.errorBody)
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
