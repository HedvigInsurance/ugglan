import Presentation
import hGraphQL

public enum ProfileAction: ActionProtocol {
    case fetchProfileState
    case openProfile
    case openCharity
    case openPayment
    case openEuroBonus
    case openChangeEuroBonus
    case dismissChangeEuroBonus
    case openSuccessChangeEuroBonus
    case openFreeTextChat
    case openAppInformation
    case openAppSettings(animated: Bool)
    case setMember(id: String, name: String, email: String, phone: String?)
    case setMemberEmail(email: String)
    case setMemberPhone(phone: String)
    case setEurobonusNumber(partnerData: PartnerData?)
    case fetchProfileStateCompleted
    case updateEurobonusNumber(number: String)
    case setOpenAppSettings(to: Bool)
    
    case openLangaugePicker
    case closeLanguagePicker
    case continueLanguagePickerJourney
    
    case setMemberDetails(details: MemberDetails?)
    case fetchMemberDetails
    
    case deleteAccount(details: MemberDetails)
    case deleteAccountAlreadyRequested
}

public enum ProfileLoadingAction: LoadingProtocol {
    case loading
}
