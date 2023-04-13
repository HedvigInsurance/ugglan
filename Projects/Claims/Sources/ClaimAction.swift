import Apollo
import Flow
import Odyssey
import Presentation
import SwiftUI
import hCore
import hGraphQL

public indirect enum ClaimsAction: ActionProtocol, Hashable {
    case openFreeTextChat
    case submitNewClaim(from: ClaimsOrigin)
    case fetchClaims
    case setClaims(claims: [Claim])
    case fetchCommonClaims
    case setCommonClaims(commonClaims: [CommonClaim])
    case fetchCommonClaimsForSelection
    case setCommonClaimsForSelection([ClaimEntryPointResponseModel])
    case commonClaimOriginSelected(commonClaim: ClaimsOrigin)
    case openCommonClaimDetail(commonClaim: CommonClaim)
    case openHowClaimsWork
    case openClaimDetails(claim: Claim)
    case odysseyRedirect(url: String)

    case dissmissNewClaimFlow

    case submitAudioRecording(audioURL: URL)
    case submitDamage(damage: [String])

    case startClaim(from: String)
    case setNewClaimId(with: String)
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
    case setLoadingState(action: ClaimsAction, state: LoadingState<String>?)
    case setNewClaimContext(context: String)
    case setPayoutMethod(method: AvailableCheckoutMethod)
    case didAcceptHonestyPledge

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
    case setPhoneNumber(model: FlowClaimPhoneNumberStepModel)
    case setDateOfOccurrencePlusLocation(model: FlowClaimDateOfOccurrencePlusLocationStepModel)
    case setDateOfOccurence(model: FlowClaimDateOfOccurenceStepModel)
    case setLocation(model: FlowClaimLocationStepModel)
    case setSingleItem(model: FlowClamSingleItemStepModel)
    case setSummaryStep(model: FlowClaimSummaryStepModel)
    case setSingleItemCheckoutStep(model: FlowClaimSingleItemCheckoutStepModel)
    case setSuccessStep(model: FlowClaimSuccessStepModel)
    case setFailedStep(model: FlowClaimFailedStepModel)
    case setAudioStep(model: FlowClaimAudioRecordingStepModel)

}
