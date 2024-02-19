import Foundation
import Presentation
import hCore

public struct SubmitClaimsState: StateProtocol {
    @Transient(defaultValue: "") var currentClaimId: String {
        didSet {
            do {
                var isDir: ObjCBool = true
                if FileManager.default.fileExists(
                    atPath: claimsAudioRecordingRootPath.relativePath,
                    isDirectory: &isDir
                ) {
                    let content = try FileManager.default
                        .contentsOfDirectory(atPath: claimsAudioRecordingRootPath.relativePath)
                        .filter({ URL(string: $0)?.pathExtension == AudioRecorder.audioFileExtension })
                    try content.forEach({
                        try FileManager.default.removeItem(
                            atPath: claimsAudioRecordingRootPath.appendingPathComponent($0).relativePath
                        )
                    })
                } else {
                    try FileManager.default.createDirectory(
                        at: claimsAudioRecordingRootPath,
                        withIntermediateDirectories: true
                    )
                }
            } catch _ {}
        }
    }
    @OptionalTransient var currentClaimContext: String?
    @Transient(defaultValue: []) var claimEntrypoints: [ClaimEntryPointResponseModel]
    @Transient(defaultValue: []) var claimEntrypointGroups: [ClaimEntryPointGroupResponseModel]
    @OptionalTransient var summaryStep: FlowClaimSummaryStepModel?
    @OptionalTransient var dateOfOccurenceStep: FlowClaimDateOfOccurenceStepModel?
    @OptionalTransient var locationStep: FlowClaimLocationStepModel?
    @OptionalTransient var singleItemStep: FlowClamSingleItemStepModel?
    @OptionalTransient var phoneNumberStep: FlowClaimPhoneNumberStepModel?
    @OptionalTransient var dateOfOccurrencePlusLocationStep: FlowClaimDateOfOccurrencePlusLocationStepModel?
    @OptionalTransient var singleItemCheckoutStep: FlowClaimSingleItemCheckoutStepModel?
    @OptionalTransient var successStep: FlowClaimSuccessStepModel?
    @OptionalTransient var failedStep: FlowClaimFailedStepModel?
    @OptionalTransient var audioRecordingStep: FlowClaimAudioRecordingStepModel?
    @OptionalTransient var contractStep: FlowClaimContractSelectStepModel?
    @OptionalTransient var emergencyConfirm: FlowClaimConfirmEmergencyStepModel?
    @OptionalTransient var emergencyStep: FlowClaimDeflectStepModel?
    @OptionalTransient var pestsStep: FlowClaimDeflectStepModel?
    @OptionalTransient var glassDamageStep: FlowClaimDeflectStepModel?
    @OptionalTransient var fileUploadStep: FlowClaimFileUploadStepModel?
    @OptionalTransient var progress: Float?
    @OptionalTransient var previousProgress: Float?
    @Transient(defaultValue: EntrypointState()) var entrypoints: EntrypointState

    var claimAudioRecordingPath: URL {
        let nameOfFile: String = {
            if currentClaimId.isEmpty {
                return "audio-file-recoding"
            }
            return currentClaimId
        }()
        let audioPath =
            claimsAudioRecordingRootPath
            .appendingPathComponent(nameOfFile)
            .appendingPathExtension(AudioRecorder.audioFileExtension)
        return audioPath
    }

    private var claimsAudioRecordingRootPath: URL {
        let tempDirectory = FileManager.default.temporaryDirectory
        let claimsAudioRecoringPath =
            tempDirectory
            .appendingPathComponent("claims")
        return claimsAudioRecoringPath
    }
    public init() {}
}

public enum ClaimsOrigin: Codable, Equatable, Hashable {
    case generic
    case commonClaims(id: String)
    case commonClaimsWithOption(id: String, optionId: String)

    public var id: CommonClaimId {
        switch self {
        case .generic:
            return CommonClaimId()
        case let .commonClaims(id):
            return CommonClaimId(id: id)
        case let .commonClaimsWithOption(id, optionId):
            return CommonClaimId(
                id: id,
                entrypointOptionId: optionId
            )
        }
    }
}

public struct CommonClaimId {
    public let id: String
    public let entrypointOptionId: String?

    init(
        id: String = "",
        entrypointOptionId: String? = nil
    ) {
        self.id = id
        self.entrypointOptionId = entrypointOptionId
    }
}

struct EntrypointState: Codable, Equatable, Hashable {
    var selectedEntrypoints: [ClaimEntryPointResponseModel]?
    var selectedEntrypointId: String?
    var selectedEntrypointOptions: [ClaimEntryPointOptionResponseModel]?
}
