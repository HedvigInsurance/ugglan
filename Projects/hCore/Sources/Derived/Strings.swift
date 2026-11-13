// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
public enum L10n {
  /// Voice recording
  public static var a11YAudioRecording: String { L10n.tr("Localizable", "A11Y_AUDIO_RECORDING") }
  /// %1$d of %2$d characters entered
  public static func a11YCharacterLimit(_ p1: Int, _ p2: Int) -> String {
    return L10n.tr("Localizable", "A11Y_CHARACTER_LIMIT", p1, p2)
  }
  /// Clear field
  public static var a11YClearField: String { L10n.tr("Localizable", "A11Y_CLEAR_FIELD") }
  /// Close
  public static var a11YClose: String { L10n.tr("Localizable", "A11Y_CLOSE") }
  /// Plural format key: "%#@format@"
  public static func a11YNumberOfEligibleInsurances(_ p1: Int) -> String {
    return L10n.tr("Localizable", "A11Y_NUMBER_OF_ELIGIBLE_INSURANCES", p1)
  }
  /// of
  public static var a11YOf: String { L10n.tr("Localizable", "A11Y_OF") }
  /// Option not selected
  public static var a11YOptionNotSelected: String { L10n.tr("Localizable", "A11Y_OPTION_NOT_SELECTED") }
  /// Pause
  public static var a11YPause: String { L10n.tr("Localizable", "A11Y_PAUSE") }
  /// Play
  public static var a11YPlay: String { L10n.tr("Localizable", "A11Y_PLAY") }
  /// Red
  public static var a11YReadLabelHack: String { L10n.tr("Localizable", "A11Y_READ_LABEL_HACK") }
  /// Scroll to bottom
  public static var a11YScrollDown: String { L10n.tr("Localizable", "A11Y_SCROLL_DOWN") }
  /// Plural format key: "%#@format@"
  public static func a11YSubmittedValues(_ p1: Int) -> String {
    return L10n.tr("Localizable", "A11Y_SUBMITTED_VALUES", p1)
  }
  /// View details
  public static var a11YViewDetails: String { L10n.tr("Localizable", "A11Y_VIEW_DETAILS") }
  /// Get notified
  public static var activateNotificationsTitle: String { L10n.tr("Localizable", "ACTIVATE_NOTIFICATIONS_TITLE") }
  /// Active
  public static var addonBadgeActive: String { L10n.tr("Localizable", "ADDON_BADGE_ACTIVE") }
  /// Car Plus
  public static var addonCarPlusDisplayName: String { L10n.tr("Localizable", "ADDON_CAR_PLUS_DISPLAY_NAME") }
  /// This addon is active and linked to your insurance.\n\nTo remove it, go to the insurance it’s linked to.
  public static var addonFlowAlreadyActiveExplanationSubtitle: String { L10n.tr("Localizable", "ADDON_FLOW_ALREADY_ACTIVE_EXPLANATION_SUBTITLE") }
  /// The addon is active
  public static var addonFlowAlreadyActiveExplanationTitle: String { L10n.tr("Localizable", "ADDON_FLOW_ALREADY_ACTIVE_EXPLANATION_TITLE") }
  /// See what's included
  public static var addonFlowCoverButton: String { L10n.tr("Localizable", "ADDON_FLOW_COVER_BUTTON") }
  /// +%@/mo
  public static func addonFlowPriceLabel(_ p1: String) -> String {
    return L10n.tr("Localizable", "ADDON_FLOW_PRICE_LABEL", p1)
  }
  /// See your price
  public static var addonFlowSeePriceButton: String { L10n.tr("Localizable", "ADDON_FLOW_SEE_PRICE_BUTTON") }
  /// Select
  public static var addonFlowSelectButton: String { L10n.tr("Localizable", "ADDON_FLOW_SELECT_BUTTON") }
  /// Maximum travel limit
  public static var addonFlowSelectDaysPlaceholder: String { L10n.tr("Localizable", "ADDON_FLOW_SELECT_DAYS_PLACEHOLDER") }
  /// Select the insurance you would like to add coverage for
  public static var addonFlowSelectInsuranceSubtitle: String { L10n.tr("Localizable", "ADDON_FLOW_SELECT_INSURANCE_SUBTITLE") }
  /// Extend your coverage
  public static var addonFlowSelectInsuranceTitle: String { L10n.tr("Localizable", "ADDON_FLOW_SELECT_INSURANCE_TITLE") }
  /// Choose your maximum travel limit
  public static var addonFlowSelectSuboptionTitle: String { L10n.tr("Localizable", "ADDON_FLOW_SELECT_SUBOPTION_TITLE") }
  /// Your extended coverage will be effective from  %@.
  public static func addonFlowSuccessSubtitle(_ p1: String) -> String {
    return L10n.tr("Localizable", "ADDON_FLOW_SUCCESS_SUBTITLE", p1)
  }
  /// Added successfully
  public static var addonFlowSuccessTitle: String { L10n.tr("Localizable", "ADDON_FLOW_SUCCESS_TITLE") }
  /// Added to your total monthly premium
  public static var addonFlowSummaryPriceSubtitle: String { L10n.tr("Localizable", "ADDON_FLOW_SUMMARY_PRICE_SUBTITLE") }
  /// Select an option
  public static var addonFlowUpdateAddonDescription: String { L10n.tr("Localizable", "ADDON_FLOW_UPDATE_ADDON_DESCRIPTION") }
  /// Extend coverage
  public static var addonFlowUpgradeAddon: String { L10n.tr("Localizable", "ADDON_FLOW_UPGRADE_ADDON") }
  /// You can extend the coverage of this addon. It can only be removed when your insurance is renewed or cancelled.
  public static var addonFlowUpgradeAddonDescription: String { L10n.tr("Localizable", "ADDON_FLOW_UPGRADE_ADDON_DESCRIPTION") }
  /// Travel Insurance Plus
  public static var addonTravelDisplayName: String { L10n.tr("Localizable", "ADDON_TRAVEL_DISPLAY_NAME") }
  /// Cancel
  public static var alertCancel: String { L10n.tr("Localizable", "ALERT_CANCEL") }
  /// Listen
  public static var audioRecorderListen: String { L10n.tr("Localizable", "AUDIO_RECORDER_LISTEN") }
  /// Start
  public static var audioRecorderStart: String { L10n.tr("Localizable", "AUDIO_RECORDER_START") }
  /// Stop
  public static var audioRecorderStop: String { L10n.tr("Localizable", "AUDIO_RECORDER_STOP") }
  /// your email
  public static var authOtpYourEmail: String { L10n.tr("Localizable", "AUTH_OTP_YOUR_EMAIL") }
  /// We cannot log you in via BankID right now, try again
  public static var authenticationBankidLoginError: String { L10n.tr("Localizable", "AUTHENTICATION_BANKID_LOGIN_ERROR") }
  /// Open the BankID app on your phone or scan the QR-code to login
  public static var authenticationBankidLoginLabel: String { L10n.tr("Localizable", "AUTHENTICATION_BANKID_LOGIN_LABEL") }
  /// Login with BankID
  public static var authenticationBankidLoginTitle: String { L10n.tr("Localizable", "AUTHENTICATION_BANKID_LOGIN_TITLE") }
  /// Open BankID
  public static var authenticationBankidOpenButton: String { L10n.tr("Localizable", "AUTHENTICATION_BANKID_OPEN_BUTTON") }
  /// Something went wrong on our side. Try again in a few minutes.
  public static var authenticationLoginUnavailableBody: String { L10n.tr("Localizable", "AUTHENTICATION_LOGIN_UNAVAILABLE_BODY") }
  /// We can’t log you in right now
  public static var authenticationLoginUnavailableTitle: String { L10n.tr("Localizable", "AUTHENTICATION_LOGIN_UNAVAILABLE_TITLE") }
  /// Read more
  public static var automatedMessageInfoCardButton: String { L10n.tr("Localizable", "AUTOMATED_MESSAGE_INFO_CARD_BUTTON") }
  /// Payout to a Swedish bank account
  public static var bankPayoutMethodCardDescription: String { L10n.tr("Localizable", "BANK_PAYOUT_METHOD_CARD_DESCRIPTION") }
  /// Bank account
  public static var bankPayoutMethodCardTitle: String { L10n.tr("Localizable", "BANK_PAYOUT_METHOD_CARD_TITLE") }
  /// Login
  public static var bankidLoginTitle: String { L10n.tr("Localizable", "BANKID_LOGIN_TITLE") }
  /// %1$@ discount
  public static func bundleDiscountProgressSegmentSubtitleCurrentAppliedDiscount(_ p1: String) -> String {
    return L10n.tr("Localizable", "BUNDLE_DISCOUNT_PROGRESS_SEGMENT_SUBTITLE_CURRENT_APPLIED_DISCOUNT", p1)
  }
  /// No discount
  public static var bundleDiscountProgressSegmentSubtitleNoDiscount: String { L10n.tr("Localizable", "BUNDLE_DISCOUNT_PROGRESS_SEGMENT_SUBTITLE_NO_DISCOUNT") }
  /// 1 insurance
  public static var bundleDiscountProgressSegmentTitleOneInsurance: String { L10n.tr("Localizable", "BUNDLE_DISCOUNT_PROGRESS_SEGMENT_TITLE_ONE_INSURANCE") }
  /// 3 or more
  public static var bundleDiscountProgressSegmentTitleThreeOrMore: String { L10n.tr("Localizable", "BUNDLE_DISCOUNT_PROGRESS_SEGMENT_TITLE_THREE_OR_MORE") }
  /// 2 insurances
  public static var bundleDiscountProgressSegmentTitleTwoInsurances: String { L10n.tr("Localizable", "BUNDLE_DISCOUNT_PROGRESS_SEGMENT_TITLE_TWO_INSURANCES") }
  /// Confirm changes
  public static var changeAddressAcceptOffer: String { L10n.tr("Localizable", "CHANGE_ADDRESS_ACCEPT_OFFER") }
  /// Activates %1$@
  public static func changeAddressActivationDate(_ p1: String) -> String {
    return L10n.tr("Localizable", "CHANGE_ADDRESS_ACTIVATION_DATE", p1)
  }
  /// Add building
  public static var changeAddressAddBuilding: String { L10n.tr("Localizable", "CHANGE_ADDRESS_ADD_BUILDING") }
  /// Please enter ancillary area
  public static var changeAddressAncillaryAreaError: String { L10n.tr("Localizable", "CHANGE_ADDRESS_ANCILLARY_AREA_ERROR") }
  /// Ancillary area
  public static var changeAddressAncillaryAreaLabel: String { L10n.tr("Localizable", "CHANGE_ADDRESS_ANCILLARY_AREA_LABEL") }
  /// Homeowner
  public static var changeAddressApartmentOwnLabel: String { L10n.tr("Localizable", "CHANGE_ADDRESS_APARTMENT_OWN_LABEL") }
  /// Rental
  public static var changeAddressApartmentRentLabel: String { L10n.tr("Localizable", "CHANGE_ADDRESS_APARTMENT_RENT_LABEL") }
  /// Please enter number of bathrooms
  public static var changeAddressBathroomsError: String { L10n.tr("Localizable", "CHANGE_ADDRESS_BATHROOMS_ERROR") }
  /// Number of bathrooms
  public static var changeAddressBathroomsLabel: String { L10n.tr("Localizable", "CHANGE_ADDRESS_BATHROOMS_LABEL") }
  /// Insured people
  public static var changeAddressCoInsuredLabel: String { L10n.tr("Localizable", "CHANGE_ADDRESS_CO_INSURED_LABEL") }
  /// If you have Standard or Max, Hedvig covers your belongings in your old home for %1$li days after you've moved.
  public static func changeAddressCoverageInfoText(_ p1: Int) -> String {
    return L10n.tr("Localizable", "CHANGE_ADDRESS_COVERAGE_INFO_TEXT", p1)
  }
  /// Enter your new address
  public static var changeAddressEnterNewAddressTitle: String { L10n.tr("Localizable", "CHANGE_ADDRESS_ENTER_NEW_ADDRESS_TITLE") }
  /// Type of building
  public static var changeAddressExtraBuildingContainerTitle: String { L10n.tr("Localizable", "CHANGE_ADDRESS_EXTRA_BUILDING_CONTAINER_TITLE") }
  /// Please enter size of extra building
  public static var changeAddressExtraBuildingSizeError: String { L10n.tr("Localizable", "CHANGE_ADDRESS_EXTRA_BUILDING_SIZE_ERROR") }
  /// Size
  public static var changeAddressExtraBuildingSizeLabel: String { L10n.tr("Localizable", "CHANGE_ADDRESS_EXTRA_BUILDING_SIZE_LABEL") }
  /// Choose type of building
  public static var changeAddressExtraBuildingTypeError: String { L10n.tr("Localizable", "CHANGE_ADDRESS_EXTRA_BUILDING_TYPE_ERROR") }
  /// Extra buildings
  public static var changeAddressExtraBuildingsLabel: String { L10n.tr("Localizable", "CHANGE_ADDRESS_EXTRA_BUILDINGS_LABEL") }
  /// Connected to water
  public static var changeAddressExtraBuildingsWaterInputLabel: String { L10n.tr("Localizable", "CHANGE_ADDRESS_EXTRA_BUILDINGS_WATER_INPUT_LABEL") }
  /// Water connected
  public static var changeAddressExtraBuildingsWaterLabel: String { L10n.tr("Localizable", "CHANGE_ADDRESS_EXTRA_BUILDINGS_WATER_LABEL") }
  /// Information about your new house
  public static var changeAddressInformationAboutYourHouse: String { L10n.tr("Localizable", "CHANGE_ADDRESS_INFORMATION_ABOUT_YOUR_HOUSE") }
  /// Please enter square meters
  public static var changeAddressLivingSpaceError: String { L10n.tr("Localizable", "CHANGE_ADDRESS_LIVING_SPACE_ERROR") }
  /// The space is too big. Maximum space is %d%@.
  public static func changeAddressLivingSpaceOverLimitWithInputError(_ p1: Int, _ p2: String) -> String {
    return L10n.tr("Localizable", "CHANGE_ADDRESS_LIVING_SPACE_OVER_LIMIT_WITH_INPUT_ERROR", p1, p2)
  }
  /// Making changes...
  public static var changeAddressMakingChanges: String { L10n.tr("Localizable", "CHANGE_ADDRESS_MAKING_CHANGES") }
  /// Please select a moving date
  public static var changeAddressMovingDateError: String { L10n.tr("Localizable", "CHANGE_ADDRESS_MOVING_DATE_ERROR") }
  /// Move-in date
  public static var changeAddressMovingDateLabel: String { L10n.tr("Localizable", "CHANGE_ADDRESS_MOVING_DATE_LABEL") }
  /// Address
  public static var changeAddressNewAddressLabel: String { L10n.tr("Localizable", "CHANGE_ADDRESS_NEW_ADDRESS_LABEL") }
  /// Size
  public static var changeAddressNewLivingSpaceLabel: String { L10n.tr("Localizable", "CHANGE_ADDRESS_NEW_LIVING_SPACE_LABEL") }
  /// Postal code
  public static var changeAddressNewPostalCodeLabel: String { L10n.tr("Localizable", "CHANGE_ADDRESS_NEW_POSTAL_CODE_LABEL") }
  /// Only me
  public static var changeAddressOnlyYou: String { L10n.tr("Localizable", "CHANGE_ADDRESS_ONLY_YOU") }
  /// Your other insurance policies are affected when you move to a new address. Your price and coverage may have changed.
  public static var changeAddressOtherInsurancesInfoText: String { L10n.tr("Localizable", "CHANGE_ADDRESS_OTHER_INSURANCES_INFO_TEXT") }
  /// Please enter the postal code
  public static var changeAddressPostalCodeError: String { L10n.tr("Localizable", "CHANGE_ADDRESS_POSTAL_CODE_ERROR") }
  /// What type of home will you move to?
  public static var changeAddressSelectHousingTypeTitle: String { L10n.tr("Localizable", "CHANGE_ADDRESS_SELECT_HOUSING_TYPE_TITLE") }
  /// m²
  public static var changeAddressSizeSuffix: String { L10n.tr("Localizable", "CHANGE_ADDRESS_SIZE_SUFFIX") }
  /// Please enter the address
  public static var changeAddressStreetError: String { L10n.tr("Localizable", "CHANGE_ADDRESS_STREET_ERROR") }
  /// Student
  public static var changeAddressStudentLabel: String { L10n.tr("Localizable", "CHANGE_ADDRESS_STUDENT_LABEL") }
  /// Do you rent out the house or parts of it?
  public static var changeAddressSubletLabel: String { L10n.tr("Localizable", "CHANGE_ADDRESS_SUBLET_LABEL") }
  /// Your new home will be insured starting from %1@
  public static func changeAddressSuccessSubtitle(_ p1: String) -> String {
    return L10n.tr("Localizable", "CHANGE_ADDRESS_SUCCESS_SUBTITLE", p1)
  }
  /// Address updated
  public static var changeAddressSuccessTitle: String { L10n.tr("Localizable", "CHANGE_ADDRESS_SUCCESS_TITLE") }
  /// Summary
  public static var changeAddressSummaryTitle: String { L10n.tr("Localizable", "CHANGE_ADDRESS_SUMMARY_TITLE") }
  /// House
  public static var changeAddressVillaLabel: String { L10n.tr("Localizable", "CHANGE_ADDRESS_VILLA_LABEL") }
  /// Please enter year of construction
  public static var changeAddressYearOfConstructionError: String { L10n.tr("Localizable", "CHANGE_ADDRESS_YEAR_OF_CONSTRUCTION_ERROR") }
  /// Year of construction
  public static var changeAddressYearOfConstructionLabel: String { L10n.tr("Localizable", "CHANGE_ADDRESS_YEAR_OF_CONSTRUCTION_LABEL") }
  /// You + %1$li
  public static func changeAddressYouPlus(_ p1: Int) -> String {
    return L10n.tr("Localizable", "CHANGE_ADDRESS_YOU_PLUS", p1)
  }
  /// Fetching insurance amount...
  public static var changeInsuranceAmountProcessing: String { L10n.tr("Localizable", "CHANGE_INSURANCE_AMOUNT_PROCESSING") }
  /// Change payout account
  public static var changePayoutMethodButtonLabel: String { L10n.tr("Localizable", "CHANGE_PAYOUT_METHOD_BUTTON_LABEL") }
  /// Change coverage level
  public static var changeTierButtonTitle: String { L10n.tr("Localizable", "CHANGE_TIER_BUTTON_TITLE") }
  /// Enable push notifications to ensure you receive all our messages.
  public static var chatActivateNotificationsBody: String { L10n.tr("Localizable", "CHAT_ACTIVATE_NOTIFICATIONS_BODY") }
  /// Claim
  public static var chatConversationClaimTitle: String { L10n.tr("Localizable", "CHAT_CONVERSATION_CLAIM_TITLE") }
  /// Closed
  public static var chatConversationClosed: String { L10n.tr("Localizable", "CHAT_CONVERSATION_CLOSED") }
  /// The conversation is closed. If you need more help with this specific matter, please write here to reopen it.
  public static var chatConversationClosedInfo: String { L10n.tr("Localizable", "CHAT_CONVERSATION_CLOSED_INFO") }
  /// Conversation history
  public static var chatConversationHistoryTitle: String { L10n.tr("Localizable", "CHAT_CONVERSATION_HISTORY_TITLE") }
  /// Inbox
  public static var chatConversationInbox: String { L10n.tr("Localizable", "CHAT_CONVERSATION_INBOX") }
  /// Support
  public static var chatConversationQuestionTitle: String { L10n.tr("Localizable", "CHAT_CONVERSATION_QUESTION_TITLE") }
  /// Terminate %1$@
  public static func chatConversationTerminateContract(_ p1: String) -> String {
    return L10n.tr("Localizable", "CHAT_CONVERSATION_TERMINATE_CONTRACT", p1)
  }
  /// Delivered
  public static var chatDeliveredMessage: String { L10n.tr("Localizable", "CHAT_DELIVERED_MESSAGE") }
  /// Message not sent. Try again
  public static var chatFailedToSend: String { L10n.tr("Localizable", "CHAT_FAILED_TO_SEND") }
  /// Write here...
  public static var chatInputPlaceholder: String { L10n.tr("Localizable", "CHAT_INPUT_PLACEHOLDER") }
  /// Allow access to photos to be able to upload
  public static var chatMissingImagesPermissionSubtitle: String { L10n.tr("Localizable", "CHAT_MISSING_IMAGES_PERMISSION_SUBTITLE") }
  /// Write to start the conversation
  public static var chatNewConversationSubtitle: String { L10n.tr("Localizable", "CHAT_NEW_CONVERSATION_SUBTITLE") }
  /// New message
  public static var chatNewConversationTitle: String { L10n.tr("Localizable", "CHAT_NEW_CONVERSATION_TITLE") }
  /// New message
  public static var chatNewMessage: String { L10n.tr("Localizable", "CHAT_NEW_MESSAGE") }
  /// Go to settings
  public static var chatOpenAppSettingsButton: String { L10n.tr("Localizable", "CHAT_OPEN_APP_SETTINGS_BUTTON") }
  /// Automated message
  public static var chatSenderAutomation: String { L10n.tr("Localizable", "CHAT_SENDER_AUTOMATION") }
  /// Hedvig Service Team
  public static var chatSenderHedvig: String { L10n.tr("Localizable", "CHAT_SENDER_HEDVIG") }
  /// You
  public static var chatSenderMember: String { L10n.tr("Localizable", "CHAT_SENDER_MEMBER") }
  /// Sent a document
  public static var chatSentAFile: String { L10n.tr("Localizable", "CHAT_SENT_A_FILE") }
  /// Sent a link
  public static var chatSentALink: String { L10n.tr("Localizable", "CHAT_SENT_A_LINK") }
  /// Sent a message
  public static var chatSentAMessage: String { L10n.tr("Localizable", "CHAT_SENT_A_MESSAGE") }
  /// Sent a photo
  public static var chatSentAPhoto: String { L10n.tr("Localizable", "CHAT_SENT_A_PHOTO") }
  /// Messages
  public static var chatTitle: String { L10n.tr("Localizable", "CHAT_TITLE") }
  /// Push notifications
  public static var chatToastPushNotificationsTitle: String { L10n.tr("Localizable", "CHAT_TOAST_PUSH_NOTIFICATIONS_TITLE") }
  /// Send
  public static var chatUploadPresend: String { L10n.tr("Localizable", "CHAT_UPLOAD_PRESEND") }
  /// ID-number
  public static var chipIdLabel: String { L10n.tr("Localizable", "CHIP_ID_LABEL") }
  /// Add ID
  public static var chipIdMissingButton: String { L10n.tr("Localizable", "CHIP_ID_MISSING_BUTTON") }
  /// We are missing your pet’s ID-number
  public static var chipIdMissingMessage: String { L10n.tr("Localizable", "CHIP_ID_MISSING_MESSAGE") }
  /// You’ve already added the ID-number for all your pets
  public static var chipIdNoInsurances: String { L10n.tr("Localizable", "CHIP_ID_NO_INSURANCES") }
  /// Update ID-number
  public static var chipIdTopTitle: String { L10n.tr("Localizable", "CHIP_ID_TOP_TITLE") }
  /// We use AI to support the process of submitting and handling your claim. Our team always reviews your claim before any decision is made.
  public static var claimChatAiInfo: String { L10n.tr("Localizable", "CLAIM_CHAT_AI_INFO") }
  /// Voice recording
  public static var claimChatAudioRecordingLabel: String { L10n.tr("Localizable", "CLAIM_CHAT_AUDIO_RECORDING_LABEL") }
  /// Other item
  public static var claimChatCustomItemSubtitle: String { L10n.tr("Localizable", "CLAIM_CHAT_CUSTOM_ITEM_SUBTITLE") }
  /// Edit answer
  public static var claimChatEditAnswerButton: String { L10n.tr("Localizable", "CLAIM_CHAT_EDIT_ANSWER_BUTTON") }
  /// Editing this answer will clear everything you’ve filled in after it. You’ll need to go through those steps again.
  public static var claimChatEditExplanation: String { L10n.tr("Localizable", "CLAIM_CHAT_EDIT_EXPLANATION") }
  /// Previous answers will be reset
  public static var claimChatEditTitle: String { L10n.tr("Localizable", "CLAIM_CHAT_EDIT_TITLE") }
  /// Make sure you fill in all the required fields
  public static var claimChatErrorMessage: String { L10n.tr("Localizable", "CLAIM_CHAT_ERROR_MESSAGE") }
  /// No results
  public static var claimChatFieldSearchNothingFound: String { L10n.tr("Localizable", "CLAIM_CHAT_FIELD_SEARCH_NOTHING_FOUND") }
  /// Did you mean 
  public static var claimChatFieldSearchSuggestion: String { L10n.tr("Localizable", "CLAIM_CHAT_FIELD_SEARCH_SUGGESTION") }
  /// Uploaded files
  public static var claimChatFileTitle: String { L10n.tr("Localizable", "CLAIM_CHAT_FILE_TITLE") }
  /// Send files
  public static var claimChatFileUploadSendButton: String { L10n.tr("Localizable", "CLAIM_CHAT_FILE_UPLOAD_SEND_BUTTON") }
  /// Value must be at most %d
  public static func claimChatFormNumberMaxChar(_ p1: Int) -> String {
    return L10n.tr("Localizable", "CLAIM_CHAT_FORM_NUMBER_MAX_CHAR", p1)
  }
  /// Value must be at least %d
  public static func claimChatFormNumberMinChar(_ p1: Int) -> String {
    return L10n.tr("Localizable", "CLAIM_CHAT_FORM_NUMBER_MIN_CHAR", p1)
  }
  /// This field is required
  public static var claimChatFormRequiredField: String { L10n.tr("Localizable", "CLAIM_CHAT_FORM_REQUIRED_FIELD") }
  /// Value must be at most %d characters long
  public static func claimChatFormTextMaxChar(_ p1: Int) -> String {
    return L10n.tr("Localizable", "CLAIM_CHAT_FORM_TEXT_MAX_CHAR", p1)
  }
  /// Value must be at least %d characters long
  public static func claimChatFormTextMinChar(_ p1: Int) -> String {
    return L10n.tr("Localizable", "CLAIM_CHAT_FORM_TEXT_MIN_CHAR", p1)
  }
  /// Written description
  public static var claimChatFreeTextLabel: String { L10n.tr("Localizable", "CLAIM_CHAT_FREE_TEXT_LABEL") }
  /// Recording
  public static var claimChatRecordingTitle: String { L10n.tr("Localizable", "CLAIM_CHAT_RECORDING_TITLE") }
  /// Skip
  public static var claimChatSkipStep: String { L10n.tr("Localizable", "CLAIM_CHAT_SKIP_STEP") }
  /// Skipped
  public static var claimChatSkippedStep: String { L10n.tr("Localizable", "CLAIM_CHAT_SKIPPED_STEP") }
  /// Select time
  public static var claimChatStrollerTheftLeftAloneTime: String { L10n.tr("Localizable", "CLAIM_CHAT_STROLLER_THEFT_LEFT_ALONE_TIME") }
  /// Roughly how long had the stroller been there before you noticed it was gone?
  public static var claimChatStrollerTheftLeftAloneTimeMessage: String { L10n.tr("Localizable", "CLAIM_CHAT_STROLLER_THEFT_LEFT_ALONE_TIME_MESSAGE") }
  /// A day or more
  public static var claimChatStrollerTheftLeftFullDayOrMore: String { L10n.tr("Localizable", "CLAIM_CHAT_STROLLER_THEFT_LEFT_FULL_DAY_OR_MORE") }
  /// Overnight
  public static var claimChatStrollerTheftLeftOvernight: String { L10n.tr("Localizable", "CLAIM_CHAT_STROLLER_THEFT_LEFT_OVERNIGHT") }
  /// 2-8 hours
  public static var claimChatStrollerTheftLeftTwoToEightHours: String { L10n.tr("Localizable", "CLAIM_CHAT_STROLLER_THEFT_LEFT_TWO_TO_EIGHT_HOURS") }
  /// Under 2 hours
  public static var claimChatStrollerTheftLeftUnderTwoHours: String { L10n.tr("Localizable", "CLAIM_CHAT_STROLLER_THEFT_LEFT_UNDER_TWO_HOURS") }
  /// Tell us more
  public static var claimChatStrollerTheftLockDescription: String { L10n.tr("Localizable", "CLAIM_CHAT_STROLLER_THEFT_LOCK_DESCRIPTION") }
  /// Submit your claim
  public static var claimChatSubmitClaim: String { L10n.tr("Localizable", "CLAIM_CHAT_SUBMIT_CLAIM") }
  /// Processing information, please wait.
  public static var claimChatTaskContentDescription: String { L10n.tr("Localizable", "CLAIM_CHAT_TASK_CONTENT_DESCRIPTION") }
  /// Claim
  public static var claimChatTitle: String { L10n.tr("Localizable", "CLAIM_CHAT_TITLE") }
  /// Record with voice
  public static var claimChatUseAudio: String { L10n.tr("Localizable", "CLAIM_CHAT_USE_AUDIO") }
  /// Record
  public static var claimChatUseAudioShort: String { L10n.tr("Localizable", "CLAIM_CHAT_USE_AUDIO_SHORT") }
  /// Describe using text
  public static var claimChatUseTextInput: String { L10n.tr("Localizable", "CLAIM_CHAT_USE_TEXT_INPUT") }
  /// Write
  public static var claimChatUseTextInputShort: String { L10n.tr("Localizable", "CLAIM_CHAT_USE_TEXT_INPUT_SHORT") }
  /// Your claim was closed as we didn’t hear back from you. Please see conversation for more details.
  public static var claimOutcomeUnresponsiveSupportText: String { L10n.tr("Localizable", "claim_outcome_unresponsive_support_text") }
  /// Appeal Instruction (SWE)
  public static var claimStatusAppealInstructionLinkText: String { L10n.tr("Localizable", "claim_status_appeal_instruction_link_text") }
  /// Don’t miss out on important information for your claim
  public static var claimsActivateNotificationsBody: String { L10n.tr("Localizable", "CLAIMS_ACTIVATE_NOTIFICATIONS_BODY") }
  /// Enable notifications
  public static var claimsActivateNotificationsCta: String { L10n.tr("Localizable", "CLAIMS_ACTIVATE_NOTIFICATIONS_CTA") }
  /// Skip
  public static var claimsActivateNotificationsDismiss: String { L10n.tr("Localizable", "CLAIMS_ACTIVATE_NOTIFICATIONS_DISMISS") }
  /// Continue
  public static var claimsFileUploadRemoveCancel: String { L10n.tr("Localizable", "CLAIMS_FILE_UPLOAD_REMOVE_CANCEL") }
  /// Yes, delete
  public static var claimsFileUploadRemoveConfirm: String { L10n.tr("Localizable", "CLAIMS_FILE_UPLOAD_REMOVE_CONFIRM") }
  /// Do you want to remove the file from your claim?
  public static var claimsFileUploadRemoveSubtitle: String { L10n.tr("Localizable", "CLAIMS_FILE_UPLOAD_REMOVE_SUBTITLE") }
  /// I promise
  public static var claimsPledgeSlideLabel: String { L10n.tr("Localizable", "CLAIMS_PLEDGE_SLIDE_LABEL") }
  /// Record
  public static var claimsRecord: String { L10n.tr("Localizable", "claims_record") }
  /// Start recording
  public static var claimsStartRecordingLabel: String { L10n.tr("Localizable", "CLAIMS_START_RECORDING_LABEL") }
  /// Your claim will now be handled by our service team. Depending on the extent of your claim, the response time varies. If you have any questions, don't hesitate to get in touch here in the app.
  public static var claimsSuccessLabel: String { L10n.tr("Localizable", "CLAIMS_SUCCESS_LABEL") }
  /// Claim submitted
  public static var claimsSuccessTitle: String { L10n.tr("Localizable", "CLAIMS_SUCCESS_TITLE") }
  /// Input text must be at least %1$d characters.
  public static func claimsTextInputMinCharactersError(_ p1: Int) -> String {
    return L10n.tr("Localizable", "CLAIMS_TEXT_INPUT_MIN_CHARACTERS_ERROR", p1)
  }
  /// Describe your claim
  public static var claimsTextInputPlaceholder: String { L10n.tr("Localizable", "CLAIMS_TEXT_INPUT_PLACEHOLDER") }
  /// What happened?
  public static var claimsTextInputPopoverPlaceholder: String { L10n.tr("Localizable", "CLAIMS_TEXT_INPUT_POPOVER_PLACEHOLDER") }
  /// Your answer
  public static var claimsTriagingWhatHappenedTitle: String { L10n.tr("Localizable", "CLAIMS_TRIAGING_WHAT_HAPPENED_TITLE") }
  /// Use voice recording
  public static var claimsUseAudioRecording: String { L10n.tr("Localizable", "CLAIMS_USE_AUDIO_RECORDING") }
  /// Sending...
  public static var claimsVoiceRecordingSending: String { L10n.tr("Localizable", "CLAIMS_VOICE_RECORDING_SENDING") }
  /// Write
  public static var claimsWrite: String { L10n.tr("Localizable", "claims_write") }
  /// Your claim
  public static var claimsYourClaim: String { L10n.tr("Localizable", "CLAIMS_YOUR_CLAIM") }
  /// Insured people
  public static var coinsuredEditTitle: String { L10n.tr("Localizable", "COINSURED_EDIT_TITLE") }
  /// Enter manually
  public static var coinsuredEnterManuallyButton: String { L10n.tr("Localizable", "COINSURED_ENTER_MANUALLY_BUTTON") }
  /// SSN not found
  public static var coinsuredSsnNotFound: String { L10n.tr("Localizable", "COINSURED_SSN_NOT_FOUND") }
  /// We were unable to retrieve the information linked to this Social Security number. Please enter it manually.
  public static var coinsuredWithoutSsnInfo: String { L10n.tr("Localizable", "COINSURED_WITHOUT_SSN_INFO") }
  /// Book now
  public static var commonClaimButton: String { L10n.tr("Localizable", "COMMON_CLAIM_BUTTON") }
  /// Sick abroad
  public static var commonClaimEmergencyTitle: String { L10n.tr("Localizable", "COMMON_CLAIM_EMERGENCY_TITLE") }
  /// Please note that your changes will be effective on %@.
  public static func confirmChangesSubtitle(_ p1: String) -> String {
    return L10n.tr("Localizable", "CONFIRM_CHANGES_SUBTITLE", p1)
  }
  /// Confirm changes
  public static var confirmChangesTitle: String { L10n.tr("Localizable", "CONFIRM_CHANGES_TITLE") }
  /// Documents
  public static var confirmationScreenDocumentTitle: String { L10n.tr("Localizable", "CONFIRMATION_SCREEN_DOCUMENT_TITLE") }
  /// Add co-owner
  public static var contractAddAdditionalCoowner: String { L10n.tr("Localizable", "CONTRACT_ADD_ADDITIONAL_COOWNER") }
  /// You can add more co-owners for your vacation home
  public static var contractAddAdditionalCoownerInfo: String { L10n.tr("Localizable", "CONTRACT_ADD_ADDITIONAL_COOWNER_INFO") }
  /// Add co-insured
  public static var contractAddCoinsured: String { L10n.tr("Localizable", "CONTRACT_ADD_COINSURED") }
  /// Activates %1$@
  public static func contractAddCoinsuredActiveFrom(_ p1: String) -> String {
    return L10n.tr("Localizable", "CONTRACT_ADD_COINSURED_ACTIVE_FROM", p1)
  }
  /// Active until %1$@
  public static func contractAddCoinsuredActiveUntil(_ p1: String) -> String {
    return L10n.tr("Localizable", "CONTRACT_ADD_COINSURED_ACTIVE_UNTIL", p1)
  }
  /// Confirm changes
  public static var contractAddCoinsuredConfirmChanges: String { L10n.tr("Localizable", "CONTRACT_ADD_COINSURED_CONFIRM_CHANGES") }
  /// Add without personal identity no.
  public static var contractAddCoinsuredNoSsn: String { L10n.tr("Localizable", "CONTRACT_ADD_COINSURED_NO_SSN") }
  /// Making changes...
  public static var contractAddCoinsuredProcessing: String { L10n.tr("Localizable", "CONTRACT_ADD_COINSURED_PROCESSING") }
  /// Please add information for all co-insured in order to proceed.
  public static var contractAddCoinsuredReviewInfo: String { L10n.tr("Localizable", "CONTRACT_ADD_COINSURED_REVIEW_INFO") }
  /// Your insurance will be updated starting from %1$@
  public static func contractAddCoinsuredUpdatedLabel(_ p1: String) -> String {
    return L10n.tr("Localizable", "CONTRACT_ADD_COINSURED_UPDATED_LABEL", p1)
  }
  /// Co-insured updated
  public static var contractAddCoinsuredUpdatedTitle: String { L10n.tr("Localizable", "CONTRACT_ADD_COINSURED_UPDATED_TITLE") }
  /// Add info of co-insured
  public static var contractAddConisuredInfo: String { L10n.tr("Localizable", "CONTRACT_ADD_CONISURED_INFO") }
  /// Please add co-owner information to proceed
  public static var contractAddCoownerReviewInfo: String { L10n.tr("Localizable", "CONTRACT_ADD_COOWNER_REVIEW_INFO") }
  /// Co-owner information updated
  public static var contractAddCoownerUpdatedTitle: String { L10n.tr("Localizable", "CONTRACT_ADD_COOWNER_UPDATED_TITLE") }
  /// Date of birth
  public static var contractBirthDate: String { L10n.tr("Localizable", "CONTRACT_BIRTH_DATE") }
  /// What do you want to edit?
  public static var contractChangeInformationTitle: String { L10n.tr("Localizable", "CONTRACT_CHANGE_INFORMATION_TITLE") }
  /// Co-insured
  public static var contractCoinsured: String { L10n.tr("Localizable", "CONTRACT_COINSURED") }
  /// You need to add personal information to your co-insured people
  public static var contractCoinsuredAddPersonalInfo: String { L10n.tr("Localizable", "CONTRACT_COINSURED_ADD_PERSONAL_INFO") }
  /// Add info
  public static var contractCoinsuredMissingAddInfo: String { L10n.tr("Localizable", "CONTRACT_COINSURED_MISSING_ADD_INFO") }
  /// Add more information about your co-insured for better help
  public static var contractCoinsuredMissingInfoText: String { L10n.tr("Localizable", "CONTRACT_COINSURED_MISSING_INFO_TEXT") }
  /// We are missing information about your co-insured. Please add it as soon as possible.
  public static var contractCoinsuredMissingInformationLabel: String { L10n.tr("Localizable", "CONTRACT_COINSURED_MISSING_INFORMATION_LABEL") }
  /// Do it later
  public static var contractCoinsuredMissingLater: String { L10n.tr("Localizable", "CONTRACT_COINSURED_MISSING_LATER") }
  /// Your insurance will be updated and cover you +%1$d people starting from %2$@
  public static func contractCoinsuredUpdateInFuture(_ p1: Int, _ p2: String) -> String {
    return L10n.tr("Localizable", "CONTRACT_COINSURED_UPDATE_IN_FUTURE", p1, p2)
  }
  /// Co-owner
  public static var contractCoowner: String { L10n.tr("Localizable", "CONTRACT_COOWNER") }
  /// You need to add information about your co-owners
  public static var contractCoownersAddPersonalInfo: String { L10n.tr("Localizable", "CONTRACT_COOWNERS_ADD_PERSONAL_INFO") }
  /// Add co-owner information for your vacation home
  public static var contractCoownersMissingInfoText: String { L10n.tr("Localizable", "CONTRACT_COOWNERS_MISSING_INFO_TEXT") }
  /// More information
  public static var contractCoverageMoreInfo: String { L10n.tr("Localizable", "CONTRACT_COVERAGE_MORE_INFO") }
  /// Edit co-insured
  public static var contractEditCoinsured: String { L10n.tr("Localizable", "CONTRACT_EDIT_COINSURED") }
  /// Edit info
  public static var contractEditInfo: String { L10n.tr("Localizable", "CONTRACT_EDIT_INFO") }
  /// Edit your insurance
  public static var contractEditInfoLabel: String { L10n.tr("Localizable", "CONTRACT_EDIT_INFO_LABEL") }
  /// First name
  public static var contractFirstName: String { L10n.tr("Localizable", "CONTRACT_FIRST_NAME") }
  /// Last name
  public static var contractLastName: String { L10n.tr("Localizable", "CONTRACT_LAST_NAME") }
  /// No information available
  public static var contractNoInformation: String { L10n.tr("Localizable", "CONTRACT_NO_INFORMATION") }
  /// Activates on %1$@
  public static func contractOverviewAddonActivatesDate(_ p1: String) -> String {
    return L10n.tr("Localizable", "CONTRACT_OVERVIEW_ADDON_ACTIVATES_DATE", p1)
  }
  /// Add
  public static var contractOverviewAddonAdd: String { L10n.tr("Localizable", "CONTRACT_OVERVIEW_ADDON_ADD") }
  /// Ends on %1$@
  public static func contractOverviewAddonEndsDate(_ p1: String) -> String {
    return L10n.tr("Localizable", "CONTRACT_OVERVIEW_ADDON_ENDS_DATE", p1)
  }
  /// Added
  public static var contractOverviewAddonIsAdded: String { L10n.tr("Localizable", "CONTRACT_OVERVIEW_ADDON_IS_ADDED") }
  /// Personal identity no.
  public static var contractPersonalIdentity: String { L10n.tr("Localizable", "CONTRACT_PERSONAL_IDENTITY") }
  /// Are you sure you want to \nremove co-insured?
  public static var contractRemoveCoinsuredConfirmation: String { L10n.tr("Localizable", "CONTRACT_REMOVE_COINSURED_CONFIRMATION") }
  /// Are you sure you want to \nremove co-owner?
  public static var contractRemoveCoownerConfirmation: String { L10n.tr("Localizable", "CONTRACT_REMOVE_COOWNER_CONFIRMATION") }
  /// Fetch info
  public static var contractSsnFetchInfo: String { L10n.tr("Localizable", "CONTRACT_SSN_FETCH_INFO") }
  /// To be activated on %1$@
  public static func contractStatusActiveInFuture(_ p1: String) -> String {
    return L10n.tr("Localizable", "CONTRACT_STATUS_ACTIVE_IN_FUTURE", p1)
  }
  /// Waiting for start date
  public static var contractStatusPending: String { L10n.tr("Localizable", "CONTRACT_STATUS_PENDING") }
  /// To be terminated after today
  public static var contractStatusTerminatedToday: String { L10n.tr("Localizable", "CONTRACT_STATUS_TERMINATED_TODAY") }
  /// Terminates on %1$@
  public static func contractStatusToBeTerminated(_ p1: String) -> String {
    return L10n.tr("Localizable", "CONTRACT_STATUS_TO_BE_TERMINATED", p1)
  }
  /// Terminated  %1$@
  public static func contractTerminatedOn(_ p1: String) -> String {
    return L10n.tr("Localizable", "CONTRACT_TERMINATED_ON", p1)
  }
  /// View certificate
  public static var contractViewCertificateButton: String { L10n.tr("Localizable", "CONTRACT_VIEW_CERTIFICATE_BUTTON") }
  /// Valid until %1$@
  public static func contractsTrialTerminationDateMessage(_ p1: String) -> String {
    return L10n.tr("Localizable", "CONTRACTS_TRIAL_TERMINATION_DATE_MESSAGE", p1)
  }
  /// Valid until tomorrow
  public static var contractsTrialTerminationDateMessageTomorrow: String { L10n.tr("Localizable", "CONTRACTS_TRIAL_TERMINATION_DATE_MESSAGE_TOMORROW") }
  /// Popular choice
  public static var crossSellBannerText: String { L10n.tr("Localizable", "CROSS_SELL_BANNER_TEXT") }
  /// See your price
  public static var crossSellButton: String { L10n.tr("Localizable", "CROSS_SELL_BUTTON") }
  /// Get price
  public static var crossSellGetPrice: String { L10n.tr("Localizable", "cross_sell_get_price") }
  /// See price
  public static var crossSellSeePrice: String { L10n.tr("Localizable", "cross_sell_see_price") }
  /// Discover more coverage
  public static var crossSellSubtitle: String { L10n.tr("Localizable", "CROSS_SELL_SUBTITLE") }
  /// For you
  public static var crossSellTitle: String { L10n.tr("Localizable", "CROSS_SELL_TITLE") }
  /// Active
  public static var dashboardInsuranceStatusActive: String { L10n.tr("Localizable", "DASHBOARD_INSURANCE_STATUS_ACTIVE") }
  /// To be updated %1$@
  public static func dashboardInsuranceStatusActiveUpdateDate(_ p1: String) -> String {
    return L10n.tr("Localizable", "DASHBOARD_INSURANCE_STATUS_ACTIVE_UPDATE_DATE", p1)
  }
  /// Read new certificates
  public static var dashboardMultipleRenewalsPrompterButton: String { L10n.tr("Localizable", "dashboard_multiple_renewals_prompter_button") }
  /// Contact us
  public static var dashboardOpenChat: String { L10n.tr("Localizable", "DASHBOARD_OPEN_CHAT") }
  /// In %1$li days your insurance will be renewed. Read your updated insurance certificate here.
  public static func dashboardRenewalPrompterBody(_ p1: Int) -> String {
    return L10n.tr("Localizable", "DASHBOARD_RENEWAL_PROMPTER_BODY", p1)
  }
  /// Read certificate
  public static var dashboardRenewalPrompterBodyButton: String { L10n.tr("Localizable", "DASHBOARD_RENEWAL_PROMPTER_BODY_BUTTON") }
  /// Your insurance will be renewed tomorrow. Read your updated insurance certificate here.
  public static var dashboardRenewalPrompterBodyTomorrow: String { L10n.tr("Localizable", "DASHBOARD_RENEWAL_PROMPTER_BODY_TOMORROW") }
  /// Contract
  public static var deepLinkContract: String { L10n.tr("Localizable", "DEEP_LINK_CONTRACT") }
  /// Cancel
  public static var demoModeCancel: String { L10n.tr("Localizable", "DEMO_MODE_CANCEL") }
  /// Start demo mode
  public static var demoModeStart: String { L10n.tr("Localizable", "DEMO_MODE_START") }
  /// Price
  public static var detailsTableInsurancePremium: String { L10n.tr("Localizable", "DETAILS_TABLE_INSURANCE_PREMIUM") }
  /// OK
  public static var discountRedeemSuccessButton: String { L10n.tr("Localizable", "DISCOUNT_REDEEM_SUCCESS_BUTTON") }
  /// PDF
  public static var documentPdfLabel: String { L10n.tr("Localizable", "DOCUMENT_PDF_LABEL") }
  /// YYYYMMDD-XXXX
  public static var editCoinsuredSsnPlaceholder: String { L10n.tr("Localizable", "edit_coinsured_ssn_placeholder") }
  /// Edit co-owners for your vacation home
  public static var editCoownerSubtitle: String { L10n.tr("Localizable", "EDIT_COOWNER_SUBTITLE") }
  /// Edit co-owners
  public static var editCoownerTitle: String { L10n.tr("Localizable", "EDIT_COOWNER_TITLE") }
  /// email@domain.com
  public static var emailPlaceholder: String { L10n.tr("Localizable", "EMAIL_PLACEHOLDER") }
  /// Email
  public static var emailRowTitle: String { L10n.tr("Localizable", "EMAIL_ROW_TITLE") }
  /// Go back
  public static var embarkGoBackButton: String { L10n.tr("Localizable", "EMBARK_GO_BACK_BUTTON") }
  /// Loading...
  public static var embarkLoading: String { L10n.tr("Localizable", "EMBARK_LOADING") }
  /// Record again
  public static var embarkRecordAgain: String { L10n.tr("Localizable", "EMBARK_RECORD_AGAIN") }
  /// Stop recording
  public static var embarkStopRecording: String { L10n.tr("Localizable", "EMBARK_STOP_RECORDING") }
  /// Submit Claim
  public static var embarkSubmitClaim: String { L10n.tr("Localizable", "EMBARK_SUBMIT_CLAIM") }
  /// Your app is out of date and needs to be updated before you can proceed.
  public static var embarkUpdateAppBody: String { L10n.tr("Localizable", "EMBARK_UPDATE_APP_BODY") }
  /// Update now
  public static var embarkUpdateAppButton: String { L10n.tr("Localizable", "EMBARK_UPDATE_APP_BUTTON") }
  /// Update app
  public static var embarkUpdateAppTitle: String { L10n.tr("Localizable", "EMBARK_UPDATE_APP_TITLE") }
  /// Other Files
  public static var fileUploadChooseFiles: String { L10n.tr("Localizable", "file_upload_choose_files") }
  /// Added files saved
  public static var fileUploadFilesAdded: String { L10n.tr("Localizable", "file_upload_files_added") }
  /// Uploading...
  public static var fileUploadIsUploading: String { L10n.tr("Localizable", "FILE_UPLOAD_IS_UPLOADING") }
  /// Your photos
  public static var fileUploadPhotoLibrary: String { L10n.tr("Localizable", "file_upload_photo_library") }
  /// Take Photo
  public static var fileUploadTakePhoto: String { L10n.tr("Localizable", "file_upload_take_photo") }
  /// Upload files
  public static var fileUploadUploadFiles: String { L10n.tr("Localizable", "file_upload_upload_files") }
  /// You’ve been logged out
  public static var forceLogoutMessageTitle: String { L10n.tr("Localizable", "FORCE_LOGOUT_MESSAGE_TITLE") }
  /// Plural format key: "%#@format@"
  public static func foreverReferralInvitedByYouPlural(_ p1: Int) -> String {
    return L10n.tr("Localizable", "FOREVER_REFERRAL_INVITED_BY_YOU_PLURAL", p1)
  }
  /// Invited friends
  public static var foreverReferralListLabel: String { L10n.tr("Localizable", "FOREVER_REFERRAL_LIST_LABEL") }
  /// Monthly discount
  public static var foreverTabMonthlyDiscount: String { L10n.tr("Localizable", "FOREVER_TAB_MONTHLY_DISCOUNT") }
  /// Full Name
  public static var fullNameText: String { L10n.tr("Localizable", "FULL_NAME_TEXT") }
  /// Add
  public static var generalAddButton: String { L10n.tr("Localizable", "GENERAL_ADD_BUTTON") }
  /// Add info
  public static var generalAddInfoButton: String { L10n.tr("Localizable", "GENERAL_ADD_INFO_BUTTON") }
  /// Add new
  public static var generalAddNew: String { L10n.tr("Localizable", "GENERAL_ADD_NEW") }
  /// Cancel
  public static var generalCancelButton: String { L10n.tr("Localizable", "general_cancel_button") }
  /// Close
  public static var generalCloseButton: String { L10n.tr("Localizable", "general_close_button") }
  /// Confirm
  public static var generalConfirm: String { L10n.tr("Localizable", "GENERAL_CONFIRM") }
  /// Contact our service team
  public static var generalContactUsTitle: String { L10n.tr("Localizable", "GENERAL_CONTACT_US_TITLE") }
  /// Continue
  public static var generalContinueButton: String { L10n.tr("Localizable", "general_continue_button") }
  /// Disabled
  public static var generalDisabled: String { L10n.tr("Localizable", "GENERAL_DISABLED") }
  /// Done
  public static var generalDoneButton: String { L10n.tr("Localizable", "general_done_button") }
  /// Enabled
  public static var generalEnabled: String { L10n.tr("Localizable", "GENERAL_ENABLED") }
  /// Error
  public static var generalError: String { L10n.tr("Localizable", "general_error") }
  /// Go to %1$@
  public static func generalGoTo(_ p1: String) -> String {
    return L10n.tr("Localizable", "GENERAL_GO_TO", p1)
  }
  /// No thanks
  public static var generalNoThanks: String { L10n.tr("Localizable", "GENERAL_NO_THANKS") }
  /// Not selected
  public static var generalNotSelected: String { L10n.tr("Localizable", "GENERAL_NOT_SELECTED") }
  /// Try again
  public static var generalRetry: String { L10n.tr("Localizable", "GENERAL_RETRY") }
  /// Save
  public static var generalSaveButton: String { L10n.tr("Localizable", "general_save_button") }
  /// Select
  public static var generalSelectButton: String { L10n.tr("Localizable", "general_select_button") }
  /// Today
  public static var generalToday: String { L10n.tr("Localizable", "GENERAL_TODAY") }
  /// Please try again
  public static var generalTryAgain: String { L10n.tr("Localizable", "GENERAL_TRY_AGAIN") }
  /// Yesterday
  public static var generalYesterday: String { L10n.tr("Localizable", "GENERAL_YESTERDAY") }
  /// Unknown
  public static var genericUnknown: String { L10n.tr("Localizable", "GENERIC_UNKNOWN") }
  /// All questions
  public static var hcAllQuestionTitle: String { L10n.tr("Localizable", "HC_ALL_QUESTION_TITLE") }
  /// Answer
  public static var hcAnswerTitle: String { L10n.tr("Localizable", "HC_ANSWER_TITLE") }
  /// Reach us on weekdays 08–22 or weekends & public holidays 10–22
  public static var hcChatAnswer: String { L10n.tr("Localizable", "HC_CHAT_ANSWER") }
  /// Go to inbox
  public static var hcChatGoToInbox: String { L10n.tr("Localizable", "HC_CHAT_GO_TO_INBOX") }
  /// Still need help?
  public static var hcChatQuestion: String { L10n.tr("Localizable", "HC_CHAT_QUESTION") }
  /// Common questions
  public static var hcCommonQuestionsTitle: String { L10n.tr("Localizable", "HC_COMMON_QUESTIONS_TITLE") }
  /// Common topics
  public static var hcCommonTopicsTitle: String { L10n.tr("Localizable", "HC_COMMON_TOPICS_TITLE") }
  /// There is a lot you can do directly here in the app. Select a topic to resolve your issue quickly. Still need help? Send us a message.
  public static var hcHomeViewAnswer: String { L10n.tr("Localizable", "HC_HOME_VIEW_ANSWER") }
  /// Need help?
  public static var hcHomeViewQuestion: String { L10n.tr("Localizable", "HC_HOME_VIEW_QUESTION") }
  /// Question
  public static var hcQuestionTitle: String { L10n.tr("Localizable", "HC_QUESTION_TITLE") }
  /// Questions
  public static var hcQuestionsTitle: String { L10n.tr("Localizable", "HC_QUESTIONS_TITLE") }
  /// Cancellation
  public static var hcQuickActionsCancellationTitle: String { L10n.tr("Localizable", "HC_QUICK_ACTIONS_CANCELLATION_TITLE") }
  /// Update to a new home address
  public static var hcQuickActionsChangeAddressSubtitle: String { L10n.tr("Localizable", "HC_QUICK_ACTIONS_CHANGE_ADDRESS_SUBTITLE") }
  /// Move to new address
  public static var hcQuickActionsChangeAddressTitle: String { L10n.tr("Localizable", "HC_QUICK_ACTIONS_CHANGE_ADDRESS_TITLE") }
  /// Edit your co-insured
  public static var hcQuickActionsCoInsuredSubtitle: String { L10n.tr("Localizable", "HC_QUICK_ACTIONS_CO_INSURED_SUBTITLE") }
  /// Co-insured
  public static var hcQuickActionsCoInsuredTitle: String { L10n.tr("Localizable", "HC_QUICK_ACTIONS_CO_INSURED_TITLE") }
  /// Edit co-insured
  public static var hcQuickActionsEditCoinsured: String { L10n.tr("Localizable", "HC_QUICK_ACTIONS_EDIT_COINSURED") }
  /// Manage and update your insurance
  public static var hcQuickActionsEditInsuranceSubtitle: String { L10n.tr("Localizable", "HC_QUICK_ACTIONS_EDIT_INSURANCE_SUBTITLE") }
  /// Edit your insurance
  public static var hcQuickActionsEditInsuranceTitle: String { L10n.tr("Localizable", "HC_QUICK_ACTIONS_EDIT_INSURANCE_TITLE") }
  /// Schedule a call with a vet
  public static var hcQuickActionsFirstvetSubtitle: String { L10n.tr("Localizable", "HC_QUICK_ACTIONS_FIRSTVET_SUBTITLE") }
  /// FirstVet
  public static var hcQuickActionsFirstvetTitle: String { L10n.tr("Localizable", "HC_QUICK_ACTIONS_FIRSTVET_TITLE") }
  /// Change bank or bank account
  public static var hcQuickActionsPaymentsSubtitle: String { L10n.tr("Localizable", "HC_QUICK_ACTIONS_PAYMENTS_SUBTITLE") }
  /// Manage payment methods
  public static var hcQuickActionsPaymentsSubtitle2: String { L10n.tr("Localizable", "HC_QUICK_ACTIONS_PAYMENTS_SUBTITLE_2") }
  /// Payments
  public static var hcQuickActionsPaymentsTitle: String { L10n.tr("Localizable", "HC_QUICK_ACTIONS_PAYMENTS_TITLE") }
  /// Change or remove active addons
  public static var hcQuickActionsRemoveAddonSubtitle: String { L10n.tr("Localizable", "HC_QUICK_ACTIONS_REMOVE_ADDON_SUBTITLE") }
  /// Get emergency help when sick abroad
  public static var hcQuickActionsSickAbroadSubtitle: String { L10n.tr("Localizable", "HC_QUICK_ACTIONS_SICK_ABROAD_SUBTITLE") }
  /// Sick abroad
  public static var hcQuickActionsSickAbroadTitle: String { L10n.tr("Localizable", "HC_QUICK_ACTIONS_SICK_ABROAD_TITLE") }
  /// No binding time, cancel anytime
  public static var hcQuickActionsTerminationSubtitle: String { L10n.tr("Localizable", "HC_QUICK_ACTIONS_TERMINATION_SUBTITLE") }
  /// Cancellation
  public static var hcQuickActionsTerminationTitle: String { L10n.tr("Localizable", "HC_QUICK_ACTIONS_TERMINATION_TITLE") }
  /// Quick actions
  public static var hcQuickActionsTitle: String { L10n.tr("Localizable", "HC_QUICK_ACTIONS_TITLE") }
  /// Travel certificate
  public static var hcQuickActionsTravelCertificate: String { L10n.tr("Localizable", "HC_QUICK_ACTIONS_TRAVEL_CERTIFICATE") }
  /// Get a travel certificate for your trip
  public static var hcQuickActionsTravelCertificateSubtitle: String { L10n.tr("Localizable", "HC_QUICK_ACTIONS_TRAVEL_CERTIFICATE_SUBTITLE") }
  /// Change your coverage level and deductible
  public static var hcQuickActionsUpgradeCoverageSubtitle: String { L10n.tr("Localizable", "HC_QUICK_ACTIONS_UPGRADE_COVERAGE_SUBTITLE") }
  /// Change coverage
  public static var hcQuickActionsUpgradeCoverageTitle: String { L10n.tr("Localizable", "HC_QUICK_ACTIONS_UPGRADE_COVERAGE_TITLE") }
  /// Related questions
  public static var hcRelatedQuestionsTitle: String { L10n.tr("Localizable", "HC_RELATED_QUESTIONS_TITLE") }
  /// Help and support
  public static var hcTitle: String { L10n.tr("Localizable", "HC_TITLE") }
  /// Read more
  public static var homeAddonsReadMoreButton: String { L10n.tr("Localizable", "HOME_ADDONS_READ_MORE_BUTTON") }
  /// Discover our insurances
  public static var homeDiscoverSectionTitle: String { L10n.tr("Localizable", "HOME_DISCOVER_SECTION_TITLE") }
  /// How can we help?
  public static var homeGreetingSubtitle: String { L10n.tr("Localizable", "HOME_GREETING_SUBTITLE") }
  /// Hi %1$@
  public static func homeGreetingTitle(_ p1: String) -> String {
    return L10n.tr("Localizable", "HOME_GREETING_TITLE", p1)
  }
  /// I'm moving
  public static var homeQuickActionsChangeAddress: String { L10n.tr("Localizable", "HOME_QUICK_ACTIONS_CHANGE_ADDRESS") }
  /// Edit insurance
  public static var homeQuickActionsEditInsurance: String { L10n.tr("Localizable", "HOME_QUICK_ACTIONS_EDIT_INSURANCE") }
  /// Invite a friend
  public static var homeQuickActionsInvite: String { L10n.tr("Localizable", "HOME_QUICK_ACTIONS_INVITE") }
  /// Travel certificate
  public static var homeQuickActionsTravelCert: String { L10n.tr("Localizable", "HOME_QUICK_ACTIONS_TRAVEL_CERT") }
  /// Upcoming payment
  public static var homeQuickActionsUpcomingPayment: String { L10n.tr("Localizable", "HOME_QUICK_ACTIONS_UPCOMING_PAYMENT") }
  /// Change my coverage
  public static var homeQuickActionsUpgradeCoverage: String { L10n.tr("Localizable", "HOME_QUICK_ACTIONS_UPGRADE_COVERAGE") }
  /// Your quotes
  public static var homeQuotesSectionTitle: String { L10n.tr("Localizable", "HOME_QUOTES_SECTION_TITLE") }
  /// Add co-insured
  public static var homeTodoAddCoinsuredTitle: String { L10n.tr("Localizable", "HOME_TODO_ADD_COINSURED_TITLE") }
  /// Add co-owner
  public static var homeTodoAddCoownerTitle: String { L10n.tr("Localizable", "HOME_TODO_ADD_COOWNER_TITLE") }
  /// Missing pet chip-ID
  public static var homeTodoMissingChipIdTitle: String { L10n.tr("Localizable", "HOME_TODO_MISSING_CHIP_ID_TITLE") }
  /// Missing payment method
  public static var homeTodoMissingPaymentMethodTitle: String { L10n.tr("Localizable", "HOME_TODO_MISSING_PAYMENT_METHOD_TITLE") }
  /// Missing payout method
  public static var homeTodoMissingPayoutMethodTitle: String { L10n.tr("Localizable", "HOME_TODO_MISSING_PAYOUT_METHOD_TITLE") }
  /// Your payment is overdue
  public static var homeTodoPaymentOverdueTitle: String { L10n.tr("Localizable", "HOME_TODO_PAYMENT_OVERDUE_TITLE") }
  /// Action needed
  public static var homeTodoRequiresActionSubtitle: String { L10n.tr("Localizable", "HOME_TODO_REQUIRES_ACTION_SUBTITLE") }
  /// To do
  public static var homeTodoSectionTitle: String { L10n.tr("Localizable", "HOME_TODO_SECTION_TITLE") }
  /// Choose how we use your data
  public static var homeTodoSelectUsageDataTitle: String { L10n.tr("Localizable", "HOME_TODO_SELECT_USAGE_DATA_TITLE") }
  /// Update contact details
  public static var homeTodoUpdateContactDetailsTitle: String { L10n.tr("Localizable", "HOME_TODO_UPDATE_CONTACT_DETAILS_TITLE") }
  /// Hedvig is based on trust. I solemnly swear to recite the event as it was and only claim the compensation I’m entitled to.
  public static var honestyPledgeDescription: String { L10n.tr("Localizable", "HONESTY_PLEDGE_DESCRIPTION") }
  /// Make a claim
  public static var honestyPledgeHeader: String { L10n.tr("Localizable", "HONESTY_PLEDGE_HEADER") }
  /// Not sure about what’s covered? Submit your claim anyway
  public static var honestyPledgeNote1: String { L10n.tr("Localizable", "HONESTY_PLEDGE_NOTE_1") }
  /// Have receipts or other documentation ready to help us help you faster
  public static var honestyPledgeNote2: String { L10n.tr("Localizable", "HONESTY_PLEDGE_NOTE_2") }
  /// We’ll contact you if we need more information
  public static var honestyPledgeNote3: String { L10n.tr("Localizable", "HONESTY_PLEDGE_NOTE_3") }
  /// Before we start
  public static var honestyPledgeTitle: String { L10n.tr("Localizable", "HONESTY_PLEDGE_TITLE") }
  /// No conversations yet. Start one by writing a message
  public static var inboxEmptyStateSubtitle: String { L10n.tr("Localizable", "INBOX_EMPTY_STATE_SUBTITLE") }
  /// Your inbox is empty
  public static var inboxEmptyStateTitle: String { L10n.tr("Localizable", "INBOX_EMPTY_STATE_TITLE") }
  /// New
  public static var inboxNewMessage: String { L10n.tr("Localizable", "INBOX_NEW_MESSAGE") }
  /// Make a claim for something that's happened to you or your things
  public static var inboxNewMessageClaimDescription: String { L10n.tr("Localizable", "INBOX_NEW_MESSAGE_CLAIM_DESCRIPTION") }
  /// Questions about your insurance, payments and more
  public static var inboxNewMessageSupportDescription: String { L10n.tr("Localizable", "INBOX_NEW_MESSAGE_SUPPORT_DESCRIPTION") }
  /// Addon
  public static var insuranceAddonSubheading: String { L10n.tr("Localizable", "INSURANCE_ADDON_SUBHEADING") }
  /// Addons
  public static var insuranceAddonsSubheading: String { L10n.tr("Localizable", "INSURANCE_ADDONS_SUBHEADING") }
  /// Insurance certificate
  public static var insuranceCertificateTitle: String { L10n.tr("Localizable", "insurance_certificate_title") }
  /// To return to your previous coverage, register your car as active again with Transportstyrelsen.
  public static var insuranceDetailsDecommissionInfo: String { L10n.tr("Localizable", "INSURANCE_DETAILS_DECOMMISSION_INFO") }
  /// Offers
  public static var insuranceOffersSubheading: String { L10n.tr("Localizable", "INSURANCE_OFFERS_SUBHEADING") }
  /// This is a simplified summary. Your terms always decide what’s covered.
  public static var insurancePerilsInfo: String { L10n.tr("Localizable", "INSURANCE_PERILS_INFO") }
  /// Get a price quote
  public static var insurancesTabMovingFlowInfoButtonTitle: String { L10n.tr("Localizable", "insurances_tab_moving_flow_info_button_title") }
  /// Are you moving? See if we can offer you a better price on your new home.
  public static var insurancesTabMovingFlowInfoTitle: String { L10n.tr("Localizable", "insurances_tab_moving_flow_info_title") }
  /// Do you want to pay your insurance via direct debit and enable quick payouts in the event of claims?
  public static var kivraNotificationBoxText: String { L10n.tr("Localizable", "KIVRA_NOTIFICATION_BOX_TEXT") }
  /// The invoice is sent to your Kivra inbox 14 days before the due date each month.
  public static var kivraPaymentInfo: String { L10n.tr("Localizable", "KIVRA_PAYMENT_INFO") }
  /// Accessibility
  public static var legalA11Y: String { L10n.tr("Localizable", "LEGAL_A11Y") }
  /// Legal information
  public static var legalInformation: String { L10n.tr("Localizable", "LEGAL_INFORMATION") }
  /// Privacy policy
  public static var legalPrivacyPolicy: String { L10n.tr("Localizable", "LEGAL_PRIVACY_POLICY") }
  /// Privacy notice (Hedvig app)
  public static var legalPrivacyPolicyApp: String { L10n.tr("Localizable", "LEGAL_PRIVACY_POLICY_APP") }
  /// Privacy notice
  public static var legalPrivacyPolicyAppShort: String { L10n.tr("Localizable", "LEGAL_PRIVACY_POLICY_APP_SHORT") }
  /// Choose your preferred language
  public static var loginLanguagePreferences: String { L10n.tr("Localizable", "LOGIN_LANGUAGE_PREFERENCES") }
  /// Cancel
  public static var logoutAlertActionCancel: String { L10n.tr("Localizable", "LOGOUT_ALERT_ACTION_CANCEL") }
  /// Yes
  public static var logoutAlertActionConfirm: String { L10n.tr("Localizable", "LOGOUT_ALERT_ACTION_CONFIRM") }
  /// Are you sure you want to log out?
  public static var logoutAlertTitle: String { L10n.tr("Localizable", "LOGOUT_ALERT_TITLE") }
  /// Logout
  public static var logoutButton: String { L10n.tr("Localizable", "LOGOUT_BUTTON") }
  /// Activate your coverage again by contacting us once your payment has been processed
  public static var manualChargeCancellationWarning: String { L10n.tr("Localizable", "MANUAL_CHARGE_CANCELLATION_WARNING") }
  /// Other
  public static var manualInputListOther: String { L10n.tr("Localizable", "MANUAL_INPUT_LIST_OTHER") }
  /// Get a price quote
  public static var marketingGetHedvig: String { L10n.tr("Localizable", "MARKETING_GET_HEDVIG") }
  /// Review contact info
  public static var missingContactInfoCardButton: String { L10n.tr("Localizable", "MISSING_CONTACT_INFO_CARD_BUTTON") }
  /// Make sure we have the right contact info in case we need to reach you.
  public static var missingContactInfoCardText: String { L10n.tr("Localizable", "MISSING_CONTACT_INFO_CARD_TEXT") }
  /// mo
  public static var monthAbbreviationLabel: String { L10n.tr("Localizable", "MONTH_ABBREVIATION_LABEL") }
  /// Something went wrong, please send us a message here in the app for further help.
  public static var moveintentGenericError: String { L10n.tr("Localizable", "MOVEINTENT_GENERIC_ERROR") }
  /// Change address
  public static var movingEmbarkTitle: String { L10n.tr("Localizable", "moving_embark_title") }
  /// Which insurance do you want to update the address for?
  public static var movingFlowBody: String { L10n.tr("Localizable", "MOVING_FLOW_BODY") }
  /// Insurance certificate
  public static var myDocumentsInsuranceCertificate: String { L10n.tr("Localizable", "MY_DOCUMENTS_INSURANCE_CERTIFICATE") }
  /// You forgot to enter your email
  public static var myInfoEmailEmptyError: String { L10n.tr("Localizable", "MY_INFO_EMAIL_EMPTY_ERROR") }
  /// The entered email address doesn't seem correct
  public static var myInfoEmailMalformedError: String { L10n.tr("Localizable", "MY_INFO_EMAIL_MALFORMED_ERROR") }
  /// You have not entered a phone number
  public static var myInfoPhoneNumberEmptyError: String { L10n.tr("Localizable", "MY_INFO_PHONE_NUMBER_EMPTY_ERROR") }
  /// Check that the phone number you've entered is correct
  public static var myInfoPhoneNumberMalformedError: String { L10n.tr("Localizable", "MY_INFO_PHONE_NUMBER_MALFORMED_ERROR") }
  /// Bank
  public static var myPaymentBankRowLabel: String { L10n.tr("Localizable", "MY_PAYMENT_BANK_ROW_LABEL") }
  /// Connect card
  public static var myPaymentDirectDebitButton: String { L10n.tr("Localizable", "MY_PAYMENT_DIRECT_DEBIT_BUTTON") }
  /// Change bank account
  public static var myPaymentDirectDebitReplaceButton: String { L10n.tr("Localizable", "MY_PAYMENT_DIRECT_DEBIT_REPLACE_BUTTON") }
  /// Payments
  public static var myPaymentTitle: String { L10n.tr("Localizable", "MY_PAYMENT_TITLE") }
  /// You have just added or changed your bank account, your new bank account will appear here after your bank has accepted autogiro. Usually within 2 working days.
  public static var myPaymentUpdatingMessage: String { L10n.tr("Localizable", "MY_PAYMENT_UPDATING_MESSAGE") }
  /// New message
  public static var newMessageButton: String { L10n.tr("Localizable", "NEW_MESSAGE_BUTTON") }
  /// Your monthly compensation
  public static var offerPresenterInsuranceAmountSubtitle: String { L10n.tr("Localizable", "OFFER_PRESENTER_INSURANCE_AMOUNT_SUBTITLE") }
  /// Choose insurance amount
  public static var offerPresenterInsuranceAmountTitle: String { L10n.tr("Localizable", "OFFER_PRESENTER_INSURANCE_AMOUNT_TITLE") }
  /// Summary
  public static var offerUpdateSummaryTitle: String { L10n.tr("Localizable", "OFFER_UPDATE_SUMMARY_TITLE") }
  /// Add
  public static var onboardingAddButton: String { L10n.tr("Localizable", "ONBOARDING_ADD_BUTTON") }
  /// Add co-insured
  public static var onboardingAddCoinsuredTitle: String { L10n.tr("Localizable", "ONBOARDING_ADD_COINSURED_TITLE") }
  /// Add co-owners
  public static var onboardingAddCoownersTitle: String { L10n.tr("Localizable", "ONBOARDING_ADD_COOWNERS_TITLE") }
  /// You can add this later
  public static var onboardingAddInfoLaterLabel: String { L10n.tr("Localizable", "ONBOARDING_ADD_INFO_LATER_LABEL") }
  /// Add your pet ID-numbers
  public static var onboardingAddPetChipIdsTitle: String { L10n.tr("Localizable", "ONBOARDING_ADD_PET_CHIP_IDS_TITLE") }
  /// Added
  public static var onboardingAddedLabel: String { L10n.tr("Localizable", "ONBOARDING_ADDED_LABEL") }
  /// Allow
  public static var onboardingAnalyticsAllowButton: String { L10n.tr("Localizable", "ONBOARDING_ANALYTICS_ALLOW_BUTTON") }
  /// Don't allow
  public static var onboardingAnalyticsDenyButton: String { L10n.tr("Localizable", "ONBOARDING_ANALYTICS_DENY_BUTTON") }
  /// We use technical tools to collect data on how you use the app, so we can improve the experience.\n\nProduct analytics is completely optional and can be turned off anytime in settings. This data is not used for marketing.
  public static var onboardingAnalyticsSubtitle: String { L10n.tr("Localizable", "ONBOARDING_ANALYTICS_SUBTITLE") }
  /// Help us make the app better
  public static var onboardingAnalyticsTitle: String { L10n.tr("Localizable", "ONBOARDING_ANALYTICS_TITLE") }
  /// You can change this anytime in settings
  public static var onboardingChangeSettingsLaterLabel: String { L10n.tr("Localizable", "ONBOARDING_CHANGE_SETTINGS_LATER_LABEL") }
  /// Bank
  public static var onboardingConnectPaymentBankLabel: String { L10n.tr("Localizable", "ONBOARDING_CONNECT_PAYMENT_BANK_LABEL") }
  /// You can change accounts later in settings
  public static var onboardingConnectPaymentFootnote: String { L10n.tr("Localizable", "ONBOARDING_CONNECT_PAYMENT_FOOTNOTE") }
  /// You need to connect a payment method to keep your insurance active
  public static var onboardingConnectPaymentSubtitle: String { L10n.tr("Localizable", "ONBOARDING_CONNECT_PAYMENT_SUBTITLE") }
  /// You can change your payment method later in Payments
  public static var onboardingConnectPaymentSwitchAccountsLater: String { L10n.tr("Localizable", "ONBOARDING_CONNECT_PAYMENT_SWITCH_ACCOUNTS_LATER") }
  /// Connect payment method
  public static var onboardingConnectPaymentTitle: String { L10n.tr("Localizable", "ONBOARDING_CONNECT_PAYMENT_TITLE") }
  /// Go to the app
  public static var onboardingContinueToAppButton: String { L10n.tr("Localizable", "ONBOARDING_CONTINUE_TO_APP_BUTTON") }
  /// You get a 15%% bundle discount when you have two or more insurances with us
  public static var onboardingCrossSellSubtitle: String { L10n.tr("Localizable", "ONBOARDING_CROSS_SELL_SUBTITLE") }
  /// Get bundle discount
  public static var onboardingCrossSellTitle: String { L10n.tr("Localizable", "ONBOARDING_CROSS_SELL_TITLE") }
  /// Do this later
  public static var onboardingDoThisLaterButton: String { L10n.tr("Localizable", "ONBOARDING_DO_THIS_LATER_BUTTON") }
  /// When someone gets Hedvig with your code you both get %1$@ discount per month
  public static func onboardingInviteFriendSubtitle(_ p1: String) -> String {
    return L10n.tr("Localizable", "ONBOARDING_INVITE_FRIEND_SUBTITLE", p1)
  }
  /// When someone gets Hedvig with your code you both get monthly discount
  public static var onboardingInviteFriendSubtitleFallback: String { L10n.tr("Localizable", "ONBOARDING_INVITE_FRIEND_SUBTITLE_FALLBACK") }
  /// Invite a friend
  public static var onboardingInviteFriendTitle: String { L10n.tr("Localizable", "ONBOARDING_INVITE_FRIEND_TITLE") }
  /// It's faster if you ever need to make a claim
  public static var onboardingMissingInfoPetSubtitle: String { L10n.tr("Localizable", "ONBOARDING_MISSING_INFO_PET_SUBTITLE") }
  /// So we know who's covered by your insurance
  public static var onboardingMissingInfoSubtitle: String { L10n.tr("Localizable", "ONBOARDING_MISSING_INFO_SUBTITLE") }
  /// Plural format key: "%#@format@"
  public static func onboardingNumberOfCoinsured(_ p1: Int) -> String {
    return L10n.tr("Localizable", "ONBOARDING_NUMBER_OF_COINSURED", p1)
  }
  /// Plural format key: "%#@format@"
  public static func onboardingNumberOfCoowners(_ p1: Int) -> String {
    return L10n.tr("Localizable", "ONBOARDING_NUMBER_OF_COOWNERS", p1)
  }
  /// Opens in your browser
  public static var onboardingOpensInBrowserHint: String { L10n.tr("Localizable", "ONBOARDING_OPENS_IN_BROWSER_HINT") }
  /// Could not save, please try again
  public static var onboardingPhoneSaveError: String { L10n.tr("Localizable", "ONBOARDING_PHONE_SAVE_ERROR") }
  /// So we can reach you if we need to
  public static var onboardingPhoneSubtitle: String { L10n.tr("Localizable", "ONBOARDING_PHONE_SUBTITLE") }
  /// Phone number
  public static var onboardingPhoneTitle: String { L10n.tr("Localizable", "ONBOARDING_PHONE_TITLE") }
  /// Always dark
  public static var onboardingThemeDarkSubtitle: String { L10n.tr("Localizable", "ONBOARDING_THEME_DARK_SUBTITLE") }
  /// Always light
  public static var onboardingThemeLightSubtitle: String { L10n.tr("Localizable", "ONBOARDING_THEME_LIGHT_SUBTITLE") }
  /// Choose how the app looks
  public static var onboardingThemeSubtitle: String { L10n.tr("Localizable", "ONBOARDING_THEME_SUBTITLE") }
  /// Follows your phone's setting
  public static var onboardingThemeSystemSubtitle: String { L10n.tr("Localizable", "ONBOARDING_THEME_SYSTEM_SUBTITLE") }
  /// Get started
  public static var onboardingWelcomeButton: String { L10n.tr("Localizable", "ONBOARDING_WELCOME_BUTTON") }
  /// A few steps to get started with your insurance
  public static var onboardingWelcomeSubtitle: String { L10n.tr("Localizable", "ONBOARDING_WELCOME_SUBTITLE") }
  /// Welcome to Hedvig
  public static var onboardingWelcomeTitle: String { L10n.tr("Localizable", "ONBOARDING_WELCOME_TITLE") }
  /// Write message
  public static var openChat: String { L10n.tr("Localizable", "open_chat") }
  /// %@ is not supported. Update to the latest operating system to use the Hedvig app.
  public static func osVersionTooLowBody(_ p1: String) -> String {
    return L10n.tr("Localizable", "OS_VERSION_TOO_LOW_BODY", p1)
  }
  /// Your iOS needs to be updated
  public static var osVersionTooLowTitle: String { L10n.tr("Localizable", "OS_VERSION_TOO_LOW_TITLE") }
  /// By connecting a payment method, you agree that your premium will be charged automatically each month. We'll notify you in the Hedvig app before each payment.
  public static var payinInfoBox: String { L10n.tr("Localizable", "PAYIN_INFO_BOX") }
  /// Add payment method
  public static var paymentAddMethodButton: String { L10n.tr("Localizable", "PAYMENT_ADD_METHOD_BUTTON") }
  /// You can change payment method later
  public static var paymentChangeFootnote: String { L10n.tr("Localizable", "PAYMENT_CHANGE_FOOTNOTE") }
  /// Change payment method
  public static var paymentChangeMethodButton: String { L10n.tr("Localizable", "PAYMENT_CHANGE_METHOD_BUTTON") }
  /// Change primary method
  public static var paymentChoosePrimaryButton: String { L10n.tr("Localizable", "PAYMENT_CHOOSE_PRIMARY_BUTTON") }
  /// Your next payment will be made via %1$@
  public static func paymentConfirmPrimaryWarning(_ p1: String) -> String {
    return L10n.tr("Localizable", "PAYMENT_CONFIRM_PRIMARY_WARNING", p1)
  }
  /// Add a new payment method for your insurance
  public static var paymentConnectSubtitle: String { L10n.tr("Localizable", "PAYMENT_CONNECT_SUBTITLE") }
  /// Connect payment
  public static var paymentConnectTitle: String { L10n.tr("Localizable", "PAYMENT_CONNECT_TITLE") }
  /// Payment history
  public static var paymentHistoryTitle: String { L10n.tr("Localizable", "PAYMENT_HISTORY_TITLE") }
  /// It can take a few days for your new payment method to take effect.
  public static var paymentMethodPending: String { L10n.tr("Localizable", "PAYMENT_METHOD_PENDING") }
  /// Pending
  public static var paymentMethodPendingStatusLabel: String { L10n.tr("Localizable", "PAYMENT_METHOD_PENDING_STATUS_LABEL") }
  /// Required to keep your insurance active
  public static var paymentMethodRequiredFootnote: String { L10n.tr("Localizable", "PAYMENT_METHOD_REQUIRED_FOOTNOTE") }
  /// Payment method
  public static var paymentMethodTitle: String { L10n.tr("Localizable", "PAYMENT_METHOD_TITLE") }
  /// No payment method added. Add one to pay for your insurance.
  public static var paymentMethodsEmpty: String { L10n.tr("Localizable", "PAYMENT_METHODS_EMPTY") }
  /// Payment methods
  public static var paymentMethodsTitle: String { L10n.tr("Localizable", "PAYMENT_METHODS_TITLE") }
  /// Open Swish
  public static var paymentOpenSwishButton: String { L10n.tr("Localizable", "PAYMENT_OPEN_SWISH_BUTTON") }
  /// Connected
  public static var paymentOptionConnectedLabel: String { L10n.tr("Localizable", "PAYMENT_OPTION_CONNECTED_LABEL") }
  /// Invoice to your Kivra
  public static var paymentOptionInvoiceSubtitle: String { L10n.tr("Localizable", "PAYMENT_OPTION_INVOICE_SUBTITLE") }
  /// Payments and payouts via Swish
  public static var paymentOptionSwishSubtitle: String { L10n.tr("Localizable", "PAYMENT_OPTION_SWISH_SUBTITLE") }
  /// Connect your bank via Trustly
  public static var paymentOptionTrustlySubtitle: String { L10n.tr("Localizable", "PAYMENT_OPTION_TRUSTLY_SUBTITLE") }
  /// Payout account added
  public static var paymentPayoutBankSuccessTitle: String { L10n.tr("Localizable", "PAYMENT_PAYOUT_BANK_SUCCESS_TITLE") }
  /// Confirm payment method
  public static var paymentPrimaryConfirmTitle: String { L10n.tr("Localizable", "PAYMENT_PRIMARY_CONFIRM_TITLE") }
  /// Primary
  public static var paymentPrimaryLabel: String { L10n.tr("Localizable", "PAYMENT_PRIMARY_LABEL") }
  /// This method will be used for your monthly payments
  public static var paymentPrimarySubtitle: String { L10n.tr("Localizable", "PAYMENT_PRIMARY_SUBTITLE") }
  /// Choose payment method
  public static var paymentPrimaryTitle: String { L10n.tr("Localizable", "PAYMENT_PRIMARY_TITLE") }
  /// This is your primary payment method. Choose another one or add a new one before removing it.
  public static var paymentRemovePrimarySubtitle: String { L10n.tr("Localizable", "PAYMENT_REMOVE_PRIMARY_SUBTITLE") }
  /// Can't be removed right now
  public static var paymentRemovePrimaryTitle: String { L10n.tr("Localizable", "PAYMENT_REMOVE_PRIMARY_TITLE") }
  /// You can add it back any time
  public static var paymentRemoveSubtitle: String { L10n.tr("Localizable", "PAYMENT_REMOVE_SUBTITLE") }
  /// Remove payment method
  public static var paymentRemoveTitle: String { L10n.tr("Localizable", "PAYMENT_REMOVE_TITLE") }
  /// Approve the connection in Swish
  public static var paymentSwishApproveTitle: String { L10n.tr("Localizable", "PAYMENT_SWISH_APPROVE_TITLE") }
  /// Change phone number
  public static var paymentSwishChangeNumber: String { L10n.tr("Localizable", "PAYMENT_SWISH_CHANGE_NUMBER") }
  /// Read more about recurring payments
  public static var paymentSwishExplanationButton: String { L10n.tr("Localizable", "PAYMENT_SWISH_EXPLANATION_BUTTON") }
  /// We couldn't connect Swish
  public static var paymentSwishFailureTitle: String { L10n.tr("Localizable", "PAYMENT_SWISH_FAILURE_TITLE") }
  /// Use the number linked to your Swish
  public static var paymentSwishSubtitle: String { L10n.tr("Localizable", "PAYMENT_SWISH_SUBTITLE") }
  /// Your account is charged automatically each month. We’ll notify you in the Hedvig app before each payment.
  public static var paymentSwishSuccessSubtitle: String { L10n.tr("Localizable", "PAYMENT_SWISH_SUCCESS_SUBTITLE") }
  /// Swish is now connected
  public static var paymentSwishSuccessTitle: String { L10n.tr("Localizable", "PAYMENT_SWISH_SUCCESS_TITLE") }
  /// Confirm your Swish number
  public static var paymentSwishTitle: String { L10n.tr("Localizable", "PAYMENT_SWISH_TITLE") }
  /// Connection failed
  public static var paymentTrustlyFailureTitle: String { L10n.tr("Localizable", "PAYMENT_TRUSTLY_FAILURE_TITLE") }
  /// We'll notify you in the app each month
  public static var paymentTrustlySuccessSubtitle: String { L10n.tr("Localizable", "PAYMENT_TRUSTLY_SUCCESS_SUBTITLE") }
  /// Account
  public static var paymentsAccount: String { L10n.tr("Localizable", "PAYMENTS_ACCOUNT") }
  /// I confirm this is my own Swish number, connected to my personal identity number.
  public static var paymentsAddSwishPayoutInfo: String { L10n.tr("Localizable", "PAYMENTS_ADD_SWISH_PAYOUT_INFO") }
  /// Amount to pay
  public static var paymentsAmountToPay: String { L10n.tr("Localizable", "PAYMENTS_AMOUNT_TO_PAY") }
  /// Direct debit
  public static var paymentsAutogiroLabel: String { L10n.tr("Localizable", "PAYMENTS_AUTOGIRO_LABEL") }
  /// Carried adjustment
  public static var paymentsCarriedAdjustment: String { L10n.tr("Localizable", "payments_carried_adjustment") }
  /// Your balance has been used to adjust this month's payment.
  public static var paymentsCarriedAdjustmentInfo: String { L10n.tr("Localizable", "payments_carried_adjustment_info") }
  /// Discounts
  public static var paymentsDiscountsSectionTitle: String { L10n.tr("Localizable", "PAYMENTS_DISCOUNTS_SECTION_TITLE") }
  /// %1$@ each month
  public static func paymentsDueDescription(_ p1: String) -> String {
    return L10n.tr("Localizable", "PAYMENTS_DUE_DESCRIPTION", p1)
  }
  /// For information about payments older than 12 months, please send us a message here in the app.
  public static var paymentsHistoryInfo: String { L10n.tr("Localizable", "PAYMENTS_HISTORY_INFO") }
  /// The payment is being processed. Please note that it may take 1 to 3 banking days for the charge to appear on your account
  public static var paymentsInProgress: String { L10n.tr("Localizable", "PAYMENTS_IN_PROGRESS") }
  /// You can find your invoice in the Kivra app
  public static var paymentsInProgressKivra: String { L10n.tr("Localizable", "PAYMENTS_IN_PROGRESS_KIVRA") }
  /// Share your code
  public static var paymentsInviteFriends: String { L10n.tr("Localizable", "PAYMENTS_INVITE_FRIENDS") }
  /// Invoice
  public static var paymentsInvoice: String { L10n.tr("Localizable", "PAYMENTS_INVOICE") }
  /// Your payment for the period %1$@ – %2$@ didn't process as expected. The amount has been added to this payment.
  public static func paymentsMissedPayment(_ p1: String, _ p2: String) -> String {
    return L10n.tr("Localizable", "PAYMENTS_MISSED_PAYMENT", p1, p2)
  }
  /// There is no record of your payment history
  public static var paymentsNoHistoryData: String { L10n.tr("Localizable", "PAYMENTS_NO_HISTORY_DATA") }
  /// You have no payments in progress
  public static var paymentsNoPaymentsInProgress: String { L10n.tr("Localizable", "PAYMENTS_NO_PAYMENTS_IN_PROGRESS") }
  /// Outstanding payment
  public static var paymentsOutstandingPayment: String { L10n.tr("Localizable", "PAYMENTS_OUTSTANDING_PAYMENT") }
  /// Your monthly payment is processed using digital direct debit (Autogiro) through our payment partner Trustly. Your price is based on several factors, including aspects related to you, your belongings, your lifestyle, and where you live.
  public static var paymentsPaymentDetailsInfoDescription: String { L10n.tr("Localizable", "PAYMENTS_PAYMENT_DETAILS_INFO_DESCRIPTION") }
  /// Your monthly payment is charged automatically via Swish. Your price is based on several factors, including aspects related to you, your belongings, your lifestyle, and where you live.
  public static var paymentsPaymentDetailsSwishDescription: String { L10n.tr("Localizable", "PAYMENTS_PAYMENT_DETAILS_SWISH_DESCRIPTION") }
  /// Payment due
  public static var paymentsPaymentDue: String { L10n.tr("Localizable", "PAYMENTS_PAYMENT_DUE") }
  /// If you update your bank account close to the %1$@, the withdrawal might take a few extra days.
  public static func paymentsPaymentDueInfo(_ p1: String) -> String {
    return L10n.tr("Localizable", "PAYMENTS_PAYMENT_DUE_INFO", p1)
  }
  /// This payment failed and was added to your payment on %1$@.
  public static func paymentsPaymentFailed(_ p1: String) -> String {
    return L10n.tr("Localizable", "PAYMENTS_PAYMENT_FAILED", p1)
  }
  /// Payment history
  public static var paymentsPaymentHistoryButtonLabel: String { L10n.tr("Localizable", "PAYMENTS_PAYMENT_HISTORY_BUTTON_LABEL") }
  /// Payment in progress
  public static var paymentsPaymentInProgress: String { L10n.tr("Localizable", "PAYMENTS_PAYMENT_IN_PROGRESS") }
  /// It may take up to 5 business days for the charge to process
  public static var paymentsPaymentInProgressDescription: String { L10n.tr("Localizable", "PAYMENTS_PAYMENT_IN_PROGRESS_DESCRIPTION") }
  /// Swish payments usually go through right away, it can take a few minutes before it shows up in the app
  public static var paymentsPaymentInProgressSwishDescription: String { L10n.tr("Localizable", "PAYMENTS_PAYMENT_IN_PROGRESS_SWISH_DESCRIPTION") }
  /// It can take up to 5 business days for your bank to process it
  public static var paymentsPaymentInProgressTrustlyDescription: String { L10n.tr("Localizable", "PAYMENTS_PAYMENT_IN_PROGRESS_TRUSTLY_DESCRIPTION") }
  /// Payment method
  public static var paymentsPaymentMethod: String { L10n.tr("Localizable", "PAYMENTS_PAYMENT_METHOD") }
  /// Amount due: %1$@
  public static func paymentsPaymentOverdueAmountDue(_ p1: String) -> String {
    return L10n.tr("Localizable", "PAYMENTS_PAYMENT_OVERDUE_AMOUNT_DUE", p1)
  }
  /// We couldn't collect this payment from your bank account. Pay now to keep your coverage active.
  public static var paymentsPaymentOverdueBody: String { L10n.tr("Localizable", "PAYMENTS_PAYMENT_OVERDUE_BODY") }
  /// Review payment
  public static var paymentsPaymentOverdueButton: String { L10n.tr("Localizable", "PAYMENTS_PAYMENT_OVERDUE_BUTTON") }
  /// Pay now to avoid interruption
  public static var paymentsPaymentOverdueDetailsBody: String { L10n.tr("Localizable", "PAYMENTS_PAYMENT_OVERDUE_DETAILS_BODY") }
  /// Payment due
  public static var paymentsPaymentOverdueDetailsDueDate: String { L10n.tr("Localizable", "PAYMENTS_PAYMENT_OVERDUE_DETAILS_DUE_DATE") }
  /// Ensure your account has enough funds to cover this payment
  public static var paymentsPaymentOverdueDetailsFinePrint: String { L10n.tr("Localizable", "PAYMENTS_PAYMENT_OVERDUE_DETAILS_FINE_PRINT") }
  /// Pay %1$@
  public static func paymentsPaymentOverdueDetailsPay(_ p1: String) -> String {
    return L10n.tr("Localizable", "PAYMENTS_PAYMENT_OVERDUE_DETAILS_PAY", p1)
  }
  /// Overdue since %1$@
  public static func paymentsPaymentOverdueDetailsSince(_ p1: String) -> String {
    return L10n.tr("Localizable", "PAYMENTS_PAYMENT_OVERDUE_DETAILS_SINCE", p1)
  }
  /// View payment details
  public static var paymentsPaymentOverdueDetailsViewDetails: String { L10n.tr("Localizable", "PAYMENTS_PAYMENT_OVERDUE_DETAILS_VIEW_DETAILS") }
  /// No overdue payments
  public static var paymentsPaymentOverdueMissingSubtitle: String { L10n.tr("Localizable", "PAYMENTS_PAYMENT_OVERDUE_MISSING_SUBTITLE") }
  /// Payments up to date
  public static var paymentsPaymentOverdueMissingTitle: String { L10n.tr("Localizable", "PAYMENTS_PAYMENT_OVERDUE_MISSING_TITLE") }
  /// Payment overdue
  public static var paymentsPaymentOverdueTitle: String { L10n.tr("Localizable", "PAYMENTS_PAYMENT_OVERDUE_TITLE") }
  /// Payment successful
  public static var paymentsPaymentSuccessful: String { L10n.tr("Localizable", "PAYMENTS_PAYMENT_SUCCESSFUL") }
  /// %1$@ days
  public static func paymentsPeriodDays(_ p1: String) -> String {
    return L10n.tr("Localizable", "PAYMENTS_PERIOD_DAYS", p1)
  }
  /// Full period
  public static var paymentsPeriodFull: String { L10n.tr("Localizable", "PAYMENTS_PERIOD_FULL") }
  /// Processing payment
  public static var paymentsProcessingPayment: String { L10n.tr("Localizable", "PAYMENTS_PROCESSING_PAYMENT") }
  /// Referral discount
  public static var paymentsReferralDiscount: String { L10n.tr("Localizable", "PAYMENTS_REFERRAL_DISCOUNT") }
  /// We couldn't collect your payment and will try again automatically. Make sure there's enough in your account before the next attempt.
  public static var paymentsRetryInfo: String { L10n.tr("Localizable", "PAYMENTS_RETRY_INFO") }
  /// Settlement adjustment
  public static var paymentsSettlementAdjustment: String { L10n.tr("Localizable", "payments_settlement_adjustment") }
  /// A portion of your balance has been used to adjust this month's payment. The rest will be used to adjust the upcoming month's payment.
  public static var paymentsSettlementAdjustmentInfo: String { L10n.tr("Localizable", "payments_settlement_adjustment_info") }
  /// Subtotal
  public static var paymentsSubtotal: String { L10n.tr("Localizable", "PAYMENTS_SUBTOTAL") }
  /// Phone number
  public static var paymentsSwishNumber: String { L10n.tr("Localizable", "PAYMENTS_SWISH_NUMBER") }
  /// Upcoming payment
  public static var paymentsUpcomingPayment: String { L10n.tr("Localizable", "PAYMENTS_UPCOMING_PAYMENT") }
  /// View payment
  public static var paymentsViewPayment: String { L10n.tr("Localizable", "PAYMENTS_VIEW_PAYMENT") }
  /// Add payout method
  public static var payoutAddPayoutMethod: String { L10n.tr("Localizable", "PAYOUT_ADD_PAYOUT_METHOD") }
  /// Will be used for your payouts
  public static var payoutChooseMethodSubtitle: String { L10n.tr("Localizable", "PAYOUT_CHOOSE_METHOD_SUBTITLE") }
  /// Going forward, we’ll pay out via %1$@
  public static func payoutConfirmationInfo(_ p1: String) -> String {
    return L10n.tr("Localizable", "PAYOUT_CONFIRMATION_INFO", p1)
  }
  /// Confirm payout method
  public static var payoutConfirmationTitle: String { L10n.tr("Localizable", "PAYOUT_CONFIRMATION_TITLE") }
  /// Direct payment via Invoice
  public static var payoutMethodInvoiceDescription: String { L10n.tr("Localizable", "PAYOUT_METHOD_INVOICE_DESCRIPTION") }
  /// Instant payout with Swish
  public static var payoutMethodSwishDescription: String { L10n.tr("Localizable", "PAYOUT_METHOD_SWISH_DESCRIPTION") }
  /// Payout via Trustly
  public static var payoutMethodTrustlyDescription: String { L10n.tr("Localizable", "PAYOUT_METHOD_TRUSTLY_DESCRIPTION") }
  /// You haven’t added a payout method yet. Add one to receive payouts.
  public static var payoutMissingInfo: String { L10n.tr("Localizable", "PAYOUT_MISSING_INFO") }
  /// To receive payouts, you need to connect direct debit
  public static var payoutNoPayoutOptionsSubtitle: String { L10n.tr("Localizable", "PAYOUT_NO_PAYOUT_OPTIONS_SUBTITLE") }
  /// No payout method available
  public static var payoutNoPayoutOptionsTitle: String { L10n.tr("Localizable", "PAYOUT_NO_PAYOUT_OPTIONS_TITLE") }
  /// Payout account
  public static var payoutPageHeading: String { L10n.tr("Localizable", "PAYOUT_PAGE_HEADING") }
  /// Choose payout method
  public static var payoutSelectPayoutMethod: String { L10n.tr("Localizable", "PAYOUT_SELECT_PAYOUT_METHOD") }
  /// /mo
  public static var perMonthShort: String { L10n.tr("Localizable", "PER_MONTH_SHORT") }
  /// Phone
  public static var phoneNumberRowTitle: String { L10n.tr("Localizable", "PHONE_NUMBER_ROW_TITLE") }
  /// Price details
  public static var priceDetailsTitle: String { L10n.tr("Localizable", "PRICE_DETAILS_TITLE") }
  /// New price
  public static var priceNewPrice: String { L10n.tr("Localizable", "PRICE_NEW_PRICE") }
  /// Previous price
  public static var pricePreviousPrice: String { L10n.tr("Localizable", "PRICE_PREVIOUS_PRICE") }
  /// Member ID
  public static var profileAboutAppMemberId: String { L10n.tr("Localizable", "PROFILE_ABOUT_APP_MEMBER_ID") }
  /// Version
  public static var profileAboutAppVersion: String { L10n.tr("Localizable", "PROFILE_ABOUT_APP_VERSION") }
  /// Allow notifications to get notified when we have new updates regarding your claim
  public static var profileAllowNotificationsInfoLabel: String { L10n.tr("Localizable", "PROFILE_ALLOW_NOTIFICATIONS_INFO_LABEL") }
  /// App info
  public static var profileAppInfo: String { L10n.tr("Localizable", "PROFILE_APP_INFO") }
  /// Delete my account
  public static var profileDeleteAccountConfirmDeletion: String { L10n.tr("Localizable", "PROFILE_DELETE_ACCOUNT_CONFIRM_DELETION") }
  /// Information
  public static var profileInfoLabel: String { L10n.tr("Localizable", "PROFILE_INFO_LABEL") }
  /// Make sure your contact info is up to date, so we can reach you if needed.
  public static var profileMyInfoReviewInfoCard: String { L10n.tr("Localizable", "PROFILE_MY_INFO_REVIEW_INFO_CARD") }
  /// Contact
  public static var profileMyInfoRowTitle: String { L10n.tr("Localizable", "PROFILE_MY_INFO_ROW_TITLE") }
  /// Changes saved
  public static var profileMyInfoSaveSuccessToastBody: String { L10n.tr("Localizable", "PROFILE_MY_INFO_SAVE_SUCCESS_TOAST_BODY") }
  /// Contact info
  public static var profileMyInfoTitle: String { L10n.tr("Localizable", "PROFILE_MY_INFO_TITLE") }
  /// Turned off
  public static var profileNotificationsStatusOff: String { L10n.tr("Localizable", "PROFILE_NOTIFICATIONS_STATUS_OFF") }
  /// Turned on
  public static var profileNotificationsStatusOn: String { L10n.tr("Localizable", "PROFILE_NOTIFICATIONS_STATUS_ON") }
  /// Connect direct debit
  public static var profilePaymentConnectDirectDebitButton: String { L10n.tr("Localizable", "PROFILE_PAYMENT_CONNECT_DIRECT_DEBIT_BUTTON") }
  /// Your profile
  public static var profileTitle: String { L10n.tr("Localizable", "PROFILE_TITLE") }
  /// Go to guides
  public static var puppyGuideGoButton: String { L10n.tr("Localizable", "PUPPY_GUIDE_GO_BUTTON") }
  /// In the puppy guide, you’ll find helpful articles covering everything from the first vet visit to choosing the right food.
  public static var puppyGuideInfo: String { L10n.tr("Localizable", "PUPPY_GUIDE_INFO") }
  /// Featured guides
  public static var puppyGuideLabel: String { L10n.tr("Localizable", "PUPPY_GUIDE_LABEL") }
  /// Read
  public static var puppyGuideLabelRead: String { L10n.tr("Localizable", "PUPPY_GUIDE_LABEL_READ") }
  /// Not helpful
  public static var puppyGuideRatingNotHelpful: String { L10n.tr("Localizable", "PUPPY_GUIDE_RATING_NOT_HELPFUL") }
  /// Was this article helpful?
  public static var puppyGuideRatingQuestion: String { L10n.tr("Localizable", "PUPPY_GUIDE_RATING_QUESTION") }
  /// Very helpful
  public static var puppyGuideRatingVeryHelpful: String { L10n.tr("Localizable", "PUPPY_GUIDE_RATING_VERY_HELPFUL") }
  /// Helpful guides for you and your puppy
  public static var puppyGuideSubtitle: String { L10n.tr("Localizable", "PUPPY_GUIDE_SUBTITLE") }
  /// Puppy Guide
  public static var puppyGuideTitle: String { L10n.tr("Localizable", "PUPPY_GUIDE_TITLE") }
  /// Not now
  public static var pushNotificationsAlertActionNotNow: String { L10n.tr("Localizable", "PUSH_NOTIFICATIONS_ALERT_ACTION_NOT_NOW") }
  /// Activate
  public static var pushNotificationsAlertActionOk: String { L10n.tr("Localizable", "PUSH_NOTIFICATIONS_ALERT_ACTION_OK") }
  /// Notifications
  public static var pushNotificationsAlertTitle: String { L10n.tr("Localizable", "PUSH_NOTIFICATIONS_ALERT_TITLE") }
  /// Pending
  public static var referralPendingStatusLabel: String { L10n.tr("Localizable", "REFERRAL_PENDING_STATUS_LABEL") }
  /// Hey! Get Hedvig using my link and we both get %1$@ per month discount on the monthly cost. Follow the link: %2$@
  public static func referralSmsMessage(_ p1: String, _ p2: String) -> String {
    return L10n.tr("Localizable", "REFERRAL_SMS_MESSAGE", p1, p2)
  }
  /// Inactive
  public static var referralTerminatedStatusLabel: String { L10n.tr("Localizable", "REFERRAL_TERMINATED_STATUS_LABEL") }
  /// Remove addon
  public static var removeAddonButtonTitle: String { L10n.tr("Localizable", "REMOVE_ADDON_BUTTON_TITLE") }
  /// This addon is active and part of your insurance
  public static var removeAddonDescription: String { L10n.tr("Localizable", "REMOVE_ADDON_DESCRIPTION") }
  /// The addon is tied to your contract period and can only be removed when your insurance is renewed or cancelled.
  public static var removeAddonDescriptionRenewal: String { L10n.tr("Localizable", "REMOVE_ADDON_DESCRIPTION_RENEWAL") }
  /// Yes, remove
  public static var removeConfirmationButton: String { L10n.tr("Localizable", "REMOVE_CONFIRMATION_BUTTON") }
  /// Try again or send us a message directly in the app
  public static var renewalOpenInsuranceTermsErrorBody: String { L10n.tr("Localizable", "RENEWAL_OPEN_INSURANCE_TERMS_ERROR_BODY") }
  /// Failed to open new insurance terms
  public static var renewalOpenInsuranceTermsErrorTitle: String { L10n.tr("Localizable", "RENEWAL_OPEN_INSURANCE_TERMS_ERROR_TITLE") }
  /// Continue
  public static var resumeClaimContinueButton: String { L10n.tr("Localizable", "RESUME_CLAIM_CONTINUE_BUTTON") }
  /// Everything you've filled in so far will be lost.
  public static var resumeClaimDeleteBody: String { L10n.tr("Localizable", "RESUME_CLAIM_DELETE_BODY") }
  /// Delete
  public static var resumeClaimDeleteButton: String { L10n.tr("Localizable", "RESUME_CLAIM_DELETE_BUTTON") }
  /// Delete this draft?
  public static var resumeClaimDeleteTitle: String { L10n.tr("Localizable", "RESUME_CLAIM_DELETE_TITLE") }
  /// Draft
  public static var resumeClaimDraft: String { L10n.tr("Localizable", "RESUME_CLAIM_DRAFT") }
  /// Starting a new claim will remove your current draft.
  public static var resumeClaimDraftAlertBody: String { L10n.tr("Localizable", "RESUME_CLAIM_DRAFT_ALERT_BODY") }
  /// Continue claim
  public static var resumeClaimDraftAlertContinue: String { L10n.tr("Localizable", "RESUME_CLAIM_DRAFT_ALERT_CONTINUE") }
  /// New claim
  public static var resumeClaimDraftAlertStartNew: String { L10n.tr("Localizable", "RESUME_CLAIM_DRAFT_ALERT_START_NEW") }
  /// You already have a draft
  public static var resumeClaimDraftAlertTitle: String { L10n.tr("Localizable", "RESUME_CLAIM_DRAFT_ALERT_TITLE") }
  /// Drafts are saved for 7 days. You can start a new claim instead.
  public static var resumeClaimExpiredBody: String { L10n.tr("Localizable", "RESUME_CLAIM_EXPIRED_BODY") }
  /// This draft has expired
  public static var resumeClaimExpiredTitle: String { L10n.tr("Localizable", "RESUME_CLAIM_EXPIRED_TITLE") }
  /// Continue
  public static var resumeClaimFallbackTitle: String { L10n.tr("Localizable", "RESUME_CLAIM_FALLBACK_TITLE") }
  /// What you've filled in is saved as a draft for 7 days.
  public static var resumeClaimLeaveBody: String { L10n.tr("Localizable", "RESUME_CLAIM_LEAVE_BODY") }
  /// Continue claim
  public static var resumeClaimLeaveCancel: String { L10n.tr("Localizable", "RESUME_CLAIM_LEAVE_CANCEL") }
  /// Save and close
  public static var resumeClaimLeaveConfirm: String { L10n.tr("Localizable", "RESUME_CLAIM_LEAVE_CONFIRM") }
  /// Close this claim?
  public static var resumeClaimLeaveTitle: String { L10n.tr("Localizable", "RESUME_CLAIM_LEAVE_TITLE") }
  /// Started %1$@
  public static func resumeClaimStated(_ p1: String) -> String {
    return L10n.tr("Localizable", "RESUME_CLAIM_STATED", p1)
  }
  /// Save and continue
  public static var saveAndContinueButtonLabel: String { L10n.tr("Localizable", "SAVE_AND_CONTINUE_BUTTON_LABEL") }
  /// Search
  public static var searchPlaceholder: String { L10n.tr("Localizable", "SEARCH_PLACEHOLDER") }
  /// Payment can't be charged
  public static var selfManualChargeChangesBeenMadeTitle: String { L10n.tr("Localizable", "SELF_MANUAL_CHARGE_CHANGES_BEEN_MADE_TITLE") }
  /// Please set termination date for your insurance.
  public static var setTerminationDateText: String { L10n.tr("Localizable", "SET_TERMINATION_DATE_TEXT") }
  /// Language
  public static var settingsLanguageTitle: String { L10n.tr("Localizable", "SETTINGS_LANGUAGE_TITLE") }
  /// Dark
  public static var settingsThemeDark: String { L10n.tr("Localizable", "SETTINGS_THEME_DARK") }
  /// Choose theme
  public static var settingsThemeDialogTitle: String { L10n.tr("Localizable", "SETTINGS_THEME_DIALOG_TITLE") }
  /// Light
  public static var settingsThemeLight: String { L10n.tr("Localizable", "SETTINGS_THEME_LIGHT") }
  /// System default
  public static var settingsThemeSystemDefault: String { L10n.tr("Localizable", "SETTINGS_THEME_SYSTEM_DEFAULT") }
  /// Theme
  public static var settingsThemeTitle: String { L10n.tr("Localizable", "SETTINGS_THEME_TITLE") }
  /// Disabled
  public static var settingsUsageDataDisabled: String { L10n.tr("Localizable", "SETTINGS_USAGE_DATA_DISABLED") }
  /// Enabled
  public static var settingsUsageDataEnabled: String { L10n.tr("Localizable", "SETTINGS_USAGE_DATA_ENABLED") }
  /// Usage data
  public static var settingsUsageDataTitle: String { L10n.tr("Localizable", "SETTINGS_USAGE_DATA_TITLE") }
  /// Something went wrong
  public static var somethingWentWrong: String { L10n.tr("Localizable", "something_went_wrong") }
  /// Call %1$@
  public static func submitClaimGlobalAssistanceCallLabel(_ p1: String) -> String {
    return L10n.tr("Localizable", "SUBMIT_CLAIM_GLOBAL_ASSISTANCE_CALL_LABEL", p1)
  }
  /// We’re here 08–22, Mon–Fri\nand weekends 10–22
  public static var submitClaimNeedHelpLabel: String { L10n.tr("Localizable", "SUBMIT_CLAIM_NEED_HELP_LABEL") }
  /// Need help with something else?
  public static var submitClaimNeedHelpTitle: String { L10n.tr("Localizable", "SUBMIT_CLAIM_NEED_HELP_TITLE") }
  /// Our partner
  public static var submitClaimPartnerSingularTitle: String { L10n.tr("Localizable", "SUBMIT_CLAIM_PARTNER_SINGULAR_TITLE") }
  /// Our partners
  public static var submitClaimPartnerTitle: String { L10n.tr("Localizable", "SUBMIT_CLAIM_PARTNER_TITLE") }
  /// Coverage
  public static var summaryScreenCoverage: String { L10n.tr("Localizable", "SUMMARY_SCREEN_COVERAGE") }
  /// Overview
  public static var summaryScreenOverview: String { L10n.tr("Localizable", "SUMMARY_SCREEN_OVERVIEW") }
  /// Changes activate %@
  public static func summaryTotalPriceSubtitle(_ p1: String) -> String {
    return L10n.tr("Localizable", "SUMMARY_TOTAL_PRICE_SUBTITLE", p1)
  }
  /// Your insurance is paid via Swish each month. No need to approve every time.
  public static var swishExplanationItem1Text: String { L10n.tr("Localizable", "SWISH_EXPLANATION_ITEM_1_TEXT") }
  /// Paid automatically
  public static var swishExplanationItem1Title: String { L10n.tr("Localizable", "SWISH_EXPLANATION_ITEM_1_TITLE") }
  /// Claims payouts are sent to your Swish number.
  public static var swishExplanationItem2Text: String { L10n.tr("Localizable", "SWISH_EXPLANATION_ITEM_2_TEXT") }
  /// Payouts straight to Swish
  public static var swishExplanationItem2Title: String { L10n.tr("Localizable", "SWISH_EXPLANATION_ITEM_2_TITLE") }
  /// Switch or remove your payment method in settings.
  public static var swishExplanationItem3Text: String { L10n.tr("Localizable", "SWISH_EXPLANATION_ITEM_3_TEXT") }
  /// Change anytime
  public static var swishExplanationItem3Title: String { L10n.tr("Localizable", "SWISH_EXPLANATION_ITEM_3_TITLE") }
  /// Home
  public static var tabHomeTitle: String { L10n.tr("Localizable", "TAB_HOME_TITLE") }
  /// Insurances
  public static var tabInsurancesTitle: String { L10n.tr("Localizable", "TAB_INSURANCES_TITLE") }
  /// Payments
  public static var tabPaymentsTitle: String { L10n.tr("Localizable", "TAB_PAYMENTS_TITLE") }
  /// Profile
  public static var tabProfileTitle: String { L10n.tr("Localizable", "TAB_PROFILE_TITLE") }
  /// Forever
  public static var tabReferralsTitle: String { L10n.tr("Localizable", "TAB_REFERRALS_TITLE") }
  /// Cancelling...
  public static var terminateContractTerminatingProgress: String { L10n.tr("Localizable", "TERMINATE_CONTRACT_TERMINATING_PROGRESS") }
  /// Your insurance was cancelled before the activation date. You will not be charged anything.
  public static var terminateContractTerminationComplete: String { L10n.tr("Localizable", "TERMINATE_CONTRACT_TERMINATION_COMPLETE") }
  /// Extra coverage
  public static var terminationAddonCoverageTitle: String { L10n.tr("Localizable", "TERMINATION_ADDON_COVERAGE_TITLE") }
  /// Cancel insurance
  public static var terminationButton: String { L10n.tr("Localizable", "TERMINATION_BUTTON") }
  /// Select termination date
  public static var terminationDateText: String { L10n.tr("Localizable", "TERMINATION_DATE_TEXT") }
  /// We’ll send a cancellation confirmation within a few days. If you don’t get it after 5 days, feel free to contact us.
  public static var terminationFlowAutoCancelAbout: String { L10n.tr("Localizable", "TERMINATION_FLOW_AUTO_CANCEL_ABOUT") }
  /// If you’ve decommissioned your car, we’ll cancel your insurance automatically. We get this information directly from Transportstyrelsen.
  public static var terminationFlowAutoCancelDecom: String { L10n.tr("Localizable", "TERMINATION_FLOW_AUTO_CANCEL_DECOM") }
  /// Once your car is registered as active with Transportstyrelsen, your insurance will be updated automatically to your previous coverage.
  public static var terminationFlowAutoCancelRecommission: String { L10n.tr("Localizable", "TERMINATION_FLOW_AUTO_CANCEL_RECOMMISSION") }
  /// If you’ve scrapped your car, we’ll cancel your insurance automatically. We get this information directly from Transportstyrelsen.
  public static var terminationFlowAutoCancelScrapped: String { L10n.tr("Localizable", "TERMINATION_FLOW_AUTO_CANCEL_SCRAPPED") }
  /// If you’ve sold your car, we’ll cancel your insurance automatically. We receive this information directly from Transportstyrelsen.
  public static var terminationFlowAutoCancelSold: String { L10n.tr("Localizable", "TERMINATION_FLOW_AUTO_CANCEL_SOLD") }
  /// We’ll cancel your insurance automatically
  public static var terminationFlowAutoCancelTitle: String { L10n.tr("Localizable", "TERMINATION_FLOW_AUTO_CANCEL_TITLE") }
  /// You’ll receive a confirmation email within a few days, where you can see your new price.
  public static var terminationFlowAutoDecomCostsInfo: String { L10n.tr("Localizable", "TERMINATION_FLOW_AUTO_DECOM_COSTS_INFO") }
  /// What it costs
  public static var terminationFlowAutoDecomCostsTitle: String { L10n.tr("Localizable", "TERMINATION_FLOW_AUTO_DECOM_COSTS_TITLE") }
  /// The insurance covers damage such as theft, fire, vandalism, and body damage while the car is decommissioned. Legal protection is also included. The insurance is only valid as long as the car remains in Sweden.
  public static var terminationFlowAutoDecomCoveredInfo: String { L10n.tr("Localizable", "TERMINATION_FLOW_AUTO_DECOM_COVERED_INFO") }
  /// What’s covered
  public static var terminationFlowAutoDecomCoveredTitle: String { L10n.tr("Localizable", "TERMINATION_FLOW_AUTO_DECOM_COVERED_TITLE") }
  /// If you’ve decommissioned your car through Transportstyrelsen, your insurance will automatically switch to decommission insurance.
  public static var terminationFlowAutoDecomInfo: String { L10n.tr("Localizable", "TERMINATION_FLOW_AUTO_DECOM_INFO") }
  /// If you don’t want to keep your decommission insurance, you can cancel it below.
  public static var terminationFlowAutoDecomNotification: String { L10n.tr("Localizable", "TERMINATION_FLOW_AUTO_DECOM_NOTIFICATION") }
  /// Your insurance will switch to decommission insurance
  public static var terminationFlowAutoDecomTitle: String { L10n.tr("Localizable", "TERMINATION_FLOW_AUTO_DECOM_TITLE") }
  /// We’ll update your insurance automatically
  public static var terminationFlowAutoRecommissionTitle: String { L10n.tr("Localizable", "TERMINATION_FLOW_AUTO_RECOMMISSION_TITLE") }
  /// Select the insurance you \nwant to cancel
  public static var terminationFlowBody: String { L10n.tr("Localizable", "TERMINATION_FLOW_BODY") }
  /// You can cancel your insurance at any time. You will only be charged for the time you have been an active member. When the insurance is cancelled you can see your last payment under the tab "Payments" here in the app.
  public static var terminationFlowCancelInfoText: String { L10n.tr("Localizable", "TERMINATION_FLOW_CANCEL_INFO_TEXT") }
  /// Cancelling your insurance
  public static var terminationFlowCancelInfoTitle: String { L10n.tr("Localizable", "TERMINATION_FLOW_CANCEL_INFO_TITLE") }
  /// Cancel insurance
  public static var terminationFlowCancellationTitle: String { L10n.tr("Localizable", "TERMINATION_FLOW_CANCELLATION_TITLE") }
  /// Yes, cancel
  public static var terminationFlowConfirmButton: String { L10n.tr("Localizable", "TERMINATION_FLOW_CONFIRM_BUTTON") }
  /// Your insurance will be cancelled directly
  public static var terminationFlowConfirmation: String { L10n.tr("Localizable", "TERMINATION_FLOW_CONFIRMATION") }
  /// Your insurance will be cancelled on %@
  public static func terminationFlowConfirmationSubtitleTermination(_ p1: String) -> String {
    return L10n.tr("Localizable", "TERMINATION_FLOW_CONFIRMATION_SUBTITLE_TERMINATION", p1)
  }
  /// No thanks, continue
  public static var terminationFlowContinueCancelling: String { L10n.tr("Localizable", "TERMINATION_FLOW_CONTINUE_CANCELLING") }
  /// Select date...
  public static var terminationFlowDateFieldPlaceholder: String { L10n.tr("Localizable", "TERMINATION_FLOW_DATE_FIELD_PLACEHOLDER") }
  /// Termination date
  public static var terminationFlowDateFieldText: String { L10n.tr("Localizable", "TERMINATION_FLOW_DATE_FIELD_TEXT") }
  /// Since this insurance is not active yet it will be cancelled and removed today. You won’t be charged anything.
  public static var terminationFlowDeletionInfoCard: String { L10n.tr("Localizable", "TERMINATION_FLOW_DELETION_INFO_CARD") }
  /// I understand
  public static var terminationFlowIUnderstandText: String { L10n.tr("Localizable", "TERMINATION_FLOW_I_UNDERSTAND_TEXT") }
  /// If there is a gap in your insurance, you may not receive future help or compensation. Make sure that you always have an active insurance.
  public static var terminationFlowImportantInformationText: String { L10n.tr("Localizable", "TERMINATION_FLOW_IMPORTANT_INFORMATION_TEXT") }
  /// Important information
  public static var terminationFlowImportantInformationTitle: String { L10n.tr("Localizable", "TERMINATION_FLOW_IMPORTANT_INFORMATION_TITLE") }
  /// Learn more
  public static var terminationFlowLearnMore: String { L10n.tr("Localizable", "TERMINATION_FLOW_LEARN_MORE") }
  /// Your insurance will be cancelled on %@. We will send you an email with all the details.
  public static func terminationFlowSuccessSubtitleWithDate(_ p1: String) -> String {
    return L10n.tr("Localizable", "TERMINATION_FLOW_SUCCESS_SUBTITLE_WITH_DATE", p1)
  }
  /// Insurance cancelled
  public static var terminationFlowSuccessTitle: String { L10n.tr("Localizable", "TERMINATION_FLOW_SUCCESS_TITLE") }
  /// Review and confirm
  public static var terminationFlowSummarySubtitle: String { L10n.tr("Localizable", "TERMINATION_FLOW_SUMMARY_SUBTITLE") }
  /// Cancel insurance
  public static var terminationFlowTitle: String { L10n.tr("Localizable", "TERMINATION_FLOW_TITLE") }
  /// Today
  public static var terminationFlowToday: String { L10n.tr("Localizable", "TERMINATION_FLOW_TODAY") }
  /// Keep insurance
  public static var terminationKeepInsuranceButton: String { L10n.tr("Localizable", "TERMINATION_KEEP_INSURANCE_BUTTON") }
  /// You already have the best coverage and price for this insurance
  public static var terminationNoTierQuotesSubtitle: String { L10n.tr("Localizable", "TERMINATION_NO_TIER_QUOTES_SUBTITLE") }
  /// Cancellation unsuccessful
  public static var terminationNotSuccessfulTitle: String { L10n.tr("Localizable", "TERMINATION_NOT_SUCCESSFUL_TITLE") }
  /// Change coverage level
  public static var terminationOfferButtonChangeTier: String { L10n.tr("Localizable", "TERMINATION_OFFER_BUTTON_CHANGE_TIER") }
  /// Update my address
  public static var terminationOfferButtonUpdateAddress: String { L10n.tr("Localizable", "TERMINATION_OFFER_BUTTON_UPDATE_ADDRESS") }
  /// Leave a comment
  public static var terminationSurveyFeedbackHint: String { L10n.tr("Localizable", "TERMINATION_SURVEY_FEEDBACK_HINT") }
  /// Please enter your feedback
  public static var terminationSurveyFeedbackInfo: String { L10n.tr("Localizable", "TERMINATION_SURVEY_FEEDBACK_INFO") }
  /// Please provide feedback to help us improve
  public static var terminationSurveyFeedbackPopoverHint: String { L10n.tr("Localizable", "TERMINATION_SURVEY_FEEDBACK_POPOVER_HINT") }
  /// Before we continue
  public static var terminationSurveyGenericSubtitle: String { L10n.tr("Localizable", "TERMINATION_SURVEY_GENERIC_SUBTITLE") }
  /// Why do you want to cancel your insurance?
  public static var terminationSurveySubtitle: String { L10n.tr("Localizable", "TERMINATION_SURVEY_SUBTITLE") }
  /// Find the best plan available for you
  public static var tierComparisonSubtitle: String { L10n.tr("Localizable", "TIER_COMPARISON_SUBTITLE") }
  /// Compare coverage levels
  public static var tierComparisonTitle: String { L10n.tr("Localizable", "TIER_COMPARISON_TITLE") }
  /// Extended travel coverage
  public static var tierFlowAddonLabel: String { L10n.tr("Localizable", "TIER_FLOW_ADDON_LABEL") }
  /// No extended coverage
  public static var tierFlowAddonNoCoverageLabel: String { L10n.tr("Localizable", "TIER_FLOW_ADDON_NO_COVERAGE_LABEL") }
  /// Your updates will be effective from  %@.
  public static func tierFlowCommitProcessingDescription(_ p1: String) -> String {
    return L10n.tr("Localizable", "TIER_FLOW_COMMIT_PROCESSING_DESCRIPTION", p1)
  }
  /// The changes couldn't be completed. Please try again.
  public static var tierFlowCommitProcessingErrorDescription: String { L10n.tr("Localizable", "TIER_FLOW_COMMIT_PROCESSING_ERROR_DESCRIPTION") }
  /// Processing changes...
  public static var tierFlowCommitProcessingLoadingTitle: String { L10n.tr("Localizable", "TIER_FLOW_COMMIT_PROCESSING_LOADING_TITLE") }
  /// Changes complete
  public static var tierFlowCommitProcessingTitle: String { L10n.tr("Localizable", "TIER_FLOW_COMMIT_PROCESSING_TITLE") }
  /// Compare coverage
  public static var tierFlowCompareButton: String { L10n.tr("Localizable", "TIER_FLOW_COMPARE_BUTTON") }
  /// Coverage level
  public static var tierFlowCoverageLabel: String { L10n.tr("Localizable", "TIER_FLOW_COVERAGE_LABEL") }
  /// Select coverage level...
  public static var tierFlowCoveragePlaceholder: String { L10n.tr("Localizable", "TIER_FLOW_COVERAGE_PLACEHOLDER") }
  /// Deductible
  public static var tierFlowDeductibleLabel: String { L10n.tr("Localizable", "TIER_FLOW_DEDUCTIBLE_LABEL") }
  /// Select deductible...
  public static var tierFlowDeductiblePlaceholder: String { L10n.tr("Localizable", "TIER_FLOW_DEDUCTIBLE_PLACEHOLDER") }
  /// You are unable to make changes to this coverage level
  public static var tierFlowLockedInfoDescription: String { L10n.tr("Localizable", "TIER_FLOW_LOCKED_INFO_DESCRIPTION") }
  /// Your previous price %1$@
  public static func tierFlowPreviousPrice(_ p1: String) -> String {
    return L10n.tr("Localizable", "TIER_FLOW_PREVIOUS_PRICE", p1)
  }
  /// From %@/mo
  public static func tierFlowPriceLabelWithoutCurrency(_ p1: String) -> String {
    return L10n.tr("Localizable", "TIER_FLOW_PRICE_LABEL_WITHOUT_CURRENCY", p1)
  }
  /// Fetching coverage levels...
  public static var tierFlowProcessing: String { L10n.tr("Localizable", "TIER_FLOW_PROCESSING") }
  /// Days covered when travelling
  public static var tierFlowSelectAddonSubtitle: String { L10n.tr("Localizable", "TIER_FLOW_SELECT_ADDON_SUBTITLE") }
  /// Find the right coverage for you
  public static var tierFlowSelectCoverageSubtitle: String { L10n.tr("Localizable", "TIER_FLOW_SELECT_COVERAGE_SUBTITLE") }
  /// Select your coverage
  public static var tierFlowSelectCoverageTitle: String { L10n.tr("Localizable", "TIER_FLOW_SELECT_COVERAGE_TITLE") }
  /// Amount deducted from your compensation
  public static var tierFlowSelectDeductibleSubtitle: String { L10n.tr("Localizable", "TIER_FLOW_SELECT_DEDUCTIBLE_SUBTITLE") }
  /// Select your deductible
  public static var tierFlowSelectDeductibleTitle: String { L10n.tr("Localizable", "TIER_FLOW_SELECT_DEDUCTIBLE_TITLE") }
  /// Select the insurance you want to edit
  public static var tierFlowSelectInsuranceSubtitle: String { L10n.tr("Localizable", "TIER_FLOW_SELECT_INSURANCE_SUBTITLE") }
  /// Monthly compensation
  public static var tierFlowSelectPaymentProtectionDropdownTitle: String { L10n.tr("Localizable", "TIER_FLOW_SELECT_PAYMENT_PROTECTION_DROPDOWN_TITLE") }
  /// Show your coverage
  public static var tierFlowShowCoverage: String { L10n.tr("Localizable", "TIER_FLOW_SHOW_COVERAGE") }
  /// Set your coverage level and deductible
  public static var tierFlowSubtitle: String { L10n.tr("Localizable", "TIER_FLOW_SUBTITLE") }
  /// Set your coverage level
  public static var tierFlowSubtitleWithoutDeductible: String { L10n.tr("Localizable", "TIER_FLOW_SUBTITLE_WITHOUT_DEDUCTIBLE") }
  /// Customize your coverage
  public static var tierFlowTitle: String { L10n.tr("Localizable", "TIER_FLOW_TITLE") }
  /// Total
  public static var tierFlowTotal: String { L10n.tr("Localizable", "TIER_FLOW_TOTAL") }
  /// OK
  public static var trustlyMissingBankIdAppAlertAction: String { L10n.tr("Localizable", "TRUSTLY_MISSING_BANK_ID_APP_ALERT_ACTION") }
  /// To be able to log in to your bank you need to have the XXX app installed.
  public static var trustlyMissingBankIdAppAlertMessage: String { L10n.tr("Localizable", "TRUSTLY_MISSING_BANK_ID_APP_ALERT_MESSAGE") }
  /// You do not have BankID on this device
  public static var trustlyMissingBankIdAppAlertTitle: String { L10n.tr("Localizable", "TRUSTLY_MISSING_BANK_ID_APP_ALERT_TITLE") }
  /// Invalid start date, must be on or before September 4th
  public static var userErrorUwGlInvalidStartdateForSas: String { L10n.tr("Localizable", "USER_ERROR_UW_GL_INVALID_STARTDATE_FOR_SAS") }
  /// Click to copy code
  public static var voiceOverCopyCode: String { L10n.tr("Localizable", "VOICE_OVER_COPY_CODE") }
  /// Press to proceed to help center
  public static var voiceOverInfoHelpcenter: String { L10n.tr("Localizable", "VOICE_OVER_INFO_HELPCENTER") }
  /// Is accepted
  public static var voiceoverAccepted: String { L10n.tr("Localizable", "VOICEOVER_ACCEPTED") }
  /// add information
  public static var voiceoverAddInformation: String { L10n.tr("Localizable", "VOICEOVER_ADD_INFORMATION") }
  /// Counting down
  public static var voiceoverAudioCountdown: String { L10n.tr("Localizable", "VOICEOVER_AUDIO_COUNTDOWN") }
  /// Microphone permission denied
  public static var voiceoverAudioMicPermissionDenied: String { L10n.tr("Localizable", "VOICEOVER_AUDIO_MIC_PERMISSION_DENIED") }
  /// Could not record
  public static var voiceoverAudioRecordingFailed: String { L10n.tr("Localizable", "VOICEOVER_AUDIO_RECORDING_FAILED") }
  /// Play submitted audio recording
  public static var voiceoverAudioRecordingPlay: String { L10n.tr("Localizable", "VOICEOVER_AUDIO_RECORDING_PLAY") }
  /// Could not send recording
  public static var voiceoverAudioSendingFailed: String { L10n.tr("Localizable", "VOICEOVER_AUDIO_SENDING_FAILED") }
  /// Could not play recording
  public static var voiceoverAuidoPlaybackFailed: String { L10n.tr("Localizable", "VOICEOVER_AUIDO_PLAYBACK_FAILED") }
  /// Discount name: %@
  public static func voiceoverBundleDiscountTag(_ p1: String) -> String {
    return L10n.tr("Localizable", "VOICEOVER_BUNDLE_DISCOUNT_TAG", p1)
  }
  /// change value
  public static var voiceoverChangeValue: String { L10n.tr("Localizable", "VOICEOVER_CHANGE_VALUE") }
  /// Camera
  public static var voiceoverChatCamera: String { L10n.tr("Localizable", "VOICEOVER_CHAT_CAMERA") }
  /// Camera roll
  public static var voiceoverChatCameraroll: String { L10n.tr("Localizable", "VOICEOVER_CHAT_CAMERAROLL") }
  /// File
  public static var voiceoverChatFile: String { L10n.tr("Localizable", "VOICEOVER_CHAT_FILE") }
  /// Files
  public static var voiceoverChatFiles: String { L10n.tr("Localizable", "VOICEOVER_CHAT_FILES") }
  /// Image
  public static var voiceoverChatImage: String { L10n.tr("Localizable", "VOICEOVER_CHAT_IMAGE") }
  /// Send message
  public static var voiceoverChatSendMessageButton: String { L10n.tr("Localizable", "VOICEOVER_CHAT_SEND_MESSAGE_BUTTON") }
  /// Collapsed
  public static var voiceoverCollapsed: String { L10n.tr("Localizable", "VOICEOVER_COLLAPSED") }
  /// Current price
  public static var voiceoverCurrentPrice: String { L10n.tr("Localizable", "VOICEOVER_CURRENT_PRICE") }
  /// Your current tier is 
  public static var voiceoverCurrentTier: String { L10n.tr("Localizable", "VOICEOVER_CURRENT_TIER") }
  /// Current value
  public static var voiceoverCurrentValue: String { L10n.tr("Localizable", "VOICEOVER_CURRENT_VALUE") }
  /// Delete co-insured
  public static var voiceoverDeleteCoinsuredButton: String { L10n.tr("Localizable", "VOICEOVER_DELETE_COINSURED_BUTTON") }
  /// Double click to
  public static var voiceoverDoubleClickTo: String { L10n.tr("Localizable", "VOICEOVER_DOUBLE_CLICK_TO") }
  /// edit
  public static var voiceoverEdit: String { L10n.tr("Localizable", "VOICEOVER_EDIT") }
  /// Expanded
  public static var voiceoverExpanded: String { L10n.tr("Localizable", "VOICEOVER_EXPANDED") }
  /// Click to confirm
  public static var voiceoverHonestypledgeSlider: String { L10n.tr("Localizable", "VOICEOVER_HONESTYPLEDGE_SLIDER") }
  /// Is included in
  public static var voiceoverIncluded: String { L10n.tr("Localizable", "VOICEOVER_INCLUDED") }
  /// Tap for more info
  public static var voiceoverMoreInfo: String { L10n.tr("Localizable", "VOICEOVER_MORE_INFO") }
  /// New value
  public static var voiceoverNewValue: String { L10n.tr("Localizable", "VOICEOVER_NEW_VALUE") }
  /// is not accepted
  public static var voiceoverNotAccepted: String { L10n.tr("Localizable", "VOICEOVER_NOT_ACCEPTED") }
  /// is not included in
  public static var voiceoverNotIncluded: String { L10n.tr("Localizable", "VOICEOVER_NOT_INCLUDED") }
  /// Notification
  public static var voiceoverNotificationAlert: String { L10n.tr("Localizable", "VOICEOVER_NOTIFICATION_ALERT") }
  /// Option selected
  public static var voiceoverOptionSelected: String { L10n.tr("Localizable", "VOICEOVER_OPTION_SELECTED") }
  /// Select one option and then press %@ button
  public static func voiceoverPickerInfo(_ p1: String) -> String {
    return L10n.tr("Localizable", "VOICEOVER_PICKER_INFO", p1)
  }
  /// Select one or more options and then press %@ button
  public static func voiceoverPickerInfoMultiple(_ p1: String) -> String {
    return L10n.tr("Localizable", "VOICEOVER_PICKER_INFO_MULTIPLE", p1)
  }
  /// Press to
  public static var voiceoverPressTo: String { L10n.tr("Localizable", "VOICEOVER_PRESS_TO") }
  /// show price breakdown
  public static var voiceoverPriceBreakdown: String { L10n.tr("Localizable", "VOICEOVER_PRICE_BREAKDOWN") }
  /// remove
  public static var voiceoverRemove: String { L10n.tr("Localizable", "VOICEOVER_REMOVE") }
  /// Current tab %@.
  public static func voiceoverSegmentedcontrolSelectedTab(_ p1: String) -> String {
    return L10n.tr("Localizable", "VOICEOVER_SEGMENTEDCONTROL_SELECTED_TAB", p1)
  }
  /// Press to switch tab.
  public static var voiceoverSegmentedcontrolSwitchTab: String { L10n.tr("Localizable", "VOICEOVER_SEGMENTEDCONTROL_SWITCH_TAB") }
  /// Tap to select language
  public static var voiceoverSelectLanguage: String { L10n.tr("Localizable", "VOICEOVER_SELECT_LANGUAGE") }
  /// Select one option and then press continue button
  public static var voiceoverSubmitClaimsTriagingInfo: String { L10n.tr("Localizable", "VOICEOVER_SUBMIT_CLAIMS_TRIAGING_INFO") }
  /// Click to see what is covered in %@
  public static func voiceoverTierComparisionClick(_ p1: String) -> String {
    return L10n.tr("Localizable", "VOICEOVER_TIER_COMPARISION_CLICK", p1)
  }

