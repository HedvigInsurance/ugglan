@preconcurrency import XCTest
import hCore

@testable import Claims
@testable import SubmitClaim

@MainActor
final class SubmitClaimTests: XCTestCase {
    weak var sut: MockSubmitClaimService?
    let context = "context"

    override func setUp() {
        super.setUp()
    }

    override func tearDown() async throws {
        Dependencies.shared.remove(for: SubmitClaimClient.self)
        try await Task.sleep(seconds: 0.0000001)

        XCTAssertNil(sut)
    }

    func testUpdateClaimSuccess() async {
        let phoneNumer = "0712121212"

        let model = FlowClaimPhoneNumberStepModel(id: "id", phoneNumber: phoneNumer)

        let updateClaimResponse: SubmitClaimStepResponse = .init(
            claimId: "claimId",
            context: context,
            progress: 0.1,
            step: .setPhoneNumber(model: model),
            nextStepId: ""
        )

        let mockService = MockData.createMockSubmitClaimService(
            update: { _, _, _ in
                updateClaimResponse
            }
        )
        sut = mockService

        let respons = try! await mockService.update(phoneNumer, context, model)
        assert(respons.claimId == updateClaimResponse.claimId)
        assert(respons.context == updateClaimResponse.context)
        assert(respons.progress == updateClaimResponse.progress)
        assert(respons.step == updateClaimResponse.step)
    }

    func testDateOfOccurrenceAndLocationSuccess() async {
        let model = SubmitClaimStep.DateOfOccurrencePlusLocationStepModels(
            dateOfOccurencePlusLocationModel: .init(id: "id")
        )

        let dateOfOccurrenceAndLocationResponse: SubmitClaimStepResponse = .init(
            claimId: "claimId",
            context: context,
            progress: 0.3,
            step: .setDateOfOccurrencePlusLocation(model: model),
            nextStepId: ""
        )

        let mockService = MockData.createMockSubmitClaimService(
            dateOfOccurrenceAndLocation: { _, _ in
                dateOfOccurrenceAndLocationResponse
            }
        )
        sut = mockService

        let respons = try! await mockService.dateOfOccurrenceAndLocation(context, model)
        assert(respons.claimId == dateOfOccurrenceAndLocationResponse.claimId)
        assert(respons.context == dateOfOccurrenceAndLocationResponse.context)
        assert(respons.progress == dateOfOccurrenceAndLocationResponse.progress)
        assert(respons.step == dateOfOccurrenceAndLocationResponse.step)
    }

    func testAudioRecordingSuccess() async throws {
        let claimId = "claimId"

        let audioRecordingType: SubmitAudioRecordingType = .audio(url: URL(string: "/file")!)
        let fileUploaderClient: MockFileUploaderService = .init(
            uploadFile: { _, _ in
                .init(audioUrl: "/file")
            }
        )

        let uploadResponse = try await fileUploaderClient.upload(
            flowId: "flowId",
            file: .init(data: Data(), name: "name", mimeType: MimeType.PDF.mime)
        )
        let model = FlowClaimAudioRecordingStepModel(
            id: "id",
            questions: [],
            audioContent: .init(audioUrl: "/file", signedUrl: uploadResponse.audioUrl),
            textQuestions: [],
            inputTextContent: nil,
            optionalAudio: false
        )
        let audioRecordingResponse: SubmitClaimStepResponse = .init(
            claimId: "claimId",
            context: context,
            progress: 0.3,
            step: .setAudioStep(model: model),
            nextStepId: ""
        )

        let mockService = MockData.createMockSubmitClaimService(
            audioRecording: { _, _, _, _ in
                audioRecordingResponse
            }
        )
        sut = mockService

        let respons = try! await mockService.audioRecording(
            audioRecordingType,
            context,
            claimId,
            model
        )
        assert(respons.claimId == audioRecordingResponse.claimId)
        assert(respons.context == audioRecordingResponse.context)
        assert(respons.progress == audioRecordingResponse.progress)
        assert(respons.step == audioRecordingResponse.step)
    }

    func testSingleItemSuccess() async {
        let model = FlowClaimSingleItemStepModel(
            id: "id",
            availableItemBrandOptions: [],
            availableItemModelOptions: [],
            availableItemProblems: [],
            prefferedCurrency: nil,
            currencyCode: nil,
            defaultItemProblems: nil,
            purchasePriceApplicable: true
        )

        let singleItemResponse: SubmitClaimStepResponse = .init(
            claimId: "claimId",
            context: context,
            progress: 0.3,
            step: .setSingleItem(model: model),
            nextStepId: ""
        )

        let mockService = MockData.createMockSubmitClaimService(
            singleItem: { _, _ in
                singleItemResponse
            }
        )
        sut = mockService

        let respons = try! await mockService.singleItem(context, model)
        assert(respons.claimId == singleItemResponse.claimId)
        assert(respons.context == singleItemResponse.context)
        assert(respons.progress == singleItemResponse.progress)
        assert(respons.step == singleItemResponse.step)
    }

