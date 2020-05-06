// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
internal enum L10n {
    /// Language/Språk
    internal static let aboutLanguageRow = L10n.tr("Localizable", "ABOUT_LANGUAGE_ROW")
    /// License-rights
    internal static let aboutLicensesRow = L10n.tr("Localizable", "ABOUT_LICENSES_ROW")
    /// Userid
    internal static let aboutMemberIdRowKey = L10n.tr("Localizable", "ABOUT_MEMBER_ID_ROW_KEY")
    /// Activate push-notififcations
    internal static let aboutPushRow = L10n.tr("Localizable", "ABOUT_PUSH_ROW")
    /// About the app
    internal static let aboutScreenTitle = L10n.tr("Localizable", "ABOUT_SCREEN_TITLE")
    /// Show intro
    internal static let aboutShowIntroRow = L10n.tr("Localizable", "ABOUT_SHOW_INTRO_ROW")
    /// Hedvig believes strongly in open-source, here's the libraries with belonging licenses that we use to build our iOS app
    internal static let acknowledgementHeaderTitle = L10n.tr("Localizable", "ACKNOWLEDGEMENT_HEADER_TITLE")
    /// Activate when your current insurance expires
    internal static let activateInsuranceEndBtn = L10n.tr("Localizable", "ACTIVATE_INSURANCE_END_BTN")
    /// Activate today
    internal static let activateTodayBtn = L10n.tr("Localizable", "ACTIVATE_TODAY_BTN")
    /// Cancel
    internal static let alertCancel = L10n.tr("Localizable", "ALERT_CANCEL")
    /// Continue
    internal static let alertContinue = L10n.tr("Localizable", "ALERT_CONTINUE")
    /// If you pick your own start date you need to cancel your old insurance yourself so that everything goes smoothly.
    internal static let alertDescriptionStartdate = L10n.tr("Localizable", "ALERT_DESCRIPTION_STARTDATE")
    /// Choose your own startdate?
    internal static let alertTitleStartdate = L10n.tr("Localizable", "ALERT_TITLE_STARTDATE")
    /// itms-apps://itunes.apple.com/app/1303668531?action=write-review
    internal static let appStoreReviewUrl = L10n.tr("Localizable", "APP_STORE_REVIEW_URL")
    /// Send
    internal static let attachGifImageSend = L10n.tr("Localizable", "ATTACH_GIF_IMAGE_SEND")
    /// Playback
    internal static let audioInputPlay = L10n.tr("Localizable", "AUDIO_INPUT_PLAY")
    /// %1$@s
    internal static func audioInputPlaybackProgress(_ p1: String) -> String {
        return L10n.tr("Localizable", "AUDIO_INPUT_PLAYBACK_PROGRESS", p1)
    }

    /// Record
    internal static let audioInputRecordDescription = L10n.tr("Localizable", "AUDIO_INPUT_RECORD_DESCRIPTION")
    /// Recording: %1$@s
    internal static func audioInputRecording(_ p1: String) -> String {
        return L10n.tr("Localizable", "AUDIO_INPUT_RECORDING", p1)
    }

    /// Redo
    internal static let audioInputRedo = L10n.tr("Localizable", "AUDIO_INPUT_REDO")
    /// Submit
    internal static let audioInputSave = L10n.tr("Localizable", "AUDIO_INPUT_SAVE")
    /// Start recording
    internal static let audioInputStartRecording = L10n.tr("Localizable", "AUDIO_INPUT_START_RECORDING")
    /// Stop
    internal static let audioInputStopDescription = L10n.tr("Localizable", "AUDIO_INPUT_STOP_DESCRIPTION")
    /// Send
    internal static let audioRecordSend = L10n.tr("Localizable", "AUDIO_RECORD_SEND")
    /// Start the BankID-app
    internal static let bankIdAuthTitleInitiated = L10n.tr("Localizable", "BANK_ID_AUTH_TITLE_INITIATED")
    /// The BankID-app does not appear to be installed on your phone. Install it and acquire a BankID at your bank.
    internal static let bankIdNotInstalled = L10n.tr("Localizable", "BANK_ID_NOT_INSTALLED")
    /// OK
    internal static let bankidInactiveButton = L10n.tr("Localizable", "BANKID_INACTIVE_BUTTON")
    /// BankID was canceled due to inactivity. Please try again.
    internal static let bankidInactiveMessage = L10n.tr("Localizable", "BANKID_INACTIVE_MESSAGE")
    /// Canceled due to inactivity
    internal static let bankidInactiveTitle = L10n.tr("Localizable", "BANKID_INACTIVE_TITLE")
    /// Login
    internal static let bankidLoginTitle = L10n.tr("Localizable", "BANKID_LOGIN_TITLE")
    /// Scan the QR-code with the BankID app on the phone where it's installed
    internal static let bankidMissingMessage = L10n.tr("Localizable", "BANKID_MISSING_MESSAGE")
    /// BankID missing on this device
    internal static let bankidMissingTitle = L10n.tr("Localizable", "BANKID_MISSING_TITLE")
    /// It's an emergency, call me
    internal static let callMeChatTitle = L10n.tr("Localizable", "CALL_ME_CHAT_TITLE")
    /// Pick a charitable organization
    internal static let cashbackNeedsSetupAction = L10n.tr("Localizable", "CASHBACK_NEEDS_SETUP_ACTION")
    /// You have not chosen a charity organization
    internal static let cashbackNeedsSetupMessage = L10n.tr("Localizable", "CASHBACK_NEEDS_SETUP_MESSAGE")
    /// Choose which charity you want your share of any surplus to go to.
    internal static let cashbackNeedsSetupOverlayParagraph = L10n.tr("Localizable", "CASHBACK_NEEDS_SETUP_OVERLAY_PARAGRAPH")
    /// Pick a charitable organization
    internal static let cashbackNeedsSetupOverlayTitle = L10n.tr("Localizable", "CASHBACK_NEEDS_SETUP_OVERLAY_TITLE")
    /// Charity organizations
    internal static let charityOptionsHeaderTitle = L10n.tr("Localizable", "CHARITY_OPTIONS_HEADER_TITLE")
    /// You have not chosen which charity your share of any surplus should go.
    internal static let charityScreenHeaderMessage = L10n.tr("Localizable", "CHARITY_SCREEN_HEADER_MESSAGE")
    /// Select
    internal static let chartityPickOption = L10n.tr("Localizable", "CHARTITY_PICK_OPTION")
    /// Could not load the file...
    internal static let chatCouldNotLoadFile = L10n.tr("Localizable", "CHAT_COULD_NOT_LOAD_FILE")
    /// Cancel
    internal static let chatEditMessageCancel = L10n.tr("Localizable", "CHAT_EDIT_MESSAGE_CANCEL")
    /// Edit message
    internal static let chatEditMessageDescription = L10n.tr("Localizable", "CHAT_EDIT_MESSAGE_DESCRIPTION")
    /// Edit
    internal static let chatEditMessageSubmit = L10n.tr("Localizable", "CHAT_EDIT_MESSAGE_SUBMIT")
    /// Would you like to edit your message?
    internal static let chatEditMessageTitle = L10n.tr("Localizable", "CHAT_EDIT_MESSAGE_TITLE")
    /// Attached file
    internal static let chatFileDownload = L10n.tr("Localizable", "CHAT_FILE_DOWNLOAD")
    /// Loading...
    internal static let chatFileLoading = L10n.tr("Localizable", "CHAT_FILE_LOADING")
    /// %1$@-file uploaded
    internal static func chatFileUploaded(_ p1: String) -> String {
        return L10n.tr("Localizable", "CHAT_FILE_UPLOADED", p1)
    }

    /// Oh no, no GIF for this search...
    internal static let chatGiphyPickerNoSearchText = L10n.tr("Localizable", "CHAT_GIPHY_PICKER_NO_SEARCH_TEXT")
    /// Search for something to send GIFs!
    internal static let chatGiphyPickerText = L10n.tr("Localizable", "CHAT_GIPHY_PICKER_TEXT")
    /// Search...
    internal static let chatGiphySearchHint = L10n.tr("Localizable", "CHAT_GIPHY_SEARCH_HINT")
    /// GIPHY
    internal static let chatGiphyTitle = L10n.tr("Localizable", "CHAT_GIPHY_TITLE")
    /// Open the chat
    internal static let chatPreviewOpenChat = L10n.tr("Localizable", "CHAT_PREVIEW_OPEN_CHAT")
    /// Cancel
    internal static let chatRestartAlertCancel = L10n.tr("Localizable", "CHAT_RESTART_ALERT_CANCEL")
    /// OK
    internal static let chatRestartAlertConfirm = L10n.tr("Localizable", "CHAT_RESTART_ALERT_CONFIRM")
    /// All information you've entered so far will be removed
    internal static let chatRestartAlertMessage = L10n.tr("Localizable", "CHAT_RESTART_ALERT_MESSAGE")
    /// Do you want to restart?
    internal static let chatRestartAlertTitle = L10n.tr("Localizable", "CHAT_RESTART_ALERT_TITLE")
    /// Activate push notifications
    internal static let chatToastPushNotificationsSubtitle = L10n.tr("Localizable", "CHAT_TOAST_PUSH_NOTIFICATIONS_SUBTITLE")
    /// Send
    internal static let chatUploadPresend = L10n.tr("Localizable", "CHAT_UPLOAD_PRESEND")
    /// Uploading...
    internal static let chatUploadingAnimationText = L10n.tr("Localizable", "CHAT_UPLOADING_ANIMATION_TEXT")
    /// Choose date
    internal static let chooseDateBtn = L10n.tr("Localizable", "CHOOSE_DATE_BTN")
    /// In order for you to get information about your claim and see our messages, it is important that you activate your push notifications.
    internal static let claimsActivateNotificationsBody = L10n.tr("Localizable", "CLAIMS_ACTIVATE_NOTIFICATIONS_BODY")
    /// Enable notifications
    internal static let claimsActivateNotificationsCta = L10n.tr("Localizable", "CLAIMS_ACTIVATE_NOTIFICATIONS_CTA")
    /// Skip
    internal static let claimsActivateNotificationsDismiss = L10n.tr("Localizable", "CLAIMS_ACTIVATE_NOTIFICATIONS_DISMISS")
    /// Activate push notifications
    internal static let claimsActivateNotificationsHeadline = L10n.tr("Localizable", "CLAIMS_ACTIVATE_NOTIFICATIONS_HEADLINE")
    /// Report a claim
    internal static let claimsChatTitle = L10n.tr("Localizable", "CLAIMS_CHAT_TITLE")
    /// Start claim
    internal static let claimsHeaderActionButton = L10n.tr("Localizable", "CLAIMS_HEADER_ACTION_BUTTON")
    /// Have you lost your phone or been the victim of theft? Report it to Hedvig.
    internal static let claimsHeaderSubtitle = L10n.tr("Localizable", "CLAIMS_HEADER_SUBTITLE")
    /// Has something happened? Start your claim here!
    internal static let claimsHeaderTitle = L10n.tr("Localizable", "CLAIMS_HEADER_TITLE")
    /// Your Hedvig insurance isn't active yet but once it is you can file a claim here. If you need help right now feel free to contact us via the chat.
    internal static let claimsInactiveMessage = L10n.tr("Localizable", "CLAIMS_INACTIVE_MESSAGE")
    /// Slide to claim
    internal static let claimsPledgeSlideLabel = L10n.tr("Localizable", "CLAIMS_PLEDGE_SLIDE_LABEL")
    /// Quick choices
    internal static let claimsQuickChoiceHeader = L10n.tr("Localizable", "CLAIMS_QUICK_CHOICE_HEADER")
    /// Claims
    internal static let claimsScreenTab = L10n.tr("Localizable", "CLAIMS_SCREEN_TAB")
    /// Claims
    internal static let claimsScreenTitle = L10n.tr("Localizable", "CLAIMS_SCREEN_TITLE")
    /// Connect card
    internal static let connectCard = L10n.tr("Localizable", "CONNECT_CARD")
    /// %1$@ covers
    internal static func contractCoverageContractType(_ p1: String) -> String {
        return L10n.tr("Localizable", "CONTRACT_COVERAGE_CONTRACT_TYPE", p1)
    }

    /// My protection
    internal static let contractCoverageMainTitle = L10n.tr("Localizable", "CONTRACT_COVERAGE_MAIN_TITLE")
    /// More information
    internal static let contractCoverageMoreInfo = L10n.tr("Localizable", "CONTRACT_COVERAGE_MORE_INFO")
    /// Change information
    internal static let contractDetailCoinsuredChangeInfo = L10n.tr("Localizable", "CONTRACT_DETAIL_COINSURED_CHANGE_INFO")
    /// Quantity
    internal static let contractDetailCoinsuredNumber = L10n.tr("Localizable", "CONTRACT_DETAIL_COINSURED_NUMBER")
    /// You and %1$li other(s)
    internal static func contractDetailCoinsuredNumberInput(_ p1: Int) -> String {
        return L10n.tr("Localizable", "CONTRACT_DETAIL_COINSURED_NUMBER_INPUT", p1)
    }

    /// Just you
    internal static let contractDetailCoinsuredNumberInputZeroCoinsured = L10n.tr("Localizable", "CONTRACT_DETAIL_COINSURED_NUMBER_INPUT_ZERO_COINSURED")
    /// Co-insured
    internal static let contractDetailCoinsuredTitle = L10n.tr("Localizable", "CONTRACT_DETAIL_COINSURED_TITLE")
    /// Adress
    internal static let contractDetailHomeAddress = L10n.tr("Localizable", "CONTRACT_DETAIL_HOME_ADDRESS")
    /// Change information
    internal static let contractDetailHomeChangeInfo = L10n.tr("Localizable", "CONTRACT_DETAIL_HOME_CHANGE_INFO")
    /// Zip code
    internal static let contractDetailHomePostcode = L10n.tr("Localizable", "CONTRACT_DETAIL_HOME_POSTCODE")
    /// Living space
    internal static let contractDetailHomeSize = L10n.tr("Localizable", "CONTRACT_DETAIL_HOME_SIZE")
    /// %1$li sq.m.
    internal static func contractDetailHomeSizeInput(_ p1: Int) -> String {
        return L10n.tr("Localizable", "CONTRACT_DETAIL_HOME_SIZE_INPUT", p1)
    }

    /// My home
    internal static let contractDetailHomeTitle = L10n.tr("Localizable", "CONTRACT_DETAIL_HOME_TITLE")
    /// Type
    internal static let contractDetailHomeType = L10n.tr("Localizable", "CONTRACT_DETAIL_HOME_TYPE")
    /// My information
    internal static let contractDetailMainTitle = L10n.tr("Localizable", "CONTRACT_DETAIL_MAIN_TITLE")
    /// Copied!
    internal static let copied = L10n.tr("Localizable", "COPIED")
    /// /monthly
    internal static let costMonthly = L10n.tr("Localizable", "COST_MONTHLY")
    /// Your insurance is active
    internal static let dashboardBannerActiveInfo = L10n.tr("Localizable", "DASHBOARD_BANNER_ACTIVE_INFO")
    /// Hi %1$@!
    internal static func dashboardBannerActiveTitle(_ p1: String) -> String {
        return L10n.tr("Localizable", "DASHBOARD_BANNER_ACTIVE_TITLE", p1)
    }

    /// D
    internal static let dashboardBannerDays = L10n.tr("Localizable", "DASHBOARD_BANNER_DAYS")
    /// H
    internal static let dashboardBannerHours = L10n.tr("Localizable", "DASHBOARD_BANNER_HOURS")
    /// M
    internal static let dashboardBannerMinutes = L10n.tr("Localizable", "DASHBOARD_BANNER_MINUTES")
    /// M
    internal static let dashboardBannerMonths = L10n.tr("Localizable", "DASHBOARD_BANNER_MONTHS")
    /// Your insurance is inactive
    internal static let dashboardBannerTerminatedInfo = L10n.tr("Localizable", "DASHBOARD_BANNER_TERMINATED_INFO")
    /// What would you like to do today?
    internal static let dashboardChatActionsHeader = L10n.tr("Localizable", "DASHBOARD_CHAT_ACTIONS_HEADER")
    /// Your deductible is 1 500 kr
    internal static let dashboardDeductibleFootnote = L10n.tr("Localizable", "DASHBOARD_DEDUCTIBLE_FOOTNOTE")
    /// You insurance actives in:
    internal static let dashboardHaveStartDateBannerTitle = L10n.tr("Localizable", "DASHBOARD_HAVE_START_DATE_BANNER_TITLE")
    /// Close
    internal static let dashboardInfoBoxCloseDescription = L10n.tr("Localizable", "DASHBOARD_INFO_BOX_CLOSE_DESCRIPTION")
    /// Your deductible is 1 500 kr
    internal static let dashboardInfoDeductible = L10n.tr("Localizable", "DASHBOARD_INFO_DEDUCTIBLE")
    /// An increased deductible applies for certain claims, this applies to flooding and freeze damages, among other things. Please read the terms or contact us in the chat if you have any questions.
    internal static let dashboardInfoDeductibleHouse = L10n.tr("Localizable", "DASHBOARD_INFO_DEDUCTIBLE_HOUSE")
    /// More info
    internal static let dashboardInfoHeader = L10n.tr("Localizable", "DASHBOARD_INFO_HEADER")
    /// Your house is insured to its full value
    internal static let dashboardInfoHouseValue = L10n.tr("Localizable", "DASHBOARD_INFO_HOUSE_VALUE")
    /// Your stuff is insured for a total of 1 000 000 kr
    internal static let dashboardInfoInsuranceAmount = L10n.tr("Localizable", "DASHBOARD_INFO_INSURANCE_AMOUNT")
    /// Max compensation for your items are\n%1$@
    internal static func dashboardInfoInsuranceStuffAmount(_ p1: String) -> String {
        return L10n.tr("Localizable", "DASHBOARD_INFO_INSURANCE_STUFF_AMOUNT", p1)
    }

