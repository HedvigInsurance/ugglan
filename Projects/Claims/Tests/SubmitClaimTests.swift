import XCTest
import hCore

@testable import Claims

final class SubmitClaimTests: XCTestCase {
    weak var sut: MockSubmitClaimService?
    let context = "context"

    override func setUp() {
        super.setUp()
        sut = nil
    }

    override func tearDown() async throws {
        Dependencies.shared.remove(for: SubmitClaimClient.self)
        try await Task.sleep(nanoseconds: 100)

        XCTAssertNil(sut)
    }

    func testStartNewClaimSuccess() async {
        let startClaimResponse: SubmitClaimStepResponse = .init(
            claimId: "claimId",
            context: context,
            progress: 0.1,
            action: .startClaimRequest(
                entrypointId: "entrypointId",
                entrypointOptionId: "entrypointOptionId"
            )
        )

        let mockService = MockData.createMockSubmitClaimService(
            start: { entrypointId, entrypointOptionId in
                startClaimResponse
            }
        )
        self.sut = mockService

        let respons = try! await mockService.start("entrypointId", "entrypointOptionId")
        assert(respons.claimId == startClaimResponse.claimId)
        assert(respons.context == startClaimResponse.context)
        assert(respons.progress == startClaimResponse.progress)
        assert(respons.action == startClaimResponse.action)
    }

    func testUpdateClaimSuccess() async {
        let phoneNumer = "0712121212"

        let updateClaimResponse: SubmitClaimStepResponse = .init(
            claimId: "claimId",
            context: context,
            progress: 0.1,
            action: .phoneNumberRequest(phoneNumber: phoneNumer)
        )

        let mockService = MockData.createMockSubmitClaimService(
            update: { phoneNumber, context in
                updateClaimResponse
            }
        )
        self.sut = mockService

        let respons = try! await mockService.update(phoneNumer, context)
        assert(respons.claimId == updateClaimResponse.claimId)
        assert(respons.context == updateClaimResponse.context)
        assert(respons.progress == updateClaimResponse.progress)
        assert(respons.action == updateClaimResponse.action)
    }

    func testDateOfOccurrenceAndLocationSuccess() async {
        let dateOfOccurrenceAndLocationResponse: SubmitClaimStepResponse = .init(
            claimId: "claimId",
            context: context,
            progress: 0.3,
            action: .dateOfOccurrenceAndLocationRequest
        )

        let mockService = MockData.createMockSubmitClaimService(
            dateOfOccurrenceAndLocation: { context in
                dateOfOccurrenceAndLocationResponse
            }
        )
        self.sut = mockService

        let respons = try! await mockService.dateOfOccurrenceAndLocation(context)
        assert(respons.claimId == dateOfOccurrenceAndLocationResponse.claimId)
        assert(respons.context == dateOfOccurrenceAndLocationResponse.context)
        assert(respons.progress == dateOfOccurrenceAndLocationResponse.progress)
        assert(respons.action == dateOfOccurrenceAndLocationResponse.action)
    }

    func testAudioRecordingSuccess() async {
        let audioRecordingType: SubmitAudioRecordingType = .audio(url: URL(string: "/file")!)
        let fileUploaderClient: MockFileUploaderService = .init(
            uploadFile: { flowId, file in
                return .init(audioUrl: "/file")
            }
        )

        let audioRecordingResponse: SubmitClaimStepResponse = .init(
            claimId: "claimId",
            context: context,
            progress: 0.3,
            action: .submitAudioRecording(type: audioRecordingType)
        )

        let mockService = MockData.createMockSubmitClaimService(
            audioRecording: { type, fileUploaderClient, context in
                audioRecordingResponse
            }
        )
        self.sut = mockService

        let respons = try! await mockService.audioRecording(audioRecordingType, fileUploaderClient, context)
        assert(respons.claimId == audioRecordingResponse.claimId)
        assert(respons.context == audioRecordingResponse.context)
        assert(respons.progress == audioRecordingResponse.progress)
        assert(respons.action == audioRecordingResponse.action)
    }