  public enum Certificates {
    /// Create certificate
    public static var createCertificate: String { L10n.tr("Localizable", "CERTIFICATES.CREATE_CERTIFICATE") }
    /// Download certificate
    public static var download: String { L10n.tr("Localizable", "CERTIFICATES.DOWNLOAD") }
    /// Email sent
    public static var emailSent: String { L10n.tr("Localizable", "CERTIFICATES.EMAIL_SENT") }
    /// Generating
    public static var generating: String { L10n.tr("Localizable", "CERTIFICATES.GENERATING") }
    /// Where should we send the certificate?
    public static var verifyEmail: String { L10n.tr("Localizable", "CERTIFICATES.VERIFY_EMAIL") }
  }

  public enum DeleteAccount {
    /// As an insurance company, Hedvig is obliged to save the insurance contract and related information as long as it is possible to claim insurance compensation. This period can vary depending on the type of insurance, but is at least 10 years after the insurance has ended.\n\nIf you want us to delete the information we are not required by law to save, you can use the button below.\n\n[Here](https://www.hedvig.com/se-en/hedvig/privacy-policy) you can read about how Hedvig handles your personal data.
    public static var deleteAccountDescription: String { L10n.tr("Localizable", "DELETE_ACCOUNT.DELETE_ACCOUNT_DESCRIPTION") }
    /// Important information
    public static var deleteAccountTitle: String { L10n.tr("Localizable", "DELETE_ACCOUNT.DELETE_ACCOUNT_TITLE") }
    /// We will delete the information that we are not required to store by law.
    public static var processedTitle: String { L10n.tr("Localizable", "DELETE_ACCOUNT.PROCESSED_TITLE") }
    /// As we use our app for our claims handling, we recommend that you keep your account active until your claims are solved.
    public static var youHaveActiveClaimDescription: String { L10n.tr("Localizable", "DELETE_ACCOUNT.YOU_HAVE_ACTIVE_CLAIM_DESCRIPTION") }
    /// You have an ongoing claim
    public static var youHaveActiveClaimTitle: String { L10n.tr("Localizable", "DELETE_ACCOUNT.YOU_HAVE_ACTIVE_CLAIM_TITLE") }
    /// As you have an active insurance policy with us, we cannot delete your account. If you want to terminate your insurance, you can do it [here](https://link.hedvig.com/terminate-contract).
    public static var youHaveActiveInsuranceDescription: String { L10n.tr("Localizable", "DELETE_ACCOUNT.YOU_HAVE_ACTIVE_INSURANCE_DESCRIPTION") }
    /// You have an active insurance
    public static var youHaveActiveInsuranceTitle: String { L10n.tr("Localizable", "DELETE_ACCOUNT.YOU_HAVE_ACTIVE_INSURANCE_TITLE") }
  }

