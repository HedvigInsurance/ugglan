import hCore

struct MockData {

    static func createMockFetchClaimService(
        fetch: @escaping FetchClaims = {
            .init(
                repeating: .init(
                    id: "id",
                    status: .beingHandled,
                    outcome: .none,
                    submittedAt: nil,
                    signedAudioURL: nil,
                    memberFreeText: nil,
                    payoutAmount: nil,
                    targetFileUploadUri: "",
                    claimType: "",
                    incidentDate: nil,
                    productVariant: nil,
                    conversation: nil
                ),
                count: 0
            )
        },
        fetchFiles: @escaping FetchFiles = {
            [:]
        }
    ) -> MockFetchClaimService {
        let service = MockFetchClaimService(
            fetch: fetch,
            fetchFiles: fetchFiles
        )
        Dependencies.shared.add(module: Module { () -> hFetchClaimClient in service })
        return service
    }

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

    static func createMockFileUploaderService(
        uploadFile: @escaping Upload = { flowId, file in
            .init(audioUrl: "https://audioUrl")
        }
    ) -> MockFileUploaderService {
        let service = MockFileUploaderService(uploadFile: uploadFile)
        Dependencies.shared.add(module: Module { () -> FileUploaderClient in service })
        return service
    }

    static func createMockSubmitClaimService(
        start: @escaping ClaimStart = { entrypointId, entrypointOptionId in
            .init(
                claimId: "claim id",
                context: "context",
                progress: 0.5,
                action: .startClaimRequest(entrypointId: entrypointId, entrypointOptionId: entrypointOptionId)
            )
        },
        update: @escaping ContractUpdate = { phoneNumber, context in
            .init(
                claimId: "claim id",
                context: context,
                progress: 0.5,
                action: .phoneNumberRequest(phoneNumber: phoneNumber)
            )
        },
        dateOfOccurrenceAndLocation: @escaping DateOfOccurrenceAndLocation = { context in
            .init(
                claimId: "claim id",
                context: context,
                progress: 0.5,
                action: .dateOfOccurrenceAndLocationRequest
            )
        },
        audioRecording: @escaping AudioRecording = { type, fileUploaderClient, context in
            .init(
                claimId: "claim id",
                context: context,
                progress: 0.5,
                action: .submitAudioRecording(type: type)
            )
        },
        singleItem: @escaping SingleItem = { purchasePrice, context in
            .init(
                claimId: "claim id",
                context: context,
                progress: 0.5,
                action: .singleItemRequest(purchasePrice: purchasePrice)
            )

        },
        summary: @escaping Summary = { context in
            .init(
                claimId: "claim id",
                context: context,
                progress: 0.5,
                action: .summaryRequest
            )
        },
        singleItemCheckout: @escaping SingleItemCheckout = { context in
            .init(
                claimId: "claim id",
                context: context,
                progress: 0.5,
                action: .singleItemCheckoutRequest
            )
        },
        contractSelect: @escaping ContractSelect = { contractId, context in
            .init(
                claimId: "claim id",
                context: context,
                progress: 0.5,
                action: .contractSelectRequest(contractId: contractId)
            )
        },
        emergencyConfirm: @escaping EmergencyConfirm = { isEmeregency, context in
            .init(
                claimId: "claim id",
                context: context,
                progress: 0.5,
                action: .emergencyConfirmRequest(isEmergency: isEmeregency)
            )
        },
        submitFile: @escaping SubmitFile = { ids, context in
            .init(
                claimId: "claim id",
                context: context,
                progress: 0.5,
                action: .submitFileUpload(ids: ids)
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
}

typealias FetchClaims = () async throws -> [ClaimModel]
typealias FetchFiles = () async throws -> [String: [hCore.File]]

class MockFetchClaimService: hFetchClaimClient {
    var events = [Event]()
    var fetch: FetchClaims
    var fetchFiles: FetchFiles

    enum Event {
        case get
        case getFiles
    }

    init(
        fetch: @escaping FetchClaims,
        fetchFiles: @escaping FetchFiles
    ) {
        self.fetch = fetch
        self.fetchFiles = fetchFiles
    }

    func get() async throws -> [ClaimModel] {
        events.append(.get)
        let data = try await fetch()
        return data
    }

    func getFiles() async throws -> [String: [hCore.File]] {
        events.append(.getFiles)
        let data = try await fetchFiles()
        return data
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

typealias ClaimStart = (String?, String?) async throws -> SubmitClaimStepResponse
typealias ContractUpdate = (String, String) async throws -> SubmitClaimStepResponse
typealias DateOfOccurrenceAndLocation = (String) async throws -> SubmitClaimStepResponse
typealias AudioRecording = (SubmitAudioRecordingType, any FileUploaderClient, String) async throws ->
    SubmitClaimStepResponse
typealias SingleItem = (Double?, String) async throws -> SubmitClaimStepResponse
typealias Summary = (String) async throws -> SubmitClaimStepResponse
typealias SingleItemCheckout = (String) async throws -> SubmitClaimStepResponse
typealias ContractSelect = (String, String) async throws -> SubmitClaimStepResponse
typealias EmergencyConfirm = (Bool, String) async throws -> SubmitClaimStepResponse
typealias SubmitFile = ([String], String) async throws -> SubmitClaimStepResponse

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

    func updateContact(phoneNumber: String, context: String) async throws -> SubmitClaimStepResponse {
        events.append(.updateContact)
        let data = try await update(phoneNumber, context)
        return data
    }

    func dateOfOccurrenceAndLocationRequest(context: String) async throws -> SubmitClaimStepResponse {
        events.append(.dateOfOccurrenceAndLocationRequest)
        let data = try await dateOfOccurrenceAndLocation(context)
        return data
    }

    func submitAudioRecording(
        type: SubmitAudioRecordingType,
        fileUploaderClient: any FileUploaderClient,
        context: String
    ) async throws -> SubmitClaimStepResponse {
        events.append(.submitAudioRecording)
        let data = try await audioRecording(type, fileUploaderClient, context)
        return data
    }

    func singleItemRequest(purchasePrice: Double?, context: String) async throws -> SubmitClaimStepResponse {
        events.append(.singleItemRequest)
        let data = try await singleItem(purchasePrice, context)
        return data
    }

    func summaryRequest(context: String) async throws -> SubmitClaimStepResponse {
        events.append(.summaryRequest)
        let data = try await summary(context)
        return data
    }

    func singleItemCheckoutRequest(context: String) async throws -> SubmitClaimStepResponse {
        events.append(.singleItemCheckoutRequest)
        let data = try await singleItemCheckout(context)
        return data
    }

    func contractSelectRequest(contractId: String, context: String) async throws -> SubmitClaimStepResponse {
        events.append(.contractSelectRequest)
        let data = try await contractSelect(contractId, context)
        return data
    }

    func emergencyConfirmRequest(isEmergency: Bool, context: String) async throws -> SubmitClaimStepResponse {
        events.append(.emergencyConfirmRequest)
        let data = try await emergencyConfirm(isEmergency, context)
        return data
    }

    func submitFileUpload(ids: [String], context: String) async throws -> SubmitClaimStepResponse {
        events.append(.submitFileUpload)
        let data = try await submitFile(ids, context)
        return data
    }
}
