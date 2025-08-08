import EditCoInsured
import Foundation
import hCore
import hGraphQL

class EditCoInsuredClientOctopus: EditCoInsuredClient {
    @Inject var octopus: hOctopus

    func sendMidtermChangeIntentCommit(commitId: String) async throws {
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

    func getPersonalInformation(SSN: String) async throws -> PersonalData? {
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

    func sendIntent(contractId: String, coInsured: [CoInsuredModel]) async throws -> Intent {
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
            //            currentCost: .init(fragment: intent.currentCost.fragments.itemCostFragment),
            //            newCost: .init(fragment: intent.newCost.fragments.itemCostFragment),
            currentTotalCost: .init(fragment: intent.currentTotalCost.fragments.itemCostFragment),
            newTotalCost: .init(fragment: intent.newTotalCost.fragments.itemCostFragment),
            id: intent.id,
            state: intent.state.rawValue,
            quote: .init(
                id: "quoteId",
                currentCost: .init(
                    discounts: [
                        .init(
                            amount: .sek(10),
                            campaignCode: "code",
                            displayName: "code name",
                            displayValue: "display value",
                            explanation: "explanation"
                        )
                    ],
                    monthlyGross: .sek(229),
                    montlyNet: .sek(219)
                ),
                newCost: .init(
                    discounts: [
                        .init(
                            amount: .sek(10),
                            campaignCode: "code",
                            displayName: "code name",
                            displayValue: "display value",
                            explanation: "explanation"
                        )
                    ],
                    monthlyGross: .sek(289),
                    montlyNet: .sek(289)
                ),
                exposureName: "exposure name",
                displayItems: [
                    .init(displayTitle: "title", displaySubtitle: nil, displayValue: "value")
                ],
                productVariant: .init(displayName: "display name"),
                addons: []
            )
            /* TODO: FILL WITH REAL DATA */
        )
    }

    func fetchContracts() async throws -> [Contract] {
        let query = OctopusGraphQL.ContractsQuery()
        let data = try await octopus.client.fetch(
            query: query,
            cachePolicy: .fetchIgnoringCacheCompletely
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
            upcomingChangedAgreement: .init(agreement: contract.upcomingChangedAgreement?.fragments.agreementFragment),
            currentAgreement: .init(agreement: contract.currentAgreement.fragments.agreementFragment),
            terminationDate: contract.terminationDate,
            coInsured: contract.coInsured?.map { .init(data: $0.fragments.coInsuredFragment) } ?? [],
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
extension CoInsuredModel {
    public init(
        data: OctopusGraphQL.CoInsuredFragment
    ) {
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

extension ItemCost {
    public init(
        fragment: OctopusGraphQL.ItemCostFragment
    ) {
        self.init(
            discounts: fragment.discounts.map({ .init(fragment: $0.fragments.itemDiscountFragment) }),
            monthlyGross: .init(fragment: fragment.monthlyGross.fragments.moneyFragment),
            montlyNet: .init(fragment: fragment.monthlyNet.fragments.moneyFragment)
        )
    }
}

extension ItemDiscount {
    public init(
        fragment: OctopusGraphQL.ItemDiscountFragment
    ) {
        self.init(
            amount: .init(fragment: fragment.amount.fragments.moneyFragment),
            campaignCode: fragment.campaignCode,
            displayName: fragment.displayName,
            displayValue: fragment.displayValue,
            explanation: fragment.explanation
        )
    }
}