  public enum Forever {
    public enum Referral {
      /// Invite from %@
      public static func invitedYou(_ p1: String) -> String {
        return L10n.tr("Localizable", "FOREVER.REFERRAL.INVITED_YOU", p1)
      }
    }
  }

  public enum General {
    /// Are you sure?
    public static var areYouSure: String { L10n.tr("Localizable", "GENERAL.ARE_YOU_SURE") }
    /// Send message
    public static var chatButton: String { L10n.tr("Localizable", "GENERAL.CHAT_BUTTON") }
    /// Copied
    public static var copied: String { L10n.tr("Localizable", "GENERAL.COPIED") }
    /// We were unable to load this information.
    public static var defaultError: String { L10n.tr("Localizable", "GENERAL.DEFAULT_ERROR") }
    /// Edit
    public static var edit: String { L10n.tr("Localizable", "GENERAL.EDIT") }
    /// We were unable to load this information. Check your internet connection and try again.
    public static var errorBody: String { L10n.tr("Localizable", "GENERAL.ERROR_BODY") }
    /// No
    public static var no: String { L10n.tr("Localizable", "GENERAL.NO") }
    /// Exiting now will require you to restart from the beginning.
    public static var progressWillBeLostAlert: String { L10n.tr("Localizable", "GENERAL.PROGRESS_WILL_BE_LOST_ALERT") }
    /// Remove
    public static var remove: String { L10n.tr("Localizable", "GENERAL.REMOVE") }
    /// Subscribed
    public static var subscribed: String { L10n.tr("Localizable", "GENERAL.SUBSCRIBED") }
    /// Unsubscribed
    public static var unsubscribed: String { L10n.tr("Localizable", "GENERAL.UNSUBSCRIBED") }
    /// Yes
    public static var yes: String { L10n.tr("Localizable", "GENERAL.YES") }
  }