    /// about your home insurance
    internal static let dashboardInfoSubheader = L10n.tr("Localizable", "DASHBOARD_INFO_SUBHEADER")
    /// Valid on travels anywhere in the world
    internal static let dashboardInfoTravel = L10n.tr("Localizable", "DASHBOARD_INFO_TRAVEL")
    /// Your stuff is insured for a total of %1$@ kr
    internal static func dashboardInsuranceAmountFootnote(_ p1: String) -> String {
        return L10n.tr("Localizable", "DASHBOARD_INSURANCE_AMOUNT_FOOTNOTE", p1)
    }

    /// Your insurance is active
    internal static let dashboardInsuranceStatus = L10n.tr("Localizable", "DASHBOARD_INSURANCE_STATUS")
    /// Active
    internal static let dashboardInsuranceStatusActive = L10n.tr("Localizable", "DASHBOARD_INSURANCE_STATUS_ACTIVE")
    /// To be terminated on %1$@
    internal static func dashboardInsuranceStatusActiveTerminationdate(_ p1: String) -> String {
        return L10n.tr("Localizable", "DASHBOARD_INSURANCE_STATUS_ACTIVE_TERMINATIONDATE", p1)
    }

    /// Waiting for start date
    internal static let dashboardInsuranceStatusInactiveNoStartdate = L10n.tr("Localizable", "DASHBOARD_INSURANCE_STATUS_INACTIVE_NO_STARTDATE")
    /// To be activated on %1$@
    internal static func dashboardInsuranceStatusInactiveStartdate(_ p1: String) -> String {
        return L10n.tr("Localizable", "DASHBOARD_INSURANCE_STATUS_INACTIVE_STARTDATE", p1)
    }

    /// To be activated on %1$@, to be terminated on %2$@
    internal static func dashboardInsuranceStatusInactiveStartdateTerminatedInFuture(_ p1: String, _ p2: String) -> String {
        return L10n.tr("Localizable", "DASHBOARD_INSURANCE_STATUS_INACTIVE_STARTDATE_TERMINATED_IN_FUTURE", p1, p2)
    }

    /// Terminated
    internal static let dashboardInsuranceStatusTerminated = L10n.tr("Localizable", "DASHBOARD_INSURANCE_STATUS_TERMINATED")
    /// To be terminated after today
    internal static let dashboardInsuranceStatusTerminatedToday = L10n.tr("Localizable", "DASHBOARD_INSURANCE_STATUS_TERMINATED_TODAY")
    /// Less info
    internal static let dashboardLessInfoButtonText = L10n.tr("Localizable", "DASHBOARD_LESS_INFO_BUTTON_TEXT")
    /// More info
    internal static let dashboardMoreInfoButtonText = L10n.tr("Localizable", "DASHBOARD_MORE_INFO_BUTTON_TEXT")
    /// Tap to read more
    internal static let dashboardMyCoverageSubtitle = L10n.tr("Localizable", "DASHBOARD_MY_COVERAGE_SUBTITLE")
    /// My coverage
    internal static let dashboardMyCoverageTitle = L10n.tr("Localizable", "DASHBOARD_MY_COVERAGE_TITLE")
    /// Insurance certificate and full terms
    internal static let dashboardMyDocumentsSubtitle = L10n.tr("Localizable", "DASHBOARD_MY_DOCUMENTS_SUBTITLE")
    /// My documents
    internal static let dashboardMyDocumentsTitle = L10n.tr("Localizable", "DASHBOARD_MY_DOCUMENTS_TITLE")
    /// You + %1$li Co-insured persons
    internal static func dashboardMyInfoCoinsured(_ p1: Int) -> String {
        return L10n.tr("Localizable", "DASHBOARD_MY_INFO_COINSURED", p1)
    }

    /// You are covered
    internal static let dashboardMyInfoNoCoinsured = L10n.tr("Localizable", "DASHBOARD_MY_INFO_NO_COINSURED")
    /// My information
    internal static let dashboardMyInfoTitle = L10n.tr("Localizable", "DASHBOARD_MY_INFO_TITLE")
    /// Your insurance is active!
    internal static let dashboardNotStartedBannerTitle = L10n.tr("Localizable", "DASHBOARD_NOT_STARTED_BANNER_TITLE")
    /// The apartment is insured to its total value
    internal static let dashboardOwnerFootnote = L10n.tr("Localizable", "DASHBOARD_OWNER_FOOTNOTE")
    /// Connect payment
    internal static let dashboardPaymentSetupButton = L10n.tr("Localizable", "DASHBOARD_PAYMENT_SETUP_BUTTON")
    /// To have your insurance valid in the future, you need to connect your bank account with Hedvig.
    internal static let dashboardPaymentSetupInfo = L10n.tr("Localizable", "DASHBOARD_PAYMENT_SETUP_INFO")
    /// D
    internal static let dashboardPendingDays = L10n.tr("Localizable", "DASHBOARD_PENDING_DAYS")
    /// You're still insured by your previous insurance company. Your Hedvig insurance will be activated on %1$@ the same day as your current insurance expires!
    internal static func dashboardPendingHasDate(_ p1: String) -> String {
        return L10n.tr("Localizable", "DASHBOARD_PENDING_HAS_DATE", p1)
    }

    /// Your insurance is on its way!
    internal static let dashboardPendingHeader = L10n.tr("Localizable", "DASHBOARD_PENDING_HEADER")
    /// H
    internal static let dashboardPendingHours = L10n.tr("Localizable", "DASHBOARD_PENDING_HOURS")
    /// Less info
    internal static let dashboardPendingLessInfo = L10n.tr("Localizable", "DASHBOARD_PENDING_LESS_INFO")
    /// M
    internal static let dashboardPendingMinutes = L10n.tr("Localizable", "DASHBOARD_PENDING_MINUTES")
    /// M
    internal static let dashboardPendingMonths = L10n.tr("Localizable", "DASHBOARD_PENDING_MONTHS")
    /// More info
    internal static let dashboardPendingMoreInfo = L10n.tr("Localizable", "DASHBOARD_PENDING_MORE_INFO")
    /// You're still insured by your previous insurance company. We have initiated the move and will inform you as soon as we know the starting date!
    internal static let dashboardPendingNoDate = L10n.tr("Localizable", "DASHBOARD_PENDING_NO_DATE")
    /// Click an icon for more info
    internal static let dashboardPerilFooter = L10n.tr("Localizable", "DASHBOARD_PERIL_FOOTER")
    /// Click the icons for more info
    internal static let dashboardPerilsCategoryInfo = L10n.tr("Localizable", "DASHBOARD_PERILS_CATEGORY_INFO")
    /// You are still insured with your former insurance company. We have started the move and on %1$@ your insurance with Hedvig will be activated!
    internal static func dashboardReadmoreHaveStartDateText(_ p1: String) -> String {
        return L10n.tr("Localizable", "DASHBOARD_READMORE_HAVE_START_DATE_TEXT", p1)
    }

    /// You are still insured with your former insurance company. We have started the switch to Hedvig and will inform you as soon as we know the activation date!
    internal static let dashboardReadmoreNotStartedText = L10n.tr("Localizable", "DASHBOARD_READMORE_NOT_STARTED_TEXT")
    /// In %1$li days your insurance will be renewed. Read your updated insurance certificate here.
    internal static func dashboardRenewalPrompterBody(_ p1: Int) -> String {
        return L10n.tr("Localizable", "DASHBOARD_RENEWAL_PROMPTER_BODY", p1)
    }

    /// Read new insurance certificate
    internal static let dashboardRenewalPrompterCta = L10n.tr("Localizable", "DASHBOARD_RENEWAL_PROMPTER_CTA")
    /// Your insurance is renewed
    internal static let dashboardRenewalPrompterTitle = L10n.tr("Localizable", "DASHBOARD_RENEWAL_PROMPTER_TITLE")
    /// Insurance
    internal static let dashboardScreenTitle = L10n.tr("Localizable", "DASHBOARD_SCREEN_TITLE")
    /// Connect direct debit
    internal static let dashboardSetupDirectDebitTitle = L10n.tr("Localizable", "DASHBOARD_SETUP_DIRECT_DEBIT_TITLE")
    /// Applies for travel anywhere in the world
    internal static let dashboardTravelFootnote = L10n.tr("Localizable", "DASHBOARD_TRAVEL_FOOTNOTE")
    /// 1500 kr
    internal static let deductible = L10n.tr("Localizable", "DEDUCTIBLE")
    /// Cancel
    internal static let demoModeCancel = L10n.tr("Localizable", "DEMO_MODE_CANCEL")
    /// Start demo-mode
    internal static let demoModeStart = L10n.tr("Localizable", "DEMO_MODE_START")
    /// No
    internal static let directDebitDismissAlertCancelAction = L10n.tr("Localizable", "DIRECT_DEBIT_DISMISS_ALERT_CANCEL_ACTION")
    /// Yes
    internal static let directDebitDismissAlertConfirmAction = L10n.tr("Localizable", "DIRECT_DEBIT_DISMISS_ALERT_CONFIRM_ACTION")
    /// You have not set up payment yet.
    internal static let directDebitDismissAlertMessage = L10n.tr("Localizable", "DIRECT_DEBIT_DISMISS_ALERT_MESSAGE")
    /// Are you sure?
    internal static let directDebitDismissAlertTitle = L10n.tr("Localizable", "DIRECT_DEBIT_DISMISS_ALERT_TITLE")
    /// Cancel
    internal static let directDebitDismissButton = L10n.tr("Localizable", "DIRECT_DEBIT_DISMISS_BUTTON")
    /// Go back
    internal static let directDebitFailButton = L10n.tr("Localizable", "DIRECT_DEBIT_FAIL_BUTTON")
    /// Something's gone wrong
    internal static let directDebitFailHeading = L10n.tr("Localizable", "DIRECT_DEBIT_FAIL_HEADING")
    /// Due to a technical error, your bank account could not be updated. Please try again or write to Hedvig in the chat.
    internal static let directDebitFailMessage = L10n.tr("Localizable", "DIRECT_DEBIT_FAIL_MESSAGE")
    /// Change bank account
    internal static let directDebitSetupChangeScreenTitle = L10n.tr("Localizable", "DIRECT_DEBIT_SETUP_CHANGE_SCREEN_TITLE")
    /// Connect bank account
    internal static let directDebitSetupScreenTitle = L10n.tr("Localizable", "DIRECT_DEBIT_SETUP_SCREEN_TITLE")
    /// Back
    internal static let directDebitSuccessButton = L10n.tr("Localizable", "DIRECT_DEBIT_SUCCESS_BUTTON")
    /// Account switch done!
    internal static let directDebitSuccessHeading = L10n.tr("Localizable", "DIRECT_DEBIT_SUCCESS_HEADING")
    /// Your bank account is now up to date and will be visible shortly. The next payment will be deducted from the new bank account.
    internal static let directDebitSuccessMessage = L10n.tr("Localizable", "DIRECT_DEBIT_SUCCESS_MESSAGE")
    /// What date do you want your insurance to be activated?
    internal static let draggableStartdateDescription = L10n.tr("Localizable", "DRAGGABLE_STARTDATE_DESCRIPTION")
    /// Change start date
    internal static let draggableStartdateTitle = L10n.tr("Localizable", "DRAGGABLE_STARTDATE_TITLE")
    /// Edit
    internal static let editableRowEdit = L10n.tr("Localizable", "EDITABLE_ROW_EDIT")
    /// Save
    internal static let editableRowSave = L10n.tr("Localizable", "EDITABLE_ROW_SAVE")
    /// Nothing specified
    internal static let emailRowEmpty = L10n.tr("Localizable", "EMAIL_ROW_EMPTY")
    /// Email address
    internal static let emailRowTitle = L10n.tr("Localizable", "EMAIL_ROW_TITLE")
    /// OK
    internal static let emergencyAbroadAlertNonPhoneOkButton = L10n.tr("Localizable", "EMERGENCY_ABROAD_ALERT_NON_PHONE_OK_BUTTON")
    /// Hedvig Global Assistance
    internal static let emergencyAbroadAlertNonPhoneTitle = L10n.tr("Localizable", "EMERGENCY_ABROAD_ALERT_NON_PHONE_TITLE")
    /// Call Hedvig Global Assistance
    internal static let emergencyAbroadButton = L10n.tr("Localizable", "EMERGENCY_ABROAD_BUTTON")
    /// +4538489461
    internal static let emergencyAbroadButtonActionPhoneNumber = L10n.tr("Localizable", "EMERGENCY_ABROAD_BUTTON_ACTION_PHONE_NUMBER")
    /// Are you ill or injured abroad and need care? The first thing you need to do is contact Hedvig Global Assistance.
    internal static let emergencyAbroadDescription = L10n.tr("Localizable", "EMERGENCY_ABROAD_DESCRIPTION")
    /// Emergency illness abroad
    internal static let emergencyAbroadTitle = L10n.tr("Localizable", "EMERGENCY_ABROAD_TITLE")
    /// Call me
    internal static let emergencyCallMeButton = L10n.tr("Localizable", "EMERGENCY_CALL_ME_BUTTON")
    /// If it's a crisis we can call you. Be sure to notify SOS Alarm first in case of emergency!
    internal static let emergencyCallMeDescription = L10n.tr("Localizable", "EMERGENCY_CALL_ME_DESCRIPTION")
    /// Speak with someone
    internal static let emergencyCallMeTitle = L10n.tr("Localizable", "EMERGENCY_CALL_ME_TITLE")
    /// Write to us
    internal static let emergencyUnsureButton = L10n.tr("Localizable", "EMERGENCY_UNSURE_BUTTON")
    /// Unsure if it's an emergency? Contact Hedvig first!
    internal static let emergencyUnsureDescription = L10n.tr("Localizable", "EMERGENCY_UNSURE_DESCRIPTION")
    /// Unsure?
    internal static let emergencyUnsureTitle = L10n.tr("Localizable", "EMERGENCY_UNSURE_TITLE")
    /// Close
    internal static let expandableContentCollapse = L10n.tr("Localizable", "EXPANDABLE_CONTENT_COLLAPSE")
    /// Read more
    internal static let expandableContentExpand = L10n.tr("Localizable", "EXPANDABLE_CONTENT_EXPAND")
    /// Hedvig becomes better when you share it with your friends! You and your friends gets (REFERRAL_VALUE) off your monthly payments – per friend!
    internal static let featurePromoBody = L10n.tr("Localizable", "FEATURE_PROMO_BODY")
    /// Read more
    internal static let featurePromoBtn = L10n.tr("Localizable", "FEATURE_PROMO_BTN")
    /// Bonusrain to the people!
    internal static let featurePromoHeadline = L10n.tr("Localizable", "FEATURE_PROMO_HEADLINE")
    /// What's new?
    internal static let featurePromoTitle = L10n.tr("Localizable", "FEATURE_PROMO_TITLE")
    /// ios@hedvig.com
    internal static let feedbackIosEmail = L10n.tr("Localizable", "FEEDBACK_IOS_EMAIL")
    /// Help us be better
    internal static let feedbackScreenLabel = L10n.tr("Localizable", "FEEDBACK_SCREEN_LABEL")
    /// Device: %1$@\nSystem: %1$@ %1$@\nApp Version: %1$@\nMember ID: %1$@
    internal static func feedbackScreenReportBugEmailAttachment(_ p1: String) -> String {
        return L10n.tr("Localizable", "FEEDBACK_SCREEN_REPORT_BUG_EMAIL_ATTACHMENT", p1)
    }

    /// Report a bug
    internal static let feedbackScreenReportBugTitle = L10n.tr("Localizable", "FEEDBACK_SCREEN_REPORT_BUG_TITLE")
    /// Review the app
    internal static let feedbackScreenReviewAppTitle = L10n.tr("Localizable", "FEEDBACK_SCREEN_REVIEW_APP_TITLE")
    /// App Store
    internal static let feedbackScreenReviewAppValue = L10n.tr("Localizable", "FEEDBACK_SCREEN_REVIEW_APP_VALUE")
    /// Feedback
    internal static let feedbackScreenTitle = L10n.tr("Localizable", "FEEDBACK_SCREEN_TITLE")
    /// You have not given us access to your phone library, so we cannot display your photos here. Go to Settings on your phone to give us access to your photo library.
    internal static let fileUploadError = L10n.tr("Localizable", "FILE_UPLOAD_ERROR")
    /// Try again
    internal static let fileUploadErrorRetryButton = L10n.tr("Localizable", "FILE_UPLOAD_ERROR_RETRY_BUTTON")
    /// Unknown
    internal static let genericUnknown = L10n.tr("Localizable", "GENERIC_UNKNOWN")
    /// GIF
    internal static let gifButtonTitle = L10n.tr("Localizable", "GIF_BUTTON_TITLE")
    /// hedvig
    internal static let hedvigLogoAccessibility = L10n.tr("Localizable", "HEDVIG_LOGO_ACCESSIBILITY")
    /// I understand that Hedvig is based on trust. I promise the information I give you regarding the incident is true and I claim only the compensation I am entitled to.
    internal static let honestyPledgeDescription = L10n.tr("Localizable", "HONESTY_PLEDGE_DESCRIPTION")
    /// Your pledge
    internal static let honestyPledgeTitle = L10n.tr("Localizable", "HONESTY_PLEDGE_TITLE")
    /// Attefalls
    internal static let houseInfoAttefalls = L10n.tr("Localizable", "HOUSE_INFO_ATTEFALLS")
    /// Bathroom
    internal static let houseInfoBathroom = L10n.tr("Localizable", "HOUSE_INFO_BATHROOM")
    /// Ancillary space
    internal static let houseInfoBiyta = L10n.tr("Localizable", "HOUSE_INFO_BIYTA")
    /// %1$li sqm
    internal static func houseInfoBiytaSquaremeters(_ p1: Int) -> String {
        return L10n.tr("Localizable", "HOUSE_INFO_BIYTA_SQUAREMETERS", p1)
    }

