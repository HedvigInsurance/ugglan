import Apollo
import Flow
import Odyssey
import Presentation
import SwiftUI
import hCore
import hGraphQL

extension ClaimsAction: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .submitAudioRecording:
            hasher.combine("submitAudioRecording")
        default:
            hasher.combine("\(try! JSONEncoder().encode(self))")
        }
    }
}

public indirect enum ClaimsAction: ActionProtocol {
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

    case submitClaimDateOfOccurrence(dateOfOccurrence: Date)
    case submitClaimLocation(displayValue: String, value: String)

    case submitAudioRecording(audioURL: URL)
    case submitSingleItem(purchasePrice: Double)
    case submitDamage(damage: [Damage])
    case claimNextDamage(damages: Damage)

    case startClaim(from: String)
    case setNewClaim(from: NewClaim)
    case claimNextPhoneNumber(phoneNumber: String)
    case claimNextDateOfOccurrence(dateOfOccurrence: Date)
    case claimNextLocation(displayName: String, displayValue: String)
    case claimNextDateOfOccurrenceAndLocation
    case claimNextSingleItem(purchasePrice: Double)
    case claimNextSummary
    case claimNextSingleItemCheckout

    case setNewLocation(location: Location?)
    case setNewDate(dateOfOccurrence: String?)
    case setListOfLocations(displayValues: [Location])
    case setPurchasePrice(priceOfPurchase: Amount)
    case setSingleItemLists(brands: [Brand], models: [Model], damages: [Damage], defaultDamages: [Damage])
    case setSingleItemModel(modelName: Model)
    case setSingleItemDamage(damages: [Damage])
    case setSingleItemPurchaseDate(purchaseDate: Date)
    case setItemBrand(brand: Brand)
    case setLoadingState(action: ClaimsAction, state: LoadingState<String>?)
    case setPayoutAmountDeductibleDepreciation(payoutAmount: Amount, deductible: Amount, depreciation: Amount)
    case setPrefferedCurrency(currency: String)
    case setNewClaimContext(context: String)
    case setMaxDateOfOccurrence(maxDate: String)
    case didAcceptHonestyPledge

    case navigationAction(action: ClaimsNavigationAction)
    case stepModelAction(action: ClaimsStepModelAction)
}

public enum ClaimsNavigationAction: ActionProtocol {
    case openPhoneNumberScreen(model: ClaimFlowPhoneNumberStepModel)
    case openDateOfOccurrenceScreen(maxDate: Date)
    case openAudioRecordingScreen(questions: [String])
    case openLocationPicker
    case openDatePicker
    case openSuccessScreen
    case openSingleItemScreen(maxDate: Date)
    case openSummaryScreen
    case openSummaryEditScreen
    case openDamagePickerScreen
    case openModelPicker
    case openBrandPicker
    case openCheckoutNoRepairScreen
    case openCheckoutTransferringScreen
    case openCheckoutTransferringDoneScreen
    case openFailureSceen
    case openUpdateAppScreen
}

public enum ClaimsStepModelAction: ActionProtocol {
    case setPhoneNumber(model: ClaimFlowPhoneNumberStepModel)
}