    func testSummarySuccess() async {
        let model = SubmitClaimStep.SummaryStepModels(
            summaryStep: nil,
            singleItemStepModel: nil,
            dateOfOccurenceModel: .init(id: "id", maxDate: nil),
            locationModel: .init(id: "id", options: []),
            audioRecordingModel: nil,
            fileUploadModel: nil
        )

        let summaryResponse: SubmitClaimStepResponse = .init(
            claimId: "claimId",
            context: context,
            progress: 0.3,
            step: .setSummaryStep(model: model),
            nextStepId: ""
        )

        let mockService = MockData.createMockSubmitClaimService(
            summary: { _, _ in
                summaryResponse
            }
        )
        sut = mockService

        let respons = try! await mockService.summary(context, model)
        assert(respons.claimId == summaryResponse.claimId)
        assert(respons.context == summaryResponse.context)
        assert(respons.progress == summaryResponse.progress)
        assert(respons.step == summaryResponse.step)
    }

    func testSingleItemCheckoutSuccess() async {
        let model = FlowClaimSingleItemCheckoutStepModel(
            id: "id",
            payoutMethods: [],
            compensation: .init(
                id: "id",
                deductible: .init(amount: "220", currency: "SEK"),
                payoutAmount: .init(amount: "1000", currency: "SEK"),
                repairCompensation: nil,
                valueCompensation: nil
            ),
            singleItemModel: nil
        )

        let singleItemCheckoutResponse: SubmitClaimStepResponse = .init(
            claimId: "claimId",
            context: context,
            progress: 0.3,
            step: .setSingleItemCheckoutStep(model: model),
            nextStepId: ""
        )

        let mockService = MockData.createMockSubmitClaimService(
            singleItemCheckout: { _, _ in
                singleItemCheckoutResponse
            }
        )
        sut = mockService

        let respons = try! await mockService.singleItemCheckout(context, model)
        assert(respons.claimId == singleItemCheckoutResponse.claimId)
        assert(respons.context == singleItemCheckoutResponse.context)
        assert(respons.progress == singleItemCheckoutResponse.progress)
        assert(respons.step == singleItemCheckoutResponse.step)
    }

    func testContractSelectSuccess() async {
        let model = FlowClaimContractSelectStepModel(availableContractOptions: [])

        let contractId = "contractId"
        let contractSelectResponse: SubmitClaimStepResponse = .init(
            claimId: "claimId",
            context: context,
            progress: 0.3,
            step: .setContractSelectStep(model: model),
            nextStepId: ""
        )

        let mockService = MockData.createMockSubmitClaimService(
            contractSelect: { _, _, _ in
                contractSelectResponse
            }
        )
        sut = mockService

        let respons = try! await mockService.contractSelect(contractId, context, model)
        assert(respons.claimId == contractSelectResponse.claimId)
        assert(respons.context == contractSelectResponse.context)
        assert(respons.progress == contractSelectResponse.progress)
        assert(respons.step == contractSelectResponse.step)
    }

    func testEmergencyConfirmSuccess() async {
        let model = FlowClaimConfirmEmergencyStepModel(id: "id", text: "", confirmEmergency: nil, options: [])
        let isEmergency = true

        let emergencyConfirmResponse: SubmitClaimStepResponse = .init(
            claimId: "claimId",
            context: context,
            progress: 0.3,
            step: .setConfirmDeflectEmergencyStepModel(model: model),
            nextStepId: ""
        )

        let mockService = MockData.createMockSubmitClaimService(
            emergencyConfirm: { _, _ in
                emergencyConfirmResponse
            }
        )
        sut = mockService

        let respons = try! await mockService.emergencyConfirmRequest(isEmergency: isEmergency, context: context)
        assert(respons.claimId == emergencyConfirmResponse.claimId)
        assert(respons.context == emergencyConfirmResponse.context)
        assert(respons.progress == emergencyConfirmResponse.progress)
        assert(respons.step == emergencyConfirmResponse.step)
    }

    func testSubmitFileSuccess() async {
        let ids: [String] = ["id1", "id2", "id3"]
        let model = FlowClaimFileUploadStepModel(id: "id", title: "title", targetUploadUrl: "", uploads: [])

        let submitFileResponse: SubmitClaimStepResponse = .init(
            claimId: "claimId",
            context: context,
            progress: 0.3,
            step: .setFileUploadStep(model: model),
            nextStepId: ""
        )

        let mockService = MockData.createMockSubmitClaimService(
            submitFile: { _, _, _ in
                submitFileResponse
            }
        )
        sut = mockService

        let respons = try! await mockService.submitFile(ids, context, model)
        assert(respons.claimId == submitFileResponse.claimId)
        assert(respons.context == submitFileResponse.context)
        assert(respons.progress == submitFileResponse.progress)
        assert(respons.step == submitFileResponse.step)
    }
}