    /// Living area
    internal static let houseInfoBoyta = L10n.tr("Localizable", "HOUSE_INFO_BOYTA")
    /// %1$li sqm
    internal static func houseInfoBoytaSquaremeters(_ p1: Int) -> String {
        return L10n.tr("Localizable", "HOUSE_INFO_BOYTA_SQUAREMETERS", p1)
    }

    /// Number of co-insured
    internal static let houseInfoCoinsured = L10n.tr("Localizable", "HOUSE_INFO_COINSURED")
    /// 1,5 million kr
    internal static let houseInfoCompensationGadgets = L10n.tr("Localizable", "HOUSE_INFO_COMPENSATION_GADGETS")
    /// Connected water main
    internal static let houseInfoConnectedWater = L10n.tr("Localizable", "HOUSE_INFO_CONNECTED_WATER")
    /// Extra buildings
    internal static let houseInfoExtrabuildings = L10n.tr("Localizable", "HOUSE_INFO_EXTRABUILDINGS")
    /// Garage
    internal static let houseInfoGarage = L10n.tr("Localizable", "HOUSE_INFO_GARAGE")
    /// Annan
    internal static let houseInfoMisc = L10n.tr("Localizable", "HOUSE_INFO_MISC")
    /// Partly subleted?
    internal static let houseInfoRented = L10n.tr("Localizable", "HOUSE_INFO_RENTED")
    /// Shed
    internal static let houseInfoShed = L10n.tr("Localizable", "HOUSE_INFO_SHED")
    /// No
    internal static let houseInfoSubletedFalse = L10n.tr("Localizable", "HOUSE_INFO_SUBLETED_FALSE")
    /// Yes
    internal static let houseInfoSubletedTrue = L10n.tr("Localizable", "HOUSE_INFO_SUBLETED_TRUE")
    /// House
    internal static let houseInfoType = L10n.tr("Localizable", "HOUSE_INFO_TYPE")
    /// Year built
    internal static let houseInfoYearBuilt = L10n.tr("Localizable", "HOUSE_INFO_YEAR_BUILT")
    /// ICA Insurance
    internal static let icaForsakringApp = L10n.tr("Localizable", "ICA_FORSAKRING_APP")
    /// You + %1$li Co-insured persons
    internal static func insurancePageAdditionalInsuranceMyInfoText(_ p1: Int) -> String {
        return L10n.tr("Localizable", "INSURANCE_PAGE_ADDITIONAL_INSURANCE_MY_INFO_TEXT", p1)
    }

    /// Click to read
    internal static let insurancePageMyCoverText = L10n.tr("Localizable", "INSURANCE_PAGE_MY_COVER_TEXT")
    /// My cover
    internal static let insurancePageMyCoverTitle = L10n.tr("Localizable", "INSURANCE_PAGE_MY_COVER_TITLE")
    /// Insurance agreement
    internal static let insurancePageMyDocumentsText = L10n.tr("Localizable", "INSURANCE_PAGE_MY_DOCUMENTS_TEXT")
    /// My documents
    internal static let insurancePageMyDocumentsTitle = L10n.tr("Localizable", "INSURANCE_PAGE_MY_DOCUMENTS_TITLE")
    /// My information
    internal static let insurancePageMyInfoTitle = L10n.tr("Localizable", "INSURANCE_PAGE_MY_INFO_TITLE")
    /// Active
    internal static let insurancePageTypeActive = L10n.tr("Localizable", "INSURANCE_PAGE_TYPE_ACTIVE")
    /// Chat with Hedvig
    internal static let insuranceStatusTerminatedAlertActionChat = L10n.tr("Localizable", "INSURANCE_STATUS_TERMINATED_ALERT_ACTION_CHAT")
    /// Chat with Hedvig
    internal static let insuranceStatusTerminatedAlertCta = L10n.tr("Localizable", "INSURANCE_STATUS_TERMINATED_ALERT_CTA")
    /// You can write to Hedvig if you want to activate your insurance again
    internal static let insuranceStatusTerminatedAlertMessage = L10n.tr("Localizable", "INSURANCE_STATUS_TERMINATED_ALERT_MESSAGE")
    /// Your insurance is not active
    internal static let insuranceStatusTerminatedAlertTitle = L10n.tr("Localizable", "INSURANCE_STATUS_TERMINATED_ALERT_TITLE")
    /// Home insurance
    internal static let insuranceTypeHomeDefinite = L10n.tr("Localizable", "INSURANCE_TYPE_HOME_DEFINITE")
    /// Travel insurance
    internal static let insuranceTypeTravelDefinite = L10n.tr("Localizable", "INSURANCE_TYPE_TRAVEL_DEFINITE")
    /// Bike
    internal static let itemTypeBike = L10n.tr("Localizable", "ITEM_TYPE_BIKE")
    /// If it is vandalized
    internal static let itemTypeBikeCoveredFour = L10n.tr("Localizable", "ITEM_TYPE_BIKE_COVERED_FOUR")
    /// If it gets stolen
    internal static let itemTypeBikeCoveredOne = L10n.tr("Localizable", "ITEM_TYPE_BIKE_COVERED_ONE")
    /// If you crash your bike
    internal static let itemTypeBikeCoveredThree = L10n.tr("Localizable", "ITEM_TYPE_BIKE_COVERED_THREE")
    /// If you or someone else damages it
    internal static let itemTypeBikeCoveredTwo = L10n.tr("Localizable", "ITEM_TYPE_BIKE_COVERED_TWO")
    /// Damage caused by an other vehicle
    internal static let itemTypeBikeNotCoveredOne = L10n.tr("Localizable", "ITEM_TYPE_BIKE_NOT_COVERED_ONE")
    /// Damage caused by usage over time
    internal static let itemTypeBikeNotCoveredThree = L10n.tr("Localizable", "ITEM_TYPE_BIKE_NOT_COVERED_THREE")
    /// Personal injury caused by an accident
    internal static let itemTypeBikeNotCoveredTwo = L10n.tr("Localizable", "ITEM_TYPE_BIKE_NOT_COVERED_TWO")
    /// Computer
    internal static let itemTypeComputer = L10n.tr("Localizable", "ITEM_TYPE_COMPUTER")
    /// If it gets stolen
    internal static let itemTypeComputerCoveredFive = L10n.tr("Localizable", "ITEM_TYPE_COMPUTER_COVERED_FIVE")
    /// If water damage occurs
    internal static let itemTypeComputerCoveredFour = L10n.tr("Localizable", "ITEM_TYPE_COMPUTER_COVERED_FOUR")
    /// If you drop it on the ground
    internal static let itemTypeComputerCoveredOne = L10n.tr("Localizable", "ITEM_TYPE_COMPUTER_COVERED_ONE")
    /// If you or someone else damages it
    internal static let itemTypeComputerCoveredThree = L10n.tr("Localizable", "ITEM_TYPE_COMPUTER_COVERED_THREE")
    /// If you drop it in water
    internal static let itemTypeComputerCoveredTwo = L10n.tr("Localizable", "ITEM_TYPE_COMPUTER_COVERED_TWO")
    /// If you lose it
    internal static let itemTypeComputerNotCoveredOne = L10n.tr("Localizable", "ITEM_TYPE_COMPUTER_NOT_COVERED_ONE")
    /// Faults that are covered by warranty
    internal static let itemTypeComputerNotCoveredTwo = L10n.tr("Localizable", "ITEM_TYPE_COMPUTER_NOT_COVERED_TWO")
    /// Jewelry
    internal static let itemTypeJewelry = L10n.tr("Localizable", "ITEM_TYPE_JEWELRY")
    /// If it gets stolen
    internal static let itemTypeJewelryCoveredOne = L10n.tr("Localizable", "ITEM_TYPE_JEWELRY_COVERED_ONE")
    /// If you or someone else damages it
    internal static let itemTypeJewelryCoveredTwo = L10n.tr("Localizable", "ITEM_TYPE_JEWELRY_COVERED_TWO")
    /// If you lose it
    internal static let itemTypeJewelryNotCoveredOne = L10n.tr("Localizable", "ITEM_TYPE_JEWELRY_NOT_COVERED_ONE")
    /// Damage caused by wear and tear
    internal static let itemTypeJewelryNotCoveredTwo = L10n.tr("Localizable", "ITEM_TYPE_JEWELRY_NOT_COVERED_TWO")
    /// Phone
    internal static let itemTypePhone = L10n.tr("Localizable", "ITEM_TYPE_PHONE")
    /// If it gets stolen
    internal static let itemTypePhoneCoveredFive = L10n.tr("Localizable", "ITEM_TYPE_PHONE_COVERED_FIVE")
    /// If water damage occurs
    internal static let itemTypePhoneCoveredFour = L10n.tr("Localizable", "ITEM_TYPE_PHONE_COVERED_FOUR")
    /// If you drop it on the ground
    internal static let itemTypePhoneCoveredOne = L10n.tr("Localizable", "ITEM_TYPE_PHONE_COVERED_ONE")
    /// If you or someone else damages it
    internal static let itemTypePhoneCoveredThree = L10n.tr("Localizable", "ITEM_TYPE_PHONE_COVERED_THREE")
    /// If you drop it in water
    internal static let itemTypePhoneCoveredTwo = L10n.tr("Localizable", "ITEM_TYPE_PHONE_COVERED_TWO")
    /// If you lose it
    internal static let itemTypePhoneNotCoveredOne = L10n.tr("Localizable", "ITEM_TYPE_PHONE_NOT_COVERED_ONE")
    /// Faults that are covered by warranty
    internal static let itemTypePhoneNotCoveredTwo = L10n.tr("Localizable", "ITEM_TYPE_PHONE_NOT_COVERED_TWO")
    /// Smartwatch
    internal static let itemTypeSmartWatch = L10n.tr("Localizable", "ITEM_TYPE_SMART_WATCH")
    /// If it gets stolen
    internal static let itemTypeSmartWatchCoveredFive = L10n.tr("Localizable", "ITEM_TYPE_SMART_WATCH_COVERED_FIVE")
    /// If water damage occurs
    internal static let itemTypeSmartWatchCoveredFour = L10n.tr("Localizable", "ITEM_TYPE_SMART_WATCH_COVERED_FOUR")
    /// If you drop it on the ground
    internal static let itemTypeSmartWatchCoveredOne = L10n.tr("Localizable", "ITEM_TYPE_SMART_WATCH_COVERED_ONE")
    /// If you or someone else damages it
    internal static let itemTypeSmartWatchCoveredThree = L10n.tr("Localizable", "ITEM_TYPE_SMART_WATCH_COVERED_THREE")
    /// If you drop it in water
    internal static let itemTypeSmartWatchCoveredTwo = L10n.tr("Localizable", "ITEM_TYPE_SMART_WATCH_COVERED_TWO")
    /// If you lose it
    internal static let itemTypeSmartWatchNotCoveredOne = L10n.tr("Localizable", "ITEM_TYPE_SMART_WATCH_NOT_COVERED_ONE")
    /// Faults that are covered by warranty
    internal static let itemTypeSmartWatchNotCoveredTwo = L10n.tr("Localizable", "ITEM_TYPE_SMART_WATCH_NOT_COVERED_TWO")
    /// Tablet
    internal static let itemTypeTablet = L10n.tr("Localizable", "ITEM_TYPE_TABLET")
    /// If it gets stolen
    internal static let itemTypeTabletCoveredFive = L10n.tr("Localizable", "ITEM_TYPE_TABLET_COVERED_FIVE")
    /// If water damage occurs
    internal static let itemTypeTabletCoveredFour = L10n.tr("Localizable", "ITEM_TYPE_TABLET_COVERED_FOUR")
    /// If you drop it on the ground
    internal static let itemTypeTabletCoveredOne = L10n.tr("Localizable", "ITEM_TYPE_TABLET_COVERED_ONE")
    /// If you or someone else damages it
    internal static let itemTypeTabletCoveredThree = L10n.tr("Localizable", "ITEM_TYPE_TABLET_COVERED_THREE")
    /// If you drop it in water
    internal static let itemTypeTabletCoveredTwo = L10n.tr("Localizable", "ITEM_TYPE_TABLET_COVERED_TWO")
    /// If you lose it
    internal static let itemTypeTabletNotCoveredOne = L10n.tr("Localizable", "ITEM_TYPE_TABLET_NOT_COVERED_ONE")
    /// Faults that are covered by warranty
    internal static let itemTypeTabletNotCoveredTwo = L10n.tr("Localizable", "ITEM_TYPE_TABLET_NOT_COVERED_TWO")
    /// TV
    internal static let itemTypeTv = L10n.tr("Localizable", "ITEM_TYPE_TV")
    /// If its damaged during a move
    internal static let itemTypeTvCoveredFour = L10n.tr("Localizable", "ITEM_TYPE_TV_COVERED_FOUR")
    /// If you or someone else damages it
    internal static let itemTypeTvCoveredOne = L10n.tr("Localizable", "ITEM_TYPE_TV_COVERED_ONE")
    /// Damage caused by fire
    internal static let itemTypeTvCoveredThree = L10n.tr("Localizable", "ITEM_TYPE_TV_COVERED_THREE")
    /// If you have a break-in and someone steals it
    internal static let itemTypeTvCoveredTwo = L10n.tr("Localizable", "ITEM_TYPE_TV_COVERED_TWO")
    /// Faults that are covered by warranty
    internal static let itemTypeTvNotCoveredOne = L10n.tr("Localizable", "ITEM_TYPE_TV_NOT_COVERED_ONE")
    /// Short circuit caused by water
    internal static let itemTypeTvNotCoveredTwo = L10n.tr("Localizable", "ITEM_TYPE_TV_NOT_COVERED_TWO")
    /// Watch
    internal static let itemTypeWatch = L10n.tr("Localizable", "ITEM_TYPE_WATCH")
    /// If it gets stolen
    internal static let itemTypeWatchCoveredOne = L10n.tr("Localizable", "ITEM_TYPE_WATCH_COVERED_ONE")
    /// If you or someone else damages it
    internal static let itemTypeWatchCoveredTwo = L10n.tr("Localizable", "ITEM_TYPE_WATCH_COVERED_TWO")
    /// If you lose it
    internal static let itemTypeWatchNotCoveredOne = L10n.tr("Localizable", "ITEM_TYPE_WATCH_NOT_COVERED_ONE")
    /// Damage caused by wear and tear
    internal static let itemTypeWatchNotCoveredTwo = L10n.tr("Localizable", "ITEM_TYPE_WATCH_NOT_COVERED_TWO")
    /// Add an item
    internal static let keyGearAddButton = L10n.tr("Localizable", "KEY_GEAR_ADD_BUTTON")
    /// Add photo
    internal static let keyGearAddItemAddPhotoButton = L10n.tr("Localizable", "KEY_GEAR_ADD_ITEM_ADD_PHOTO_BUTTON")
    /// The information you entered will not be saved
    internal static let keyGearAddItemPageCloseAlertBody = L10n.tr("Localizable", "KEY_GEAR_ADD_ITEM_PAGE_CLOSE_ALERT_BODY")
    /// Yes, cancel
    internal static let keyGearAddItemPageCloseAlertContinueButton = L10n.tr("Localizable", "KEY_GEAR_ADD_ITEM_PAGE_CLOSE_ALERT_CONTINUE_BUTTON")
    /// No, continue
    internal static let keyGearAddItemPageCloseAlertDismissButton = L10n.tr("Localizable", "KEY_GEAR_ADD_ITEM_PAGE_CLOSE_ALERT_DISMISS_BUTTON")
    /// Are you sure you want to cancel?
    internal static let keyGearAddItemPageCloseAlertTitle = L10n.tr("Localizable", "KEY_GEAR_ADD_ITEM_PAGE_CLOSE_ALERT_TITLE")
    /// Cancel
    internal static let keyGearAddItemPageCloseButton = L10n.tr("Localizable", "KEY_GEAR_ADD_ITEM_PAGE_CLOSE_BUTTON")
    /// Add item
    internal static let keyGearAddItemPageTitle = L10n.tr("Localizable", "KEY_GEAR_ADD_ITEM_PAGE_TITLE")
    /// Save
    internal static let keyGearAddItemSaveButton = L10n.tr("Localizable", "KEY_GEAR_ADD_ITEM_SAVE_BUTTON")
    /// Added %1$@
    internal static func keyGearAddItemSuccess(_ p1: String) -> String {
        return L10n.tr("Localizable", "KEY_GEAR_ADD_ITEM_SUCCESS", p1)
    }

    /// Type of item
    internal static let keyGearAddItemTypeHeadline = L10n.tr("Localizable", "KEY_GEAR_ADD_ITEM_TYPE_HEADLINE")
    /// Enter when you purchased the %1$@ and how much it cost in order to calculate the estimated value
    internal static func keyGearAddPurchaseInfoBody(_ p1: String) -> String {
        return L10n.tr("Localizable", "KEY_GEAR_ADD_PURCHASE_INFO_BODY", p1)
    }

