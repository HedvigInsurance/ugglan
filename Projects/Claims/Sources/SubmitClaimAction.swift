import PresentableStore
import SwiftUI
import hCore

public indirect enum SubmitClaimsAction: ActionProtocol, Hashable {
    case dismissNewClaimFlow
    case popClaimFlow
    case submitClaimOpenFreeTextChat

    case setNewClaimId(with: String)

    case phoneNumberRequest(phoneNumber: String)
    case emergencyConfirmRequest(isEmergency: Bool)
    case summaryRequest
    case singleItemCheckoutRequest
    case contractSelectRequest(contractId: String?)

    case setPayoutMethod(method: AvailableCheckoutMethod)

    case setProgress(progress: Float?)
    case setOnlyProgress(progress: Float?)
    case setOnlyPreviousProgress(progress: Float?)

    case navigationAction(action: SubmitClaimsNavigationAction)
    case stepModelAction(action: ClaimsStepModelAction)
}

public enum SubmitAudioRecordingType: ActionProtocol, Hashable {
    case audio(url: URL)
    case text(text: String)
}

public enum SubmitClaimsNavigationAction: ActionProtocol, Hashable {
    case openPhoneNumberScreen(model: FlowClaimPhoneNumberStepModel)
    case openDateOfOccurrencePlusLocationScreen(options: SubmitClaimOption)
    case openAudioRecordingScreen
    case openSuccessScreen
    case openSingleItemScreen
    case openSummaryScreen
    case openClaimCheckoutScreen
    case openFailureSceen
    case openUpdateAppScreen
    case openSelectContractScreen
    case openDeflectScreen(type: FlowClaimDeflectStepType)
    case openConfirmEmergencyScreen
    case openFileUploadScreen
    case openCheckoutTransferringScreen

    public struct SubmitClaimOption: OptionSet, ActionProtocol, Hashable {
        public let rawValue: UInt

        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }

        static let location = SubmitClaimOption(rawValue: 1 << 0)
        static let date = SubmitClaimOption(rawValue: 1 << 1)

        var title: String {
            let hasLocation = self.contains(.location)
            let hasDate = self.contains(.date)
            if hasLocation && hasDate {
                return L10n.claimsLocatonOccuranceTitle
            } else if hasDate {
                return L10n.Claims.Incident.Screen.Date.Of.incident
            } else if hasLocation {
                return L10n.Claims.Incident.Screen.location
            }
            return ""
        }
    }
}

public enum ClaimsStepModelAction: ActionProtocol, Hashable {
    public struct SummaryStepModels: ActionProtocol, Hashable {
        let summaryStep: FlowClaimSummaryStepModel?
        let singleItemStepModel: FlowClamSingleItemStepModel?
        let dateOfOccurenceModel: FlowClaimDateOfOccurenceStepModel
        let locationModel: FlowClaimLocationStepModel
        let audioRecordingModel: FlowClaimAudioRecordingStepModel?
        let fileUploadModel: FlowClaimFileUploadStepModel?
    }

    case setPhoneNumber(model: FlowClaimPhoneNumberStepModel)
    case setSummaryStep(model: SummaryStepModels)
    case setSingleItemCheckoutStep(model: FlowClaimSingleItemCheckoutStepModel)
    case setSuccessStep(model: FlowClaimSuccessStepModel)
    case setFailedStep(model: FlowClaimFailedStepModel)
    case setContractSelectStep(model: FlowClaimContractSelectStepModel)
    case setConfirmDeflectEmergencyStepModel(model: FlowClaimConfirmEmergencyStepModel)
    case setDeflectModel(model: FlowClaimDeflectStepModel)
}

extension ClaimsStepModelAction {
    var nextStepAction: SubmitClaimsNavigationAction {
        switch self {
        case .setPhoneNumber(let model):
            return .openPhoneNumberScreen(model: model)
        case .setSummaryStep:
            return .openSummaryScreen
        case .setSingleItemCheckoutStep:
            return .openClaimCheckoutScreen
        case .setSuccessStep:
            return .openSuccessScreen
        case .setFailedStep:
            return .openFailureSceen
        case .setContractSelectStep:
            return .openSelectContractScreen
        case .setConfirmDeflectEmergencyStepModel:
            return .openConfirmEmergencyScreen
        case .setDeflectModel(let model):
            switch model.id {
            case .Unknown:
                return .openUpdateAppScreen
            default:
                return .openDeflectScreen(type: model.id)
            }
        }
    }
}

public enum ClaimsLoadingType: LoadingProtocol {
    case postPhoneNumber
    case postSummary
    case postSingleItemCheckout
    case postContractSelect
    case postConfirmEmergency
}
