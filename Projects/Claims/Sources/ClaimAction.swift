import Apollo
import Flow
import Odyssey
import Presentation
import SwiftUI
import hCore
import hGraphQL

public enum ClaimsAction: ActionProtocol, Hashable {
    case didAcceptHonestyPledge
    case submitNewClaim(from: ClaimsOrigin)
    case fetchClaims
    case setClaims(claims: [Claim])
    case fetchCommonClaims
    case setCommonClaims(commonClaims: [CommonClaim])
    case fetchCommonClaimsForSelection
    case setCommonClaimsForSelection([ClaimEntryPointResponseModel])
    case commonClaimOriginSelected(commonClaim: ClaimsOrigin)
    
    case openFreeTextChat
    case openCommonClaimDetail(commonClaim: CommonClaim)
    case openHowClaimsWork
    case openClaimDetails(claim: Claim)
    case odysseyRedirect(url: String)

    case dissmissNewClaimFlow

    case submitAudioRecording(audioURL: URL)
    case submitDamage(damage: [String])

    case setNewClaimId(with: String)
    case setNewClaimContext(context: String)
    
    case startClaimRequest(with: String)
    case claimNextPhoneNumber(phoneNumber: String)
    case claimNextDateOfOccurrence(dateOfOccurrence: Date?)
    case claimNextDateOfOccurrenceAndLocation
    case claimNextLocation(location: String?)
    case claimNextSingleItem(purchasePrice: Double?)
    case claimNextSummary
    case claimNextSingleItemCheckout

    case setNewLocation(location: String?)
    case setNewDate(dateOfOccurrence: String?)
    case setPurchasePrice(priceOfPurchase: Double?)
    case setSingleItemModel(modelName: ClaimFlowItemModelOptionModel)
    case setSingleItemDamage(damages: [String])
    case setSingleItemPurchaseDate(purchaseDate: Date?)
    case setItemBrand(brand: ClaimFlowItemBrandOptionModel)
    case setLoadingState(action: ClaimsLoadingType, state: LoadingState<String>?)
    case setPayoutMethod(method: AvailableCheckoutMethod)

    case navigationAction(action: ClaimsNavigationAction)
    case stepModelAction(action: ClaimsStepModelAction)
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
    case openCheckoutNoRepairScreen
    case openCheckoutTransferringScreen
    case openFailureSceen
    case openUpdateAppScreen
    case openNotificationsPermissionScreen

    public enum LocationPickerType: ActionProtocol {
        case setLocation
        case submitLocation
    }

    public enum DatePickerType: ActionProtocol {
        case setDateOfOccurrence
        case submitDateOfOccurence
        case setDateOfPurchase
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
    case fetchCommonClaims
    case postPhoneNumber
    case postDateOfOccurrence
    case postDateOfOccurrenceAndLocation
    case postLocation
    case postSingleItem
    case postSummary
    case postSingleItemCheckout
    case postAudioRecording
}