    /// Add purchase info
    internal static let keyGearAddPurchaseInfoPageTitle = L10n.tr("Localizable", "KEY_GEAR_ADD_PURCHASE_INFO_PAGE_TITLE")
    /// Purchase price
    internal static let keyGearAddPurchasePriceCellTitle = L10n.tr("Localizable", "KEY_GEAR_ADD_PURCHASE_PRICE_CELL_TITLE")
    /// Auto added
    internal static let keyGearAddedAutomaticallyTag = L10n.tr("Localizable", "KEY_GEAR_ADDED_AUTOMATICALLY_TAG")
    /// Camera
    internal static let keyGearImagePickerCamera = L10n.tr("Localizable", "KEY_GEAR_IMAGE_PICKER_CAMERA")
    /// Cancel
    internal static let keyGearImagePickerCancel = L10n.tr("Localizable", "KEY_GEAR_IMAGE_PICKER_CANCEL")
    /// Document
    internal static let keyGearImagePickerDocument = L10n.tr("Localizable", "KEY_GEAR_IMAGE_PICKER_DOCUMENT")
    /// Photo library
    internal static let keyGearImagePickerPhotoLibrary = L10n.tr("Localizable", "KEY_GEAR_IMAGE_PICKER_PHOTO_LIBRARY")
    /// Delete
    internal static let keyGearItemDelete = L10n.tr("Localizable", "KEY_GEAR_ITEM_DELETE")
    /// Cancel
    internal static let keyGearItemOptionsCancel = L10n.tr("Localizable", "KEY_GEAR_ITEM_OPTIONS_CANCEL")
    /// Enter when you purchased the %1$@ and how much it cost in order to calculate the estimated value
    internal static func keyGearItemViewAddPurchaseDateBody(_ p1: String) -> String {
        return L10n.tr("Localizable", "KEY_GEAR_ITEM_VIEW_ADD_PURCHASE_DATE_BODY", p1)
    }

    /// Save
    internal static let keyGearItemViewAddPurchaseDateButton = L10n.tr("Localizable", "KEY_GEAR_ITEM_VIEW_ADD_PURCHASE_DATE_BUTTON")
    /// Add purchase info
    internal static let keyGearItemViewAddPurchaseDatePageTitle = L10n.tr("Localizable", "KEY_GEAR_ITEM_VIEW_ADD_PURCHASE_DATE_PAGE_TITLE")
    /// Your insurance covers
    internal static let keyGearItemViewCoverageTableTitle = L10n.tr("Localizable", "KEY_GEAR_ITEM_VIEW_COVERAGE_TABLE_TITLE")
    /// SEK
    internal static let keyGearItemViewDeductibleCurrency = L10n.tr("Localizable", "KEY_GEAR_ITEM_VIEW_DEDUCTIBLE_CURRENCY")
    /// Deductible
    internal static let keyGearItemViewDeductibleTitle = L10n.tr("Localizable", "KEY_GEAR_ITEM_VIEW_DEDUCTIBLE_TITLE")
    /// 1 500
    internal static let keyGearItemViewDeductibleValue = L10n.tr("Localizable", "KEY_GEAR_ITEM_VIEW_DEDUCTIBLE_VALUE")
    /// Edit
    internal static let keyGearItemViewItemNameEditButton = L10n.tr("Localizable", "KEY_GEAR_ITEM_VIEW_ITEM_NAME_EDIT_BUTTON")
    /// Save
    internal static let keyGearItemViewItemNameSaveButton = L10n.tr("Localizable", "KEY_GEAR_ITEM_VIEW_ITEM_NAME_SAVE_BUTTON")
    /// Item name
    internal static let keyGearItemViewItemNameTableTitle = L10n.tr("Localizable", "KEY_GEAR_ITEM_VIEW_ITEM_NAME_TABLE_TITLE")
    /// Your insurance does not cover
    internal static let keyGearItemViewNonCoverageTableTitle = L10n.tr("Localizable", "KEY_GEAR_ITEM_VIEW_NON_COVERAGE_TABLE_TITLE")
    /// Add +
    internal static let keyGearItemViewReceiptCellAddButton = L10n.tr("Localizable", "KEY_GEAR_ITEM_VIEW_RECEIPT_CELL_ADD_BUTTON")
    /// Receipt
    internal static let keyGearItemViewReceiptCellTitle = L10n.tr("Localizable", "KEY_GEAR_ITEM_VIEW_RECEIPT_CELL_TITLE")
    /// Show
    internal static let keyGearItemViewReceiptShow = L10n.tr("Localizable", "KEY_GEAR_ITEM_VIEW_RECEIPT_SHOW")
    /// You don't have to add the receipt, it can just be nice to know where it is.
    internal static let keyGearItemViewReceiptTableFooter = L10n.tr("Localizable", "KEY_GEAR_ITEM_VIEW_RECEIPT_TABLE_FOOTER")
    /// Receipt
    internal static let keyGearItemViewReceiptTableTitle = L10n.tr("Localizable", "KEY_GEAR_ITEM_VIEW_RECEIPT_TABLE_TITLE")
    /// We deduct the value with a certain percentage based on how long since you purchased the %1$@
    internal static func keyGearItemViewValuationAgeDeductionBody(_ p1: String) -> String {
        return L10n.tr("Localizable", "KEY_GEAR_ITEM_VIEW_VALUATION_AGE_DEDUCTION_BODY", p1)
    }

    /// Expand
    internal static let keyGearItemViewValuationAgeDeductionTableExpandButton = L10n.tr("Localizable", "KEY_GEAR_ITEM_VIEW_VALUATION_AGE_DEDUCTION_TABLE_EXPAND_BUTTON")
    /// Age deduction
    internal static let keyGearItemViewValuationAgeDeductionTitle = L10n.tr("Localizable", "KEY_GEAR_ITEM_VIEW_VALUATION_AGE_DEDUCTION_TITLE")
    /// We first try to repair your %1$@, but if it needs to be replaced (e.g. if it was stolen) you will be compensated **%2$@%%** of the purchase price **%3$@ SEK**, i.e **%4$@ SEK**.
    internal static func keyGearItemViewValuationBody(_ p1: String, _ p2: String, _ p3: String, _ p4: String) -> String {
        return L10n.tr("Localizable", "KEY_GEAR_ITEM_VIEW_VALUATION_BODY", p1, p2, p3, p4)
    }

    /// Add purchase info +
    internal static let keyGearItemViewValuationEmpty = L10n.tr("Localizable", "KEY_GEAR_ITEM_VIEW_VALUATION_EMPTY")
    /// We first try to repair your %1$@, but if it needs to be replaced (e.g. if it was stolen) you will be compensated by **%2$li%%** of its current market value.
    internal static func keyGearItemViewValuationMarketBody(_ p1: String, _ p2: Int) -> String {
        return L10n.tr("Localizable", "KEY_GEAR_ITEM_VIEW_VALUATION_MARKET_BODY", p1, p2)
    }

    /// of the market value
    internal static let keyGearItemViewValuationMarketDescription = L10n.tr("Localizable", "KEY_GEAR_ITEM_VIEW_VALUATION_MARKET_DESCRIPTION")
    /// Valuation
    internal static let keyGearItemViewValuationPageTitle = L10n.tr("Localizable", "KEY_GEAR_ITEM_VIEW_VALUATION_PAGE_TITLE")
    /// of the purchase price
    internal static let keyGearItemViewValuationPercentageLabel = L10n.tr("Localizable", "KEY_GEAR_ITEM_VIEW_VALUATION_PERCENTAGE_LABEL")
    /// Valued at
    internal static let keyGearItemViewValuationTitle = L10n.tr("Localizable", "KEY_GEAR_ITEM_VIEW_VALUATION_TITLE")
    /// In Key Gear you can add information about your most important things. You input information about what type of item it is and when you bought it, and you'll get detailed information about the exact coverage and the estimated valuation if something were to happen to it. You don't have to add your things – they are of course covered whether you add them to Key Gear or not.
    internal static let keyGearMoreInfoBody = L10n.tr("Localizable", "KEY_GEAR_MORE_INFO_BODY")
    /// More info
    internal static let keyGearMoreInfoButton = L10n.tr("Localizable", "KEY_GEAR_MORE_INFO_BUTTON")
    /// This is Your things
    internal static let keyGearMoreInfoHeadline = L10n.tr("Localizable", "KEY_GEAR_MORE_INFO_HEADLINE")
    /// Observe that your %1$@ is more expensive than what your all-risk covers, we recommend that you contact us through the chat to purchase extra insurance coverage for this %1$@.
    internal static func keyGearNotCovered(_ p1: String) -> String {
        return L10n.tr("Localizable", "KEY_GEAR_NOT_COVERED", p1)
    }

    /// Close
    internal static let keyGearRecceiptViewCloseButton = L10n.tr("Localizable", "KEY_GEAR_RECCEIPT_VIEW_CLOSE_BUTTON")
    /// Receipt
    internal static let keyGearRecceiptViewPageTitle = L10n.tr("Localizable", "KEY_GEAR_RECCEIPT_VIEW_PAGE_TITLE")
    /// Share
    internal static let keyGearRecceiptViewShareButton = L10n.tr("Localizable", "KEY_GEAR_RECCEIPT_VIEW_SHARE_BUTTON")
    /// Upload receipt
    internal static let keyGearReceiptUploadSheetTitle = L10n.tr("Localizable", "KEY_GEAR_RECEIPT_UPLOAD_SHEET_TITLE")
    /// Report claim
    internal static let keyGearReportClaimRow = L10n.tr("Localizable", "KEY_GEAR_REPORT_CLAIM_ROW")
    /// Sometimes we damage or lose our things. Simply log your things with us so you can make a claim with just a click, and see how they're covered and what you'll recieve if you have to make a claim.
    internal static let keyGearStartEmptyBody = L10n.tr("Localizable", "KEY_GEAR_START_EMPTY_BODY")
    /// Get an overview of your things
    internal static let keyGearStartEmptyHeadline = L10n.tr("Localizable", "KEY_GEAR_START_EMPTY_HEADLINE")
    /// Your things
    internal static let keyGearTabTitle = L10n.tr("Localizable", "KEY_GEAR_TAB_TITLE")
    /// Cancel
    internal static let keyGearYearmonthPickerNegAction = L10n.tr("Localizable", "KEY_GEAR_YEARMONTH_PICKER_NEG_ACTION")
    /// OK
    internal static let keyGearYearmonthPickerPosAction = L10n.tr("Localizable", "KEY_GEAR_YEARMONTH_PICKER_POS_ACTION")
    /// Purchase Date
    internal static let keyGearYearmonthPickerTitle = L10n.tr("Localizable", "KEY_GEAR_YEARMONTH_PICKER_TITLE")
    /// Search for something to show gifs
    internal static let labelSearchGif = L10n.tr("Localizable", "LABEL_SEARCH_GIF")
    // TODO:
    internal static let latePaymentMessage = L10n.tr("Localizable", "LATE_PAYMENT_MESSAGE")
    /// License-rights
    internal static let licensesScreenTitle = L10n.tr("Localizable", "LICENSES_SCREEN_TITLE")
    /// Cancel
    internal static let logoutAlertActionCancel = L10n.tr("Localizable", "LOGOUT_ALERT_ACTION_CANCEL")
    /// Yes
    internal static let logoutAlertActionConfirm = L10n.tr("Localizable", "LOGOUT_ALERT_ACTION_CONFIRM")
    /// Are you sure you want to log out?
    internal static let logoutAlertTitle = L10n.tr("Localizable", "LOGOUT_ALERT_TITLE")
    /// Log out
    internal static let logoutButton = L10n.tr("Localizable", "LOGOUT_BUTTON")
    /// OK
    internal static let mailViewCantSendAlertButton = L10n.tr("Localizable", "MAIL_VIEW_CANT_SEND_ALERT_BUTTON")
    /// You have not set up an email account in the Mail app yet, you must do that before you can email us.
    internal static let mailViewCantSendAlertMessage = L10n.tr("Localizable", "MAIL_VIEW_CANT_SEND_ALERT_MESSAGE")
    /// Unable to open Mail
    internal static let mailViewCantSendAlertTitle = L10n.tr("Localizable", "MAIL_VIEW_CANT_SEND_ALERT_TITLE")
    /// Pick language
    internal static let marketPickerLanguageTitle = L10n.tr("Localizable", "MARKET_PICKER_LANGUAGE_TITLE")
    /// Select your country of residence
    internal static let marketPickerTitle = L10n.tr("Localizable", "MARKET_PICKER_TITLE")
    /// Get Hedvig
    internal static let marketingGetHedvig = L10n.tr("Localizable", "MARKETING_GET_HEDVIG")
    /// © Hedvig AB. Exclusive insurer for Hedvig's insurance is HDI Global Specialty SE, org. nr. 516402-6345. Hedvig is regulated by the Swedish Financial Supervisory Authority.
    internal static let marketingLegal = L10n.tr("Localizable", "MARKETING_LEGAL")
    /// Already a member? Log in
    internal static let marketingLogin = L10n.tr("Localizable", "MARKETING_LOGIN")
    /// Hedvig
    internal static let marketingLogoAccessibility = L10n.tr("Localizable", "MARKETING_LOGO_ACCESSIBILITY")
    /// Say hello to Hedvig!
    internal static let marketingScreenSayHello = L10n.tr("Localizable", "MARKETING_SCREEN_SAY_HELLO")
    /// 1 million kr
    internal static let maxCompensation = L10n.tr("Localizable", "MAX_COMPENSATION")
    /// 1.5 million kr
    internal static let maxCompensationHouse = L10n.tr("Localizable", "MAX_COMPENSATION_HOUSE")
    /// 200 000 kr
    internal static let maxCompensationStudent = L10n.tr("Localizable", "MAX_COMPENSATION_STUDENT")
    /// Moderna Insurance
    internal static let modernaForsakringApp = L10n.tr("Localizable", "MODERNA_FORSAKRING_APP")
    /// My charity
    internal static let myCharityScreenTitle = L10n.tr("Localizable", "MY_CHARITY_SCREEN_TITLE")
    /// We are working on additional functionality for co-insured, in the future all your co-insured will be able to access the app and you will be able to add and remove them freely.\n\nHave more ideas on neat features you wanna see in the app? Write to us in the chat!
    internal static let myCoinsuredComingSoonBody = L10n.tr("Localizable", "MY_COINSURED_COMING_SOON_BODY")
    /// Coming soon!
    internal static let myCoinsuredComingSoonTitle = L10n.tr("Localizable", "MY_COINSURED_COMING_SOON_TITLE")
    /// Insured
    internal static let myCoinsuredScreenCircleSublabel = L10n.tr("Localizable", "MY_COINSURED_SCREEN_CIRCLE_SUBLABEL")
    /// My co-insured
    internal static let myCoinsuredTitle = L10n.tr("Localizable", "MY_COINSURED_TITLE")
    /// Insurance certificate ↗
    internal static let myDocumentsInsuranceCertificate = L10n.tr("Localizable", "MY_DOCUMENTS_INSURANCE_CERTIFICATE")
    /// Full terms and conditions ↗
    internal static let myDocumentsInsuranceTerms = L10n.tr("Localizable", "MY_DOCUMENTS_INSURANCE_TERMS")
    /// Address
    internal static let myHomeAddressRowKey = L10n.tr("Localizable", "MY_HOME_ADDRESS_ROW_KEY")
    /// %1$@, connected to main water
    internal static func myHomeBuildingHasWaterSuffix(_ p1: String) -> String {
        return L10n.tr("Localizable", "MY_HOME_BUILDING_HAS_WATER_SUFFIX", p1)
    }

    /// Cancel
    internal static let myHomeChangeAlertActionCancel = L10n.tr("Localizable", "MY_HOME_CHANGE_ALERT_ACTION_CANCEL")
    /// Write to Hedvig
    internal static let myHomeChangeAlertActionConfirm = L10n.tr("Localizable", "MY_HOME_CHANGE_ALERT_ACTION_CONFIRM")
    /// Write to Hedvig in the chat and you'll get help right away!
    internal static let myHomeChangeAlertMessage = L10n.tr("Localizable", "MY_HOME_CHANGE_ALERT_MESSAGE")
    /// Do you want to change your insurance?
    internal static let myHomeChangeAlertTitle = L10n.tr("Localizable", "MY_HOME_CHANGE_ALERT_TITLE")
    /// Change details
    internal static let myHomeChangeInfoButton = L10n.tr("Localizable", "MY_HOME_CHANGE_INFO_BUTTON")
    /// City
    internal static let myHomeCityLabel = L10n.tr("Localizable", "MY_HOME_CITY_LABEL")
    /// Other buildings
    internal static let myHomeExtrabuildingTitle = L10n.tr("Localizable", "MY_HOME_EXTRABUILDING_TITLE")
    /// House
    internal static let myHomeInsuranceTypeHouse = L10n.tr("Localizable", "MY_HOME_INSURANCE_TYPE_HOUSE")
    /// Ancillary area
    internal static let myHomeRowAncillaryAreaKey = L10n.tr("Localizable", "MY_HOME_ROW_ANCILLARY_AREA_KEY")
    /// %1$@ sqm
    internal static func myHomeRowAncillaryAreaValue(_ p1: String) -> String {
        return L10n.tr("Localizable", "MY_HOME_ROW_ANCILLARY_AREA_VALUE", p1)
    }

