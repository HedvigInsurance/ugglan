import hCore

@testable import SubmitClaim

@MainActor
struct MockData {
    @discardableResult
    static func createMockFetchEntrypointsService(
        fetchEntrypoints: @escaping FetchEntrypoints = {
            .init(
                repeating: .init(
                    id: "id",
                    displayName: "display name",
                    entrypoints: []
                ),
                count: 0
            )
        }
    ) -> MockFetchEntrypointsService {
        let service = MockFetchEntrypointsService(fetchEntrypoints: fetchEntrypoints)
        Dependencies.shared.add(module: Module { () -> hFetchEntrypointsClient in service })
        return service
    }

    @discardableResult
    static func createMockSubmitClaimService(
        start: @escaping ClaimStart = { _, _ in
            .init(
                claimId: "claim id",
                context: "context",
                progress: 0.5,
                step: .setSuccessStep(model: .init(id: "")),
                nextStepId: ""
            )
        },
        update: @escaping ContractUpdate = { phoneNumber, context, _ in
            .init(
                claimId: "claim id",
                context: context,
                progress: 0.5,
                step: .setPhoneNumber(model: .init(id: "id", phoneNumber: phoneNumber)),
                nextStepId: ""
            )
        },
        dateOfOccurrenceAndLocation: @escaping DateOfOccurrenceAndLocation = { context, _ in
            .init(
                claimId: "claim id",
                context: context,
                progress: 0.5,
                step: .setDateOfOccurrencePlusLocation(model: .init(dateOfOccurencePlusLocationModel: nil)),
                nextStepId: ""
            )
        },
        audioRecording: @escaping AudioRecording = { _, context, _, _ in
            .init(
                claimId: "claim id",
                context: context,
                progress: 0.5,
                step: .setAudioStep(
                    model: .init(id: "", questions: [], textQuestions: [], inputTextContent: nil, optionalAudio: true)
                ),
                nextStepId: ""
            )
        },
        singleItem: @escaping SingleItem = { context, _ in
            .init(
                claimId: "claim id",
                context: context,
                progress: 0.5,
                step: .setSingleItem(
                    model: .init(
                        id: "",
                        availableItemBrandOptions: [],
                        availableItemModelOptions: [],
                        availableItemProblems: [],
                        prefferedCurrency: nil,
                        currencyCode: nil,
                        defaultItemProblems: nil,
                        purchasePriceApplicable: true
                    )
                ),
                nextStepId: ""
            )
        },
        summary: @escaping Summary = { context, _ in
            .init(
                claimId: "claim id",
                context: context,
                progress: 0.5,
                step: .setSummaryStep(
                    model: .init(
                        summaryStep: nil,
                        singleItemStepModel: nil,
                        dateOfOccurenceModel: .init(id: "", maxDate: nil),
                        locationModel: .init(id: "", options: []),
                        audioRecordingModel: nil,
                        fileUploadModel: nil
                    )
                ),
                nextStepId: ""
            )
        },
        singleItemCheckout: @escaping SingleItemCheckout = { context, _ in
            .init(
                claimId: "claim id",
                context: context,
                progress: 0.5,
                step: .setSingleItemCheckoutStep(
                    model: .init(
                        id: "",
                        payoutMethods: [],
                        compensation: .init(
                            id: "",
                            deductible: .init(amount: "", currency: ""),
                            payoutAmount: .init(amount: "", currency: ""),
                            repairCompensation: nil,
                            valueCompensation: nil
                        ),
                        singleItemModel: nil
                    )
                ),
                nextStepId: ""
            )
        },
        contractSelect: @escaping ContractSelect = { _, context, _ in
            .init(
                claimId: "claim id",
                context: context,
                progress: 0.5,
                step: .setContractSelectStep(model: .init(availableContractOptions: [])),
                nextStepId: ""
            )
        },
        emergencyConfirm: @escaping EmergencyConfirm = { _, context in
            .init(
                claimId: "claim id",
                context: context,
                progress: 0.5,
                step: .setConfirmDeflectEmergencyStepModel(
                    model: .init(id: "", text: "", confirmEmergency: nil, options: [])
                ),
                nextStepId: ""
            )
        },
        submitFile: @escaping SubmitFile = { _, context, _ in
            .init(
                claimId: "claim id",
                context: context,
                progress: 0.5,
                step: .setFileUploadStep(model: .init(id: "", title: "", targetUploadUrl: "", uploads: [])),
                nextStepId: ""
            )
        }
    ) -> MockSubmitClaimService {
        let service = MockSubmitClaimService(
            start: start,
            update: update,
            dateOfOccurrenceAndLocation: dateOfOccurrenceAndLocation,
            audioRecording: audioRecording,
            singleItem: singleItem,
            summary: summary,
            singleItemCheckout: singleItemCheckout,
            contractSelect: contractSelect,
            emergencyConfirm: emergencyConfirm,
            submitFile: submitFile
        )
        Dependencies.shared.add(module: Module { () -> SubmitClaimClient in service })
        return service
    }

