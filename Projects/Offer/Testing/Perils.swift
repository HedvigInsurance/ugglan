import Apollo
import Foundation
import hGraphQL

func generatePerils() -> [GraphQL.QuoteBundleQuery.Data.QuoteBundle.Quote.ContractPeril] {
    return .init(
        repeating: .init(
            title: "Delays",
            description:
                "If you experience delays when travelling, we'll reimburse you for the extra costs. For example, if your bag does not arrive or if your flight is delayed and you have to stay overnight in a hotel.",
            icon: .init(
                variants: .init(
                    dark: .init(pdfUrl: "/app-content-service/delayed_luggage_dark.pdf"),
                    light: .init(pdfUrl: "/app-content-service/delayed_luggage.pdf")
                )
            ),
            covered: [
                "Delayed departure due to weather, technical errors or traffic accident: expenses for an overnight stay are covered – up to 1500 kronor per person an 3000 kronorr per family. This only applies if the journey already started and the transportation has been paid for",
                "Delayed arrival due to weather, technical errors or traffic accident: extra costs to change tickets or buy new ones are covered – up to 20 000 kronor per person and 50 000 kronor per family. If it's not possible to continue on the same day, expenses for overnight stays are also covered",
            ],
            exceptions: [
                "Delayed luggage on the return journey",
                "Delay, cancellation or overbooking covered by EU Directive 261/2004 for which the airlines themselves are responsible",
                "Financial loss or damage directly/indirectly caused by strikes, labour conflicts, lockouts or bankruptcy",
            ],
            info: ""
        ),
        count: 15
    )
}