    /// No. of bathrooms
    internal static let myHomeRowBathroomsKey = L10n.tr("Localizable", "MY_HOME_ROW_BATHROOMS_KEY")
    /// Year of construction
    internal static let myHomeRowConstructionYearKey = L10n.tr("Localizable", "MY_HOME_ROW_CONSTRUCTION_YEAR_KEY")
    /// Postal code
    internal static let myHomeRowPostalCodeKey = L10n.tr("Localizable", "MY_HOME_ROW_POSTAL_CODE_KEY")
    /// Living space
    internal static let myHomeRowSizeKey = L10n.tr("Localizable", "MY_HOME_ROW_SIZE_KEY")
    /// %1$@ sqm
    internal static func myHomeRowSizeValue(_ p1: String) -> String {
        return L10n.tr("Localizable", "MY_HOME_ROW_SIZE_VALUE", p1)
    }

    /// Partly subleted?
    internal static let myHomeRowSubletedKey = L10n.tr("Localizable", "MY_HOME_ROW_SUBLETED_KEY")
    /// No
    internal static let myHomeRowSubletedValueNo = L10n.tr("Localizable", "MY_HOME_ROW_SUBLETED_VALUE_NO")
    /// Yes
    internal static let myHomeRowSubletedValueYes = L10n.tr("Localizable", "MY_HOME_ROW_SUBLETED_VALUE_YES")
    /// Condominium
    internal static let myHomeRowTypeCondominiumValue = L10n.tr("Localizable", "MY_HOME_ROW_TYPE_CONDOMINIUM_VALUE")
    /// House
    internal static let myHomeRowTypeHouseValue = L10n.tr("Localizable", "MY_HOME_ROW_TYPE_HOUSE_VALUE")
    /// Type of housing
    internal static let myHomeRowTypeKey = L10n.tr("Localizable", "MY_HOME_ROW_TYPE_KEY")
    /// Rental
    internal static let myHomeRowTypeRentalValue = L10n.tr("Localizable", "MY_HOME_ROW_TYPE_RENTAL_VALUE")
    /// Residence
    internal static let myHomeSectionTitle = L10n.tr("Localizable", "MY_HOME_SECTION_TITLE")
    /// My home
    internal static let myHomeTitle = L10n.tr("Localizable", "MY_HOME_TITLE")
    /// OK
    internal static let myInfoAlertSaveFailureButton = L10n.tr("Localizable", "MY_INFO_ALERT_SAVE_FAILURE_BUTTON")
    /// Couldn't save
    internal static let myInfoAlertSaveFailureTitle = L10n.tr("Localizable", "MY_INFO_ALERT_SAVE_FAILURE_TITLE")
    /// No
    internal static let myInfoCancelAlertButtonCancel = L10n.tr("Localizable", "MY_INFO_CANCEL_ALERT_BUTTON_CANCEL")
    /// Yes
    internal static let myInfoCancelAlertButtonConfirm = L10n.tr("Localizable", "MY_INFO_CANCEL_ALERT_BUTTON_CONFIRM")
    /// Your changes will be lost
    internal static let myInfoCancelAlertMessage = L10n.tr("Localizable", "MY_INFO_CANCEL_ALERT_MESSAGE")
    /// Are you sure?
    internal static let myInfoCancelAlertTitle = L10n.tr("Localizable", "MY_INFO_CANCEL_ALERT_TITLE")
    /// Cancel
    internal static let myInfoCancelButton = L10n.tr("Localizable", "MY_INFO_CANCEL_BUTTON")
    /// Contact details
    internal static let myInfoContactDetailsTitle = L10n.tr("Localizable", "MY_INFO_CONTACT_DETAILS_TITLE")
    /// You forgot to enter your email
    internal static let myInfoEmailEmptyError = L10n.tr("Localizable", "MY_INFO_EMAIL_EMPTY_ERROR")
    /// The entered email address doesn't seem correct
    internal static let myInfoEmailMalformedError = L10n.tr("Localizable", "MY_INFO_EMAIL_MALFORMED_ERROR")
    /// You have not entered a phone number
    internal static let myInfoPhoneNumberEmptyError = L10n.tr("Localizable", "MY_INFO_PHONE_NUMBER_EMPTY_ERROR")
    /// Check that the phone number you've entered is correct
    internal static let myInfoPhoneNumberMalformedError = L10n.tr("Localizable", "MY_INFO_PHONE_NUMBER_MALFORMED_ERROR")
    /// Save
    internal static let myInfoSaveButton = L10n.tr("Localizable", "MY_INFO_SAVE_BUTTON")
    /// My info
    internal static let myInfoTitle = L10n.tr("Localizable", "MY_INFO_TITLE")
    /// My insurance letter
    internal static let myInsuranceCertificateTitle = L10n.tr("Localizable", "MY_INSURANCE_CERTIFICATE_TITLE")
    /// Bank
    internal static let myPaymentBankRowLabel = L10n.tr("Localizable", "MY_PAYMENT_BANK_ROW_LABEL")
    ///
    internal static let myPaymentCardRowLabel = L10n.tr("Localizable", "MY_PAYMENT_CARD_ROW_LABEL")
    /// Change credit card
    internal static let myPaymentChangeCreditCardButton = L10n.tr("Localizable", "MY_PAYMENT_CHANGE_CREDIT_CARD_BUTTON")
    /// Next payment is debited on %1$@
    internal static func myPaymentDate(_ p1: String) -> String {
        return L10n.tr("Localizable", "MY_PAYMENT_DATE", p1)
    }

    /// Deductible 1500 kr
    internal static let myPaymentDeductibleCircle = L10n.tr("Localizable", "MY_PAYMENT_DEDUCTIBLE_CIRCLE")
    /// Connect bank account
    internal static let myPaymentDirectDebitButton = L10n.tr("Localizable", "MY_PAYMENT_DIRECT_DEBIT_BUTTON")
    /// Change bank account
    internal static let myPaymentDirectDebitReplaceButton = L10n.tr("Localizable", "MY_PAYMENT_DIRECT_DEBIT_REPLACE_BUTTON")
    /// Free until
    internal static let myPaymentFreeUntilMessage = L10n.tr("Localizable", "MY_PAYMENT_FREE_UNTIL_MESSAGE")
    /// Not connected
    internal static let myPaymentNotConnected = L10n.tr("Localizable", "MY_PAYMENT_NOT_CONNECTED")
    /// Price
    internal static let myPaymentPaymentRowLabel = L10n.tr("Localizable", "MY_PAYMENT_PAYMENT_ROW_LABEL")
    /// My payment
    internal static let myPaymentTitle = L10n.tr("Localizable", "MY_PAYMENT_TITLE")
    /// Direct debit
    internal static let myPaymentType = L10n.tr("Localizable", "MY_PAYMENT_TYPE")
    /// You have just added or changed your bank account, your new bank account will appear here after your bank has accepted autogiro. Usually within 2 working days.
    internal static let myPaymentUpdatingMessage = L10n.tr("Localizable", "MY_PAYMENT_UPDATING_MESSAGE")
    /// Cancel
    internal static let networkErrorAlertCancelAction = L10n.tr("Localizable", "NETWORK_ERROR_ALERT_CANCEL_ACTION")
    /// We couldn't reach Hedvig right now, are you sure you have an internet connection?
    internal static let networkErrorAlertMessage = L10n.tr("Localizable", "NETWORK_ERROR_ALERT_MESSAGE")
    /// Network Error
    internal static let networkErrorAlertTitle = L10n.tr("Localizable", "NETWORK_ERROR_ALERT_TITLE")
    /// Retry
    internal static let networkErrorAlertTryAgainAction = L10n.tr("Localizable", "NETWORK_ERROR_ALERT_TRY_AGAIN_ACTION")
    /// Explore the app and invite
    internal static let newMemberDismiss = L10n.tr("Localizable", "NEW_MEMBER_DISMISS")
    /// Next
    internal static let newMemberProceed = L10n.tr("Localizable", "NEW_MEMBER_PROCEED")
    /// Close
    internal static let newsCloseDescription = L10n.tr("Localizable", "NEWS_CLOSE_DESCRIPTION")
    /// Go to app
    internal static let newsDismiss = L10n.tr("Localizable", "NEWS_DISMISS")
    /// Next
    internal static let newsProceed = L10n.tr("Localizable", "NEWS_PROCEED")
    /// What's new?
    internal static let newsTitle = L10n.tr("Localizable", "NEWS_TITLE")
    /// Condominium
    internal static let norweigianHomeContentLobOwn = L10n.tr("Localizable", "NORWEIGIAN_HOME_CONTENT_LOB_OWN")
    /// Rental
    internal static let norweigianHomeContentLobRent = L10n.tr("Localizable", "NORWEIGIAN_HOME_CONTENT_LOB_RENT")
    /// Student condominium
    internal static let norweigianHomeContentLobStudentOwn = L10n.tr("Localizable", "NORWEIGIAN_HOME_CONTENT_LOB_STUDENT_OWN")
    /// Rental, student
    internal static let norweigianHomeContentLobStudentRent = L10n.tr("Localizable", "NORWEIGIAN_HOME_CONTENT_LOB_STUDENT_RENT")
    /// Discount
    internal static let offerAddDiscountButton = L10n.tr("Localizable", "OFFER_ADD_DISCOUNT_BUTTON")
    /// We know how important a home is. Therefore, we offer very good coverage for it, so that you can feel safe at all times.
    internal static let offerApartmentProtectionDescription = L10n.tr("Localizable", "OFFER_APARTMENT_PROTECTION_DESCRIPTION")
    /// %1$@
    internal static func offerApartmentProtectionTitle(_ p1: String) -> String {
        return L10n.tr("Localizable", "OFFER_APARTMENT_PROTECTION_TITLE", p1)
    }

    /// Sign
    internal static let offerBankidSignButton = L10n.tr("Localizable", "OFFER_BANKID_SIGN_BUTTON")
    /// No, that's not how Hedvig works
    internal static let offerBubblesBindingPeriodSubtitle = L10n.tr("Localizable", "OFFER_BUBBLES_BINDING_PERIOD_SUBTITLE")
    /// Contract length
    internal static let offerBubblesBindingPeriodTitle = L10n.tr("Localizable", "OFFER_BUBBLES_BINDING_PERIOD_TITLE")
    /// 1500 kr
    internal static let offerBubblesDeductibleSubtitle = L10n.tr("Localizable", "OFFER_BUBBLES_DEDUCTIBLE_SUBTITLE")
    /// Deductible
    internal static let offerBubblesDeductibleTitle = L10n.tr("Localizable", "OFFER_BUBBLES_DEDUCTIBLE_TITLE")
    /// %1$@ persons
    internal static func offerBubblesInsuredSubtitle(_ p1: String) -> String {
        return L10n.tr("Localizable", "OFFER_BUBBLES_INSURED_SUBTITLE", p1)
    }

    /// Insured
    internal static let offerBubblesInsuredTitle = L10n.tr("Localizable", "OFFER_BUBBLES_INSURED_TITLE")
    /// Supplemental apartment insurance included
    internal static let offerBubblesOwnedAddonTitle = L10n.tr("Localizable", "OFFER_BUBBLES_OWNED_ADDON_TITLE")
    /// Change
    internal static let offerBubblesStartDateChangeButton = L10n.tr("Localizable", "OFFER_BUBBLES_START_DATE_CHANGE_BUTTON")
    /// Choose date
    internal static let offerBubblesStartDateChangeConfirm = L10n.tr("Localizable", "OFFER_BUBBLES_START_DATE_CHANGE_CONFIRM")
    /// Which day would you like to start your insurance?
    internal static let offerBubblesStartDateChangeHeading = L10n.tr("Localizable", "OFFER_BUBBLES_START_DATE_CHANGE_HEADING")
    /// Activate today
    internal static let offerBubblesStartDateChangeResetNew = L10n.tr("Localizable", "OFFER_BUBBLES_START_DATE_CHANGE_RESET_NEW")
    /// When my contract expires
    internal static let offerBubblesStartDateChangeResetSwitcher = L10n.tr("Localizable", "OFFER_BUBBLES_START_DATE_CHANGE_RESET_SWITCHER")
    /// Change start date
    internal static let offerBubblesStartDateChangeTitle = L10n.tr("Localizable", "OFFER_BUBBLES_START_DATE_CHANGE_TITLE")
    /// today
    internal static let offerBubblesStartDateSubtitleNew = L10n.tr("Localizable", "OFFER_BUBBLES_START_DATE_SUBTITLE_NEW")
    /// As soon as your contract is over
    internal static let offerBubblesStartDateSubtitleSwitcher = L10n.tr("Localizable", "OFFER_BUBBLES_START_DATE_SUBTITLE_SWITCHER")
    /// Start date
    internal static let offerBubblesStartDateTitle = L10n.tr("Localizable", "OFFER_BUBBLES_START_DATE_TITLE")
    /// Travel Insurance included
    internal static let offerBubblesTravelProtectionTitle = L10n.tr("Localizable", "OFFER_BUBBLES_TRAVEL_PROTECTION_TITLE")
    /// Open the chat
    internal static let offerChatAccessibilityHint = L10n.tr("Localizable", "OFFER_CHAT_ACCESSIBILITY_HINT")
    /// Speak with Hedvig
    internal static let offerChatHeader = L10n.tr("Localizable", "OFFER_CHAT_HEADER")
    /// Get Hedvig by clicking the button below and signing with BankID.
    internal static let offerGetHedvigBody = L10n.tr("Localizable", "OFFER_GET_HEDVIG_BODY")
    /// Get Hedvig
    internal static let offerGetHedvigTitle = L10n.tr("Localizable", "OFFER_GET_HEDVIG_TITLE")
    /// Expand
    internal static let offerHouseSummaryButtonExpand = L10n.tr("Localizable", "OFFER_HOUSE_SUMMARY_BUTTON_EXPAND")
    /// Minimize
    internal static let offerHouseSummaryButtonMinimize = L10n.tr("Localizable", "OFFER_HOUSE_SUMMARY_BUTTON_MINIMIZE")
    /// Here's a quick overview of the information you've given us about your home.
    internal static let offerHouseSummaryDesc = L10n.tr("Localizable", "OFFER_HOUSE_SUMMARY_DESC")
    /// %1$@
    internal static func offerHouseSummaryTitle(_ p1: String) -> String {
        return L10n.tr("Localizable", "OFFER_HOUSE_SUMMARY_TITLE", p1)
    }

    /// Hedvig is backed by HDI, part of one of the world's largest insurance groups
    internal static let offerHouseTrustHdi = L10n.tr("Localizable", "OFFER_HOUSE_TRUST_HDI")
    /// Your house is insured full value
    internal static let offerHouseTrustHouse = L10n.tr("Localizable", "OFFER_HOUSE_TRUST_HOUSE")
    /// The insurance offer is valid until %1$@
    internal static func offerInfoOfferExpires(_ p1: String) -> String {
        return L10n.tr("Localizable", "OFFER_INFO_OFFER_EXPIRES", p1)
    }

    /// You are safe with us
    internal static let offerInfoTrustus = L10n.tr("Localizable", "OFFER_INFO_TRUSTUS")
    /// Contact your current insurer and terminate your home insurance. Write to us in the chat and tell us when your current insurance policy expires
    internal static let offerNonSwitchableParagraphOneApp = L10n.tr("Localizable", "OFFER_NON_SWITCHABLE_PARAGRAPH_ONE_APP")
    /// Press the icons for more information
    internal static let offerPerilsExplainer = L10n.tr("Localizable", "OFFER_PERILS_EXPLAINER")
    /// Hedvig protects you from unexpected things happen that at home, and also when things go wrong when you are traveling.
    internal static let offerPersonalProtectionDescription = L10n.tr("Localizable", "OFFER_PERSONAL_PROTECTION_DESCRIPTION")
    /// You
    internal static let offerPersonalProtectionTitle = L10n.tr("Localizable", "OFFER_PERSONAL_PROTECTION_TITLE")
    /// Pre-sale information
    internal static let offerPresaleInformation = L10n.tr("Localizable", "OFFER_PRESALE_INFORMATION")
    /// kr/per month
    internal static let offerPriceBubbleMonth = L10n.tr("Localizable", "OFFER_PRICE_BUBBLE_MONTH")
    /// kr/month
    internal static let offerPricePerMonth = L10n.tr("Localizable", "OFFER_PRICE_PER_MONTH")
    /// Personal Data Policy
    internal static let offerPrivacyPolicy = L10n.tr("Localizable", "OFFER_PRIVACY_POLICY")
    /// Cancel
    internal static let offerRemoveDiscountAlertCancel = L10n.tr("Localizable", "OFFER_REMOVE_DISCOUNT_ALERT_CANCEL")
    /// Are you sure you want to remove the discount code?
    internal static let offerRemoveDiscountAlertDescription = L10n.tr("Localizable", "OFFER_REMOVE_DISCOUNT_ALERT_DESCRIPTION")
    /// Remove
    internal static let offerRemoveDiscountAlertRemove = L10n.tr("Localizable", "OFFER_REMOVE_DISCOUNT_ALERT_REMOVE")
    /// Remove discount code?
    internal static let offerRemoveDiscountAlertTitle = L10n.tr("Localizable", "OFFER_REMOVE_DISCOUNT_ALERT_TITLE")
    /// Remove discount
    internal static let offerRemoveDiscountButton = L10n.tr("Localizable", "OFFER_REMOVE_DISCOUNT_BUTTON")
    /// Hedvig's home insurance offers a good coverage for your apartment, your things and you and your familiy while you're on holiday.
    internal static let offerScreenCoverageBodyBrf = L10n.tr("Localizable", "OFFER_SCREEN_COVERAGE_BODY_BRF")
    /// Hedvig's home insurance offer a good coverage for your house, your things and you and your family while you're on holiday.
    internal static let offerScreenCoverageBodyHouse = L10n.tr("Localizable", "OFFER_SCREEN_COVERAGE_BODY_HOUSE")
    /// Hedvig's home insurance offer a good coverage for your house, your things and you and your family while you're on holiday.
    internal static let offerScreenCoverageBodyRental = L10n.tr("Localizable", "OFFER_SCREEN_COVERAGE_BODY_RENTAL")
    /// The coverage
    internal static let offerScreenCoverageTitle = L10n.tr("Localizable", "OFFER_SCREEN_COVERAGE_TITLE")
    /// %1$li months free!
    internal static func offerScreenFreeMonthsBubble(_ p1: Int) -> String {
        return L10n.tr("Localizable", "OFFER_SCREEN_FREE_MONTHS_BUBBLE", p1)
    }