    func testSingleItemSuccess() async {
        let purchasePrice = 11300.00

        let singleItemResponse: SubmitClaimStepResponse = .init(
            claimId: "claimId",
            context: context,
            progress: 0.3,
            action: .singleItemRequest(purchasePrice: purchasePrice)
        )

        let mockService = MockData.createMockSubmitClaimService(
            singleItem: { purchasePrice, context in
                singleItemResponse
            }
        )
        self.sut = mockService

        let respons = try! await mockService.singleItem(purchasePrice, context)
        assert(respons.claimId == singleItemResponse.claimId)
        assert(respons.context == singleItemResponse.context)
        assert(respons.progress == singleItemResponse.progress)
        assert(respons.action == singleItemResponse.action)
    }

    func testSummarySuccess() async {
        let summaryResponse: SubmitClaimStepResponse = .init(
            claimId: "claimId",
            context: context,
            progress: 0.3,
            action: .summaryRequest
        )

        let mockService = MockData.createMockSubmitClaimService(
            summary: { context in
                summaryResponse
            }
        )
        self.sut = mockService

        let respons = try! await mockService.summary(context)
        assert(respons.claimId == summaryResponse.claimId)
        assert(respons.context == summaryResponse.context)
        assert(respons.progress == summaryResponse.progress)
        assert(respons.action == summaryResponse.action)
    }

    func testSingleItemCheckoutSuccess() async {
        let singleItemCheckoutResponse: SubmitClaimStepResponse = .init(
            claimId: "claimId",
            context: context,
            progress: 0.3,
            action: .singleItemCheckoutRequest
        )

        let mockService = MockData.createMockSubmitClaimService(
            singleItemCheckout: { context in
                singleItemCheckoutResponse
            }
        )
        self.sut = mockService

        let respons = try! await mockService.singleItemCheckout(context)
        assert(respons.claimId == singleItemCheckoutResponse.claimId)
        assert(respons.context == singleItemCheckoutResponse.context)
        assert(respons.progress == singleItemCheckoutResponse.progress)
        assert(respons.action == singleItemCheckoutResponse.action)
    }

    func testContractSelectSuccess() async {
        let contractId = "contractId"
        let contractSelectResponse: SubmitClaimStepResponse = .init(
            claimId: "claimId",
            context: context,
            progress: 0.3,
            action: .contractSelectRequest(contractId: contractId)
        )

        let mockService = MockData.createMockSubmitClaimService(
            contractSelect: { contractId, context in
                contractSelectResponse
            }
        )
        self.sut = mockService

        let respons = try! await mockService.contractSelect(contractId, context)
        assert(respons.claimId == contractSelectResponse.claimId)
        assert(respons.context == contractSelectResponse.context)
        assert(respons.progress == contractSelectResponse.progress)
        assert(respons.action == contractSelectResponse.action)
    }

    func testEmergencyConfirmSuccess() async {
        let isEmergency = true

        let emergencyConfirmResponse: SubmitClaimStepResponse = .init(
            claimId: "claimId",
            context: context,
            progress: 0.3,
            action: .emergencyConfirmRequest(isEmergency: isEmergency)
        )

        let mockService = MockData.createMockSubmitClaimService(
            emergencyConfirm: { isEmeregency, context in
                emergencyConfirmResponse
            }
        )
        self.sut = mockService

        let respons = try! await mockService.emergencyConfirmRequest(isEmergency: isEmergency, context: context)
        assert(respons.claimId == emergencyConfirmResponse.claimId)
        assert(respons.context == emergencyConfirmResponse.context)
        assert(respons.progress == emergencyConfirmResponse.progress)
        assert(respons.action == emergencyConfirmResponse.action)
    }

    func testSubmitFileSuccess() async {
        let ids: [String] = ["id1", "id2", "id3"]
        let submitFileResponse: SubmitClaimStepResponse = .init(
            claimId: "claimId",
            context: context,
            progress: 0.3,
            action: .submitFileUpload(ids: ids)
        )

        let mockService = MockData.createMockSubmitClaimService(
            submitFile: { ids, context in
                submitFileResponse
            }
        )
        self.sut = mockService

        let respons = try! await mockService.submitFile(ids, context)
        assert(respons.claimId == submitFileResponse.claimId)
        assert(respons.context == submitFileResponse.context)
        assert(respons.progress == submitFileResponse.progress)
        assert(respons.action == submitFileResponse.action)
    }
}
