import Presentation
import SwiftUI
import hCore

public enum SubmitClaimsAction: ActionProtocol, Hashable {
    case dissmissNewClaimFlow
    case submitClaimOpenFreeTextChat

    case fetchClaimEntrypointsForSelection(entrypointGroupId: String?)
    case fetchEntrypointGroups
    case setClaimEntrypointsForSelection([ClaimEntryPointResponseModel])
    case setClaimEntrypointGroupsForSelection([ClaimEntryPointGroupResponseModel])
    case commonClaimOriginSelected(commonClaim: ClaimsOrigin)

    case submitAudioRecording(audioURL: URL)
    case resetAudioRecording
    case submitDamage(damage: [String])

    case setNewClaimId(with: String)
    case setNewClaimContext(context: String)

    case startClaimRequest(entrypointId: String?, entrypointOptionId: String?)
    case phoneNumberRequest(phoneNumber: String)
    case dateOfOccurrenceRequest(dateOfOccurrence: Date?)
    case dateOfOccurrenceAndLocationRequest
    case locationRequest(location: ClaimFlowLocationOptionModel?)
    case singleItemRequest(purchasePrice: Double?)
    case summaryRequest
    case singleItemCheckoutRequest

    case setNewLocation(location: ClaimFlowLocationOptionModel?)
    case setNewDate(dateOfOccurrence: String?)
    case setPurchasePrice(priceOfPurchase: Double?)
    case setSingleItemModel(modelName: ClaimFlowItemModelOptionModel)
    case setSingleItemDamage(damages: [String])
    case setSingleItemPurchaseDate(purchaseDate: Date?)
    case setItemBrand(brand: ClaimFlowItemBrandOptionModel)
    case setLoadingState(action: ClaimsLoadingType, state: LoadingState<String>?)
    case setPayoutMethod(method: AvailableCheckoutMethod)

    case setProgress(progress: Float?)

    case navigationAction(action: ClaimsNavigationAction)
    case stepModelAction(action: ClaimsStepModelAction)
    case setSelectedEntrypoints(entrypoints: [ClaimEntryPointResponseModel])
    case setSelectedEntrypoint(entrypoint: ClaimEntryPointResponseModel)
    case setSelectedEntrypointOptions(entrypoints: [ClaimEntryPointOptionResponseModel])
    case setSelectedEntrypointId(entrypoints: String?)
}

public enum ClaimsNavigationAction: ActionProtocol, Hashable {
    case openPhoneNumberScreen(model: FlowClaimPhoneNumberStepModel)
    case openDateOfOccurrencePlusLocationScreen
    case openAudioRecordingScreen
    case openLocationPicker(type: LocationPickerType)
    case openDatePicker(type: DatePickerType)
    case openSuccessScreen
    case openSingleItemScreen
    case openSummaryScreen
    case openSummaryEditScreen
    case openDamagePickerScreen
    case openModelPicker
    case openBrandPicker
    case openPriceInput
    case openCheckoutNoRepairScreen
    case openCheckoutTransferringScreen
    case openFailureSceen
    case openUpdateAppScreen
    case openNotificationsPermissionScreen
    case openEntrypointScreen
    case openNewTriagingScreen
    case dismissInfoScreens
    case dismissScreen
    case dismissPreSubmitScreensAndStartClaim(origin: ClaimsOrigin)

    public enum LocationPickerType: ActionProtocol {
        case setLocation
        case submitLocation
    }

    public enum DatePickerType: ActionProtocol {
        case setDateOfOccurrence
        case submitDateOfOccurence
        case setDateOfPurchase

        var shouldShowModally: Bool {
            switch self {
            case .setDateOfOccurrence:
                return true
            case .submitDateOfOccurence:
                return false
            case .setDateOfPurchase:
                return true
            }
        }

        var title: String {
            switch self {
            case .setDateOfOccurrence, .submitDateOfOccurence:
                return L10n.Claims.Incident.Screen.Date.Of.incident
            case .setDateOfPurchase:
                return L10n.Claims.Item.Screen.Date.Of.Purchase.button
            }
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
    case setAudioStep(model: FlowClaimAudioRecordingStepModel)
}

public enum ClaimsLoadingType: Codable & Equatable & Hashable {
    case startClaim
    case fetchClaimEntrypoints
    case fetchClaimEntrypointGroups
    case postPhoneNumber
    case postDateOfOccurrence
    case postDateOfOccurrenceAndLocation
    case postLocation
    case postSingleItem
    case postSummary
    case postSingleItemCheckout
    case postAudioRecording
}
