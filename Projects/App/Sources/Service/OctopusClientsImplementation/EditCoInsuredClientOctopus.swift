import EditCoInsured
import Foundation
import hCore
import hGraphQL

class EditCoInsuredClientOctopus: EditCoInsuredClient {
    @Inject var octopus: hOctopus

    func sendMidtermChangeIntentCommit(commitId: String) async throws {
        let mutation = OctopusGraphQL.MidtermChangeIntentCommitMutation(intentId: commitId)
        let delayTask = Task {
            try await Task.sleep(seconds: 3)
        }
        let clientTask = Task { @MainActor in
            let data = try await octopus.client.mutation(mutation: mutation)
            if let error = data?.midtermChangeIntentCommit.userError {
                return error.message
            }
            return nil
        }
        try await delayTask.value
        if let error = try await clientTask.value {
            throw EditCoInsuredError.serviceError(message: error)
        }
    }

    func getPersonalInformation(SSN: String) async throws -> PersonalData? {
        let SSNInput = OctopusGraphQL.PersonalInformationInput(personalNumber: SSN)
        let query = OctopusGraphQL.PersonalInformationQuery(input: SSNInput)
        do {
            let data = try await octopus.client.fetch(
                query: query
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

    func sendIntent(
        contractId: String,
        coInsured: [StakeHolder],
        stakeHolderType: StakeHolderType
    ) async throws -> Intent {
        let coInsuredInputs: GraphQLNullable<[OctopusGraphQL.CoInsuredInput]>
        let coOwnersInputs: GraphQLNullable<[OctopusGraphQL.CoOwnersInput]>

        switch stakeHolderType {
        case .coInsured:
            coInsuredInputs = .init(optionalValue: coInsured.map(\.asGqlCoInsured))
            coOwnersInputs = nil

        case .coOwner:
            coInsuredInputs = nil
            coOwnersInputs = .init(optionalValue: coInsured.map(\.asGqlCoOwner))
        }

        let mutation = OctopusGraphQL.MidtermChangeIntentCreateMutation(
            contractId: contractId,
            input: .init(coInsuredInputs: coInsuredInputs, coOwnersInputs: coOwnersInputs)
        )
        let data = try await octopus.client.mutation(mutation: mutation)?.midtermChangeIntentCreate
        if let userError = data?.userError {
            throw EditCoInsuredError.serviceError(message: userError.message ?? L10n.General.errorBody)
        }
        guard let intent = data?.intent else {
            throw EditCoInsuredError.serviceError(message: L10n.General.errorBody)
        }
        return Intent(
            activationDate: intent.activationDate,
            currentTotalCost: .init(fragment: intent.currentTotalCost.fragments.totalCostFragment),
            newTotalCost: .init(fragment: intent.newTotalCost.fragments.totalCostFragment),
            id: intent.id,
            newCostBreakdown: intent.newCostBreakdown.compactMap({
                .init(fragment: $0.fragments.midtermChangePriceDetailItemFragment)
            })
        )
    }

    func fetchContracts() async throws -> [Contract] {
        let query = OctopusGraphQL.ContractsQuery()
        let data = try await octopus.client.fetch(
            query: query
        )
        return data.currentMember.activeContracts.compactMap { activeContract in
            Contract(
                contract: activeContract.fragments.contractFragment,
                firstName: data.currentMember.firstName,
                lastName: data.currentMember.lastName,
                ssn: data.currentMember.ssn
            )
        }
    }
}

@MainActor
extension StakeHolder {
    var asGqlCoInsured: OctopusGraphQL.CoInsuredInput {
        .init(
            firstName: GraphQLNullable(optionalValue: firstName),
            lastName: GraphQLNullable(optionalValue: lastName),
            ssn: GraphQLNullable(optionalValue: formattedSSN),
            birthdate: GraphQLNullable(optionalValue: birthDate?.calculate10DigitBirthDate)
        )
    }
    var asGqlCoOwner: OctopusGraphQL.CoOwnersInput {
        .init(
            firstName: GraphQLNullable(optionalValue: firstName),
            lastName: GraphQLNullable(optionalValue: lastName),
            ssn: GraphQLNullable(optionalValue: formattedSSN),
            birthdate: GraphQLNullable(optionalValue: birthDate?.calculate10DigitBirthDate)
        )
    }
}

@MainActor
extension Contract {
    public init(
        contract: OctopusGraphQL.ContractFragment,
        firstName: String,
        lastName: String,
        ssn: String?
    ) {
        self.init(
            id: contract.id,
            exposureDisplayName: contract.exposureDisplayName,
            supportsCoInsured: contract.supportsCoInsured,
            supportsCoOwners: contract.supportsCoOwners,
            upcomingChangedAgreement: .init(agreement: contract.upcomingChangedAgreement?.fragments.agreementFragment),
            currentAgreement: .init(agreement: contract.currentAgreement.fragments.agreementFragment),
            terminationDate: contract.terminationDate,
            coInsured: contract.coInsured?.map { .init(data: $0.fragments.coInsuredFragment) } ?? [],
            coOwners: contract.coOwners?.map { .init(data: $0.fragments.coOwnerFragment) } ?? [],
            firstName: firstName,
            lastName: lastName,
            ssn: ssn
        )
    }
}

extension Agreement {
    init?(
        agreement: OctopusGraphQL.AgreementFragment?
    ) {
        guard let agreement = agreement else {
            return nil
        }
        self.init(
            activeFrom: agreement.activeFrom,
            productVariant: .init(data: agreement.productVariant.fragments.productVariantFragment)
        )
    }
}

extension EditCoInsured.ProductVariant {
    public init(
        data: OctopusGraphQL.ProductVariantFragment
    ) {
        self.init(displayName: data.displayName)
    }
}

@MainActor
extension StakeHolder {
    public init(data: OctopusGraphQL.CoInsuredFragment) {
        self.init(
            firstName: data.firstName,
            lastName: data.lastName,
            SSN: data.ssn,
            birthDate: data.birthdate,
            needsMissingInfo: data.hasMissingInfo,
            activatesOn: data.activatesOn,
            terminatesOn: data.terminatesOn
        )
    }

    public init(data: OctopusGraphQL.CoOwnerFragment) {
        self.init(
            firstName: data.firstName,
            lastName: data.lastName,
            SSN: data.ssn,
            birthDate: data.birthdate,
            needsMissingInfo: data.hasMissingInfo,
            activatesOn: data.activatesOn,
            terminatesOn: data.terminatesOn
        )
    }
}

extension Premium {
    public init(
        fragment: OctopusGraphQL.TotalCostFragment
    ) {
        self.init(
            gross: .init(fragment: fragment.monthlyGross.fragments.moneyFragment),
            net: .init(fragment: fragment.monthlyNet.fragments.moneyFragment)
        )
    }
}

extension MidtermChangePriceDetailItem {
    public init(
        fragment: OctopusGraphQL.MidtermChangePriceDetailItemFragment
    ) {
        self.init(
            displayTitle: fragment.displayName,
            displayValue: fragment.displayValue
        )
    }
}