    /// Discount!
    internal static let offerScreenFreeMonthsBubbleTitle = L10n.tr("Localizable", "OFFER_SCREEN_FREE_MONTHS_BUBBLE_TITLE")
    /// Your information
    internal static let offerScreenInformationTitle = L10n.tr("Localizable", "OFFER_SCREEN_INFORMATION_TITLE")
    /// More information
    internal static let offerScreenInsuredAmountsTitle = L10n.tr("Localizable", "OFFER_SCREEN_INSURED_AMOUNTS_TITLE")
    /// Invited!
    internal static let offerScreenInvitedBubble = L10n.tr("Localizable", "OFFER_SCREEN_INVITED_BUBBLE")
    /// Discount!
    internal static let offerScreenPercentageDiscountBubbleTitle = L10n.tr("Localizable", "OFFER_SCREEN_PERCENTAGE_DISCOUNT_BUBBLE_TITLE")
    /// %1$li%% for %2$li months
    internal static func offerScreenPercentageDiscountBubbleTitlePlural(_ p1: Int, _ p2: Int) -> String {
        return L10n.tr("Localizable", "OFFER_SCREEN_PERCENTAGE_DISCOUNT_BUBBLE_TITLE_PLURAL", p1, p2)
    }

    /// %1$li%% for one month
    internal static func offerScreenPercentageDiscountBubbleTitleSingular(_ p1: Int) -> String {
        return L10n.tr("Localizable", "OFFER_SCREEN_PERCENTAGE_DISCOUNT_BUBBLE_TITLE_SINGULAR", p1)
    }

    /// The insurance covers
    internal static let offerScreenPerilSectionTitle = L10n.tr("Localizable", "OFFER_SCREEN_PERIL_SECTION_TITLE")
    /// Hedvig offer Sweden's only home insurance without a binding contract
    internal static let offerScreenUspOneBody = L10n.tr("Localizable", "OFFER_SCREEN_USP_ONE_BODY")
    /// Free to stay, free to leave
    internal static let offerScreenUspOneTitle = L10n.tr("Localizable", "OFFER_SCREEN_USP_ONE_TITLE")
    /// All-risk insurance is always included with Hedvig at no extra cost
    internal static let offerScreenUspThreeBody = L10n.tr("Localizable", "OFFER_SCREEN_USP_THREE_BODY")
    /// All-risk included
    internal static let offerScreenUspThreeTitle = L10n.tr("Localizable", "OFFER_SCREEN_USP_THREE_TITLE")
    /// Hedvig has the most generous compensation for electronics
    internal static let offerScreenUspTwoBody = L10n.tr("Localizable", "OFFER_SCREEN_USP_TWO_BODY")
    /// Best age deduction in the business
    internal static let offerScreenUspTwoTitle = L10n.tr("Localizable", "OFFER_SCREEN_USP_TWO_TITLE")
    /// What Hedvig covers
    internal static let offerScrollHeader = L10n.tr("Localizable", "OFFER_SCROLL_HEADER")
    /// Sign up
    internal static let offerSignButton = L10n.tr("Localizable", "OFFER_SIGN_BUTTON")
    /// Starts
    internal static let offerStartDate = L10n.tr("Localizable", "OFFER_START_DATE")
    /// Today
    internal static let offerStartDateToday = L10n.tr("Localizable", "OFFER_START_DATE_TODAY")
    /// With Hedvig all your belonging are fully covered. All-risk insurance is included and covers each gadget up to %1$@ per gadget.
    internal static func offerStuffProtectionDescription(_ p1: String) -> String {
        return L10n.tr("Localizable", "OFFER_STUFF_PROTECTION_DESCRIPTION", p1)
    }

    /// Your belongings
    internal static let offerStuffProtectionTitle = L10n.tr("Localizable", "OFFER_STUFF_PROTECTION_TITLE")
    /// Hedvig will contact your existing insurance company and cancel your policy
    internal static let offerSwitchColParagraphOneApp = L10n.tr("Localizable", "OFFER_SWITCH_COL_PARAGRAPH_ONE_APP")
    /// We make sure that your Hedvig insurance is activated automatically on the day your old one terminates
    internal static let offerSwitchColThreeParagraphApp = L10n.tr("Localizable", "OFFER_SWITCH_COL_THREE_PARAGRAPH_APP")
    /// Hedvig will manage the switch from %1$@
    internal static func offerSwitchTitleApp(_ p1: String) -> String {
        return L10n.tr("Localizable", "OFFER_SWITCH_TITLE_APP", p1)
    }

    /// Here's how to switch to Hedvig if you already have insurance
    internal static let offerSwitchTitleNonSwitchableApp = L10n.tr("Localizable", "OFFER_SWITCH_TITLE_NON_SWITCHABLE_APP")
    /// Insurance terms
    internal static let offerTerms = L10n.tr("Localizable", "OFFER_TERMS")
    /// The deductible is %1$@
    internal static func offerTermsDeductible(_ p1: String) -> String {
        return L10n.tr("Localizable", "OFFER_TERMS_DEDUCTIBLE", p1)
    }

    /// The maximum compensation for belongings in your home is %1$@
    internal static func offerTermsMaxCompensation(_ p1: String) -> String {
        return L10n.tr("Localizable", "OFFER_TERMS_MAX_COMPENSATION", p1)
    }

    ///
    internal static let offerTermsNoBindingPeriod = L10n.tr("Localizable", "OFFER_TERMS_NO_BINDING_PERIOD")
    ///
    internal static let offerTermsNoCoverageLimit = L10n.tr("Localizable", "OFFER_TERMS_NO_COVERAGE_LIMIT")
    /// Important terms
    internal static let offerTermsTitle = L10n.tr("Localizable", "OFFER_TERMS_TITLE")
    /// Your home insurance
    internal static let offerTitle = L10n.tr("Localizable", "OFFER_TITLE")
    /// You are safe with us
    internal static let offerTitleSafeWithUs = L10n.tr("Localizable", "OFFER_TITLE_SAFE_WITH_US")
    /// An increased deductible applies for certain claims, this applies to flooding and freeze damages, among other things. Please read the terms or contact us in the chat if you have any questions.
    internal static let offerTrustIncreasedDeductible = L10n.tr("Localizable", "OFFER_TRUST_INCREASED_DEDUCTIBLE")
    /// Enable notification so you never miss a message from Hedvig. We won't spam, we promise.
    internal static let onboardingActivateNotificationsBody = L10n.tr("Localizable", "ONBOARDING_ACTIVATE_NOTIFICATIONS_BODY")
    /// Enable notifications
    internal static let onboardingActivateNotificationsCta = L10n.tr("Localizable", "ONBOARDING_ACTIVATE_NOTIFICATIONS_CTA")
    /// Skip
    internal static let onboardingActivateNotificationsDismiss = L10n.tr("Localizable", "ONBOARDING_ACTIVATE_NOTIFICATIONS_DISMISS")
    /// Enable notifications
    internal static let onboardingActivateNotificationsHeadline = L10n.tr("Localizable", "ONBOARDING_ACTIVATE_NOTIFICATIONS_HEADLINE")
    /// Don't check Hedvig 24/7
    internal static let onboardingActivateNotificationsPreHeadline = L10n.tr("Localizable", "ONBOARDING_ACTIVATE_NOTIFICATIONS_PRE_HEADLINE")
    /// Money will be drawn via direct debit the 27th each month. We only start charging you once your insurance is activated.
    internal static let onboardingConnectDdBody = L10n.tr("Localizable", "ONBOARDING_CONNECT_DD_BODY")
    /// With direct debit, you put your life on autopilot. Of course we only charge once your insurance is activated.
    internal static let onboardingConnectDdBodySwitchers = L10n.tr("Localizable", "ONBOARDING_CONNECT_DD_BODY_SWITCHERS")
    /// Connect direct debit
    internal static let onboardingConnectDdCta = L10n.tr("Localizable", "ONBOARDING_CONNECT_DD_CTA")
    /// For your insurance to stay active you need to connect direct debit from your bank. You can do it later in the app.
    internal static let onboardingConnectDdFailureBody = L10n.tr("Localizable", "ONBOARDING_CONNECT_DD_FAILURE_BODY")
    /// Do it later
    internal static let onboardingConnectDdFailureCtaLater = L10n.tr("Localizable", "ONBOARDING_CONNECT_DD_FAILURE_CTA_LATER")
    /// Try again
    internal static let onboardingConnectDdFailureCtaRetry = L10n.tr("Localizable", "ONBOARDING_CONNECT_DD_FAILURE_CTA_RETRY")
    /// Ouch, something went wrong...
    internal static let onboardingConnectDdFailureHeadline = L10n.tr("Localizable", "ONBOARDING_CONNECT_DD_FAILURE_HEADLINE")
    /// Connect direct debit
    internal static let onboardingConnectDdHeadline = L10n.tr("Localizable", "ONBOARDING_CONNECT_DD_HEADLINE")
    /// Psst, don't forget...
    internal static let onboardingConnectDdPreHeadline = L10n.tr("Localizable", "ONBOARDING_CONNECT_DD_PRE_HEADLINE")
    /// Thanks for that!
    internal static let onboardingConnectDdSuccessBody = L10n.tr("Localizable", "ONBOARDING_CONNECT_DD_SUCCESS_BODY")
    /// Continue
    internal static let onboardingConnectDdSuccessCta = L10n.tr("Localizable", "ONBOARDING_CONNECT_DD_SUCCESS_CTA")
    /// Direct debit connected!
    internal static let onboardingConnectDdSuccessHeadline = L10n.tr("Localizable", "ONBOARDING_CONNECT_DD_SUCCESS_HEADLINE")
    /// your current insurance
    internal static let otherInsurerOptionApp = L10n.tr("Localizable", "OTHER_INSURER_OPTION_APP")
    /// Another
    internal static let otherSectionTitle = L10n.tr("Localizable", "OTHER_SECTION_TITLE")
    /// kr/month
    internal static let paymentCurrencyOccurrence = L10n.tr("Localizable", "PAYMENT_CURRENCY_OCCURRENCE")
    /// No money will be deducted.\n\n\nYou can go back and try again.
    internal static let paymentFailureBody = L10n.tr("Localizable", "PAYMENT_FAILURE_BODY")
    /// Go back
    internal static let paymentFailureButton = L10n.tr("Localizable", "PAYMENT_FAILURE_BUTTON")
    /// Something's gone wrong
    internal static let paymentFailureTitle = L10n.tr("Localizable", "PAYMENT_FAILURE_TITLE")
    /// %1$li kr
    internal static func paymentHistoryAmount(_ p1: Int) -> String {
        return L10n.tr("Localizable", "PAYMENT_HISTORY_AMOUNT", p1)
    }

    /// Payment history
    internal static let paymentHistoryTitle = L10n.tr("Localizable", "PAYMENT_HISTORY_TITLE")
    ///
    internal static let paymentSetupDoneCta = L10n.tr("Localizable", "PAYMENT_SETUP_DONE_CTA")
    ///
    internal static let paymentSetupDoneDescription = L10n.tr("Localizable", "PAYMENT_SETUP_DONE_DESCRIPTION")
    ///
    internal static let paymentSetupDoneTitle = L10n.tr("Localizable", "PAYMENT_SETUP_DONE_TITLE")
    ///
    internal static let paymentSetupFailedCancelCta = L10n.tr("Localizable", "PAYMENT_SETUP_FAILED_CANCEL_CTA")
    ///
    internal static let paymentSetupFailedDescription = L10n.tr("Localizable", "PAYMENT_SETUP_FAILED_DESCRIPTION")
    ///
    internal static let paymentSetupFailedRetryCta = L10n.tr("Localizable", "PAYMENT_SETUP_FAILED_RETRY_CTA")
    ///
    internal static let paymentSetupFailedTitle = L10n.tr("Localizable", "PAYMENT_SETUP_FAILED_TITLE")
    /// Hedvig will appear on your bank statement when you pay each month.
    internal static let paymentSuccessBody = L10n.tr("Localizable", "PAYMENT_SUCCESS_BODY")
    /// Done
    internal static let paymentSuccessButton = L10n.tr("Localizable", "PAYMENT_SUCCESS_BUTTON")
    /// Autogiro active
    internal static let paymentSuccessTitle = L10n.tr("Localizable", "PAYMENT_SUCCESS_TITLE")
    /// Change bank account
    internal static let paymentsBtnChangeBank = L10n.tr("Localizable", "PAYMENTS_BTN_CHANGE_BANK")
    /// View history
    internal static let paymentsBtnHistory = L10n.tr("Localizable", "PAYMENTS_BTN_HISTORY")
    /// Free until
    internal static let paymentsCampaignLfd = L10n.tr("Localizable", "PAYMENTS_CAMPAIGN_LFD")
    /// From
    internal static let paymentsCampaignOwner = L10n.tr("Localizable", "PAYMENTS_CAMPAIGN_OWNER")
    /// Date
    internal static let paymentsCardDate = L10n.tr("Localizable", "PAYMENTS_CARD_DATE")
    /// Start date not set
    internal static let paymentsCardNoStartdate = L10n.tr("Localizable", "PAYMENTS_CARD_NO_STARTDATE")
    /// Next payment
    internal static let paymentsCardTitle = L10n.tr("Localizable", "PAYMENTS_CARD_TITLE")
    /// Expiry date
    internal static let paymentsCreditCardExpiryDateLabel = L10n.tr("Localizable", "PAYMENTS_CREDIT_CARD_EXPIRY_DATE_LABEL")
    /// %1$li kr
    internal static func paymentsCurrentPremium(_ p1: Int) -> String {
        return L10n.tr("Localizable", "PAYMENTS_CURRENT_PREMIUM", p1)
    }

    /// Direct Debit
    internal static let paymentsDirectDebit = L10n.tr("Localizable", "PAYMENTS_DIRECT_DEBIT")
    /// Active
    internal static let paymentsDirectDebitActive = L10n.tr("Localizable", "PAYMENTS_DIRECT_DEBIT_ACTIVE")
    /// Not connected
    internal static let paymentsDirectDebitNeedsSetup = L10n.tr("Localizable", "PAYMENTS_DIRECT_DEBIT_NEEDS_SETUP")
    /// Pending
    internal static let paymentsDirectDebitPending = L10n.tr("Localizable", "PAYMENTS_DIRECT_DEBIT_PENDING")
    /// -%1$@ kr
    internal static func paymentsDiscountAmount(_ p1: String) -> String {
        return L10n.tr("Localizable", "PAYMENTS_DISCOUNT_AMOUNT", p1)
    }

    /// "%1$li%% discount for %2$li months"
    internal static func paymentsDiscountPercentageMonthsMany(_ p1: Int, _ p2: Int) -> String {
        return L10n.tr("Localizable", "PAYMENTS_DISCOUNT_PERCENTAGE_MONTHS_MANY", p1, p2)
    }

    /// "%1$li%% discount for a month"
    internal static func paymentsDiscountPercentageMonthsOne(_ p1: Int) -> String {
        return L10n.tr("Localizable", "PAYMENTS_DISCOUNT_PERCENTAGE_MONTHS_ONE", p1)
    }

    /// Hedvig Forever
    internal static let paymentsDiscountZero = L10n.tr("Localizable", "PAYMENTS_DISCOUNT_ZERO")
    /// %1$li kr/month
    internal static func paymentsFullPremium(_ p1: Int) -> String {
        return L10n.tr("Localizable", "PAYMENTS_FULL_PREMIUM", p1)
    }

    /// You're %1$li months late with your payments. Your next payment will be higher than your ordinary monthly payment. We will charge you %2$@
    internal static func paymentsLatePaymentsMessage(_ p1: Int, _ p2: String) -> String {
        return L10n.tr("Localizable", "PAYMENTS_LATE_PAYMENTS_MESSAGE", p1, p2)
    }

