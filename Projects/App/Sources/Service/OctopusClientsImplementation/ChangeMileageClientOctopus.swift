import ChangeMileageCore
import Foundation
import hCore
import hGraphQL

class ChangeMileageClientOctopus: ChangeMileageClient {
    @Inject var octopus: hOctopus

    func createIntent(contractId: String) async throws -> ChangeMileageIntent {
        let mutation = OctopusGraphQL.ChangeMileageCreateIntentMutation(contractId: contractId)
        let output: OctopusGraphQL.ChangeMileageCreateIntentMutation.Data.ChangeMileageCreateIntent
        do {
            guard let data = try await octopus.client.mutation(mutation: mutation) else {
                throw ChangeMileageError.somethingWentWrong
            }
            output = data.changeMileageCreateIntent
        } catch {
            throw ChangeMileageError.somethingWentWrong
        }
        if let userError = output.asUserError {
            throw ChangeMileageError.userError(message: userError.message)
        }
        guard let intent = output.asChangeMileageIntent else {
            throw ChangeMileageError.somethingWentWrong
        }
        return ChangeMileageIntent(
            activationDate: intent.activationDate.localDateToDate ?? Date(),
            currentTotalCost: .init(fragment: intent.currentTotalCost.fragments.itemCostFragment),
            quotes: intent.quotes.map { quote in
                MileageQuote(
                    id: quote.id,
                    displayName: quote.displayName,
                    isCurrent: quote.isCurrent,
                    totalCost: .init(fragment: quote.totalCost.fragments.itemCostFragment),
                    displayItems: quote.displayItems.map {
                        .init(title: $0.displayTitle, value: $0.displayValue, previousValue: $0.previousDisplayValue)
                    }
                )
            }
        )
    }

    func commitIntent(quoteId: String) async throws {
        let mutation = OctopusGraphQL.ChangeMileageCommitIntentMutation(quoteId: quoteId)
        let data: OctopusGraphQL.ChangeMileageCommitIntentMutation.Data?
        do {
            data = try await Task.withMinimumDuration(.seconds(3)) {
                try await octopus.client.mutation(mutation: mutation)
            }
        } catch {
            throw ChangeMileageError.somethingWentWrong
        }
        if let userError = data?.changeMileageCommitIntent?.message {
            throw ChangeMileageError.userError(message: userError)
        }
    }
}
