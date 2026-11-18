import Foundation
import hCore

/// The five mileage bands from the design, with 1 500 mil as the current one.
public class ChangeMileageClientDemo: ChangeMileageClient {
    public init() {}

    public func createIntent(contractId _: String) async throws -> ChangeMileageIntent {
        let bands: [(name: String, price: Float)] = [
            ("1 000 mil", 371),
            ("1 500 mil", 412),
            ("2 000 mil", 449),
            ("2 500 mil", 486),
            ("Över 2 500 mil", 529),
        ]
        let currentIndex = 1
        let quotes = bands.enumerated()
            .map { index, band in
                let isCurrent = index == currentIndex
                return MileageQuote(
                    id: "demo-mileage-quote-\(index)",
                    displayName: band.name,
                    isCurrent: isCurrent,
                    totalCost: .init(gross: .sek(band.price), net: .sek(band.price)),
                    displayItems: [
                        .init(
                            title: "Körsträcka per år",
                            value: band.name,
                            previousValue: isCurrent ? nil : bands[currentIndex].name
                        ),
                        .init(title: "Registreringsnummer", value: "ABC 123", previousValue: nil),
                        .init(title: "Skyddsnivå", value: "Helförsäkring", previousValue: nil),
                    ]
                )
            }
        let currentPrice = bands[currentIndex].price
        return .init(
            activationDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
            currentTotalCost: .init(gross: .sek(currentPrice), net: .sek(currentPrice)),
            quotes: quotes
        )
    }

    public func commitIntent(quoteId _: String) async throws {}
}