  public enum InsuranceEvidence {
    /// Certificate of validity
    public static var documentTitle: String { L10n.tr("Localizable", "INSURANCE_EVIDENCE.DOCUMENT_TITLE") }
    /// The certificate has been sent to your email.
    public static var emailSentDescription: String { L10n.tr("Localizable", "INSURANCE_EVIDENCE.EMAIL_SENT_DESCRIPTION") }
    /// A certificate of validity confirms the periods during which you have had valid and paid home insurance with Hedvig, as well as its details, for example which address was insured and the amount you’ve paid.\n\nThe certificate can be used to confirm your insurance period when applying for legal protection with another insurance company, or in matters involving banks or authorities.
    public static var readMoreDescription: String { L10n.tr("Localizable", "INSURANCE_EVIDENCE.READ_MORE_DESCRIPTION") }
    /// What is a certificate of validity?
    public static var readMoreTitle: String { L10n.tr("Localizable", "INSURANCE_EVIDENCE.READ_MORE_TITLE") }
  }

  public enum SettingsScreen {
    /// Yes, unsubscribe
    public static var confirmUnsubscribe: String { L10n.tr("Localizable", "SETTINGS_SCREEN.CONFIRM_UNSUBSCRIBE") }
    /// Delete account
    public static var deleteAccountButton: String { L10n.tr("Localizable", "SETTINGS_SCREEN.DELETE_ACCOUNT_BUTTON") }
    /// Email preferences
    public static var emailPreferences: String { L10n.tr("Localizable", "SETTINGS_SCREEN.EMAIL_PREFERENCES") }
    /// Yes, I confirm
    public static var subscribeButton: String { L10n.tr("Localizable", "SETTINGS_SCREEN.SUBSCRIBE_BUTTON") }
    /// You will receive promotional emails from us
    public static var subscribeDescription: String { L10n.tr("Localizable", "SETTINGS_SCREEN.SUBSCRIBE_DESCRIPTION") }
    /// Confirm subscription
    public static var subscribeTitle: String { L10n.tr("Localizable", "SETTINGS_SCREEN.SUBSCRIBE_TITLE") }
    /// Subscribed to receiving offers via email
    public static var subscribedMessage: String { L10n.tr("Localizable", "SETTINGS_SCREEN.SUBSCRIBED_MESSAGE") }
    /// You will no longer receive offers and campaigns from us
    public static var unsubscribeDescription: String { L10n.tr("Localizable", "SETTINGS_SCREEN.UNSUBSCRIBE_DESCRIPTION") }
    /// Unsubscribed from receiving offers via email
    public static var unsubscribedMessage: String { L10n.tr("Localizable", "SETTINGS_SCREEN.UNSUBSCRIBED_MESSAGE") }
  }

