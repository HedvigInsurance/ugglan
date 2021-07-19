import Apollo
import Contracts
import TestingUtil
import hCore
import hGraphQL

extension JSONObject {
	public static func makeNorwegianHomeContentContract(
		status: GraphQL.ContractsQuery.Data.Contract.Status
	) -> JSONObject {
		GraphQL.ContractsQuery.Data
			.Contract(
				id: "mock_norwegian_123",
				displayName: "Mock norwegian home",
				perils: [],
				insurableLimits: [],
				termsAndConditions: .init(displayName: "mock", url: "https://www.mock.com/terms.pdf"),
				status: status,
                upcomingAgreementDetailsTable: .init(title: "", sections: []),
                currentAgreement: .makeNorwegianHomeContentAgreement(
                    numberCoInsured: 0,
                    address: .init(street: "mock", postalCode: "122 22"),
                    squareMeters: 30
                )
			)
			.jsonObject
	}

	public static func makeNorwegianTravelContract(
		status: GraphQL.ContractsQuery.Data.Contract.Status
	) -> JSONObject {
		GraphQL.ContractsQuery.Data
			.Contract(
				id: "mock_norwegian_travel_123",
				displayName: "Mock norwegian travel",
				perils: [],
				insurableLimits: [],
				termsAndConditions: .init(displayName: "mock", url: "https://www.mock.com/terms.pdf"),
				status: status,
                upcomingAgreementDetailsTable: .init(title: "", sections: []),
                currentAgreement: .makeNorwegianTravelAgreement(numberCoInsured: 0)
			)
			.jsonObject
	}

	public static func makeSwedishHouseContract(status: GraphQL.ContractsQuery.Data.Contract.Status) -> JSONObject {
		GraphQL.ContractsQuery.Data
			.Contract(
				id: "mock_swedish_house_123",
				displayName: "Mock swedish house",
				perils: [],
				insurableLimits: [],
				termsAndConditions: .init(displayName: "mock", url: "https://www.mock.com/terms.pdf"),
				status: status,
                upcomingAgreementDetailsTable: .init(title: "", sections: []),
				currentAgreement: .makeSwedishHouseAgreement(
					numberCoInsured: 0,
					address: .init(street: "mock", postalCode: "122 22"),
					squareMeters: 119,
					yearOfConstruction: 1996,
					ancillaryArea: 50,
					isSubleted: true,
					numberOfBathrooms: 0,
					extraBuildings: []
				)
			)
			.jsonObject
	}
}
