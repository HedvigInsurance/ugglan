import Foundation
@preconcurrency import XCTest
import hCore

@testable import TerminateContracts

@MainActor
final class TerminateContractsTests: XCTestCase {
    weak var sut: MockTerminateContractsService?
    let context = "context"

    override func setUp() async throws {
        try await super.setUp()
    }

    override func tearDown() async throws {
        Dependencies.shared.remove(for: TerminateContractsClient.self)
        try await Task.sleep(seconds: 0.0000001)

        XCTAssertNil(sut)
    }

    func testSendTerminationDateSuccess() async {
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })

        let date = "2025-01-17"
        let model: TerminationFlowDateNextStepModel = .init(
            id: "id",
            maxDate: "2025-11-11",
            minDate: Date().localDateString,
            date: nil,
            extraCoverageItem: [
                .init(displayName: "Travel plus", displayValue: "45 days")
            ]
        )

        let terminationDateResponse: TerminateStepResponse = .init(
            context: context,
            step: .setTerminationDateStep(model: model),
            progress: nil
        )

        let mockService = MockData.createMockTerminateContractsService(sendDate: { _, _ in
            terminationDateResponse
        })
        sut = mockService

        let respons = try! await mockService.sendTerminationDate(inputDateToString: date, terminationContext: context)

        assert(respons.step == terminationDateResponse.step)
        assert(respons.context == terminationDateResponse.context)
        assert(respons.progress == terminationDateResponse.progress)
    }

    func testConfirmDeleteSuccess() async {
        let model: TerminationFlowDeletionNextModel = .init(
            id: "id",
            extraCoverageItem: [
                .init(displayName: "Travel plus", displayValue: "45 days")
            ]
        )

        let terminationConfirmDeleteResponse: TerminateStepResponse = .init(
            context: context,
            step: .setTerminationDeletion(model: model),
            progress: nil
        )

        let mockService = MockData.createMockTerminateContractsService(confirmDelete: { _, _ in
            terminationConfirmDeleteResponse
        })
        sut = mockService

        let respons = try! await mockService.sendConfirmDelete(terminationContext: context, model: model)

        assert(respons.step == terminationConfirmDeleteResponse.step)
        assert(respons.context == terminationConfirmDeleteResponse.context)
        assert(respons.progress == terminationConfirmDeleteResponse.progress)
    }

    func testSubmitSurveySuccess() async {
        let model: TerminationFlowSurveyStepModel = .init(
            id: "id",
            options: [
                .init(
                    id: "idOption1",
                    title: "option 1",
                    suggestion: nil,
                    feedBack: .init(id: "feedback id", isRequired: true),
                    subOptions: [
                        .init(
                            id: "subOptionId1",
                            title: "sub option 1",
                            suggestion: nil,
                            feedBack: .init(id: "id", isRequired: false),
                            subOptions: nil
                        )
                    ]
                ),
                .init(id: "idOption2", title: "option 2", suggestion: nil, feedBack: nil, subOptions: nil),
            ],
            subTitleType: .generic
        )

        let terminationSurveyResponse: TerminateStepResponse = .init(
            context: context,
            step: .setTerminationSurveyStep(model: model),
            progress: nil
        )

        let mockService = MockData.createMockTerminateContractsService(surveySend: { _, _, _ in
            terminationSurveyResponse
        })
        sut = mockService

        let respons = try! await mockService.sendSurvey(
            terminationContext: context,
            option: "option",
            inputData: "input data"
        )

        assert(respons.step == terminationSurveyResponse.step)
        assert(respons.context == terminationSurveyResponse.context)
        assert(respons.progress == terminationSurveyResponse.progress)
    }
}