    /// We will update this section when your old insurance is terminated and we have a startdate for your insurance at Hedvig.
    internal static let paymentsNoStartdateHelpMessage = L10n.tr("Localizable", "PAYMENTS_NO_STARTDATE_HELP_MESSAGE")
    /// Free\nmonths
    internal static let paymentsOfferMultipleMonths = L10n.tr("Localizable", "PAYMENTS_OFFER_MULTIPLE_MONTHS")
    /// Free\nmonth
    internal static let paymentsOfferSingleMonth = L10n.tr("Localizable", "PAYMENTS_OFFER_SINGLE_MONTH")
    /// Account
    internal static let paymentsSubtitleAccount = L10n.tr("Localizable", "PAYMENTS_SUBTITLE_ACCOUNT")
    /// Current campaign
    internal static let paymentsSubtitleCampaign = L10n.tr("Localizable", "PAYMENTS_SUBTITLE_CAMPAIGN")
    /// Discount
    internal static let paymentsSubtitleDiscount = L10n.tr("Localizable", "PAYMENTS_SUBTITLE_DISCOUNT")
    /// Payments history
    internal static let paymentsSubtitlePaymentHistory = L10n.tr("Localizable", "PAYMENTS_SUBTITLE_PAYMENT_HISTORY")
    /// Payment method
    internal static let paymentsSubtitlePaymentMethod = L10n.tr("Localizable", "PAYMENTS_SUBTITLE_PAYMENT_METHOD")
    /// Previous payments
    internal static let paymentsSubtitlePreviousPayments = L10n.tr("Localizable", "PAYMENTS_SUBTITLE_PREVIOUS_PAYMENTS")
    /// My payments
    internal static let paymentsTitle = L10n.tr("Localizable", "PAYMENTS_TITLE")
    /// Nothing specified
    internal static let phoneNumberRowEmpty = L10n.tr("Localizable", "PHONE_NUMBER_ROW_EMPTY")
    /// Telephone number
    internal static let phoneNumberRowTitle = L10n.tr("Localizable", "PHONE_NUMBER_ROW_TITLE")
    /// Price missing
    internal static let priceMissing = L10n.tr("Localizable", "PRICE_MISSING")
    /// https://s3.eu-central-1.amazonaws.com/com-hedvig-web-content/Hedvig+-+integritetspolicy.pdf
    internal static let privacyPolicyUrl = L10n.tr("Localizable", "PRIVACY_POLICY_URL")
    /// See what's new
    internal static let profileAboutAppOpenWhatsNew = L10n.tr("Localizable", "PROFILE_ABOUT_APP_OPEN_WHATS_NEW")
    /// About the app
    internal static let profileAboutRow = L10n.tr("Localizable", "PROFILE_ABOUT_ROW")
    /// My cause
    internal static let profileCachbackRow = L10n.tr("Localizable", "PROFILE_CACHBACK_ROW")
    /// Feedback
    internal static let profileFeedbackRow = L10n.tr("Localizable", "PROFILE_FEEDBACK_ROW")
    /// My home
    internal static let profileInsuranceAddressRow = L10n.tr("Localizable", "PROFILE_INSURANCE_ADDRESS_ROW")
    /// My insurance letter
    internal static let profileInsuranceCertificateRowHeader = L10n.tr("Localizable", "PROFILE_INSURANCE_CERTIFICATE_ROW_HEADER")
    /// Press to read
    internal static let profileInsuranceCertificateRowText = L10n.tr("Localizable", "PROFILE_INSURANCE_CERTIFICATE_ROW_TEXT")
    /// **That's how it works**\n\n** 1. ** Select the charity you want to support\n** 2. ** At the end of the year, we collect any surplus money that has not been paid out in compensation to you or to others who have chosen the same charity.\n** 3. ** Together we make a difference by donating the money
    internal static let profileMyCharityInfoBody = L10n.tr("Localizable", "PROFILE_MY_CHARITY_INFO_BODY")
    /// How does Hedvig work with charities?
    internal static let profileMyCharityInfoButton = L10n.tr("Localizable", "PROFILE_MY_CHARITY_INFO_BUTTON")
    /// Charity
    internal static let profileMyCharityInfoTitle = L10n.tr("Localizable", "PROFILE_MY_CHARITY_INFO_TITLE")
    /// No charity chosen
    internal static let profileMyCharityRowNotSelectedSubtitle = L10n.tr("Localizable", "PROFILE_MY_CHARITY_ROW_NOT_SELECTED_SUBTITLE")
    /// My charity
    internal static let profileMyCharityRowTitle = L10n.tr("Localizable", "PROFILE_MY_CHARITY_ROW_TITLE")
    /// Me + %1$@
    internal static func profileMyCoinsuredRowSubtitle(_ p1: String) -> String {
        return L10n.tr("Localizable", "PROFILE_MY_COINSURED_ROW_SUBTITLE", p1)
    }

    /// My coinsured
    internal static let profileMyCoinsuredRowTitle = L10n.tr("Localizable", "PROFILE_MY_COINSURED_ROW_TITLE")
    /// My home
    internal static let profileMyHomeRowTitle = L10n.tr("Localizable", "PROFILE_MY_HOME_ROW_TITLE")
    /// More info
    internal static let profileMyInfoRowTitle = L10n.tr("Localizable", "PROFILE_MY_INFO_ROW_TITLE")
    /// Changes saved
    internal static let profileMyInfoSaveSuccessToastBody = L10n.tr("Localizable", "PROFILE_MY_INFO_SAVE_SUCCESS_TOAST_BODY")
    /// ✏️
    internal static let profileMyInfoSaveSuccessToastSymbol = L10n.tr("Localizable", "PROFILE_MY_INFO_SAVE_SUCCESS_TOAST_SYMBOL")
    /// Becomes available when your insurance is active
    internal static let profileMyInsuranceCertificateRowDisabledSubtitle = L10n.tr("Localizable", "PROFILE_MY_INSURANCE_CERTIFICATE_ROW_DISABLED_SUBTITLE")
    /// Click to read
    internal static let profileMyInsuranceCertificateRowSubtitle = L10n.tr("Localizable", "PROFILE_MY_INSURANCE_CERTIFICATE_ROW_SUBTITLE")
    /// My insurance letter
    internal static let profileMyInsuranceCertificateRowTitle = L10n.tr("Localizable", "PROFILE_MY_INSURANCE_CERTIFICATE_ROW_TITLE")
    /// Pay via autogiro
    internal static let profileMyPaymentMethod = L10n.tr("Localizable", "PROFILE_MY_PAYMENT_METHOD")
    /// Connect direct debit with browser
    internal static let profilePaymentConnectDirectDebitWithLinkButton = L10n.tr("Localizable", "PROFILE_PAYMENT_CONNECT_DIRECT_DEBIT_WITH_LINK_BUTTON")
    /// %1$@ kr/month
    internal static func profilePaymentDiscount(_ p1: String) -> String {
        return L10n.tr("Localizable", "PROFILE_PAYMENT_DISCOUNT", p1)
    }

    /// Discount
    internal static let profilePaymentDiscountLabel = L10n.tr("Localizable", "PROFILE_PAYMENT_DISCOUNT_LABEL")
    /// %1$@ kr/month
    internal static func profilePaymentFinalCost(_ p1: String) -> String {
        return L10n.tr("Localizable", "PROFILE_PAYMENT_FINAL_COST", p1)
    }

    /// Your price
    internal static let profilePaymentFinalCostLabel = L10n.tr("Localizable", "PROFILE_PAYMENT_FINAL_COST_LABEL")
    /// %1$@ kr/month
    internal static func profilePaymentPrice(_ p1: String) -> String {
        return L10n.tr("Localizable", "PROFILE_PAYMENT_PRICE", p1)
    }

    /// Price
    internal static let profilePaymentPriceLabel = L10n.tr("Localizable", "PROFILE_PAYMENT_PRICE_LABEL")
    /// My payments
    internal static let profilePaymentRowHeader = L10n.tr("Localizable", "PROFILE_PAYMENT_ROW_HEADER")
    /// %1$@ kr/month. Pay via autogiro
    internal static func profilePaymentRowText(_ p1: String) -> String {
        return L10n.tr("Localizable", "PROFILE_PAYMENT_ROW_TEXT", p1)
    }

    /// Recommend Hedvig
    internal static let profileRowNewReferralDescription = L10n.tr("Localizable", "PROFILE_ROW_NEW_REFERRAL_DESCRIPTION")
    /// Get free insurance!
    internal static let profileRowNewReferralTitle = L10n.tr("Localizable", "PROFILE_ROW_NEW_REFERRAL_TITLE")
    /// My safety increases
    internal static let profileSafetyincreasersRowHeader = L10n.tr("Localizable", "PROFILE_SAFETYINCREASERS_ROW_HEADER")
    /// Profile
    internal static let profileTitle = L10n.tr("Localizable", "PROFILE_TITLE")
    /// Not now
    internal static let pushNotificationsAlertActionNotNow = L10n.tr("Localizable", "PUSH_NOTIFICATIONS_ALERT_ACTION_NOT_NOW")
    /// Activate
    internal static let pushNotificationsAlertActionOk = L10n.tr("Localizable", "PUSH_NOTIFICATIONS_ALERT_ACTION_OK")
    /// Activate notifications so that you know when Hedvig has answered!
    internal static let pushNotificationsAlertMessage = L10n.tr("Localizable", "PUSH_NOTIFICATIONS_ALERT_MESSAGE")
    /// Notifications
    internal static let pushNotificationsAlertTitle = L10n.tr("Localizable", "PUSH_NOTIFICATIONS_ALERT_TITLE")
    /// Activate notifications so that you know when someone got Hedvig by using your link!
    internal static let pushNotificationsReferralsAlertMesssage = L10n.tr("Localizable", "PUSH_NOTIFICATIONS_REFERRALS_ALERT_MESSSAGE")
    /// Write your discount code below
    internal static let referralAddcouponBody = L10n.tr("Localizable", "REFERRAL_ADDCOUPON_BODY")
    /// Add discount code
    internal static let referralAddcouponBtnSubmit = L10n.tr("Localizable", "REFERRAL_ADDCOUPON_BTN_SUBMIT")
    /// Add discount code
    internal static let referralAddcouponHeadline = L10n.tr("Localizable", "REFERRAL_ADDCOUPON_HEADLINE")
    /// Discount code
    internal static let referralAddcouponInputplaceholder = L10n.tr("Localizable", "REFERRAL_ADDCOUPON_INPUTPLACEHOLDER")
    /// By tapping "Add discount code" you agree to our %1$@
    internal static func referralAddcouponTc(_ p1: String) -> String {
        return L10n.tr("Localizable", "REFERRAL_ADDCOUPON_TC", p1)
    }

    /// terms and conditions
    internal static let referralAddcouponTcLink = L10n.tr("Localizable", "REFERRAL_ADDCOUPON_TC_LINK")
    /// Your code is missing, please spell check
    internal static let referralErrorMissingcodeBody = L10n.tr("Localizable", "REFERRAL_ERROR_MISSINGCODE_BODY")
    /// OK
    internal static let referralErrorMissingcodeBtn = L10n.tr("Localizable", "REFERRAL_ERROR_MISSINGCODE_BTN")
    /// Discount code missing
    internal static let referralErrorMissingcodeHeadline = L10n.tr("Localizable", "REFERRAL_ERROR_MISSINGCODE_HEADLINE")
    /// Do you want to replace your current discount code?
    internal static let referralErrorReplacecodeBody = L10n.tr("Localizable", "REFERRAL_ERROR_REPLACECODE_BODY")
    /// Cancel
    internal static let referralErrorReplacecodeBtnCancel = L10n.tr("Localizable", "REFERRAL_ERROR_REPLACECODE_BTN_CANCEL")
    /// Replace
    internal static let referralErrorReplacecodeBtnSubmit = L10n.tr("Localizable", "REFERRAL_ERROR_REPLACECODE_BTN_SUBMIT")
    /// You already have a discount code activated
    internal static let referralErrorReplacecodeHeadline = L10n.tr("Localizable", "REFERRAL_ERROR_REPLACECODE_HEADLINE")
    /// -%1$@ kr
    internal static func referralInviteActiveValue(_ p1: String) -> String {
        return L10n.tr("Localizable", "REFERRAL_INVITE_ACTIVE_VALUE", p1)
    }

    /// Ghost
    internal static let referralInviteAnon = L10n.tr("Localizable", "REFERRAL_INVITE_ANON")
    /// Ghosts
    internal static let referralInviteAnons = L10n.tr("Localizable", "REFERRAL_INVITE_ANONS")
    /// Code copied!
    internal static let referralInviteCodeCopiedMessage = L10n.tr("Localizable", "REFERRAL_INVITE_CODE_COPIED_MESSAGE")
    /// Let's fix that!
    internal static let referralInviteEmptystateDescription = L10n.tr("Localizable", "REFERRAL_INVITE_EMPTYSTATE_DESCRIPTION")
    /// You haven't invited anyone yet
    internal static let referralInviteEmptystateTitle = L10n.tr("Localizable", "REFERRAL_INVITE_EMPTYSTATE_TITLE")
    /// Invited you to Hedvig
    internal static let referralInviteInvitedyoustate = L10n.tr("Localizable", "REFERRAL_INVITE_INVITEDYOUSTATE")
    /// Has gotten Hedvig
    internal static let referralInviteNewstate = L10n.tr("Localizable", "REFERRAL_INVITE_NEWSTATE")
    /// Someone has opened your link
    internal static let referralInviteOpenedstate = L10n.tr("Localizable", "REFERRAL_INVITE_OPENEDSTATE")
    /// %1$li persons has opened your link
    internal static func referralInviteOpenedstateMultiple(_ p1: Int) -> String {
        return L10n.tr("Localizable", "REFERRAL_INVITE_OPENEDSTATE_MULTIPLE", p1)
    }

    /// Has left Hedvig
    internal static let referralInviteQuitstate = L10n.tr("Localizable", "REFERRAL_INVITE_QUITSTATE")
    /// Has started onboarding
    internal static let referralInviteStartedstate = L10n.tr("Localizable", "REFERRAL_INVITE_STARTEDSTATE")
    /// Your invites
    internal static let referralInviteTitle = L10n.tr("Localizable", "REFERRAL_INVITE_TITLE")
    /// Continue on the web
    internal static let referralLandingpageBtnWeb = L10n.tr("Localizable", "REFERRAL_LANDINGPAGE_BTN_WEB")
    /// Do you want to accept the invitation or continue without a discount?
    internal static let referralLinkInvitationScreenBody = L10n.tr("Localizable", "REFERRAL_LINK_INVITATION_SCREEN_BODY")
    /// Yes, I want the discount!
    internal static let referralLinkInvitationScreenBtnAccept = L10n.tr("Localizable", "REFERRAL_LINK_INVITATION_SCREEN_BTN_ACCEPT")
    /// No, continue without
    internal static let referralLinkInvitationScreenBtnDecline = L10n.tr("Localizable", "REFERRAL_LINK_INVITATION_SCREEN_BTN_DECLINE")
    /// You have been invited by %1$@ and is going to get %1$@ kr discount per month
    internal static func referralLinkInvitationScreenHeadline(_ p1: String) -> String {
        return L10n.tr("Localizable", "REFERRAL_LINK_INVITATION_SCREEN_HEADLINE", p1)
    }

    /// https://www.hedvig.com/en/invite/terms
    internal static let referralMoreInfoLink = L10n.tr("Localizable", "REFERRAL_MORE_INFO_LINK")
    /// -%1$@ kr/month discount
    internal static func referralOfferDiscountBody(_ p1: String) -> String {
        return L10n.tr("Localizable", "REFERRAL_OFFER_DISCOUNT_BODY", p1)
    }

    /// Invite!
    internal static let referralOfferDiscountHeadline = L10n.tr("Localizable", "REFERRAL_OFFER_DISCOUNT_HEADLINE")
    /// Invite
    internal static let referralProgressBarCta = L10n.tr("Localizable", "REFERRAL_PROGRESS_BAR_CTA")
    /// You are giving away %1$li kr discount and get %1$li kr discount for each friend that you invite with your unique link! Can you get free insurance?
    internal static func referralProgressBody(_ p1: Int) -> String {
        return L10n.tr("Localizable", "REFERRAL_PROGRESS_BODY", p1)
    }

    /// Your code
    internal static let referralProgressCodeTitle = L10n.tr("Localizable", "REFERRAL_PROGRESS_CODE_TITLE")
    /// %1$@ kr
    internal static func referralProgressCurrentPremiumPrice(_ p1: String) -> String {
        return L10n.tr("Localizable", "REFERRAL_PROGRESS_CURRENT_PREMIUM_PRICE", p1)
    }

    /// Lower your monthly cost!
    internal static let referralProgressEdgecaseHeadline = L10n.tr("Localizable", "REFERRAL_PROGRESS_EDGECASE_HEADLINE")
    /// Free!
    internal static let referralProgressFree = L10n.tr("Localizable", "REFERRAL_PROGRESS_FREE")
    /// Share Hedvig and lower your price
    internal static let referralProgressHeadline = L10n.tr("Localizable", "REFERRAL_PROGRESS_HEADLINE")
    /// Current price: %1$li kr/month
    internal static func referralProgressHighPremiumDescription(_ p1: Int) -> String {
        return L10n.tr("Localizable", "REFERRAL_PROGRESS_HIGH_PREMIUM_DESCRIPTION", p1)
    }

    /// -%1$@ kr
    internal static func referralProgressHighPremiumDiscount(_ p1: String) -> String {
        return L10n.tr("Localizable", "REFERRAL_PROGRESS_HIGH_PREMIUM_DISCOUNT", p1)
    }

    /// %1$@ kr
    internal static func referralProgressHighPremiumDiscountNoMinus(_ p1: String) -> String {
        return L10n.tr("Localizable", "REFERRAL_PROGRESS_HIGH_PREMIUM_DISCOUNT_NO_MINUS", p1)
    }

    /// discount per month
    internal static let referralProgressHighPremiumDiscountSubtitle = L10n.tr("Localizable", "REFERRAL_PROGRESS_HIGH_PREMIUM_DISCOUNT_SUBTITLE")
    /// Read Terms & Conditions
    internal static let referralProgressMoreInfoCta = L10n.tr("Localizable", "REFERRAL_PROGRESS_MORE_INFO_CTA")
    /// Invite a friend
    internal static let referralProgressMoreInfoHeadline = L10n.tr("Localizable", "REFERRAL_PROGRESS_MORE_INFO_HEADLINE")
    /// Referrals with Hedvig are simple. Refer a friend with your unique code and both you and your friend gets a %1$@ kr discount.\n\nYou can invite friends until your monthly price is 0 kr, so you can get completely free home insurance. The discount is valid only as long as both you and your friend are both active members.
    internal static func referralProgressMoreInfoParagraph(_ p1: String) -> String {
        return L10n.tr("Localizable", "REFERRAL_PROGRESS_MORE_INFO_PARAGRAPH", p1)
    }