  public enum Toast {
    /// New message
    public static var newMessage: String { L10n.tr("Localizable", "TOAST.NEW_MESSAGE") }
    /// New offer
    public static var newOffer: String { L10n.tr("Localizable", "TOAST.NEW_OFFER") }
    /// Learn more
    public static var readMore: String { L10n.tr("Localizable", "TOAST.READ_MORE") }
  }

  public enum AppInfo {
    /// Device ID
    public static var deviceIdLabel: String { L10n.tr("Localizable", "app_info.device_id_label") }
    public enum SubmitBug {
      /// Report technical issue
      public static var button: String { L10n.tr("Localizable", "app_info.submit_bug.button") }
      /// I came across a technical issue in the Hedvig app!\n\nDescription of the technical issue step-by-step: \n(Keep it short and simple)\n\nAttached a screenshot:\n(Got a screenshot? Please attach it to this email.)\n\nInfo for developers (Do not modify)\nMID: %@\nDID: %@\nAVC: %@\nSV: %@
      public static func prefilledLetterBody(_ p1: String, _ p2: String, _ p3: String, _ p4: String) -> String {
        return L10n.tr("Localizable", "app_info.submit_bug.prefilled_letter_body", p1, p2, p3, p4)
      }
      /// Technical Issue Report
      public static var prefilledLetterSubject: String { L10n.tr("Localizable", "app_info.submit_bug.prefilled_letter_subject") }
      /// Please note that you can only report technical issues regarding the Hedvig app. For claims related questions, please write to us here in the app.
      public static var warning: String { L10n.tr("Localizable", "app_info.submit_bug.warning") }
    }
  }

