import Presentation
import SwiftUI
import hCore

public indirect enum SubmitClaimsAction: ActionProtocol, Hashable {
    case dissmissNewClaimFlow
    case popClaimFlow
    case submitClaimOpenFreeTextChat

    case fetchEntrypointGroups
    case setClaimEntrypointsForSelection([ClaimEntryPointResponseModel])
    case setClaimEntrypointGroupsForSelection([ClaimEntryPointGroupResponseModel])
    case commonClaimOriginSelected(commonClaim: ClaimsOrigin)

    case submitAudioRecording(type: SubmitAudioRecordingType)
    case resetAudioRecording

    case setNewClaimId(with: String)
    case setNewClaimContext(context: String)

    case startClaimRequest(entrypointId: String?, entrypointOptionId: String?)
    case phoneNumberRequest(phoneNumber: String)
    case dateOfOccurrenceAndLocationRequest
    case singleItemRequest(purchasePrice: Double?)
    case emergencyConfirmRequest(isEmergency: Bool)
    case summaryRequest
    case singleItemCheckoutRequest
    case contractSelectRequest(contractId: String?)
    case submitFileUpload(ids: [String])

    case setNewLocation(location: ClaimFlowLocationOptionModel?)
    case setNewDate(dateOfOccurrence: String?)
    case setPurchasePrice(priceOfPurchase: Double?)
    case setSingleItemDamage(damages: [String])
    case setSingleItemPurchaseDate(purchaseDate: Date?)
    case setItemBrand(brand: ClaimFlowItemBrandOptionModel)
    case setItemModel(model: SelectedModel)
    case setPayoutMethod(method: AvailableCheckoutMethod)
    case setLocation(location: String?)
    case setProgress(progress: Float?)

    case navigationAction(action: SubmitClaimsNavigationAction)
    case stepModelAction(action: ClaimsStepModelAction)
    case setSelectedEntrypoints(entrypoints: [ClaimEntryPointResponseModel])
    case setSelectedEntrypoint(entrypoint: ClaimEntryPointResponseModel)
    case setSelectedEntrypointOptions(entrypoints: [ClaimEntryPointOptionResponseModel], entrypointId: String?)
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
    case openSummaryEditScreen
    case openClaimCheckoutScreen
    case openCheckoutTransferringScreen
    case openFailureSceen
    case openUpdateAppScreen
    case openNotificationsPermissionScreen
    case openSelectContractScreen
    case openTriagingGroupScreen
    case openTriagingEntrypointScreen
    case openTriagingOptionScreen
    case openDeflectScreen
    case openConfirmEmergencyScreen
    case openFileUploadScreen

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

    public struct DateOfOccurrencePlusLocationStepModels: ActionProtocol, Hashable {
        let dateOfOccurencePlusLocationModel: FlowClaimDateOfOccurrencePlusLocationStepModel
        let dateOfOccurenceModel: FlowClaimDateOfOccurenceStepModel
        let locationModel: FlowClaimLocationStepModel
    }

    public struct SummaryStepModels: ActionProtocol, Hashable {
        let summaryStep: FlowClaimSummaryStepModel?
        let singleItemStepModel: FlowClamSingleItemStepModel?
        let dateOfOccurenceModel: FlowClaimDateOfOccurenceStepModel
        let locationModel: FlowClaimLocationStepModel
        let audioRecordingModel: FlowClaimAudioRecordingStepModel?
        let fileUploadModel: FlowClaimFileUploadStepModel?
    }

    case setPhoneNumber(model: FlowClaimPhoneNumberStepModel)
    case setDateOfOccurrencePlusLocation(model: DateOfOccurrencePlusLocationStepModels)
    case setDateOfOccurence(model: FlowClaimDateOfOccurenceStepModel)
    case setLocation(model: FlowClaimLocationStepModel)
    case setSingleItem(model: FlowClamSingleItemStepModel)
    case setSummaryStep(model: SummaryStepModels)
    case setSingleItemCheckoutStep(model: FlowClaimSingleItemCheckoutStepModel)
    case setSuccessStep(model: FlowClaimSuccessStepModel)
    case setFailedStep(model: FlowClaimFailedStepModel)
    case setAudioStep(model: FlowClaimAudioRecordingStepModel?)
    case setContractSelectStep(model: FlowClaimContractSelectStepModel)
    case setConfirmDeflectEmergencyStepModel(model: FlowClaimConfirmEmergencyStepModel)
    case setDeflectModel(model: FlowClaimDeflectStepModel)
    case setFileUploadStep(model: FlowClaimFileUploadStepModel?)
}

extension ClaimsStepModelAction {
    var nextStepAction: SubmitClaimsNavigationAction {
        switch self {
        case .setPhoneNumber(let model):
            return .openPhoneNumberScreen(model: model)
        case .setDateOfOccurrencePlusLocation:
            return .openDateOfOccurrencePlusLocationScreen(options: [.date, .location])
        case .setDateOfOccurence:
            return .openDateOfOccurrencePlusLocationScreen(options: [.date])
        case .setLocation:
            return .openDateOfOccurrencePlusLocationScreen(options: [.location])
        case .setSingleItem:
            return .openSingleItemScreen
        case .setSummaryStep:
            return .openSummaryScreen
        case .setSingleItemCheckoutStep:
            return .openClaimCheckoutScreen
        case .setSuccessStep:
            return .openSuccessScreen
        case .setFailedStep:
            return .openFailureSceen
        case .setAudioStep:
            return .openAudioRecordingScreen
        case .setContractSelectStep:
            return .openSelectContractScreen
        case .setConfirmDeflectEmergencyStepModel:
            return .openConfirmEmergencyScreen
        case .setDeflectModel(let model):
            switch model.id {
            case .Unknown:
                return .openUpdateAppScreen
            default:
                return .openDeflectScreen
            }
        case .setFileUploadStep:
            return .openFileUploadScreen
        }
    }
}

public enum ClaimsLoadingType: LoadingProtocol {
    case startClaim
    case fetchClaimEntrypointGroups
    case postPhoneNumber
    case postDateOfOccurrenceAndLocation
    case postSingleItem
    case postSummary
    case postSingleItemCheckout
    case postAudioRecording
    case postContractSelect
    case postConfirmEmergency
    case postUploadFiles
}