    @discardableResult
    static func createMockFileUploaderService(
        uploadFile: @escaping Upload = { _, _ in
            .init(audioUrl: "https://audioUrl")
        }
    ) -> MockFileUploaderService {
        let service = MockFileUploaderService(uploadFile: uploadFile)
        Dependencies.shared.add(module: Module { () -> FileUploaderClient in service })
        return service
    }
}

typealias FetchEntrypoints = () async throws -> [ClaimEntryPointGroupResponseModel]

class MockFetchEntrypointsService: hFetchEntrypointsClient {
    var events = [Event]()
    var fetchEntrypoints: FetchEntrypoints

    enum Event {
        case fetchEntrypoints
    }

    init(
        fetchEntrypoints: @escaping FetchEntrypoints
    ) {
        self.fetchEntrypoints = fetchEntrypoints
    }

    func get() async throws -> [ClaimEntryPointGroupResponseModel] {
        events.append(.fetchEntrypoints)
        let data = try await fetchEntrypoints()
        return data
    }
}

typealias ClaimStart = (String?, String?) async throws -> SubmitClaimStepResponse
typealias ContractUpdate = (String, String, FlowClaimPhoneNumberStepModel) async throws -> SubmitClaimStepResponse
typealias DateOfOccurrenceAndLocation = (String, SubmitClaimStep.DateOfOccurrencePlusLocationStepModels?) async throws
    -> SubmitClaimStepResponse
typealias AudioRecording = (
    SubmitAudioRecordingType, String, String, FlowClaimAudioRecordingStepModel
) async throws ->
    SubmitClaimStepResponse
typealias SingleItem = (String, FlowClaimSingleItemStepModel) async throws -> SubmitClaimStepResponse
typealias Summary = (String, SubmitClaimStep.SummaryStepModels) async throws -> SubmitClaimStepResponse
typealias SingleItemCheckout = (String, FlowClaimSingleItemCheckoutStepModel) async throws -> SubmitClaimStepResponse
typealias ContractSelect = (String, String, FlowClaimContractSelectStepModel) async throws -> SubmitClaimStepResponse
typealias EmergencyConfirm = (Bool, String) async throws -> SubmitClaimStepResponse
typealias SubmitFile = ([String], String, FlowClaimFileUploadStepModel) async throws -> SubmitClaimStepResponse

class MockSubmitClaimService: SubmitClaimClient {
    var events = [Event]()
    var start: ClaimStart
    var update: ContractUpdate
    var dateOfOccurrenceAndLocation: DateOfOccurrenceAndLocation
    var audioRecording: AudioRecording
    var singleItem: SingleItem
    var summary: Summary
    var singleItemCheckout: SingleItemCheckout
    var contractSelect: ContractSelect
    var emergencyConfirm: EmergencyConfirm
    var submitFile: SubmitFile

    enum Event {
        case startClaim
        case updateContact
        case dateOfOccurrenceAndLocationRequest
        case submitAudioRecording
        case singleItemRequest
        case summaryRequest
        case singleItemCheckoutRequest
        case contractSelectRequest
        case emergencyConfirmRequest
        case submitFileUpload
    }