  public enum BankidMissingLogin {
    /// Log in with email
    public static var emailButton: String { L10n.tr("Localizable", "bankid_missing_login.email_button") }
  }

  public enum Claim {
    public enum Casetype {
      /// Insurance case
      public static var insuranceCase: String { L10n.tr("Localizable", "claim.casetype.insurance_case") }
    }
    public enum Decision {
      /// Not compensated
      public static var notCompensated: String { L10n.tr("Localizable", "claim.decision.not_compensated") }
      /// Not covered
      public static var notCovered: String { L10n.tr("Localizable", "claim.decision.not_covered") }
      /// Paid
      public static var paid: String { L10n.tr("Localizable", "claim.decision.paid") }
      /// Missing response
      public static var unresponsive: String { L10n.tr("Localizable", "claim.decision.unresponsive") }
    }
    public enum StatusBar {
      /// Being handled
      public static var beingHandled: String { L10n.tr("Localizable", "claim.status_bar.being_handled") }
      /// Closed
      public static var closed: String { L10n.tr("Localizable", "claim.status_bar.closed") }
      /// Submitted
      public static var submitted: String { L10n.tr("Localizable", "claim.status_bar.submitted") }
    }
  }

  public enum ClaimHistory {
    public enum EmptyState {
      /// Your past claims will appear here automatically once processed.
      public static var body: String { L10n.tr("Localizable", "claim_history.empty_state.body") }
      /// No claims in history
      public static var title: String { L10n.tr("Localizable", "claim_history.empty_state.title") }
    }
  }