    /// Referrals with Hedvig are simple. Refer a friend with your unique code and both you and your friend gets a %1$@ kr discount.
    internal static func referralProgressMoreInfoParagraphOne(_ p1: String) -> String {
        return L10n.tr("Localizable", "REFERRAL_PROGRESS_MORE_INFO_PARAGRAPH_ONE", p1)
    }

    /// You can invite friends until your monthly price is 0 kr, so you can get completely free home insurance. The discount is valid only as long as both you and your friend are both active members.
    internal static let referralProgressMoreInfoParagraphTwo = L10n.tr("Localizable", "REFERRAL_PROGRESS_MORE_INFO_PARAGRAPH_TWO")
    /// More info
    internal static let referralProgressTopbarButton = L10n.tr("Localizable", "REFERRAL_PROGRESS_TOPBAR_BUTTON")
    /// Lower your price
    internal static let referralProgressTopbarTitle = L10n.tr("Localizable", "REFERRAL_PROGRESS_TOPBAR_TITLE")
    /// Hedvig is better when you share it with your friends! You and your friends gets (REFERRAL_VALUE) off your monthly payments – per friend!
    internal static let referralRecieverWelcomeBody = L10n.tr("Localizable", "REFERRAL_RECIEVER_WELCOME_BODY")
    /// Invite friend straight away! 👯‍♀️
    internal static let referralRecieverWelcomeBtnCta = L10n.tr("Localizable", "REFERRAL_RECIEVER_WELCOME_BTN_CTA")
    /// Check out the app
    internal static let referralRecieverWelcomeBtnSkip = L10n.tr("Localizable", "REFERRAL_RECIEVER_WELCOME_BTN_SKIP")
    /// Welcome as a member %1$@!
    internal static func referralRecieverWelcomeHeadline(_ p1: String) -> String {
        return L10n.tr("Localizable", "REFERRAL_RECIEVER_WELCOME_HEADLINE", p1)
    }

    /// Congrats! Your discount code has been added
    internal static let referralRedeemSuccessBody = L10n.tr("Localizable", "REFERRAL_REDEEM_SUCCESS_BODY")
    /// OK, nice!
    internal static let referralRedeemSuccessBtn = L10n.tr("Localizable", "REFERRAL_REDEEM_SUCCESS_BTN")
    /// Discount code added!
    internal static let referralRedeemSuccessHeadline = L10n.tr("Localizable", "REFERRAL_REDEEM_SUCCESS_HEADLINE")
    /// You have been invited by
    internal static let referralReferredByTitle = L10n.tr("Localizable", "REFERRAL_REFERRED_BY_TITLE")
    /// Hedvig - Nice insurance
    internal static let referralShareSocialDescription = L10n.tr("Localizable", "REFERRAL_SHARE_SOCIAL_DESCRIPTION")
    /// Get Hedvig!
    internal static let referralShareSocialTitle = L10n.tr("Localizable", "REFERRAL_SHARE_SOCIAL_TITLE")
    /// Share your invite
    internal static let referralShareinvite = L10n.tr("Localizable", "REFERRAL_SHAREINVITE")
    /// Hey! Get Hedvig using my link and we both get %1$@ kr per month discount on the monthly cost. Follow the link: %2$@
    internal static func referralSmsMessage(_ p1: String, _ p2: String) -> String {
        return L10n.tr("Localizable", "REFERRAL_SMS_MESSAGE", p1, p2)
    }

    /// Do you want to accept the invite or continue without the discount?
    internal static let referralStartscreenBody = L10n.tr("Localizable", "REFERRAL_STARTSCREEN_BODY")
    /// Yes, accept discount!
    internal static let referralStartscreenBtnCta = L10n.tr("Localizable", "REFERRAL_STARTSCREEN_BTN_CTA")
    /// No, continue without it
    internal static let referralStartscreenBtnSkip = L10n.tr("Localizable", "REFERRAL_STARTSCREEN_BTN_SKIP")
    /// You have been invited by a friend and will get %1$li off your monthly payment
    internal static func referralStartscreenHeadline(_ p1: Int) -> String {
        return L10n.tr("Localizable", "REFERRAL_STARTSCREEN_HEADLINE", p1)
    }

    /// As a thank you both you and your friends get %1$li kr less in your monthly fee. Keep inviting friends to lower it even more!
    internal static func referralSuccessBody(_ p1: Int) -> String {
        return L10n.tr("Localizable", "REFERRAL_SUCCESS_BODY", p1)
    }

    /// Close
    internal static let referralSuccessBtnClose = L10n.tr("Localizable", "REFERRAL_SUCCESS_BTN_CLOSE")
    /// Invite more friends!
    internal static let referralSuccessBtnCta = L10n.tr("Localizable", "REFERRAL_SUCCESS_BTN_CTA")
    /// %1$@ got Hedvig thanks to you!
    internal static func referralSuccessHeadline(_ p1: String) -> String {
        return L10n.tr("Localizable", "REFERRAL_SUCCESS_HEADLINE", p1)
    }

    /// %1$@ of your friends signed up to Hedvig because of you!
    internal static func referralSuccessHeadlineMultiple(_ p1: String) -> String {
        return L10n.tr("Localizable", "REFERRAL_SUCCESS_HEADLINE_MULTIPLE", p1)
    }

    /// Wow. You Did It - Free insurance! We are proud beyond what words can express!
    internal static let referralUltimateSuccessBody = L10n.tr("Localizable", "REFERRAL_ULTIMATE_SUCCESS_BODY")
    /// Apply for a job at Hedvig!
    internal static let referralUltimateSuccessBtnCta = L10n.tr("Localizable", "REFERRAL_ULTIMATE_SUCCESS_BTN_CTA")
    /// You did it!
    internal static let referralUltimateSuccessTitle = L10n.tr("Localizable", "REFERRAL_ULTIMATE_SUCCESS_TITLE")
    /// Copy
    internal static let referralsCodeSheetCopy = L10n.tr("Localizable", "REFERRALS_CODE_SHEET_COPY")
    /// https://hedvig.com/invite/desktop?invitedBy=%1$@&incentive=%1$@
    internal static func referralsDynamicLinkLanding(_ p1: String) -> String {
        return L10n.tr("Localizable", "REFERRALS_DYNAMIC_LINK_LANDING", p1)
    }

    /// Free!
    internal static let referralsFreeLabel = L10n.tr("Localizable", "REFERRALS_FREE_LABEL")
    /// Invite
    internal static let referralsInviteLabel = L10n.tr("Localizable", "REFERRALS_INVITE_LABEL")
    /// You friend gets
    internal static let referralsOfferReceiverTitle = L10n.tr("Localizable", "REFERRALS_OFFER_RECEIVER_TITLE")
    /// %1$@ kr for each Hedvig signup via your link
    internal static func referralsOfferReceiverValue(_ p1: String) -> String {
        return L10n.tr("Localizable", "REFERRALS_OFFER_RECEIVER_VALUE", p1)
    }

    /// You get
    internal static let referralsOfferSenderTitle = L10n.tr("Localizable", "REFERRALS_OFFER_SENDER_TITLE")
    /// %1$@ kr discount for each new person who joins via your link.
    internal static func referralsOfferSenderValue(_ p1: String) -> String {
        return L10n.tr("Localizable", "REFERRALS_OFFER_SENDER_VALUE", p1)
    }

    /// https://www.hedvig.com/TODO
    internal static let referralsReceiverTermsLink = L10n.tr("Localizable", "REFERRALS_RECEIVER_TERMS_LINK")
    /// Invite your friends to Hedvig
    internal static let referralsRowSubtitle = L10n.tr("Localizable", "REFERRALS_ROW_SUBTITLE")
    /// Get %1$@ kr, give %1$@ kr!
    internal static func referralsRowTitle(_ p1: String) -> String {
        return L10n.tr("Localizable", "REFERRALS_ROW_TITLE", p1)
    }

    /// Invite your friends
    internal static let referralsScreenTitle = L10n.tr("Localizable", "REFERRALS_SCREEN_TITLE")
    /// Share your link
    internal static let referralsShareButton = L10n.tr("Localizable", "REFERRALS_SHARE_BUTTON")
    /// Get nice home insurance from Hedvig and receive %1$@ kr! If you already have home insurance, Hedvig will handle the switch for you! 🙌 Get Hedvig here: %1$@
    internal static func referralsShareMessage(_ p1: String) -> String {
        return L10n.tr("Localizable", "REFERRALS_SHARE_MESSAGE", p1)
    }

    /// Terms
    internal static let referralsTermsRowTitle = L10n.tr("Localizable", "REFERRALS_TERMS_ROW_TITLE")
    /// https://www.hedvig.com/invite/terms
    internal static let referralsTermsWebsiteUrl = L10n.tr("Localizable", "REFERRALS_TERMS_WEBSITE_URL")
    /// Hedvig get's better when you share with friends!
    internal static let referralsTitle = L10n.tr("Localizable", "REFERRALS_TITLE")
    /// Yes
    internal static let restartOfferChatButtonConfirm = L10n.tr("Localizable", "RESTART_OFFER_CHAT_BUTTON_CONFIRM")
    /// No
    internal static let restartOfferChatButtonDismiss = L10n.tr("Localizable", "RESTART_OFFER_CHAT_BUTTON_DISMISS")
    /// If you press yes, the conversation will restart and your current quote will disappear
    internal static let restartOfferChatParagraph = L10n.tr("Localizable", "RESTART_OFFER_CHAT_PARAGRAPH")
    /// Do you want to start over?
    internal static let restartOfferChatTitle = L10n.tr("Localizable", "RESTART_OFFER_CHAT_TITLE")
    /// Search for gifs
    internal static let searchBarGif = L10n.tr("Localizable", "SEARCH_BAR_GIF")
    /// Cancel
    internal static let settingsAlertChangeMarketCancel = L10n.tr("Localizable", "SETTINGS_ALERT_CHANGE_MARKET_CANCEL")
    /// OK
    internal static let settingsAlertChangeMarketOk = L10n.tr("Localizable", "SETTINGS_ALERT_CHANGE_MARKET_OK")
    /// You will be logged out when changing market
    internal static let settingsAlertChangeMarketText = L10n.tr("Localizable", "SETTINGS_ALERT_CHANGE_MARKET_TEXT")
    /// Are you sure?
    internal static let settingsAlertChangeMarketTitle = L10n.tr("Localizable", "SETTINGS_ALERT_CHANGE_MARKET_TITLE")
    /// Change country
    internal static let settingsChangeMarket = L10n.tr("Localizable", "SETTINGS_CHANGE_MARKET")
    /// Login
    internal static let settingsLoginRow = L10n.tr("Localizable", "SETTINGS_LOGIN_ROW")
    /// Market
    internal static let settingsPageMarket = L10n.tr("Localizable", "SETTINGS_PAGE_MARKET")
    /// Sign canceled 🙅
    internal static let signCanceled = L10n.tr("Localizable", "SIGN_CANCELED")
    /// Whoops! Unknown error 🙈
    internal static let signFailedReasonUnknown = L10n.tr("Localizable", "SIGN_FAILED_REASON_UNKNOWN")
    /// Sign in progress
    internal static let signInProgress = L10n.tr("Localizable", "SIGN_IN_PROGRESS")
    /// Sign with your mobile BankID
    internal static let signMobileBankId = L10n.tr("Localizable", "SIGN_MOBILE_BANK_ID")
    /// Start the BankID-app
    internal static let signStartBankid = L10n.tr("Localizable", "SIGN_START_BANKID")
    /// Sign successful 👌
    internal static let signSuccessful = L10n.tr("Localizable", "SIGN_SUCCESSFUL")
    /// Starts
    internal static let startDateBtn = L10n.tr("Localizable", "START_DATE_BTN")
    /// When my current one expires
    internal static let startDateExpires = L10n.tr("Localizable", "START_DATE_EXPIRES")
    /// Today
    internal static let startDateToday = L10n.tr("Localizable", "START_DATE_TODAY")
    /// 50 000 kr
    internal static let stuffProtectionAmount = L10n.tr("Localizable", "STUFF_PROTECTION_AMOUNT")
    /// 25 000 kr
    internal static let stuffProtectionAmountStudent = L10n.tr("Localizable", "STUFF_PROTECTION_AMOUNT_STUDENT")
    /// Condominium
    internal static let swedishApartmentLobBrf = L10n.tr("Localizable", "SWEDISH_APARTMENT_LOB_BRF")
    /// Rental
    internal static let swedishApartmentLobRent = L10n.tr("Localizable", "SWEDISH_APARTMENT_LOB_RENT")
    /// Student condominium
    internal static let swedishApartmentLobStudentBrf = L10n.tr("Localizable", "SWEDISH_APARTMENT_LOB_STUDENT_BRF")
    /// Rental, student
    internal static let swedishApartmentLobStudentRent = L10n.tr("Localizable", "SWEDISH_APARTMENT_LOB_STUDENT_RENT")
    /// House
    internal static let swedishHouseLob = L10n.tr("Localizable", "SWEDISH_HOUSE_LOB")
    /// Insurance
    internal static let tabDashboardTitle = L10n.tr("Localizable", "TAB_DASHBOARD_TITLE")
    /// Profile
    internal static let tabProfileTitle = L10n.tr("Localizable", "TAB_PROFILE_TITLE")
    /// Invite
    internal static let tabReferralsTitle = L10n.tr("Localizable", "TAB_REFERRALS_TITLE")
    /// Done
    internal static let toolbarDoneButton = L10n.tr("Localizable", "TOOLBAR_DONE_BUTTON")
    /// For your insurance to stay active you need to connect direct debit from your bank.
    internal static let trustlyAlertBody = L10n.tr("Localizable", "TRUSTLY_ALERT_BODY")
    /// No, connect now
    internal static let trustlyAlertNegativeAction = L10n.tr("Localizable", "TRUSTLY_ALERT_NEGATIVE_ACTION")
    /// Yes, connect later
    internal static let trustlyAlertPositiveAction = L10n.tr("Localizable", "TRUSTLY_ALERT_POSITIVE_ACTION")
    /// Are you sure?
    internal static let trustlyAlertTitle = L10n.tr("Localizable", "TRUSTLY_ALERT_TITLE")
    /// OK
    internal static let trustlyMissingBankIdAppAlertAction = L10n.tr("Localizable", "TRUSTLY_MISSING_BANK_ID_APP_ALERT_ACTION")
    /// To be able to log in to your bank you need to have the BankID app installed.
    internal static let trustlyMissingBankIdAppAlertMessage = L10n.tr("Localizable", "TRUSTLY_MISSING_BANK_ID_APP_ALERT_MESSAGE")
    /// You do not have BankID on this device
    internal static let trustlyMissingBankIdAppAlertTitle = L10n.tr("Localizable", "TRUSTLY_MISSING_BANK_ID_APP_ALERT_TITLE")
    /// Set up payment
    internal static let trustlyPaymentSetupAction = L10n.tr("Localizable", "TRUSTLY_PAYMENT_SETUP_ACTION")
    /// In order for your insurance to be valid you need to connect autogiro from your bank account. We use Trustly for this.
    internal static let trustlyPaymentSetupMessage = L10n.tr("Localizable", "TRUSTLY_PAYMENT_SETUP_MESSAGE")
    /// Not now
    internal static let trustlySkipButton = L10n.tr("Localizable", "TRUSTLY_SKIP_BUTTON")
    /// Upload a file
    internal static let uploadFileButtonHint = L10n.tr("Localizable", "UPLOAD_FILE_BUTTON_HINT")
    /// File
    internal static let uploadFileFileAction = L10n.tr("Localizable", "UPLOAD_FILE_FILE_ACTION")
    /// Picture or video
    internal static let uploadFileImageOrVideoAction = L10n.tr("Localizable", "UPLOAD_FILE_IMAGE_OR_VIDEO_ACTION")
    /// What would you like to send?
    internal static let uploadFileSelectTypeTitle = L10n.tr("Localizable", "UPLOAD_FILE_SELECT_TYPE_TITLE")
    /// Cancel
    internal static let uploadFileTypeCancel = L10n.tr("Localizable", "UPLOAD_FILE_TYPE_CANCEL")
    /// Get Contents insurance
    internal static let upsellNotificationContentCta = L10n.tr("Localizable", "UPSELL_NOTIFICATION_CONTENT_CTA")
    /// Get covered at home as well. \nWrite to us in the chat to get Contents insurance at a great price
    internal static let upsellNotificationContentDescription = L10n.tr("Localizable", "UPSELL_NOTIFICATION_CONTENT_DESCRIPTION")
    /// Worried about going home?
    internal static let upsellNotificationContentTitle = L10n.tr("Localizable", "UPSELL_NOTIFICATION_CONTENT_TITLE")
    /// Get Travel insurance
    internal static let upsellNotificationTravelCta = L10n.tr("Localizable", "UPSELL_NOTIFICATION_TRAVEL_CTA")
    /// Write to us in the chat to get Travel insurance at a great price
    internal static let upsellNotificationTravelDescription = L10n.tr("Localizable", "UPSELL_NOTIFICATION_TRAVEL_DESCRIPTION")
    /// Always travel with a great insurance
    internal static let upsellNotificationTravelTitle = L10n.tr("Localizable", "UPSELL_NOTIFICATION_TRAVEL_TITLE")
}

// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension L10n {
    static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
        // swiftlint:disable:next nslocalizedstring_key
        let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
        var translation = String(format: format, locale: Foundation.Locale.current, arguments: args)
        translation.derivedFromL10n = L10nDerivation(table: table, key: key, args: args)
        return translation
    }
}

private final class BundleToken {}
