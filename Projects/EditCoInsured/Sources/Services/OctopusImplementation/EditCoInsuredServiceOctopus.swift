import Foundation
import hCore
import hGraphQL

public class EditCoInsuredServiceOctopus: EditCoInsuredService {
    @Inject var octopus: hOctopus
    public init() {}

    public func sendMidtermChangeIntentCommit(commitId: String) async throws {
        let mutation = OctopusGraphQL.MidtermChangeIntentCommitMutation(intentId: commitId)
        try await octopus.client.perform(mutation: mutation)
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

    public func sendIntent(contractId: String, coInsured: [CoInsuredModel]) async throws -> IntentData? {
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
        if let intent = data.intent {
            return IntentData(
                activationDate: intent.activationDate,
                currentPremium: .init(fragment: intent.currentPremium.fragments.moneyFragment),
                newPremium: .init(fragment: intent.newPremium.fragments.moneyFragment),
                id: intent.id,
                state: intent.state.rawValue
            )
        } else if let userError = data.userError {
            return IntentData(
                userErrorMessage: userError.message ?? ""
            )
        }
        return nil
    }
}

public struct PersonalData {
    public var firstName: String
    public var lastName: String
    public let fullname: String

    init(
        firstName: String,
        lastName: String
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.fullname = firstName + " " + lastName
    }
}

public struct IntentData {
    let intent: Intent?
    let userErrorMessage: String?

    init(
        activationDate: String,
        currentPremium: MonetaryAmount,
        newPremium: MonetaryAmount,
        id: String,
        state: String
    ) {
        self.intent = Intent(
            activationDate: activationDate,
            currentPremium: currentPremium,
            newPremium: newPremium,
            id: id,
            state: state
        )
        self.userErrorMessage = nil
    }

    init(
        userErrorMessage: String
    ) {
        self.intent = nil
        self.userErrorMessage = userErrorMessage
    }
}

public struct Intent {
    let activationDate: String
    let currentPremium: MonetaryAmount
    let newPremium: MonetaryAmount
    let id: String
    let state: String
}