  public enum ClaimStatus {
    /// Show all answers
    public static var showAllAnswers: String { L10n.tr("Localizable", "claim_status.show_all_answers") }
    /// Claim status
    public static var title: String { L10n.tr("Localizable", "claim_status.title") }
    public enum BeingHandled {
      /// Your claim is being reviewed by one of our insurance specialists. We'll get back to you soon with an update.
      public static var supportText: String { L10n.tr("Localizable", "claim_status.being_handled.support_text") }
    }
    public enum BeingHandledReopened {
      /// We have reopened your claim and one of our insurance specialists is reviewing it. We'll get back to you soon with an update.
      public static var supportText: String { L10n.tr("Localizable", "claim_status.being_handled_reopened.support_text") }
    }
    public enum ClaimDetails {
      /// Show details
      public static var button: String { L10n.tr("Localizable", "claim_status.claim_details.button") }
      /// Registration number
      public static var exposureDisplayName: String { L10n.tr("Localizable", "claim_status.claim_details.exposure_display_name") }
      /// Reference number
      public static var externalId: String { L10n.tr("Localizable", "claim_status.claim_details.external_id") }
      /// Claim email
      public static var handlerEmail: String { L10n.tr("Localizable", "claim_status.claim_details.handler_email") }
      /// Is something missing? Send us a message here in the app.
      public static var infoText: String { L10n.tr("Localizable", "claim_status.claim_details.info_text") }
      /// Submitted
      public static var submitted: String { L10n.tr("Localizable", "claim_status.claim_details.submitted") }
      /// Claim details
      public static var title: String { L10n.tr("Localizable", "claim_status.claim_details.title") }
    }
    public enum NotCompensated {
      /// Your claim was covered but unfortunately the compensation is equal or less than the deductible. Please see conversation for more details.
      public static var supportText: String { L10n.tr("Localizable", "claim_status.not_compensated.support_text") }
    }
    public enum NotCovered {
      /// Your claim was unfortunately not covered. Please see conversation for more details on the decision.
      public static var supportText: String { L10n.tr("Localizable", "claim_status.not_covered.support_text") }
    }
    public enum Paid {
      /// We got you covered. You should have received the payment by now. \n\nSee your messages here in the app for more details.
      public static var supportText: String { L10n.tr("Localizable", "claim_status.paid.support_text") }
    }
    public enum Partner {
      /// Our car specialists at Eir handle this claim by email.\n\nYou’ll receive a confirmation by email once it’s been reviewed. If you need to get in touch about your claim, reply in the same email thread.
      public static var supportText: String { L10n.tr("Localizable", "claim_status.partner.support_text") }
    }
    public enum Submitted {
      /// We have received your claim and will start reviewing it soon.
      public static var supportText: String { L10n.tr("Localizable", "claim_status.submitted.support_text") }
    }
    public enum UploadedFiles {
      /// Upload files
      public static var uploadButton: String { L10n.tr("Localizable", "claim_status.uploaded_files.upload_button") }
      /// Upload photos, receipts or other documents connected to your claim
      public static var uploadText: String { L10n.tr("Localizable", "claim_status.uploaded_files.upload_text") }
    }
  }

