import Apollo
import hCore
import hGraphQL
import Home
import TestingUtil

extension JSONObject {
    public static func makeCommonClaims() -> JSONObject {
        GraphQL.CommonClaimsQuery.Data(commonClaims: [
            .init(
                title: "Mock",
                icon: .init(
                    variants: .init(
                        dark: .init(pdfUrl: ""),
                        light: .init(pdfUrl: "")
                    )
                ),
                layout: .makeTitleAndBulletPoints(
                    color: .black,
                    bulletPoints: [],
                    buttonTitle: "A button", claimFirstMessage: "Mock",
                    title: "Mock title"
                )
            ),
        ]).jsonObject
    }

    public static func makeActive() -> JSONObject {
        combineMultiple([
            GraphQL.HomeQuery.Data(
                member: .init(firstName: "Mock"),
                contracts: [.init(status: .makeActiveStatus())]
            ).jsonObject,
            GraphQL.HomeInsuranceProvidersQuery.Data(insuranceProviders: [.init(name: "Hedvig", switchable: true)]).jsonObject,
            makeCommonClaims(),
        ])
    }

    public static func makeActiveInFuture(switchable: Bool) -> JSONObject {
        combineMultiple([
            GraphQL.HomeQuery.Data(
                member: .init(firstName: "Mock"),
                contracts: [.init(status: .makeActiveInFutureStatus(futureInception: Date().localDateString))]
            ).jsonObject,
            GraphQL.HomeInsuranceProvidersQuery.Data(insuranceProviders: [.init(name: "Hedvig", switchable: switchable)]).jsonObject,
            makeCommonClaims(),
        ])
    }

    public static func makePending(switchable: Bool) -> JSONObject {
        combineMultiple([
            GraphQL.HomeQuery.Data(
                member: .init(firstName: "Mock"),
                contracts: [
                    .init(
                        switchedFromInsuranceProvider: "Hedvig",
                        status: .makePendingStatus()
                    ),
                ]
            ).jsonObject,
            GraphQL.HomeInsuranceProvidersQuery.Data(insuranceProviders: [.init(name: "Hedvig", switchable: switchable)]).jsonObject,
            makeCommonClaims(),
        ])
    }
}