    init(
        start: @escaping ClaimStart,
        update: @escaping ContractUpdate,
        dateOfOccurrenceAndLocation: @escaping DateOfOccurrenceAndLocation,
        audioRecording: @escaping AudioRecording,
        singleItem: @escaping SingleItem,
        summary: @escaping Summary,
        singleItemCheckout: @escaping SingleItemCheckout,
        contractSelect: @escaping ContractSelect,
        emergencyConfirm: @escaping EmergencyConfirm,
        submitFile: @escaping SubmitFile
    ) {
        self.start = start
        self.update = update
        self.dateOfOccurrenceAndLocation = dateOfOccurrenceAndLocation
        self.audioRecording = audioRecording
        self.singleItem = singleItem
        self.summary = summary
        self.singleItemCheckout = singleItemCheckout
        self.contractSelect = contractSelect
        self.emergencyConfirm = emergencyConfirm
        self.submitFile = submitFile
    }

    func startClaim(entrypointId: String?, entrypointOptionId: String?) async throws -> SubmitClaimStepResponse {
        events.append(.startClaim)
        let data = try await start(entrypointId, entrypointOptionId)
        return data
    }

    func updateContact(
        phoneNumber: String,
        context: String,
        model: FlowClaimPhoneNumberStepModel
    ) async throws -> SubmitClaimStepResponse {
        events.append(.updateContact)
        let data = try await update(phoneNumber, context, model)
        return data
    }

    func dateOfOccurrenceAndLocationRequest(
        context: String,
        model: SubmitClaimStep.DateOfOccurrencePlusLocationStepModels
    ) async throws -> SubmitClaimStepResponse {
        events.append(.dateOfOccurrenceAndLocationRequest)
        let data = try await dateOfOccurrenceAndLocation(context, model)
        return data
    }

    func submitAudioRecording(
        type: SubmitAudioRecordingType,
        context: String,
        currentClaimId: String,
        model: FlowClaimAudioRecordingStepModel
    ) async throws -> SubmitClaimStepResponse {
        events.append(.submitAudioRecording)
        let data = try await audioRecording(type, context, currentClaimId, model)
        return data
    }

    func singleItemRequest(
        context: String,
        model: FlowClaimSingleItemStepModel
    ) async throws -> SubmitClaimStepResponse {
        events.append(.singleItemRequest)
        let data = try await singleItem(context, model)
        return data
    }

    func summaryRequest(
        context: String,
        model: SubmitClaimStep.SummaryStepModels
    ) async throws -> SubmitClaimStepResponse {
        events.append(.summaryRequest)
        let data = try await summary(context, model)
        return data
    }

    func singleItemCheckoutRequest(
        context: String,
        model: FlowClaimSingleItemCheckoutStepModel
    ) async throws -> SubmitClaimStepResponse {
        events.append(.singleItemCheckoutRequest)
        let data = try await singleItemCheckout(context, model)
        return data
    }

    func contractSelectRequest(
        contractId: String,
        context: String,
        model: FlowClaimContractSelectStepModel
    ) async throws -> SubmitClaimStepResponse {
        events.append(.contractSelectRequest)
        let data = try await contractSelect(contractId, context, model)
        return data
    }

    func emergencyConfirmRequest(isEmergency: Bool, context: String) async throws -> SubmitClaimStepResponse {
        events.append(.emergencyConfirmRequest)
        let data = try await emergencyConfirm(isEmergency, context)
        return data
    }

    func submitFileUpload(
        ids: [String],
        context: String,
        model: FlowClaimFileUploadStepModel
    ) async throws -> SubmitClaimStepResponse {
        events.append(.submitFileUpload)
        let data = try await submitFile(ids, context, model)
        return data
    }
}

typealias Upload = (String, hCore.UploadFile) async throws -> UploadFileResponseModel

class MockFileUploaderService: FileUploaderClient {
    var events = [Event]()
    var uploadFile: Upload

    enum Event {
        case upload
    }

    init(
        uploadFile: @escaping Upload
    ) {
        self.uploadFile = uploadFile
    }

    func upload(flowId: String, file: hCore.UploadFile) async throws -> UploadFileResponseModel {
        events.append(.upload)
        let data = try await uploadFile(flowId, file)
        return data
    }
}