  public enum ClaimStatusDetail {
    /// Add files
    public static var addFiles: String { L10n.tr("Localizable", "claim_status_detail.add_files") }
    /// Add more files
    public static var addMoreFiles: String { L10n.tr("Localizable", "claim_status_detail.add_more_files") }
    /// Added files
    public static var addedFiles: String { L10n.tr("Localizable", "claim_status_detail.added_files") }
    /// Submitted
    public static var submitted: String { L10n.tr("Localizable", "claim_status_detail.submitted") }
    /// Your message
    public static var submittedMessage: String { L10n.tr("Localizable", "claim_status_detail.submitted_message") }
    public enum Documents {
      /// Claim documents
      public static var title: String { L10n.tr("Localizable", "claim_status_detail.documents.title") }
    }
    public enum InfoError {
      /// The claim audio couldn't be downloaded. Please try again to be able to listen to it.
      public static var body: String { L10n.tr("Localizable", "claim_status_detail.info_error.body") }
      /// Try again
      public static var button: String { L10n.tr("Localizable", "claim_status_detail.info_error.button") }
    }
    public enum MessageView {
      /// Go to conversation
      public static var body: String { L10n.tr("Localizable", "claim_status_detail.message_view.body") }
    }
  }

  public enum Claims {
    public enum Alert {
      /// If you exit, you'll go back to the start page and your inputted data will be lost.
      public static var body: String { L10n.tr("Localizable", "claims.alert.body") }
    }
  }

  public enum CrossSell {
    public enum Info {
      /// Contact us
      public static var faqChatButton: String { L10n.tr("Localizable", "cross_sell.info.faq_chat_button") }
    }
  }

  public enum EmbarkOnboardingMoreOptions {
    /// Settings
    public static var settingsLabel: String { L10n.tr("Localizable", "embark_onboarding_more_options.settings_label") }
  }

  public enum Home {
    public enum ClaimCard {
      public enum Pill {
        /// Claim
        public static var claim: String { L10n.tr("Localizable", "home.claim_card.pill.claim") }
        /// Reopened
        public static var reopened: String { L10n.tr("Localizable", "home.claim_card.pill.reopened") }
      }
    }
  }

  public enum HomeTab {
    /// Your insurance will be activated on %1$@. Visit our Help Center to see our most frequently asked questions.
    public static func activeInFutureInfo(_ p1: String) -> String {
      return L10n.tr("Localizable", "home_tab.active_in_future_info", p1)
    }
    /// Make a claim
    public static var claimButtonText: String { L10n.tr("Localizable", "home_tab.claim_button_text") }
    /// Help and support
    public static var getHelp: String { L10n.tr("Localizable", "home_tab.get_help") }
    /// Don't forget to cancel your previous insurance. Visit our Help Center to see our most frequently asked questions.
    public static var pendingNonswitchableInfo: String { L10n.tr("Localizable", "home_tab.pending_nonswitchable_info") }
    /// We're currently in the process of reaching out to your previous insurer to transition your insurance to Hedvig. Visit our Help Center to see our most frequently asked questions.
    public static var pendingSwitchableInfo: String { L10n.tr("Localizable", "home_tab.pending_switchable_info") }
    /// You currently have no active insurance with Hedvig. Please be aware that you can still submit claims for incidents that occurred during the active period of your cancelled insurance.
    public static var terminatedBody: String { L10n.tr("Localizable", "home_tab.terminated_body") }
    /// Hi, how can we help you?
    public static var welcomeTitleWithoutName: String { L10n.tr("Localizable", "home_tab.welcome_title_without_name") }
  }

  public enum ImportantMessage {
    /// Hide
    public static var hide: String { L10n.tr("Localizable", "important_message.hide") }
    /// Read more
    public static var readMore: String { L10n.tr("Localizable", "important_message.read_more") }
  }

  public enum InfoCardMissingPayment {
    /// For your insurance to stay active, you need to connect a payment method.
    public static var body: String { L10n.tr("Localizable", "info_card_missing_payment.body") }
    /// Your insurance will be terminated due to multiple failed payment attempts. Send a message through the app before %1$@ to avoid termination.
    public static func missingPaymentsBody(_ p1: String) -> String {
      return L10n.tr("Localizable", "info_card_missing_payment.missing_payments_body", p1)
    }
  }

  public enum InsuranceDetails {
    /// Change address
    public static var changeAddressButton: String { L10n.tr("Localizable", "insurance_details.change_address_button") }
    /// Change insurance amount
    public static var changeAmount: String { L10n.tr("Localizable", "insurance_details.change_amount") }
    /// Your monthly compensation
    public static var changeAmountSubtitle: String { L10n.tr("Localizable", "insurance_details.change_amount_subtitle") }
    /// Change coverage
    public static var changeCoverage: String { L10n.tr("Localizable", "insurance_details.change_coverage") }
    /// Move to new address
    public static var moveButton: String { L10n.tr("Localizable", "insurance_details.move_button") }
    /// Upcoming changes
    public static var updateDetailsSheetTitle: String { L10n.tr("Localizable", "insurance_details.update_details_sheet_title") }
  }

  public enum InsuranceDetailsView {
    /// Overview
    public static var tab1Title: String { L10n.tr("Localizable", "insurance_details_view.tab_1_title") }
    /// Coverage
    public static var tab2Title: String { L10n.tr("Localizable", "insurance_details_view.tab_2_title") }
    /// Documents
    public static var tab3Title: String { L10n.tr("Localizable", "insurance_details_view.tab_3_title") }
  }

  public enum InsuranceTab {
    public enum CrossSells {
      /// Discover more coverage
      public static var title: String { L10n.tr("Localizable", "insurance_tab.cross_sells.title") }
    }
  }

  public enum InsurancesTab {
    /// Cancelled insurances (%1$@)
    public static func cancelledInsurancesLabel(_ p1: String) -> String {
      return L10n.tr("Localizable", "insurances_tab.cancelled_insurances_label", p1)
    }
    /// Cancelled insurances
    public static var cancelledInsurancesTitle: String { L10n.tr("Localizable", "insurances_tab.cancelled_insurances_title") }
    /// Insurances
    public static var title: String { L10n.tr("Localizable", "insurances_tab.title") }
    /// View details
    public static var viewDetails: String { L10n.tr("Localizable", "insurances_tab.view_details") }
    /// Your insurance will be updated on %1$@.
    public static func yourInsuranceWillBeUpdated(_ p1: String) -> String {
      return L10n.tr("Localizable", "insurances_tab.your_insurance_will_be_updated", p1)
    }
    /// Your insurance will be updated on %1$@. If you want to make changes, you need to contact our service team.
    public static func yourInsuranceWillBeUpdatedWithInfo(_ p1: String) -> String {
      return L10n.tr("Localizable", "insurances_tab.your_insurance_will_be_updated_with_info", p1)
    }
  }

  public enum InsurelySeSsn {
    /// YYMMDD-XXXX
    public static var assistiveText: String { L10n.tr("Localizable", "insurely_se_ssn.assistive_text") }
  }

  public enum Login {
    /// Please enter your email address below. Log in option only available for Qasa members.
    public static var enterYourEmailAddress: String { L10n.tr("Localizable", "login.enter_your_email_address") }
    /// Open email app
    public static var openEmailAppButton: String { L10n.tr("Localizable", "login.open_email_app_button") }
    public enum CodeInput {
      public enum ErrorMsg {
        /// Verification code not valid
        public static var codeNotValid: String { L10n.tr("Localizable", "login.code_input.error_msg.code_not_valid") }
      }
    }
    public enum MediumButton {
      public enum Inactive {
        /// Resend code in %1$lis
        public static func resendCodeIn(_ p1: Int) -> String {
          return L10n.tr("Localizable", "login.medium_button.inactive.resend_code_in", p1)
        }
      }
    }
    public enum SmediumButton {
      public enum Active {
        /// Resend code
        public static var resendCode: String { L10n.tr("Localizable", "login.smedium_button.active.resend_code") }
      }
    }
    public enum Snackbar {
      /// Code sent
      public static var codeResent: String { L10n.tr("Localizable", "login.snackbar.code_resent") }
    }
    public enum Subtitle {
      /// Click the log in button in the email or enter the 6-digit code we've sent to %@.
      public static func verificationCodeEmail(_ p1: String) -> String {
        return L10n.tr("Localizable", "login.subtitle.verification_code_email", p1)
      }
    }
    public enum TextInput {
      /// Email address not valid
      public static var emailErrorNotValid: String { L10n.tr("Localizable", "login.text_input.email_error_not_valid") }
    }
    public enum Title {
      /// Check your email.
      public static var checkYourEmail: String { L10n.tr("Localizable", "login.title.check_your_email") }
    }
  }

  public enum MarketLanguageScreen {
    /// Choose language
    public static var chooseLanguageLabel: String { L10n.tr("Localizable", "market_language_screen.choose_language_label") }
  }

  public enum PayInConfirmation {
    /// Continue
    public static var continueButton: String { L10n.tr("Localizable", "pay_in_confirmation.continue_button") }
    /// Payment method connected!
    public static var headline: String { L10n.tr("Localizable", "pay_in_confirmation.headline") }
  }

  public enum PayInConfirmationDirectDebit {
    /// Bank account connected
    public static var headline: String { L10n.tr("Localizable", "pay_in_confirmation_direct_debit.headline") }
  }

  public enum PayInError {
    /// Ouch, something went wrong...
    public static var headline: String { L10n.tr("Localizable", "pay_in_error.headline") }
    /// Try again
    public static var retryButton: String { L10n.tr("Localizable", "pay_in_error.retry_button") }
  }

  public enum PayInErrorDirectDebit {
    /// We were unable to connect your bank account. Please try again or send us a message here in the app.
    public static var body: String { L10n.tr("Localizable", "pay_in_error_direct_debit.body") }
  }

  public enum PayInExplainer {
    /// Connect payment
    public static var buttonText: String { L10n.tr("Localizable", "pay_in_explainer.button_text") }
  }

  public enum PayInIframeInApp {
    /// Change bank account
    public static var connectPayment: String { L10n.tr("Localizable", "pay_in_iframe_in_app.connect_payment") }
  }

  public enum PayInIframeInAppCancelAlert {
    /// For your insurance to stay active, you need to connect a payment method.
    public static var body: String { L10n.tr("Localizable", "pay_in_iframe_in_app_cancel_alert.body") }
    /// Dismiss
    public static var dismissButton: String { L10n.tr("Localizable", "pay_in_iframe_in_app_cancel_alert.dismiss_button") }
    /// Yes, cancel
    public static var proceedButton: String { L10n.tr("Localizable", "pay_in_iframe_in_app_cancel_alert.proceed_button") }
    /// Sure you want to proceed?
    public static var title: String { L10n.tr("Localizable", "pay_in_iframe_in_app_cancel_alert.title") }
  }

  public enum PayInIframePostSign {
    /// Skip
    public static var skipButton: String { L10n.tr("Localizable", "pay_in_iframe_post_sign.skip_button") }
    /// Connect payment
    public static var title: String { L10n.tr("Localizable", "pay_in_iframe_post_sign.title") }
  }

  public enum PaymentDetails {
    public enum NavigationBar {
      /// Payment details
      public static var title: String { L10n.tr("Localizable", "payment_details.navigation_bar.title") }
    }
    public enum ReceiptCard {
      /// Total
      public static var total: String { L10n.tr("Localizable", "payment_details.receipt_card.total") }
    }
  }

  public enum Profile {
    public enum Certificates {
      /// Certificates
      public static var title: String { L10n.tr("Localizable", "profile.certificates.title") }
    }
    public enum ClaimHistory {
      /// Claim history
      public static var title: String { L10n.tr("Localizable", "profile.claim_history.title") }
    }
  }

  public enum ProfileTab {
    /// Profile
    public static var title: String { L10n.tr("Localizable", "profile_tab.title") }
  }

  public enum ReferallsInviteeStates {
    /// Invited you
    public static var invitedYou: String { L10n.tr("Localizable", "referalls_#invitee_states.invited_you") }
  }

  public enum ReferralsActiveToast {
    /// Code copied
    public static var text: String { L10n.tr("Localizable", "referrals_#active_+_toast.text") }
  }

  public enum ReferralsAllowPushNotificationSheet {
    public enum Allow {
      /// Allow
      public static var button: String { L10n.tr("Localizable", "referrals_#allow_push_notification_sheet.allow.button") }
    }
  }

  public enum ReferralsChange {
    /// Change code
    public static var changeCode: String { L10n.tr("Localizable", "referrals_#change.change_code") }
    /// Code changed
    public static var codeChanged: String { L10n.tr("Localizable", "referrals_#change.code_changed") }
  }

  public enum ReferralsEmpty {
    /// When someone gets Hedvig with your code you both get %1$@ discount per month.
    public static func body(_ p1: String) -> String {
      return L10n.tr("Localizable", "referrals_#empty.body", p1)
    }
    /// Share your code
    public static var shareCodeButton: String { L10n.tr("Localizable", "referrals_#empty.share_code_button") }
    public enum Code {
      /// Your unique code
      public static var headline: String { L10n.tr("Localizable", "referrals_#empty.code.headline") }
    }
  }

  public enum ReferralsInfoSheet {
    /// When someone gets Hedvig via your link or with your code you’ll both receive a %1$@ discount per month. The discount is applied for as long as you both stay members, hopefully forever. Spread your code and pay 0 SEK for your insurance.
    public static func body(_ p1: String) -> String {
      return L10n.tr("Localizable", "referrals_#info_sheet.body", p1)
    }
    /// Hedvig Forever
    public static var headline: String { L10n.tr("Localizable", "referrals_#info_sheet.headline") }
  }

  public enum SasIntegration {
    /// Change EuroBonus number
    public static var changeEurobonusNumber: String { L10n.tr("Localizable", "sas_integration.change_eurobonus_number") }
    /// Connect EuroBonus
    public static var connectEurobonus: String { L10n.tr("Localizable", "sas_integration.connect_eurobonus") }
    /// Enter your number
    public static var enterYourNumber: String { L10n.tr("Localizable", "sas_integration.enter_your_number") }
    /// EuroBonus connected
    public static var eurobonusConnected: String { L10n.tr("Localizable", "sas_integration.eurobonus_connected") }
    /// You need to connect your EuroBonus number to your account in order to earn points
    public static var eurobonusInfo: String { L10n.tr("Localizable", "sas_integration.eurobonus_info") }
    /// The number is incorrect, please try again
    public static var incorrectNumber: String { L10n.tr("Localizable", "sas_integration.incorrect_number") }
    /// Not connected
    public static var notConnected: String { L10n.tr("Localizable", "sas_integration.not_connected") }
    /// EuroBonus
    public static var title: String { L10n.tr("Localizable", "sas_integration.title") }
  }

  public enum SelectInsurance {
    public enum NavigationBar {
      public enum CenterElement {
        /// Select insurance
        public static var title: String { L10n.tr("Localizable", "select_insurance.navigation_bar.center_element.title") }
      }
    }
  }

  public enum TravelCertificate {
    /// Active
    public static var active: String { L10n.tr("Localizable", "travel_certificate.active") }
    /// Travel certificate
    public static var cardTitle: String { L10n.tr("Localizable", "travel_certificate.card_title") }
    /// Specify who should be covered
    public static var coinsuredErrorLabel: String { L10n.tr("Localizable", "travel_certificate.coinsured_error_label") }
    /// Create new certificate
    public static var createNewCertificate: String { L10n.tr("Localizable", "travel_certificate.create_new_certificate") }
    /// We recommend that you print the certificate so that you can easily take it with you everywhere.
    public static var downloadRecommendation: String { L10n.tr("Localizable", "travel_certificate.download_recommendation") }
    /// To view your travel certificates, you must first generate one.
    public static var emptyListMessage: String { L10n.tr("Localizable", "travel_certificate.empty_list_message") }
    /// Expired
    public static var expired: String { L10n.tr("Localizable", "travel_certificate.expired") }
    /// Register now
    public static var missingCoinsuredButton: String { L10n.tr("Localizable", "travel_certificate.missing_coinsured_button") }
    /// To include a co-insured on the certificate, you must first register their information.
    public static var missingCoinsuredInfo: String { L10n.tr("Localizable", "travel_certificate.missing_coinsured_info") }
    /// Personal number
    public static var personalNumber: String { L10n.tr("Localizable", "travel_certificate.personalNumber") }
    /// What is your primary address to be written on the travel certificate?
    public static var selectContractTitle: String { L10n.tr("Localizable", "travel_certificate.select_contract_title") }
    /// The certificate is valid for up to %1$d days when travelling to countries that are not prohibited by the Swedish Department of Foreign Affairs
    public static func startDateInfo(_ p1: Int) -> String {
      return L10n.tr("Localizable", "travel_certificate.start_date_info", p1)
    }
    /// Departure date
    public static var startDateTitle: String { L10n.tr("Localizable", "travel_certificate.start_date_title") }
    /// We have sent the travel certificate to your email. You can also download the certificate to your phone through the button below.
    public static var travelCertificateReadyDescription: String { L10n.tr("Localizable", "travel_certificate.travel_certificate_ready_description") }
    /// The travel certificate has been sent to your email.
    public static var weHaveSentCopyToYourEmail: String { L10n.tr("Localizable", "travel_certificate.we_have_sent_copy_to_your_email") }
    /// When is your departure?
    public static var whenIsYourTrip: String { L10n.tr("Localizable", "travel_certificate.when_is_your_trip") }
    /// Who is travelling?
    public static var whoIsTraveling: String { L10n.tr("Localizable", "travel_certificate.who_is_traveling") }
    public enum Info {
      /// A travel certificate confirms that you have insurance with travel coverage included. It helps you get the right treatment if an accident occurs while you are abroad.\n\nWe always recommend bringing a printed copy of your certificate with you when you travel.\n\nThe travel certificate can be valid for a maximum of the number of days stated in your insurance certificate.
      public static var subtitle: String { L10n.tr("Localizable", "travel_certificate.info.subtitle") }
      /// Why do you need a travel certificate?
      public static var title: String { L10n.tr("Localizable", "travel_certificate.info.title") }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension L10n {
  static func tr(_ table: String, _ key: String, _ args: [TranslationArgumentable]) -> String {
     guard let bundle = Bundle(for: BundleToken.self).path(forResource: Localization.Locale.currentLocale.value.translationlprojCode, ofType: "lproj") else {
      return key
    }

    let langBundle = Bundle(path: bundle)
    // swiftlint:disable:next nslocalizedstring_key
    let format = NSLocalizedString(key, tableName: table, bundle: langBundle!, comment: "")
    var translation = String(format: format, locale: Localization.Locale.currentLocale.value.translationLocale, arguments: args.map { $0.value })
    translation = translation == "" ? key : translation
    translation.derivedFromL10n = L10nDerivation(table: table, key: key, args: args)
    return translation
  }

  static func tr(_ table: String, _ key: String, _ args: TranslationArgumentable...) -> String {
    guard let bundle = Bundle(for: BundleToken.self).path(forResource: Localization.Locale.currentLocale.value.translationlprojCode, ofType: "lproj") else {
      return key
    }

    let langBundle = Bundle(path: bundle)
    // swiftlint:disable:next nslocalizedstring_key
    let format = NSLocalizedString(key, tableName: table, bundle: langBundle!, comment: "")
    var translation = String(format: format, locale: Localization.Locale.currentLocale.value.translationLocale, arguments: args.map { $0.value })
    translation = translation == "" ? key : translation
    translation.derivedFromL10n = L10nDerivation(table: table, key: key, args: args)
    return translation
  }

  static func tr(_ table: String, _ key: String, locale: Localization.Locale, _ args: TranslationArgumentable...) -> String {
     guard let bundle = Bundle(for: BundleToken.self).path(forResource: locale.lprojCode, ofType: "lproj") else {
      return key
    }

    let langBundle = Bundle(path: bundle)
    // swiftlint:disable:next nslocalizedstring_key
    let format = NSLocalizedString(key, tableName: table, bundle: langBundle!, comment: "")
    var translation = String(format: format, locale: Localization.Locale.currentLocale.value.translationLocale, arguments: args.map { $0.value })
    translation = translation == "" ? key : translation
    translation.derivedFromL10n = L10nDerivation(table: table, key: key, args: args)
    return translation
  }
}

private final class BundleToken {}
