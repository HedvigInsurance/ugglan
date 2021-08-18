import Apollo
import Foundation
import Home
import TestingUtil
import hCore
import hGraphQL

func addDaysToDate(_ days: Int = 30) -> Date {
    let today = Date()

    var dateComponent = DateComponents()
    dateComponent.day = days
    dateComponent.hour = 0

    let futureDate = Calendar.current.date(byAdding: dateComponent, to: today)

    return futureDate ?? Date()
}

extension JSONObject {
    public static func makeCommonClaims() -> JSONObject {
        GraphQL.CommonClaimsQuery
            .Data(commonClaims: [
                .init(
                    title: "Mock",
                    icon: .init(variants: .init(dark: .init(pdfUrl: ""), light: .init(pdfUrl: ""))),
                    layout: .makeTitleAndBulletPoints(
                        color: .black,
                        bulletPoints: [],
                        buttonTitle: "A button",
                        claimFirstMessage: "Mock",
                        title: "Mock title"
                    )
                )
            ])
            .jsonObject
    }

    public static func makeActiveWithRenewal() -> JSONObject {
        combineMultiple([
            GraphQL.HomeQuery
                .Data(
                    member: .init(firstName: "Mock"),
                    contracts: [
                        .init(
                            displayName: "Home insurance",
                            status: .makeActiveStatus(),
                            upcomingRenewal: .init(
                                renewalDate: addDaysToDate().localDateString ?? "",
                                draftCertificateUrl:
                                    "https://cdn.hedvig.com/info/se/sv/forsakringsvillkor-hyresratt-2020-08-v2.pdf"
                            )
                        )
                    ]
                )
                .jsonObject
        ])
    }

    public static func makeActiveWithMultipleRenewals() -> JSONObject {
        combineMultiple([
            GraphQL.HomeQuery
                .Data(
                    member: .init(firstName: "Mock"),
                    contracts: [
                        .init(
                            displayName: "Home insurance",
                            status: .makeActiveStatus(),
                            upcomingRenewal: .init(
                                renewalDate: addDaysToDate().localDateString ?? "",
                                draftCertificateUrl:
                                    "https://cdn.hedvig.com/info/se/sv/forsakringsvillkor-hyresratt-2020-08-v2.pdf"
                            )
                        ),
                        .init(
                            displayName: "Travel insurance",
                            status: .makeActiveStatus(),
                            upcomingRenewal: .init(
                                renewalDate: addDaysToDate().localDateString ?? "",
                                draftCertificateUrl:
                                    "https://cdn.hedvig.com/info/se/sv/forsakringsvillkor-hyresratt-2020-08-v2.pdf"
                            )
                        ),
                    ]
                )
                .jsonObject
        ])
    }

    public static func makeActiveWithMultipleRenewalsOnSeparateDates() -> JSONObject {
        combineMultiple([
            GraphQL.HomeQuery
                .Data(
                    member: .init(firstName: "Mock"),
                    contracts: [
                        .init(
                            displayName: "Home insurance",
                            status: .makeActiveStatus(),
                            upcomingRenewal: .init(
                                renewalDate: addDaysToDate().localDateString ?? "",
                                draftCertificateUrl:
                                    "https://cdn.hedvig.com/info/se/sv/forsakringsvillkor-hyresratt-2020-08-v2.pdf"
                            )
                        ),
                        .init(
                            displayName: "Travel insurance",
                            status: .makeActiveStatus(),
                            upcomingRenewal: .init(
                                renewalDate: addDaysToDate(20).localDateString ?? "",
                                draftCertificateUrl:
                                    "https://cdn.hedvig.com/info/se/sv/forsakringsvillkor-hyresratt-2020-08-v2.pdf"
                            )
                        ),
                    ]
                )
                .jsonObject
        ])
    }

    public static func makeActive() -> JSONObject {
        combineMultiple([
            GraphQL.HomeQuery
                .Data(
                    member: .init(firstName: "Mock"),
                    contracts: [.init(displayName: "Home insurance", status: .makeActiveStatus())]
                )
                .jsonObject,
            GraphQL.HomeInsuranceProvidersQuery
                .Data(insuranceProviders: [.init(id: "hedvig", name: "Hedvig", switchable: true)]).jsonObject,
            makeCommonClaims(),
        ])
    }

    public static func makeActiveInFuture(switchable: Bool) -> JSONObject {
        combineMultiple([
            GraphQL.HomeQuery
                .Data(
                    member: .init(firstName: "Mock"),
                    contracts: [
                        .init(
                            displayName: "Home insurance",
                            status: .makeActiveInFutureStatus(
                                futureInception: Date().localDateString
                            )
                        )
                    ]
                )
                .jsonObject,
            GraphQL.HomeInsuranceProvidersQuery
                .Data(insuranceProviders: [.init(id: "hedvig", name: "Hedvig", switchable: switchable)]).jsonObject,
            makeCommonClaims(),
        ])
    }

    public static func makePending(switchable: Bool) -> JSONObject {
        combineMultiple([
            GraphQL.HomeQuery
                .Data(
                    member: .init(firstName: "Mock"),
                    contracts: [
                        .init(
                            displayName: "Home insurance",
                            switchedFromInsuranceProvider: "Hedvig",
                            status: .makePendingStatus()
                        )
                    ]
                )
                .jsonObject,
            GraphQL.HomeInsuranceProvidersQuery
                .Data(insuranceProviders: [.init(id: "hedvig", name: "Hedvig", switchable: switchable)]).jsonObject,
            makeCommonClaims(),
        ])
    }

    public static func makeTerminatedInTheFuture() -> JSONObject {
        combineMultiple([
            GraphQL.HomeQuery
                .Data(
                    member: .init(firstName: "Mock"),
                    contracts: [
                        .init(
                            displayName: "Home insurance",
                            switchedFromInsuranceProvider: "Hedvig",
                            status: .makeTerminatedInFutureStatus()
                        )
                    ]
                )
                .jsonObject, makeCommonClaims(),
        ])
    }
}
