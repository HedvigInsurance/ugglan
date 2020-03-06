// Generated automagically, don't edit yourself

import Foundation

// swiftlint:disable identifier_name type_body_length type_name line_length nesting file_length

protocol LocalizationStringConvertible {
    var localizationDescription: String { get }
}

extension String: LocalizationStringConvertible {
    var localizationDescription: String {
        return self
    }
}

extension Int: LocalizationStringConvertible {
    var localizationDescription: String {
        return String(self)
    }
}

extension Double: LocalizationStringConvertible {
    var localizationDescription: String {
        return String(self)
    }
}

extension Float: LocalizationStringConvertible {
    var localizationDescription: String {
        return String(self)
    }
}

extension String {
    static var localizationKey: UInt8 = 0

    var localizationKey: Localization.Key? {
        get {
            guard let value = objc_getAssociatedObject(
                self,
                &String.localizationKey
            ) as? Localization.Key? else {
                return nil
            }

            return value
        }
        set(newValue) {
            objc_setAssociatedObject(
                self,
                &String.localizationKey,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    init(key: Localization.Key, locale: Localization.Locale = Localization.Locale.currentLocale) {
        switch locale {
        case .sv_SE: self = Localization.Translations.sv_SE.for(key: key)
        case .en_SE: self = Localization.Translations.en_SE.for(key: key)
        case .en_NO: self = Localization.Translations.en_NO.for(key: key)
        case .nb_NO: self = Localization.Translations.nb_NO.for(key: key)
        }

        localizationKey = key
    }
}

public struct Localization {
    enum Locale: String, CaseIterable {
        static var currentLocale: Locale = .sv_SE
        case sv_SE
        case en_SE
        case en_NO
        case nb_NO
    }

    enum Key {
        case OFFER_TITLE
        case OFFER_BUBBLES_BINDING_PERIOD_TITLE
        case OFFER_BUBBLES_BINDING_PERIOD_SUBTITLE
        case OFFER_BUBBLES_DEDUCTIBLE_TITLE
        case OFFER_BUBBLES_DEDUCTIBLE_SUBTITLE
        case OFFER_BUBBLES_INSURED_TITLE
        case OFFER_BUBBLES_INSURED_SUBTITLE(personsInHousehold: LocalizationStringConvertible)
        case OFFER_BUBBLES_START_DATE_TITLE
        case OFFER_BUBBLES_START_DATE_SUBTITLE_SWITCHER
        case OFFER_BUBBLES_START_DATE_SUBTITLE_NEW
        case OFFER_BUBBLES_TRAVEL_PROTECTION_TITLE
        case OFFER_BUBBLES_OWNED_ADDON_TITLE
        case OFFER_SIGN_BUTTON
        case OFFER_SCROLL_HEADER
        case OFFER_CHAT_HEADER
        case OFFER_GET_HEDVIG_TITLE
        case OFFER_GET_HEDVIG_BODY
        case OFFER_APARTMENT_PROTECTION_DESCRIPTION
        case OFFER_APARTMENT_PROTECTION_TITLE(address: LocalizationStringConvertible)
        case OFFER_STUFF_PROTECTION_TITLE
        case OFFER_STUFF_PROTECTION_DESCRIPTION(protectionAmount: LocalizationStringConvertible)
        case STUFF_PROTECTION_AMOUNT
        case STUFF_PROTECTION_AMOUNT_STUDENT
        case OFFER_PERSONAL_PROTECTION_TITLE
        case OFFER_PERSONAL_PROTECTION_DESCRIPTION
        case OFFER_PERILS_EXPLAINER
       /// Shows currency and interval
        case PAYMENT_CURRENCY_OCCURRENCE
        case TRUSTLY_PAYMENT_SETUP_MESSAGE
        case TRUSTLY_PAYMENT_SETUP_ACTION
        case CASHBACK_NEEDS_SETUP_MESSAGE
        case CASHBACK_NEEDS_SETUP_ACTION
        case CASHBACK_NEEDS_SETUP_OVERLAY_TITLE
        case CASHBACK_NEEDS_SETUP_OVERLAY_PARAGRAPH
        case PAYMENT_SUCCESS_TITLE
        case PAYMENT_SUCCESS_BODY
        case PAYMENT_SUCCESS_BUTTON
        case PAYMENT_FAILURE_TITLE
        case PAYMENT_FAILURE_BODY
        case PAYMENT_FAILURE_BUTTON
        case DASHBOARD_BANNER_ACTIVE_TITLE(firstName: LocalizationStringConvertible)
        case DASHBOARD_BANNER_ACTIVE_INFO
        case DASHBOARD_HAVE_START_DATE_BANNER_TITLE
        case DASHBOARD_READMORE_HAVE_START_DATE_TEXT(date: LocalizationStringConvertible)
        case DASHBOARD_BANNER_MONTHS
        case DASHBOARD_BANNER_DAYS
        case DASHBOARD_BANNER_HOURS
        case DASHBOARD_BANNER_MINUTES
        case DASHBOARD_MORE_INFO_BUTTON_TEXT
        case DASHBOARD_NOT_STARTED_BANNER_TITLE
        case DASHBOARD_READMORE_NOT_STARTED_TEXT
        case DASHBOARD_LESS_INFO_BUTTON_TEXT
        case FILE_UPLOAD_ERROR
        case FILE_UPLOAD_ERROR_RETRY_BUTTON
        case DASHBOARD_BANNER_TERMINATED_INFO
        case RESTART_OFFER_CHAT_TITLE
        case RESTART_OFFER_CHAT_PARAGRAPH
        case RESTART_OFFER_CHAT_BUTTON_CONFIRM
        case RESTART_OFFER_CHAT_BUTTON_DISMISS
        case DASHBOARD_OWNER_FOOTNOTE
        case DASHBOARD_PERILS_CATEGORY_INFO
        case DASHBOARD_TRAVEL_FOOTNOTE
        case PROFILE_CACHBACK_ROW
        case PROFILE_INSURANCE_ADDRESS_ROW
        case PROFILE_INSURANCE_CERTIFICATE_ROW_HEADER
        case PROFILE_INSURANCE_CERTIFICATE_ROW_TEXT
        case PROFILE_PAYMENT_ROW_HEADER
        case PROFILE_PAYMENT_ROW_TEXT(price: LocalizationStringConvertible)
        case PROFILE_SAFETYINCREASERS_ROW_HEADER
       /// Amount of money that stuff is insured for
        case DASHBOARD_INSURANCE_AMOUNT_FOOTNOTE(student: LocalizationStringConvertible)
        case CHAT_GIPHY_PICKER_NO_SEARCH_TEXT
        case CHAT_GIPHY_PICKER_TEXT
        case CHAT_COULD_NOT_LOAD_FILE
        case CHAT_FILE_LOADING
        case CHAT_FILE_DOWNLOAD
       /// Redo button for Audio recordings in Chat
        case AUDIO_INPUT_REDO
       /// Upload button for Audio recordings in Chat
        case AUDIO_INPUT_SAVE
       /// Playback button for Audio recordings in Chat
        case AUDIO_INPUT_PLAY
       /// Message shown in chat when a file has been uploaded successfully
        case CHAT_FILE_UPLOADED
       /// Label shown while a recording is in progress for Audio recordings in Chat
        case AUDIO_INPUT_RECORDING(seconds: LocalizationStringConvertible)
       /// Title on GIF button in Chat
        case GIF_BUTTON_TITLE
        case CHAT_UPLOAD_PRESEND
        case CHAT_UPLOADING_ANIMATION_TEXT
       /// GIPHY label shown in chat
        case CHAT_GIPHY_TITLE
        case MY_INFO_CONTACT_DETAILS_TITLE
       /// Title for My Info screen.
        case MY_INFO_TITLE
       /// Row title for my info
        case PROFILE_MY_INFO_ROW_TITLE
       /// Title of alert that is shown when a network error has occured.
        case NETWORK_ERROR_ALERT_TITLE
       /// Message of alert that is shown when a network error has occured.
        case NETWORK_ERROR_ALERT_MESSAGE
       /// Button that tries network request again.
        case NETWORK_ERROR_ALERT_TRY_AGAIN_ACTION
       /// Button that cancels the current failed network requests.
        case NETWORK_ERROR_ALERT_CANCEL_ACTION
       /// Title for row that is displaying the phone number
        case PHONE_NUMBER_ROW_TITLE
       /// Empty message that is shown when we don't have a phone number for the user.
        case PHONE_NUMBER_ROW_EMPTY
       /// Row title for my charity on profile page
        case PROFILE_MY_CHARITY_ROW_TITLE
       /// Title for row where a user can see and change their email.
        case EMAIL_ROW_TITLE
       /// A value to show when the email row is empty.
        case EMAIL_ROW_EMPTY
       /// Method used to pay fee
        case PROFILE_MY_PAYMENT_METHOD
       /// Title for "My payment" view
        case MY_PAYMENT_TITLE
       /// Title of the profile tab
        case TAB_PROFILE_TITLE
       /// Title of the dashboard tab
        case TAB_DASHBOARD_TITLE
       /// Title for licenses screen
        case LICENSES_SCREEN_TITLE
       /// Title for about screen.
        case ABOUT_SCREEN_TITLE
       /// Title for other section on profile screen
        case OTHER_SECTION_TITLE
       /// Text shown in header under acknowledgements.
        case ACKNOWLEDGEMENT_HEADER_TITLE
       /// Button that logs the user out.
        case LOGOUT_BUTTON
       /// Title for alert shown after a user has clicked the logout button.
        case LOGOUT_ALERT_TITLE
       /// Button that confirms the alert and then logs the user out.
        case LOGOUT_ALERT_ACTION_CONFIRM
       /// Button that cancels logging out.
        case LOGOUT_ALERT_ACTION_CANCEL
       /// Title of my home row on profile screen.
        case PROFILE_MY_HOME_ROW_TITLE
       /// Title for insurance certificate row on profile page.
        case PROFILE_MY_INSURANCE_CERTIFICATE_ROW_TITLE
       /// My insurance certificate row subtitle on profile page.
        case PROFILE_MY_INSURANCE_CERTIFICATE_ROW_SUBTITLE
       /// Subtitle of my insurance certificate row when it's disabled.
        case PROFILE_MY_INSURANCE_CERTIFICATE_ROW_DISABLED_SUBTITLE
       /// Title for page displaying the users insurance certificate.
        case MY_INSURANCE_CERTIFICATE_TITLE
       /// Info that is shown as a header on the charity screen.
        case CHARITY_SCREEN_HEADER_MESSAGE
       /// Label for payment row in "My payment"
        case MY_PAYMENT_PAYMENT_ROW_LABEL
       /// Label for Bank row in "My payment" view
        case MY_PAYMENT_BANK_ROW_LABEL
       /// Title for section showing all available charity options
        case CHARITY_OPTIONS_HEADER_TITLE
       /// Title of my charity screen
        case MY_CHARITY_SCREEN_TITLE
       /// Row subtitle to show when the user hasn't selected a charity
        case PROFILE_MY_CHARITY_ROW_NOT_SELECTED_SUBTITLE
       /// Heading that is shown when setting up direct debit has failed.
        case DIRECT_DEBIT_FAIL_HEADING
       /// Message that is shown when direct debit setup failed.
        case DIRECT_DEBIT_FAIL_MESSAGE
       /// Button on direct debit fail screen that takes you back to my payment.
        case DIRECT_DEBIT_FAIL_BUTTON
       /// Heading on direct debit success view.
        case DIRECT_DEBIT_SUCCESS_HEADING
       /// Success message that is shown to a user who has just nominated their bank account.
        case DIRECT_DEBIT_SUCCESS_MESSAGE
       /// Button that takes you back to my payment that is shown after a user has successfully nominated their bank account.
        case DIRECT_DEBIT_SUCCESS_BUTTON
       /// Button that cancels direct debit flow.
        case DIRECT_DEBIT_DISMISS_BUTTON
       /// Title of direct debit setup screen when a user already has a bank account.
        case DIRECT_DEBIT_SETUP_CHANGE_SCREEN_TITLE
       /// Title of alert after user has clicked the dismiss button.
        case DIRECT_DEBIT_DISMISS_ALERT_TITLE
       /// Message that is shown inside an alert when the user clicked the dismiss button.
        case DIRECT_DEBIT_DISMISS_ALERT_MESSAGE
       /// Action that confirms that the user want's to dismiss.
        case DIRECT_DEBIT_DISMISS_ALERT_CONFIRM_ACTION
       /// Button that cancels the alert and keeps the user on the same screen.
        case DIRECT_DEBIT_DISMISS_ALERT_CANCEL_ACTION
       /// My coinsured row title
        case PROFILE_MY_COINSURED_ROW_TITLE
       /// Row subtitle for my coinsured
        case PROFILE_MY_COINSURED_ROW_SUBTITLE(amountCoinsured: LocalizationStringConvertible)
       /// Title of sublabel shown under amount of coinsured.
        case MY_COINSURED_SCREEN_CIRCLE_SUBLABEL
       /// Title of the my coinsured feature is coming soon
        case MY_COINSURED_COMING_SOON_TITLE
       /// Body of my coinsured feature is coming soon message
        case MY_COINSURED_COMING_SOON_BODY
       /// Title of my home screen
        case MY_HOME_TITLE
       /// Section title for my home page for section showing details about the user's home.
        case MY_HOME_SECTION_TITLE
       /// Key title for address row.
        case MY_HOME_ADDRESS_ROW_KEY
       /// Title for postal code row.
        case MY_HOME_ROW_POSTAL_CODE_KEY
       /// Title for type of residence.
        case MY_HOME_ROW_TYPE_KEY
       /// Value for my home row, when type of housing is rental.
        case MY_HOME_ROW_TYPE_RENTAL_VALUE
       /// Value for condominium type of housing.
        case MY_HOME_ROW_TYPE_CONDOMINIUM_VALUE
       /// Generic message that is shown when something is unknown.
        case GENERIC_UNKNOWN
       /// Button that takes the user to the chat to ask about changing insurance info.
        case MY_HOME_CHANGE_INFO_BUTTON
       /// Title of direct debit setup for the first time.
        case DIRECT_DEBIT_SETUP_SCREEN_TITLE
       /// Button that opens direct debit flow that replaces bank account
        case MY_PAYMENT_DIRECT_DEBIT_REPLACE_BUTTON
       /// Button that opens direct debit flow for first time.
        case MY_PAYMENT_DIRECT_DEBIT_BUTTON
       /// Date of next payment
        case MY_PAYMENT_DATE(paymentDate: LocalizationStringConvertible)
       /// Type of payment
        case MY_PAYMENT_TYPE
       /// Payment not connected row key
        case MY_PAYMENT_NOT_CONNECTED
       /// Title of alert that is shown after the user has clicked the cancel button.
        case MY_INFO_CANCEL_ALERT_TITLE
       /// Message that is shown on alert when user has clicked the cancel button.
        case MY_INFO_CANCEL_ALERT_MESSAGE
       /// Button that confirms that the user want to cancel the current action.
        case MY_INFO_CANCEL_ALERT_BUTTON_CONFIRM
       /// Button that cancels and takes user back to the previous state.
        case MY_INFO_CANCEL_ALERT_BUTTON_CANCEL
       /// Error that is shown when email format is not correct.
        case MY_INFO_EMAIL_MALFORMED_ERROR
       /// Message that is shown when email field is left empty.
        case MY_INFO_EMAIL_EMPTY_ERROR
       /// Button that is shown as the single action when saving failed.
        case MY_INFO_ALERT_SAVE_FAILURE_BUTTON
       /// Title of alert that is shown after saving failed.
        case MY_INFO_ALERT_SAVE_FAILURE_TITLE
       /// Button that cancels ongoing editing.
        case MY_INFO_CANCEL_BUTTON
       /// Error message that is shown to the user when the phone number is malformed.
        case MY_INFO_PHONE_NUMBER_MALFORMED_ERROR
       /// Message that is shown to the user when they haven't entered their phone number.
        case MY_INFO_PHONE_NUMBER_EMPTY_ERROR
       /// Label for member id row.
        case ABOUT_MEMBER_ID_ROW_KEY
       /// Button that saves current state.
        case MY_INFO_SAVE_BUTTON
       /// Value to show inside deductible circle that is shown alongside monthlyCost
        case MY_PAYMENT_DEDUCTIBLE_CIRCLE
       /// Message that is shown when a bank account is in an updating phase.
        case MY_PAYMENT_UPDATING_MESSAGE
       /// Screen title for my coinsured
        case MY_COINSURED_TITLE
       /// Title of alert that is shown after a user clicks "change info".
        case MY_HOME_CHANGE_ALERT_TITLE
       /// Message for alert that is shown when the customer pressed change home information
        case MY_HOME_CHANGE_ALERT_MESSAGE
       /// Button that cancels the alert
        case MY_HOME_CHANGE_ALERT_ACTION_CANCEL
       /// Button that confirms the alert and takes the user to the chat to change home details
        case MY_HOME_CHANGE_ALERT_ACTION_CONFIRM
       /// The email to the iOS developers
        case FEEDBACK_IOS_EMAIL
       /// The title of the feedback screen
        case FEEDBACK_SCREEN_TITLE
       /// The label located at the top of the feedback screen
        case FEEDBACK_SCREEN_LABEL
       /// The title of the row for reporting a bug
        case FEEDBACK_SCREEN_REPORT_BUG_TITLE
       /// The title of the row that lets you review the app
        case FEEDBACK_SCREEN_REVIEW_APP_TITLE
       /// The value of the row that lets you review the app
        case FEEDBACK_SCREEN_REVIEW_APP_VALUE
       /// The attached .txt file in bug report emails
        case FEEDBACK_SCREEN_REPORT_BUG_EMAIL_ATTACHMENT(appVersion: LocalizationStringConvertible, device: LocalizationStringConvertible, memberId: LocalizationStringConvertible, systemName: LocalizationStringConvertible, systemVersion: LocalizationStringConvertible)
       /// Error alert title that is presented when a MailView can't send mail
        case MAIL_VIEW_CANT_SEND_ALERT_TITLE
       /// Message that is shown when we can't open mail.
        case MAIL_VIEW_CANT_SEND_ALERT_MESSAGE
       /// Button that acknowledges
        case MAIL_VIEW_CANT_SEND_ALERT_BUTTON
       /// URL for reviewing app on app store
        case APP_STORE_REVIEW_URL
       /// The label shown when all stories on marketing screens has been shown above the button but below the Hedvig face
        case MARKETING_SCREEN_SAY_HELLO
       /// Title of alert that is shown after trustly wants to open bankid and that failed
        case TRUSTLY_MISSING_BANK_ID_APP_ALERT_TITLE
       /// Message that is shown when trustly tried to open bankId and that didn't work
        case TRUSTLY_MISSING_BANK_ID_APP_ALERT_MESSAGE
       /// Action that acks alert
        case TRUSTLY_MISSING_BANK_ID_APP_ALERT_ACTION
       /// The text in the button that allows you to change the start date of your insurance.
        case OFFER_BUBBLES_START_DATE_CHANGE_BUTTON
       /// The title of the draggable overlay for changing start date
        case OFFER_BUBBLES_START_DATE_CHANGE_TITLE
       /// The heading text of the draggable overlay that lets you change the start date
        case OFFER_BUBBLES_START_DATE_CHANGE_HEADING
       /// The text of the confirm button in the draggable overlay that lets you change the start date.
        case OFFER_BUBBLES_START_DATE_CHANGE_CONFIRM
       /// The text of the reset button (for new members) in the draggable overlay that lets you change the start date.
        case OFFER_BUBBLES_START_DATE_CHANGE_RESET_NEW
       /// The text of the reset button (for switchers) in the draggable overlay that lets you change the start date.
        case OFFER_BUBBLES_START_DATE_CHANGE_RESET_SWITCHER
       /// The title of the screen `Profile`
        case PROFILE_TITLE
       /// Title for referrals row
        case REFERRALS_ROW_TITLE(incentive: LocalizationStringConvertible)
       /// Subtitle for referrals row.
        case REFERRALS_ROW_SUBTITLE
       /// Title on referrals screen
        case REFERRALS_TITLE
       /// Title of referrals offering towards sender
        case REFERRALS_OFFER_SENDER_TITLE
       /// Title of referrals offering towards receiver
        case REFERRALS_OFFER_RECEIVER_TITLE
       /// Value of what receiver gets
        case REFERRALS_OFFER_RECEIVER_VALUE(incentive: LocalizationStringConvertible)
       /// What the sender gets from the referral
        case REFERRALS_OFFER_SENDER_VALUE(incentive: LocalizationStringConvertible)
       /// Title of referrals screen
        case REFERRALS_SCREEN_TITLE
       /// Text on button that opens the share sheet
        case REFERRALS_SHARE_BUTTON
       /// Message that is shared with the receiver
        case REFERRALS_SHARE_MESSAGE(incentive: LocalizationStringConvertible, link: LocalizationStringConvertible)
       /// Title of row that takes you to the website to read the terms
        case REFERRALS_TERMS_ROW_TITLE
       /// Url to the terms page
        case REFERRALS_TERMS_WEBSITE_URL
       /// Title of social media share information
        case REFERRAL_SHARE_SOCIAL_TITLE
       /// Description to show when the link is shared on social media
        case REFERRAL_SHARE_SOCIAL_DESCRIPTION
       /// Landing page for desktop users when opening dynamic link
        case REFERRALS_DYNAMIC_LINK_LANDING(incentive: LocalizationStringConvertible, memberId: LocalizationStringConvertible)
       /// Key text for the living space row
        case MY_HOME_ROW_SIZE_KEY
       /// The value for the living space row
        case MY_HOME_ROW_SIZE_VALUE(livingSpace: LocalizationStringConvertible)
       /// The title of the "My Charity" info button
        case PROFILE_MY_CHARITY_INFO_BUTTON
       /// The title of the charity information overlay
        case PROFILE_MY_CHARITY_INFO_TITLE
       /// The text describing how charity works with Hedvig
        case PROFILE_MY_CHARITY_INFO_BODY
       /// Value next to checkmark showing the deductible
        case DASHBOARD_DEDUCTIBLE_FOOTNOTE
       /// Deductible info on the More info dropdown on dashboard
        case DASHBOARD_INFO_DEDUCTIBLE
       /// Header for the chat actions section in Dashboard
        case DASHBOARD_CHAT_ACTIONS_HEADER
       /// Insurance is active shown on dashboard
        case DASHBOARD_INSURANCE_STATUS
       /// Footer text for a peril category
        case DASHBOARD_PERIL_FOOTER
       /// Total insurance coverage on More section in Dashboard
        case DASHBOARD_INFO_INSURANCE_AMOUNT
       /// Travel coverage info on More section in Dashboard
        case DASHBOARD_INFO_TRAVEL
       /// Header for More section on Dashboard
        case DASHBOARD_INFO_HEADER
       /// Subtitle for More section on Dashboard
        case DASHBOARD_INFO_SUBHEADER
       /// Header for the Pending insurance section on Dashboard
        case DASHBOARD_PENDING_HEADER
       /// More info button text for pending insurance on Dashobard
        case DASHBOARD_PENDING_MORE_INFO
       /// Less info button for pending insurance on Dashboard
        case DASHBOARD_PENDING_LESS_INFO
       /// Info about payment setup on Dashboard
        case DASHBOARD_PAYMENT_SETUP_INFO
       /// Button to setup payment on Dashboard
        case DASHBOARD_PAYMENT_SETUP_BUTTON
       /// More info text on pending insurance when starting date is known
        case DASHBOARD_PENDING_HAS_DATE(date: LocalizationStringConvertible)
       /// More info text on pending insurance on Dashboard when date is unknown
        case DASHBOARD_PENDING_NO_DATE
       /// Months letter for countdown
        case DASHBOARD_PENDING_MONTHS
       /// Days letter for dashboard countdown
        case DASHBOARD_PENDING_DAYS
       /// Hours letter for dashboard countdown
        case DASHBOARD_PENDING_HOURS
       /// Minutes letter for dashboard countdown
        case DASHBOARD_PENDING_MINUTES
       /// The Sign button with a BankID symbol on the Offer Screen
        case OFFER_BANKID_SIGN_BUTTON
       /// Message to show to user when acknowledning the honesty pledge
        case HONESTY_PLEDGE_DESCRIPTION
       /// Title of honesty pledge overlay
        case HONESTY_PLEDGE_TITLE
       /// Title for the Claims tab header
        case CLAIMS_HEADER_TITLE
       /// Subtitle for the Claims tab header
        case CLAIMS_HEADER_SUBTITLE
       /// Button text for start claim button
        case CLAIMS_HEADER_ACTION_BUTTON
       /// Header text for quick choices on Claims screen
        case CLAIMS_QUICK_CHOICE_HEADER
       /// Title of dashboard screen
        case DASHBOARD_SCREEN_TITLE
       /// Title of emergency call me action
        case EMERGENCY_CALL_ME_TITLE
       /// Description of emergency call me action
        case EMERGENCY_CALL_ME_DESCRIPTION
       /// Button title of emergency call me action
        case EMERGENCY_CALL_ME_BUTTON
       /// Title of emergency abroad action
        case EMERGENCY_ABROAD_TITLE
       /// Description of emergency abroad action
        case EMERGENCY_ABROAD_DESCRIPTION
       /// Button title on emergency abroad action
        case EMERGENCY_ABROAD_BUTTON
       /// Phone number to Hedvig Global Assistance, used to open a popup asking if the user should call the number.
        case EMERGENCY_ABROAD_BUTTON_ACTION_PHONE_NUMBER
       /// Title of alert that is shown when a device doesn't support calling to Hedvig Global Assistance
        case EMERGENCY_ABROAD_ALERT_NON_PHONE_TITLE
       /// Button that closes alert
        case EMERGENCY_ABROAD_ALERT_NON_PHONE_OK_BUTTON
       /// Title of unsure action
        case EMERGENCY_UNSURE_TITLE
       /// Description of unsure action
        case EMERGENCY_UNSURE_DESCRIPTION
       /// Button of unsure action that opens the chat
        case EMERGENCY_UNSURE_BUTTON
       /// Title of claims screen
        case CLAIMS_SCREEN_TITLE
       /// Title of claims screen tab
        case CLAIMS_SCREEN_TAB
       /// Message that is shown when the user is inactive and visits the claims tab
        case CLAIMS_INACTIVE_MESSAGE
       /// Title of call me chat
        case CALL_ME_CHAT_TITLE
       /// Title of claims chat
        case CLAIMS_CHAT_TITLE
       /// Button that opens chat from the preview
        case CHAT_PREVIEW_OPEN_CHAT
       /// Action that open camera roll
        case UPLOAD_FILE_IMAGE_OR_VIDEO_ACTION
       /// Title of alert that asks for the type of file the user want's to upload
        case UPLOAD_FILE_SELECT_TYPE_TITLE
       /// Cancels bottom sheet that asks for the type of file to upload
        case UPLOAD_FILE_TYPE_CANCEL
       /// Action that opens document picker
        case UPLOAD_FILE_FILE_ACTION
       // TODO:
        case FEATURE_PROMO_TITLE
       // TODO:
        case FEATURE_PROMO_HEADLINE
       // TODO:
        case FEATURE_PROMO_BODY
       // TODO:
        case FEATURE_PROMO_BTN
       // TODO:
        case REFERRAL_PROGRESS_TOPBAR_TITLE
       // TODO:
        case REFERRAL_PROGRESS_TOPBAR_BUTTON
       // TODO:
        case REFERRAL_PROGRESS_BAR_CTA
       // TODO:
        case REFERRAL_PROGRESS_CURRENT_PREMIUM_PRICE(currentPremiumPrice: LocalizationStringConvertible)
       // TODO:
        case REFERRAL_PROGRESS_FREE
       // TODO:
        case REFERRAL_PROGRESS_HEADLINE
       // TODO:
        case REFERRAL_PROGRESS_BODY(referralValue: LocalizationStringConvertible)
       // TODO:
        case REFERRAL_PROGRESS_CODE_TITLE
       // TODO:
        case REFERRAL_INVITE_TITLE
       // TODO:
        case REFERRAL_INVITE_EMPTYSTATE_TITLE
       // TODO:
        case REFERRAL_INVITE_EMPTYSTATE_DESCRIPTION
       // TODO:
        case REFERRAL_SHAREINVITE
       // TODO:
        case REFERRAL_SMS_MESSAGE(referralLink: LocalizationStringConvertible, referralValue: LocalizationStringConvertible)
       // TODO:
        case REFERRAL_INVITE_NEWSTATE
       // TODO:
        case REFERRAL_INVITE_STARTEDSTATE
       // TODO:
        case REFERRAL_INVITE_QUITSTATE
       // TODO:
        case REFERRAL_INVITE_INVITEDYOUSTATE
       // TODO:
        case REFERRAL_INVITE_ANON
       // TODO:
        case REFERRAL_INVITE_ANONS
       // TODO:
        case REFERRAL_PROGRESS_EDGECASE_HEADLINE
       // TODO:
        case REFERRAL_SUCCESS_HEADLINE(user: LocalizationStringConvertible)
       // TODO:
        case REFERRAL_SUCCESS_HEADLINE_MULTIPLE(numberOfUsers: LocalizationStringConvertible)
       // TODO:
        case REFERRAL_SUCCESS_BODY(referralValue: LocalizationStringConvertible)
       // TODO:
        case REFERRAL_SUCCESS_BTN_CTA
       // TODO:
        case REFERRAL_SUCCESS_BTN_CLOSE
       // TODO:
        case REFERRAL_ULTIMATE_SUCCESS_TITLE
       // TODO:
        case REFERRAL_ULTIMATE_SUCCESS_BODY
       // TODO:
        case REFERRAL_ULTIMATE_SUCCESS_BTN_CTA
       // TODO:
        case REFERRAL_INVITE_OPENEDSTATE
       /// Label containing value of active referral in list of referrals on Referral screen
        case REFERRAL_INVITE_ACTIVE_VALUE(referralValue: LocalizationStringConvertible)
       /// Web landing page web onboarding button
        case REFERRAL_LANDINGPAGE_BTN_WEB
       /// Fullsize startscreen pop up headline
        case REFERRAL_STARTSCREEN_HEADLINE(referralValue: LocalizationStringConvertible)
       /// Fullsize startscreen pop up body copy
        case REFERRAL_STARTSCREEN_BODY(referralValue: LocalizationStringConvertible)
       /// Fullsize startscreen pop up CTA button
        case REFERRAL_STARTSCREEN_BTN_CTA
       /// Fullsize startscreen pop up skip button
        case REFERRAL_STARTSCREEN_BTN_SKIP
       /// Offer screen discount headline
        case REFERRAL_OFFER_DISCOUNT_HEADLINE
       /// Offer screen discount body
        case REFERRAL_OFFER_DISCOUNT_BODY(referralValue: LocalizationStringConvertible)
       /// Add coupon draggable overlay headline
        case REFERRAL_ADDCOUPON_HEADLINE
       /// Add coupon draggable overlay body
        case REFERRAL_ADDCOUPON_BODY
       /// Add coupon draggable input form placeholder text
        case REFERRAL_ADDCOUPON_INPUTPLACEHOLDER
       /// Add coupon draggable submit button
        case REFERRAL_ADDCOUPON_BTN_SUBMIT
       /// Add coupon draggable terms & conditions
        case REFERRAL_ADDCOUPON_TC(termsAndConditionsLink: LocalizationStringConvertible)
       /// Add coupon error headline
        case REFERRAL_ERROR_MISSINGCODE_HEADLINE
       /// Add coupon error body
        case REFERRAL_ERROR_MISSINGCODE_BODY
       /// Add coupon error button
        case REFERRAL_ERROR_MISSINGCODE_BTN
       /// Add coupon error replace code headline
        case REFERRAL_ERROR_REPLACECODE_HEADLINE
       /// Add coupon error replace code body
        case REFERRAL_ERROR_REPLACECODE_BODY
       /// Add coupon error replace code cancel button
        case REFERRAL_ERROR_REPLACECODE_BTN_CANCEL
       /// Add coupon error replace code submit button
        case REFERRAL_ERROR_REPLACECODE_BTN_SUBMIT
       /// Welcome screen after sign up headline
        case REFERRAL_RECIEVER_WELCOME_HEADLINE(user: LocalizationStringConvertible)
       /// Welcome screen after sign up body
        case REFERRAL_RECIEVER_WELCOME_BODY(referralValue: LocalizationStringConvertible)
       /// Welcome screen after sign up, invite friends button
        case REFERRAL_RECIEVER_WELCOME_BTN_CTA
       /// Welcome screen after sign up, skip button
        case REFERRAL_RECIEVER_WELCOME_BTN_SKIP
       /// New title of the profile row for Referrals
        case PROFILE_ROW_NEW_REFERRAL_TITLE
       /// New description of the profile row for Referrals
        case PROFILE_ROW_NEW_REFERRAL_DESCRIPTION
       /// Proceed button in the What's new-screen
        case NEWS_PROCEED
       /// Dismiss button in the What's new-screen
        case NEWS_DISMISS
       /// Headline on screen that is shown after a receiever has opened a link
        case REFERRAL_LINK_INVITATION_SCREEN_HEADLINE(name: LocalizationStringConvertible, referralValue: LocalizationStringConvertible)
       /// Body on screen that is shown after a receiever has opened a link
        case REFERRAL_LINK_INVITATION_SCREEN_BODY
       /// Button that accepts discount
        case REFERRAL_LINK_INVITATION_SCREEN_BTN_ACCEPT
       /// Button that declines discount
        case REFERRAL_LINK_INVITATION_SCREEN_BTN_DECLINE
       /// Title for the News screen
        case NEWS_TITLE
       /// Description for the close button on the News screen
        case NEWS_CLOSE_DESCRIPTION
       /// When the user has a high premium the pogress tank view gets replaced by a card, this is then used to show the discount
        case REFERRAL_PROGRESS_HIGH_PREMIUM_DISCOUNT(discountValue: LocalizationStringConvertible)
       /// When the user has a high premium the pogress tank view gets replaced by a card, this is then used to show the discount period
        case REFERRAL_PROGRESS_HIGH_PREMIUM_DISCOUNT_SUBTITLE
       /// When the user has a high premium the pogress tank view gets replaced by a card, this is then used to show the montly cost
        case REFERRAL_PROGRESS_HIGH_PREMIUM_DESCRIPTION(monthlyCost: LocalizationStringConvertible)
       /// Label for the price on the profile subscreen Payment
        case PROFILE_PAYMENT_PRICE_LABEL
       /// The price on the profile subscreen Payment
        case PROFILE_PAYMENT_PRICE(price: LocalizationStringConvertible)
       /// The label for the discount on the profile subscreen Payment
        case PROFILE_PAYMENT_DISCOUNT_LABEL
       /// The discount on the profile subscreen Payment
        case PROFILE_PAYMENT_DISCOUNT(discount: LocalizationStringConvertible)
       /// The label for the final cost on the profile subscreen Payment
        case PROFILE_PAYMENT_FINAL_COST_LABEL
       /// The final cost on the profile subscreen Payment
        case PROFILE_PAYMENT_FINAL_COST(finalCost: LocalizationStringConvertible)
       /// Button to open What's new on the profile subscreen About App
        case PROFILE_ABOUT_APP_OPEN_WHATS_NEW
       /// Alert that asks if the user wants to turn on push notifications
        case PUSH_NOTIFICATIONS_ALERT_TITLE
       /// Alert that asks if the user wants to turn on push notifications
        case PUSH_NOTIFICATIONS_ALERT_MESSAGE
       /// Alert that asks if the user wants to turn on push notifications
        case PUSH_NOTIFICATIONS_ALERT_ACTION_OK
       /// Alert that asks if the user wants to turn on push notifications
        case PUSH_NOTIFICATIONS_ALERT_ACTION_NOT_NOW
       /// Link to website where you can read referrals terms
        case REFERRALS_RECEIVER_TERMS_LINK
       /// Headline of the More Info draggable overlay
        case REFERRAL_PROGRESS_MORE_INFO_HEADLINE
       /// First paragraph of the More Info draggable overlay
        case REFERRAL_PROGRESS_MORE_INFO_PARAGRAPH_ONE(referralValue: LocalizationStringConvertible)
       /// Second paragraph of the More Info draggable overlay
        case REFERRAL_PROGRESS_MORE_INFO_PARAGRAPH_TWO
       /// CTA of the More Info draggable overlay, leads to the T&C's
        case REFERRAL_PROGRESS_MORE_INFO_CTA
       /// Text for the More Info draggable overlay
        case REFERRAL_PROGRESS_MORE_INFO_PARAGRAPH(referralValue: LocalizationStringConvertible)
       /// Button to remove an applied discount on the Offer screen
        case OFFER_REMOVE_DISCOUNT_BUTTON
       /// Button to add a discount on the Offer screen
        case OFFER_ADD_DISCOUNT_BUTTON
       /// Text for colored label inside REFERRAL_ADDCOUPON_TC
        case REFERRAL_ADDCOUPON_TC_LINK
       /// Label on the bubble shown if a user has been invited through referrals
        case OFFER_SCREEN_INVITED_BUBBLE
       /// Alert that is shown when the insurance has been terminated
        case INSURANCE_STATUS_TERMINATED_ALERT_TITLE
       /// Alert that is shown when the insurance has been terminated
        case INSURANCE_STATUS_TERMINATED_ALERT_MESSAGE
       /// Alert that is shown when the insurance has been terminated
        case INSURANCE_STATUS_TERMINATED_ALERT_ACTION_CHAT
       /// Title of the alert shown when the user tries to remove the discount on the Offer screen
        case OFFER_REMOVE_DISCOUNT_ALERT_TITLE
       /// Description of the alert shown when the user tries to remove the discount on the Offer screen
        case OFFER_REMOVE_DISCOUNT_ALERT_DESCRIPTION
       /// Label on the remove button of the alert shown when the user tries to remove the discount on the Offer screen
        case OFFER_REMOVE_DISCOUNT_ALERT_REMOVE
       /// Label on the cancel button of the alert shown when the user tries to remove the discount on the Offer screen
        case OFFER_REMOVE_DISCOUNT_ALERT_CANCEL
       /// Message shown after user has copied the code on the profile subscreen Referral
        case REFERRAL_INVITE_CODE_COPIED_MESSAGE
       /// Link to website for more info about referrals
        case REFERRAL_MORE_INFO_LINK
       /// Fallback when we couldn't get the price
        case PRICE_MISSING
       /// Alert that is shown when the insurance has been terminated, button label
        case INSURANCE_STATUS_TERMINATED_ALERT_CTA
       /// Title of referrals tab
        case TAB_REFERRALS_TITLE
       /// Button that continues in chat
        case MARKETING_GET_HEDVIG
       /// Button that logs the user in
        case MARKETING_LOGIN
       /// Title for referred by sectin in referal screen
        case REFERRAL_REFERRED_BY_TITLE
       /// moderna insurance
        case MODERNA_FORSAKRING_APP
       /// ICA insurance
        case ICA_FORSAKRING_APP
       /// other insurer
        case OTHER_INSURER_OPTION_APP
       /// sign with mobile bank id
        case SIGN_MOBILE_BANK_ID
       /// Hedvig cannot switch member, they need to cancel their old policy
        case OFFER_NON_SWITCHABLE_PARAGRAPH_ONE_APP
       /// Hedvig can switch members insurance
        case OFFER_SWITCH_COL_PARAGRAPH_ONE_APP
       /// when Hedvig will be activated
        case OFFER_SWITCH_COL_THREE_PARAGRAPH_APP
       /// title for members that can be swtiched
        case OFFER_SWITCH_TITLE_APP(insurer: LocalizationStringConvertible)
       /// title for members that cannot be swtiched
        case OFFER_SWITCH_TITLE_NON_SWITCHABLE_APP
       /// Ghost row multiple
        case REFERRAL_INVITE_OPENEDSTATE_MULTIPLE(numberOfInvites: LocalizationStringConvertible)
       /// Proceed button in the "Welcome"-screen
        case NEW_MEMBER_PROCEED
       /// Dismiss button in the "Welcome"-screen
        case NEW_MEMBER_DISMISS
       /// Hint on upload file button in Chat
        case UPLOAD_FILE_BUTTON_HINT
       /// Copy text on copy action sheet for referrals code
        case REFERRALS_CODE_SHEET_COPY
        case REFERRAL_PROGRESS_HIGH_PREMIUM_DISCOUNT_NO_MINUS(discountValue: LocalizationStringConvertible)
       /// Redeem code alert headline
        case REFERRAL_REDEEM_SUCCESS_HEADLINE
       /// Redeem code success alert body
        case REFERRAL_REDEEM_SUCCESS_BODY
       /// Redeem code success alert button
        case REFERRAL_REDEEM_SUCCESS_BTN
       /// Alert for notifications on referral share
        case PUSH_NOTIFICATIONS_REFERRALS_ALERT_MESSSAGE
       /// Accessibilty hint for record button for Audio recordings in Chat
        case AUDIO_INPUT_RECORD_DESCRIPTION
       /// Accessibility int for stop button for Audio recordings in Chat
        case AUDIO_INPUT_STOP_DESCRIPTION
       /// Label shown beside the record button for Audio recordings in Chat
        case AUDIO_INPUT_START_RECORDING
       /// Label showing progress while playing back an Audio recording in Chat
        case AUDIO_INPUT_PLAYBACK_PROGRESS(seconds: LocalizationStringConvertible)
       /// Body of successfully saved message on profile/my info
        case PROFILE_MY_INFO_SAVE_SUCCESS_TOAST_BODY
       /// The symbol of the successfully saved profile/my info message
        case PROFILE_MY_INFO_SAVE_SUCCESS_TOAST_SYMBOL
       /// Title of the alert shown when user tries to edit their message in Chat
        case CHAT_EDIT_MESSAGE_TITLE
       /// Submit text for the alert shown when the user tries to edit their message in Chat
        case CHAT_EDIT_MESSAGE_SUBMIT
       /// Cancel text for the alert shown when the user tries to edit their message in Chat
        case CHAT_EDIT_MESSAGE_CANCEL
       /// Accesibility hint for the edit message button in Chat
        case CHAT_EDIT_MESSAGE_DESCRIPTION
       /// Message that is shown when something is copied
        case COPIED
        case OFFER_SCREEN_FREE_MONTHS_BUBBLE(freeMonth: LocalizationStringConvertible)
        case OFFER_SCREEN_FREE_MONTHS_BUBBLE_TITLE
       /// Message to show on Free Until row
        case MY_PAYMENT_FREE_UNTIL_MESSAGE
        case BANK_ID_AUTH_TITLE_INITIATED
       /// Title for the terms section in the Offer screen
        case OFFER_TERMS_TITLE
        case OFFER_TERMS_NO_BINDING_PERIOD
        case OFFER_TERMS_NO_COVERAGE_LIMIT
        case OFFER_TERMS_MAX_COMPENSATION(maxCompensation: LocalizationStringConvertible)
        case OFFER_TERMS_DEDUCTIBLE(deductible: LocalizationStringConvertible)
        case OFFER_PRESALE_INFORMATION
        case OFFER_TERMS
        case OFFER_PRIVACY_POLICY
       /// Price per month label in the price bubble of the Offer screen
        case OFFER_PRICE_PER_MONTH
       /// Label shown when user must start the bankid-app
        case SIGN_START_BANKID
       /// Label shown when signing was succesful
        case SIGN_SUCCESSFUL
       /// Label shown when signing is in progress
        case SIGN_IN_PROGRESS
       /// Label shown when signing was canceled
        case SIGN_CANCELED
       /// Label shown when signing failed for an unknown reason
        case SIGN_FAILED_REASON_UNKNOWN
       /// Message shown when the user attempts to log in but no bankid is installed on the device
        case BANK_ID_NOT_INSTALLED
       /// Accessibility hint for the button that opens the chat in the Offer screen
        case OFFER_CHAT_ACCESSIBILITY_HINT
       /// Hint for the text field to search for gifs in the Chat
        case CHAT_GIPHY_SEARCH_HINT
       /// Accessibility label for the hedvig logo on the Marketing screen
        case MARKETING_LOGO_ACCESSIBILITY
       /// Dashboard renewal prompter title
        case DASHBOARD_RENEWAL_PROMPTER_TITLE
       /// Dashboard renewal prompter body copy
        case DASHBOARD_RENEWAL_PROMPTER_BODY(daysUntilRenewal: LocalizationStringConvertible)
       /// Dashboard renewal prompter Button text
        case DASHBOARD_RENEWAL_PROMPTER_CTA
       /// Title in info box shown when the user needs to connect direct debit
        case DASHBOARD_SETUP_DIRECT_DEBIT_TITLE
       /// Accessibility label for the close button on the info box on the Dashboard
        case DASHBOARD_INFO_BOX_CLOSE_DESCRIPTION
       /// Connect DD Prompt Headline
        case ONBOARDING_CONNECT_DD_HEADLINE
       /// Connect DD Prompt body
        case ONBOARDING_CONNECT_DD_BODY
       /// Connect DD Prompt body for switchers
        case ONBOARDING_CONNECT_DD_BODY_SWITCHERS
       /// Connect DD Prompt CTA
        case ONBOARDING_CONNECT_DD_CTA
       /// Skip button for Trustly flow
        case TRUSTLY_SKIP_BUTTON
       /// Activate notifications Statement before the headline
        case ONBOARDING_ACTIVATE_NOTIFICATIONS_PRE_HEADLINE
       /// Activate notifications headline
        case ONBOARDING_ACTIVATE_NOTIFICATIONS_HEADLINE
       /// Activate notifications body
        case ONBOARDING_ACTIVATE_NOTIFICATIONS_BODY
       /// Activate notifications CTA
        case ONBOARDING_ACTIVATE_NOTIFICATIONS_CTA
       /// Activate notifications Dismiss
        case ONBOARDING_ACTIVATE_NOTIFICATIONS_DISMISS
       /// Connect DD Prompt Statement before the headline
        case ONBOARDING_CONNECT_DD_PRE_HEADLINE
       /// the maximum compensation for items in the home for student insurance
        case MAX_COMPENSATION_STUDENT
       /// the maximum compensation for items in the home for regular insurance
        case MAX_COMPENSATION
       /// The deductible for the home insurance product
        case DEDUCTIBLE
       /// Title for alert when skipping trustly flow
        case TRUSTLY_ALERT_TITLE
       /// Body copy for alert when skipping trustly flow
        case TRUSTLY_ALERT_BODY
       /// Action to skip the trustly flow
        case TRUSTLY_ALERT_POSITIVE_ACTION
       /// Action to resume the trustly flow
        case TRUSTLY_ALERT_NEGATIVE_ACTION
       /// url to privacy policy
        case PRIVACY_POLICY_URL
       /// Connect DD Success Headline
        case ONBOARDING_CONNECT_DD_SUCCESS_HEADLINE
       /// Connect DD Success Body
        case ONBOARDING_CONNECT_DD_SUCCESS_BODY
       /// Connect DD Success Button
        case ONBOARDING_CONNECT_DD_SUCCESS_CTA
       /// Connect DD Failure Headline
        case ONBOARDING_CONNECT_DD_FAILURE_HEADLINE
       /// Connect DD Failure Body
        case ONBOARDING_CONNECT_DD_FAILURE_BODY
       /// Connect DD Failure CTA to try again
        case ONBOARDING_CONNECT_DD_FAILURE_CTA_RETRY
       /// Connect DD Failure button to skip for now
        case ONBOARDING_CONNECT_DD_FAILURE_CTA_LATER
       /// Title of alert that informs the user of inactivity
        case BANKID_INACTIVE_TITLE
       /// Alert message that is shown when bankid is cancelled due to inactivity
        case BANKID_INACTIVE_MESSAGE
       /// Button that acks that bankid became inactive
        case BANKID_INACTIVE_BUTTON
       /// Connect direct debit with link option in payment screen
        case PROFILE_PAYMENT_CONNECT_DIRECT_DEBIT_WITH_LINK_BUTTON
       /// Label in honestly pledge slider
        case CLAIMS_PLEDGE_SLIDE_LABEL
       /// Button that starts demo mode
        case DEMO_MODE_START
       /// Button that closes sheet where you can start demo mode
        case DEMO_MODE_CANCEL
       /// Title of screen saying that BankId is missing
        case BANKID_MISSING_TITLE
       /// Message saying that you need to scan QR code with the device where bankid is installed
        case BANKID_MISSING_MESSAGE
       /// Alert confirming restart
        case CHAT_RESTART_ALERT_TITLE
       /// Message confirming restart of chat
        case CHAT_RESTART_ALERT_MESSAGE
       /// Button that confirms reset
        case CHAT_RESTART_ALERT_CONFIRM
       /// Button that cancels reset of chat
        case CHAT_RESTART_ALERT_CANCEL
       /// Row button that opens login flow
        case SETTINGS_LOGIN_ROW
       /// Title of bankid login screen
        case BANKID_LOGIN_TITLE
       /// Title of row that takes you to the license list
        case ABOUT_LICENSES_ROW
       /// Row that asks to activate push notifications
        case ABOUT_PUSH_ROW
       /// Row that opens intro screens
        case ABOUT_SHOW_INTRO_ROW
       /// Row that opens feedback screen
        case PROFILE_FEEDBACK_ROW
       /// Button that confirms selection of charity option
        case CHARTITY_PICK_OPTION
       /// Row that opens about screen
        case PROFILE_ABOUT_ROW
       /// Page title
        case PAYMENTS_TITLE
       /// Card title
        case PAYMENTS_CARD_TITLE
       /// Current premium with campaign offers
        case PAYMENTS_CURRENT_PREMIUM(currentPremium: LocalizationStringConvertible)
       /// Date when next payment is due
        case PAYMENTS_CARD_DATE
       /// Flag text for no start date
        case PAYMENTS_CARD_NO_STARTDATE
       /// Small headline for Previous payments
        case PAYMENTS_SUBTITLE_PREVIOUS_PAYMENTS
       /// Button text to view payment history
        case PAYMENTS_BTN_HISTORY
       /// Small headline for Payment method
        case PAYMENTS_SUBTITLE_PAYMENT_METHOD
       /// Small headline for Bank account
        case PAYMENTS_SUBTITLE_ACCOUNT
       /// Direct Debit
        case PAYMENTS_DIRECT_DEBIT
       /// If direct debit is active
        case PAYMENTS_DIRECT_DEBIT_ACTIVE
       /// Button text to change bank
        case PAYMENTS_BTN_CHANGE_BANK
       /// Message if you're late with payments
        case PAYMENTS_LATE_PAYMENTS_MESSAGE(monthsLate: LocalizationStringConvertible, nextPaymentDate: LocalizationStringConvertible)
       /// The full amount of your discount
        case PAYMENTS_FULL_PREMIUM(fullPremium: LocalizationStringConvertible)
       /// Small headline for Discount
        case PAYMENTS_SUBTITLE_DISCOUNT
       /// Campaign multiple free months
        case PAYMENTS_OFFER_MULTIPLE_MONTHS
       /// Campaign single free months
        case PAYMENTS_OFFER_SINGLE_MONTH
       /// Small headline for Campaign
        case PAYMENTS_SUBTITLE_CAMPAIGN
       /// From
        case PAYMENTS_CAMPAIGN_OWNER
       /// No start date helper/footer message
        case PAYMENTS_NO_STARTDATE_HELP_MESSAGE
       /// Small headline for Payments history
        case PAYMENTS_SUBTITLE_PAYMENT_HISTORY
       /// Accessibility hint for the Hedvig Wordmark ('hedvig', but in an image)
        case HEDVIG_LOGO_ACCESSIBILITY
       /// Label in illustration that indicates it being free
        case REFERRALS_FREE_LABEL
       /// Label that says to people to invite in illustration
        case REFERRALS_INVITE_LABEL
       /// Price per month label
        case OFFER_PRICE_BUBBLE_MONTH
       /// Discount provider label for Hedvig Zero
        case PAYMENTS_DISCOUNT_ZERO
       /// Template for discount amount
        case PAYMENTS_DISCOUNT_AMOUNT(discount: LocalizationStringConvertible)
       /// Last Free Date-label for Campaign
        case PAYMENTS_CAMPAIGN_LFD
       /// Title for the Payment History Screen
        case PAYMENT_HISTORY_TITLE
       /// Template for payment history item amount
        case PAYMENT_HISTORY_AMOUNT(amount: LocalizationStringConvertible)
       /// If direct debit needs setup
        case PAYMENTS_DIRECT_DEBIT_NEEDS_SETUP
       /// If direct debit is pending
        case PAYMENTS_DIRECT_DEBIT_PENDING
       /// Summary Module Title
        case OFFER_HOUSE_SUMMARY_TITLE(userAdress: LocalizationStringConvertible)
       /// Summary Module Desc
        case OFFER_HOUSE_SUMMARY_DESC
       /// Summary Module Button Expand
        case OFFER_HOUSE_SUMMARY_BUTTON_EXPAND
       /// Summary Module Button Minimize
        case OFFER_HOUSE_SUMMARY_BUTTON_MINIMIZE
       /// USP for your house in the trust section
        case OFFER_HOUSE_TRUST_HOUSE
       /// USP for HDI in the trust section
        case OFFER_HOUSE_TRUST_HDI
       /// House info Boyta
        case HOUSE_INFO_BOYTA
       /// House info Biyta
        case HOUSE_INFO_BIYTA
       /// House info Year built
        case HOUSE_INFO_YEAR_BUILT
       /// House info Bathroom
        case HOUSE_INFO_BATHROOM
       /// House info Rented
        case HOUSE_INFO_RENTED
       /// House info Type
        case HOUSE_INFO_TYPE
       /// House info Extra buildings
        case HOUSE_INFO_EXTRABUILDINGS
       /// House info Garage
        case HOUSE_INFO_GARAGE
       /// House info Shed
        case HOUSE_INFO_SHED
       /// House info Attefalls
        case HOUSE_INFO_ATTEFALLS
       /// House info Misc
        case HOUSE_INFO_MISC
       /// House info Connected water
        case HOUSE_INFO_CONNECTED_WATER
        case MY_HOME_ROW_TYPE_HOUSE_VALUE
        case MY_HOME_ROW_ANCILLARY_AREA_VALUE(area: LocalizationStringConvertible)
        case MY_HOME_ROW_ANCILLARY_AREA_KEY
        case MY_HOME_ROW_CONSTRUCTION_YEAR_KEY
       /// How many bathrooms
        case MY_HOME_ROW_BATHROOMS_KEY
       /// Title of extra buildings section
        case MY_HOME_EXTRABUILDING_TITLE
       /// House info: Boyta in square meters
        case HOUSE_INFO_BOYTA_SQUAREMETERS(houseInfoAmountBoyta: LocalizationStringConvertible)
       /// House info: Biyta in square meters
        case HOUSE_INFO_BIYTA_SQUAREMETERS(houseInfoAmountBiyta: LocalizationStringConvertible)
       /// Offer expiery info
        case OFFER_INFO_OFFER_EXPIRES(offerExpieryDate: LocalizationStringConvertible)
       /// House info: Amount of co-insured
        case HOUSE_INFO_COINSURED
       /// Button that expands an expandable content
        case EXPANDABLE_CONTENT_EXPAND
       /// Collapse the expandable box
        case EXPANDABLE_CONTENT_COLLAPSE
        case OFFER_TRUST_INCREASED_DEDUCTIBLE
       /// House info: Subleted, true
        case HOUSE_INFO_SUBLETED_TRUE
       /// House info: Subleted, false
        case HOUSE_INFO_SUBLETED_FALSE
       /// Offer trust us headline
        case OFFER_INFO_TRUSTUS
       /// The amount of compensation for gadgets
        case HOUSE_INFO_COMPENSATION_GADGETS
       /// Suffix added to building description saying it has water connected
        case MY_HOME_BUILDING_HAS_WATER_SUFFIX(base: LocalizationStringConvertible)
       /// If home its subleted
        case MY_HOME_ROW_SUBLETED_KEY
       /// If home is subleted
        case MY_HOME_ROW_SUBLETED_VALUE_YES
       /// If home is not subleted
        case MY_HOME_ROW_SUBLETED_VALUE_NO
       /// Maximum compensation for house
        case MAX_COMPENSATION_HOUSE
       /// Deductible info for house
        case DASHBOARD_INFO_DEDUCTIBLE_HOUSE(deductible: LocalizationStringConvertible)
       /// Value of covered house
        case DASHBOARD_INFO_HOUSE_VALUE
        case DASHBOARD_INFO_INSURANCE_STUFF_AMOUNT(maxCompensation: LocalizationStringConvertible)
       /// Label for insurance type house on the My Home-screen
        case MY_HOME_INSURANCE_TYPE_HOUSE
       /// Label for city on the My Home-screen
        case MY_HOME_CITY_LABEL
       /// Generic cost per monthly
        case COST_MONTHLY
       /// Title for the safe with us-section in the Offer screen
        case OFFER_TITLE_SAFE_WITH_US
       /// Subtitle that urges user to activate push notifications
        case CHAT_TOAST_PUSH_NOTIFICATIONS_SUBTITLE
       /// Button to send a gif
        case ATTACH_GIF_IMAGE_SEND
       /// Label with text to search for gif
        case LABEL_SEARCH_GIF
       /// Input string in searchbar to show gifs
        case SEARCH_BAR_GIF
        case OFFER_SCREEN_PERCENTAGE_DISCOUNT_BUBBLE_TITLE
        case OFFER_SCREEN_PERCENTAGE_DISCOUNT_BUBBLE_TITLE_SINGULAR(percentage: LocalizationStringConvertible)
        case OFFER_SCREEN_PERCENTAGE_DISCOUNT_BUBBLE_TITLE_PLURAL(months: LocalizationStringConvertible, percentage: LocalizationStringConvertible)
       /// To change starting date
        case OFFER_START_DATE
       /// Todays date when changeing start date
        case OFFER_START_DATE_TODAY
        case CLAIMS_ACTIVATE_NOTIFICATIONS_HEADLINE
       ///
        case CLAIMS_ACTIVATE_NOTIFICATIONS_BODY
        case CLAIMS_ACTIVATE_NOTIFICATIONS_CTA
        case CLAIMS_ACTIVATE_NOTIFICATIONS_DISMISS
       /// Discount sphere text when user has a percentage discount for a single month
        case PAYMENTS_DISCOUNT_PERCENTAGE_MONTHS_MANY(months: LocalizationStringConvertible, percentage: LocalizationStringConvertible)
       /// Discount sphere text when user has a percentage discount for a single month
        case PAYMENTS_DISCOUNT_PERCENTAGE_MONTHS_ONE(percentage: LocalizationStringConvertible)
       /// Title for draggable choose start date
        case DRAGGABLE_STARTDATE_TITLE
       /// Asks what date to start insurance
        case DRAGGABLE_STARTDATE_DESCRIPTION
       /// Button with label activate today
        case ACTIVATE_TODAY_BTN
       /// Button with string
        case ACTIVATE_INSURANCE_END_BTN
       /// Button with text: Choose date
        case CHOOSE_DATE_BTN
       /// Button with string start date
        case START_DATE_BTN
       /// A label with text today
        case START_DATE_TODAY
       /// Button with text continue in Alert
        case ALERT_CONTINUE
       /// Button with text cancel in Alert
        case ALERT_CANCEL
       /// The title in the alert popup
        case ALERT_TITLE_STARTDATE
       /// A message to the user about choosing own startdate in alert pop up
        case ALERT_DESCRIPTION_STARTDATE
       /// Text that tells user that insurance will activate when the current insurer expires
        case START_DATE_EXPIRES
       /// Message to user that payment is late
        case LATE_PAYMENT_MESSAGE(date: LocalizationStringConvertible, months: LocalizationStringConvertible)
       /// Button that starts editing an editable row
        case EDITABLE_ROW_EDIT
       /// Button that saves a currently editing row
        case EDITABLE_ROW_SAVE
       /// The tab title
        case KEY_GEAR_TAB_TITLE
       /// The headline in the empty state
        case KEY_GEAR_START_EMPTY_HEADLINE
       /// The body copy in the empty state
        case KEY_GEAR_START_EMPTY_BODY
       /// The add button text
        case KEY_GEAR_ADD_BUTTON
       /// The added automatically tag
        case KEY_GEAR_ADDED_AUTOMATICALLY_TAG
       /// The More info button in the nav
        case KEY_GEAR_MORE_INFO_BUTTON
       /// The headline in the more info overlay
        case KEY_GEAR_MORE_INFO_HEADLINE
       /// The body copy in the more info overlay
        case KEY_GEAR_MORE_INFO_BODY
       /// The page title of add item
        case KEY_GEAR_ADD_ITEM_PAGE_TITLE
       /// The close button of the add item page
        case KEY_GEAR_ADD_ITEM_PAGE_CLOSE_BUTTON
       /// Title for Are you sure-alert
        case KEY_GEAR_ADD_ITEM_PAGE_CLOSE_ALERT_TITLE
       /// Body for Are you sure-alert
        case KEY_GEAR_ADD_ITEM_PAGE_CLOSE_ALERT_BODY
       /// Button for dismissing Are you sure-alert
        case KEY_GEAR_ADD_ITEM_PAGE_CLOSE_ALERT_DISMISS_BUTTON
       /// Button for proceeding Are you sure-alert
        case KEY_GEAR_ADD_ITEM_PAGE_CLOSE_ALERT_CONTINUE_BUTTON
       /// Add photo button
        case KEY_GEAR_ADD_ITEM_ADD_PHOTO_BUTTON
       /// Headline for item type section
        case KEY_GEAR_ADD_ITEM_TYPE_HEADLINE
       /// Button for saving in add item page
        case KEY_GEAR_ADD_ITEM_SAVE_BUTTON
       /// Text for success screen
        case KEY_GEAR_ADD_ITEM_SUCCESS(itemType: LocalizationStringConvertible)
       /// Title for valuation card
        case KEY_GEAR_ITEM_VIEW_VALUATION_TITLE
       /// Text for empty state in valuation card
        case KEY_GEAR_ITEM_VIEW_VALUATION_EMPTY
       /// Title for deductible card
        case KEY_GEAR_ITEM_VIEW_DEDUCTIBLE_TITLE
       /// Value for deductible card
        case KEY_GEAR_ITEM_VIEW_DEDUCTIBLE_VALUE
       /// Currency for deductible card
        case KEY_GEAR_ITEM_VIEW_DEDUCTIBLE_CURRENCY
       /// Title for coverage table
        case KEY_GEAR_ITEM_VIEW_COVERAGE_TABLE_TITLE
       /// Title for non coverage table
        case KEY_GEAR_ITEM_VIEW_NON_COVERAGE_TABLE_TITLE
       /// Title for item name table
        case KEY_GEAR_ITEM_VIEW_ITEM_NAME_TABLE_TITLE
       /// Button for editing the item name
        case KEY_GEAR_ITEM_VIEW_ITEM_NAME_EDIT_BUTTON
       /// Title for receipt table
        case KEY_GEAR_ITEM_VIEW_RECEIPT_TABLE_TITLE
       /// Title for receipt cell
        case KEY_GEAR_ITEM_VIEW_RECEIPT_CELL_TITLE
       /// Button for adding receipt
        case KEY_GEAR_ITEM_VIEW_RECEIPT_CELL_ADD_BUTTON
       /// Footer for receipt table
        case KEY_GEAR_ITEM_VIEW_RECEIPT_TABLE_FOOTER
       /// Page title of add purchase date overlay
        case KEY_GEAR_ITEM_VIEW_ADD_PURCHASE_DATE_PAGE_TITLE
       /// Body copy of add purchase date overlay
        case KEY_GEAR_ITEM_VIEW_ADD_PURCHASE_DATE_BODY(itemType: LocalizationStringConvertible)
       /// Button of the add purchase date overlay
        case KEY_GEAR_ITEM_VIEW_ADD_PURCHASE_DATE_BUTTON
       /// Page title of valuation overlay
        case KEY_GEAR_ITEM_VIEW_VALUATION_PAGE_TITLE
       /// Label of the percentage value
        case KEY_GEAR_ITEM_VIEW_VALUATION_PERCENTAGE_LABEL
       /// Body copy of valuation overlay
        case KEY_GEAR_ITEM_VIEW_VALUATION_BODY(itemType: LocalizationStringConvertible, purchasePrice: LocalizationStringConvertible, valuationPercentage: LocalizationStringConvertible, valuationPrice: LocalizationStringConvertible)
       /// Title of age deduction section
        case KEY_GEAR_ITEM_VIEW_VALUATION_AGE_DEDUCTION_TITLE
       /// Body copy of age deduction section
        case KEY_GEAR_ITEM_VIEW_VALUATION_AGE_DEDUCTION_BODY(itemType: LocalizationStringConvertible)
       /// Age deduction table expand button
        case KEY_GEAR_ITEM_VIEW_VALUATION_AGE_DEDUCTION_TABLE_EXPAND_BUTTON
       /// Title for year/month-picker for android
        case KEY_GEAR_YEARMONTH_PICKER_TITLE
       /// Positive action for year/month-picker for android
        case KEY_GEAR_YEARMONTH_PICKER_POS_ACTION
       /// Negative action for year/month-picker for android
        case KEY_GEAR_YEARMONTH_PICKER_NEG_ACTION
       /// Page title for receipt view
        case KEY_GEAR_RECCEIPT_VIEW_PAGE_TITLE
       /// Content description for close button in receipt view
        case KEY_GEAR_RECCEIPT_VIEW_CLOSE_BUTTON
       /// Content description for share button in receipt view
        case KEY_GEAR_RECCEIPT_VIEW_SHARE_BUTTON
       /// Title of add purchase price cell
        case KEY_GEAR_ADD_PURCHASE_PRICE_CELL_TITLE
       /// Phone key gear category
        case ITEM_TYPE_PHONE
       /// Computer key gear category
        case ITEM_TYPE_COMPUTER
       /// TV Key gear category
        case ITEM_TYPE_TV
       /// Bike Key gear category
        case ITEM_TYPE_BIKE
       /// Watch key gear category
        case ITEM_TYPE_WATCH
       /// Jewelry key gear category
        case ITEM_TYPE_JEWELRY
       /// Page title of add purchase date overlay
        case KEY_GEAR_ADD_PURCHASE_INFO_PAGE_TITLE
       /// Body copy of add purchase info overlay
        case KEY_GEAR_ADD_PURCHASE_INFO_BODY(itemType: LocalizationStringConvertible)
       /// Title for recept uploading sheet for android
        case KEY_GEAR_RECEIPT_UPLOAD_SHEET_TITLE
       /// Button for showing a previously added receipt
        case KEY_GEAR_ITEM_VIEW_RECEIPT_SHOW
       /// Button that completes action
        case TOOLBAR_DONE_BUTTON
       /// Title for first covered title for phone
        case ITEM_TYPE_PHONE_COVERED_ONE
       /// Title for second covered title for phone
        case ITEM_TYPE_PHONE_COVERED_TWO
       /// Title for third covered title for phone
        case ITEM_TYPE_PHONE_COVERED_THREE
       /// Title for fourth covered title for phone
        case ITEM_TYPE_PHONE_COVERED_FOUR
       /// Title for fifth covered title for computer
        case ITEM_TYPE_PHONE_COVERED_FIVE
       /// Title for first not covered title for phone
        case ITEM_TYPE_PHONE_NOT_COVERED_ONE
       /// Title for second not covered title for phone
        case ITEM_TYPE_PHONE_NOT_COVERED_TWO
       /// Title for first covered title for computer
        case ITEM_TYPE_COMPUTER_COVERED_ONE
       /// Title for second covered title for computer
        case ITEM_TYPE_COMPUTER_COVERED_TWO
       /// Title for third covered title for computer
        case ITEM_TYPE_COMPUTER_COVERED_THREE
       /// Title for fourth covered title for computer
        case ITEM_TYPE_COMPUTER_COVERED_FOUR
       /// Title for fifth covered title for computer
        case ITEM_TYPE_COMPUTER_COVERED_FIVE
       /// Title for first not covered title for computer
        case ITEM_TYPE_COMPUTER_NOT_COVERED_ONE
       /// Title for second not covered title for computer
        case ITEM_TYPE_COMPUTER_NOT_COVERED_TWO
       /// Title for first covered title for TV
        case ITEM_TYPE_TV_COVERED_ONE
       /// Title for second covered title for TV
        case ITEM_TYPE_TV_COVERED_TWO
       /// Title for third covered title for TV
        case ITEM_TYPE_TV_COVERED_THREE
       /// Title for fourth covered title for TV
        case ITEM_TYPE_TV_COVERED_FOUR
       /// Title for first not covered title for TV
        case ITEM_TYPE_TV_NOT_COVERED_ONE
       /// Title for second not covered title for TV
        case ITEM_TYPE_TV_NOT_COVERED_TWO
       /// Title for first covered title for bike
        case ITEM_TYPE_BIKE_COVERED_ONE
       /// Title for second covered title for bike
        case ITEM_TYPE_BIKE_COVERED_TWO
       /// Title for third covered title for bike
        case ITEM_TYPE_BIKE_COVERED_THREE
       /// Title for fourth covered title for bike
        case ITEM_TYPE_BIKE_COVERED_FOUR
       /// Title for first not covered title for bike
        case ITEM_TYPE_BIKE_NOT_COVERED_ONE
       /// Title for second not covered title for bike
        case ITEM_TYPE_BIKE_NOT_COVERED_TWO
       /// Title for third not covered title for bike
        case ITEM_TYPE_BIKE_NOT_COVERED_THREE
       /// Title for first covered title for watch
        case ITEM_TYPE_WATCH_COVERED_ONE
       /// Title for second covered title for watch
        case ITEM_TYPE_WATCH_COVERED_TWO
       /// Title for first not covered title for watch
        case ITEM_TYPE_WATCH_NOT_COVERED_ONE
       /// Title for second not covered title for watch
        case ITEM_TYPE_WATCH_NOT_COVERED_TWO
       /// Title for first covered title for jewelry
        case ITEM_TYPE_JEWELRY_COVERED_ONE
       /// Title for second covered title for jewelry
        case ITEM_TYPE_JEWELRY_COVERED_TWO
       /// Title for first not covered title for jewelry
        case ITEM_TYPE_JEWELRY_NOT_COVERED_ONE
       /// Title for second not covered title for jewelry
        case ITEM_TYPE_JEWELRY_NOT_COVERED_TWO
       /// Camera option in key gear image picker
        case KEY_GEAR_IMAGE_PICKER_CAMERA
       /// Key gear image picker select from library button
        case KEY_GEAR_IMAGE_PICKER_PHOTO_LIBRARY
       /// Key gear pick a document button
        case KEY_GEAR_IMAGE_PICKER_DOCUMENT
       /// Button that cancels sheet
        case KEY_GEAR_IMAGE_PICKER_CANCEL
       /// Options sheet item that deletes a key gear
        case KEY_GEAR_ITEM_DELETE
       /// Button that cancels options sheet
        case KEY_GEAR_ITEM_OPTIONS_CANCEL
       /// Button for saving the item name
        case KEY_GEAR_ITEM_VIEW_ITEM_NAME_SAVE_BUTTON
       /// Body copy of valuation overlay when its decided on market value
        case KEY_GEAR_ITEM_VIEW_VALUATION_MARKET_BODY(itemType: LocalizationStringConvertible, valuationPercentage: LocalizationStringConvertible)
       /// Label of the percentage value
        case KEY_GEAR_ITEM_VIEW_VALUATION_MARKET_DESCRIPTION
       /// Title for first covered title for phone
        case ITEM_TYPE_SMART_WATCH_COVERED_ONE
       /// Title for second covered title for phone
        case ITEM_TYPE_SMART_WATCH_COVERED_TWO
       /// Title for third covered title for phone
        case ITEM_TYPE_SMART_WATCH_COVERED_THREE
       /// Title for fourth covered title for phone
        case ITEM_TYPE_SMART_WATCH_COVERED_FOUR
       /// Title for fifth covered title for computer
        case ITEM_TYPE_SMART_WATCH_COVERED_FIVE
       /// Title for first not covered title for phone
        case ITEM_TYPE_SMART_WATCH_NOT_COVERED_ONE
       /// Title for second not covered title for phone
        case ITEM_TYPE_SMART_WATCH_NOT_COVERED_TWO
       /// Smartwatch key gear category
        case ITEM_TYPE_SMART_WATCH
       /// Button that starts claims flow for key gear item
        case KEY_GEAR_REPORT_CLAIM_ROW
       /// Tablet key gear category
        case ITEM_TYPE_TABLET
       /// Message shown when item is not covered by all-risk
        case KEY_GEAR_NOT_COVERED(itemType: LocalizationStringConvertible)
       /// Title for first covered title for phone
        case ITEM_TYPE_TABLET_COVERED_ONE
       /// Title for second covered title for phone
        case ITEM_TYPE_TABLET_COVERED_TWO
       /// Title for third covered title for phone
        case ITEM_TYPE_TABLET_COVERED_THREE
       /// Title for fourth covered title for phone
        case ITEM_TYPE_TABLET_COVERED_FOUR
       /// Title for fifth covered title for computer
        case ITEM_TYPE_TABLET_COVERED_FIVE
       /// Title for first not covered title for phone
        case ITEM_TYPE_TABLET_NOT_COVERED_ONE
       /// Title for second not covered title for phone
        case ITEM_TYPE_TABLET_NOT_COVERED_TWO
       /// Title of market picker
        case MARKET_PICKER_TITLE
    }

    struct Translations {
        struct sv_SE {
            static func `for`(key: Localization.Key) -> String {
                switch key {
                case .OFFER_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Försäkringsförslag
                    """
                case .PAYMENT_CURRENCY_OCCURRENCE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    kr/mån
                    """
                case .OFFER_BUBBLES_BINDING_PERIOD_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Bindningstid
                    """
                case .OFFER_BUBBLES_BINDING_PERIOD_SUBTITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Nope, så jobbar inte Hedvig
                    """
                case .OFFER_BUBBLES_DEDUCTIBLE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Självrisk
                    """
                case .OFFER_BUBBLES_DEDUCTIBLE_SUBTITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    1500 kr
                    """
                case .OFFER_BUBBLES_INSURED_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Försäkrade
                    """
                case let .OFFER_BUBBLES_INSURED_SUBTITLE(personsInHousehold):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["personsInHousehold": personsInHousehold]) {
                        return text
                    }

                    return """
                    \(personsInHousehold) personer
                    """
                case .OFFER_BUBBLES_START_DATE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Startdatum
                    """
                case .OFFER_BUBBLES_START_DATE_SUBTITLE_SWITCHER:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Så fort din bindningstid går ut
                    """
                case .OFFER_BUBBLES_START_DATE_SUBTITLE_NEW:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    idag
                    """
                case .OFFER_BUBBLES_TRAVEL_PROTECTION_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Reseskydd ingår
                    """
                case .OFFER_BUBBLES_OWNED_ADDON_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Bostadsrätts- tillägg ingår
                    """
                case .OFFER_SIGN_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Signera
                    """
                case .OFFER_SCROLL_HEADER:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Vad Hedvig täcker
                    """
                case .OFFER_CHAT_HEADER:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Prata med Hedvig
                    """
                case .OFFER_GET_HEDVIG_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Skaffa Hedvig
                    """
                case .OFFER_GET_HEDVIG_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Skaffa Hedvig genom att klicka på knappen nedan och signera med BankID.
                    """
                case .OFFER_APARTMENT_PROTECTION_DESCRIPTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Vi vet hur mycket ett hem betyder. Därför ger vi det ett riktigt bra skydd, så att du kan känna dig trygg i alla lägen.
                    """
                case let .OFFER_APARTMENT_PROTECTION_TITLE(address):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["address": address]) {
                        return text
                    }

                    return """
                    \(address)
                    """
                case .OFFER_STUFF_PROTECTION_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Dina prylar
                    """
                case let .OFFER_STUFF_PROTECTION_DESCRIPTION(protectionAmount):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["protectionAmount": protectionAmount]) {
                        return text
                    }

                    return """
                    Med Hedvig får du ett komplett skydd för dina prylar. Drulleförsäkring ingår och täcker prylar värda upp till \(protectionAmount) styck.
                    """
                case .STUFF_PROTECTION_AMOUNT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    50 000 kr
                    """
                case .STUFF_PROTECTION_AMOUNT_STUDENT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    25 000 kr
                    """
                case .OFFER_PERSONAL_PROTECTION_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Dig
                    """
                case .OFFER_PERSONAL_PROTECTION_DESCRIPTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Hedvig skyddar dig mot obehagliga saker som kan hända på hemmaplan, och det mesta som kan hända när du är ute och reser.
                    """
                case .OFFER_PERILS_EXPLAINER:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Tryck på ikonerna för mer info
                    """
                case .TRUSTLY_PAYMENT_SETUP_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    För att din försäkring ska gälla framöver behöver du koppla autogiro från ditt bankkonto. Vi sköter det via Trustly.
                    """
                case .TRUSTLY_PAYMENT_SETUP_ACTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Sätt upp betalning
                    """
                case .CASHBACK_NEEDS_SETUP_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Du har ännu inte valt din välgörenhets organisation
                    """
                case .CASHBACK_NEEDS_SETUP_ACTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Välj välgörenhetsorganisation
                    """
                case .CASHBACK_NEEDS_SETUP_OVERLAY_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Välj välgörenhetsorganisation
                    """
                case .CASHBACK_NEEDS_SETUP_OVERLAY_PARAGRAPH:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Välj vilken välgörenhet du vill att din andel av årets överskott ska gå till.
                    """
                case .PAYMENT_SUCCESS_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Autogirot aktivt
                    """
                case .PAYMENT_SUCCESS_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Hedvig kommer att synas på ditt kontoutdrag när vi tar betalt varje månad.
                    """
                case .PAYMENT_SUCCESS_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Klar
                    """
                case .PAYMENT_FAILURE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Något gick fel
                    """
                case .PAYMENT_FAILURE_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Inga pengar kommer att dras.


                    Du kan gå tillbaka för att försöka igen.
                    """
                case .PAYMENT_FAILURE_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Gå tillbaka
                    """
                case let .DASHBOARD_BANNER_ACTIVE_TITLE(firstName):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["firstName": firstName]) {
                        return text
                    }

                    return """
                    Hej \(firstName)!
                    """
                case .DASHBOARD_BANNER_ACTIVE_INFO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Din försäkring är aktiv
                    """
                case .DASHBOARD_HAVE_START_DATE_BANNER_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Din försäkring aktiveras om:
                    """
                case let .DASHBOARD_READMORE_HAVE_START_DATE_TEXT(date):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["date": date]) {
                        return text
                    }

                    return """
                    Du är fortfarande försäkrad hos ditt tidigare försäkringsbolag. Vi har påbörjat flytten och den \(date) aktiveras din försäkring hos Hedvig!
                    """
                case .DASHBOARD_BANNER_MONTHS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    M
                    """
                case .DASHBOARD_BANNER_DAYS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    D
                    """
                case .DASHBOARD_BANNER_HOURS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    H
                    """
                case .DASHBOARD_BANNER_MINUTES:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    M
                    """
                case .DASHBOARD_MORE_INFO_BUTTON_TEXT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Mer info
                    """
                case .DASHBOARD_NOT_STARTED_BANNER_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Din försäkring är på gång!
                    """
                case .DASHBOARD_READMORE_NOT_STARTED_TEXT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Du är fortfarande försäkrad hos ditt tidigare försäkringsbolag. Vi har påbörjat flytten till Hedvig och informerar dig så fort vi vet aktiveringsdatumet!
                    """
                case .DASHBOARD_LESS_INFO_BUTTON_TEXT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Mindre info
                    """
                case .FILE_UPLOAD_ERROR:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Du gav oss inte tillgång till ditt bildbibliotek, vi kan därför inte visa dina bilder här. Gå till inställningar för att ge oss tillgång till ditt bildbibliotek.
                    """
                case .FILE_UPLOAD_ERROR_RETRY_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Försök igen
                    """
                case .DASHBOARD_BANNER_TERMINATED_INFO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Din försäkring är inaktiv
                    """
                case .RESTART_OFFER_CHAT_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Vill du börja om?
                    """
                case .RESTART_OFFER_CHAT_PARAGRAPH:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Om du trycker ja börjar konversationen om och ditt nuvarande förslag försvinner
                    """
                case .RESTART_OFFER_CHAT_BUTTON_CONFIRM:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Ja
                    """
                case .RESTART_OFFER_CHAT_BUTTON_DISMISS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Nej
                    """
                case .DASHBOARD_DEDUCTIBLE_FOOTNOTE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Din självrisk är 1 500 kr
                    """
                case .DASHBOARD_OWNER_FOOTNOTE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Lägenheten försäkras till sitt fulla värde
                    """
                case .DASHBOARD_PERILS_CATEGORY_INFO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Klicka på ikonerna för mer info
                    """
                case .DASHBOARD_TRAVEL_FOOTNOTE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Gäller på resor runtom i världen
                    """
                case .PROFILE_CACHBACK_ROW:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Min välgörenhet
                    """
                case .PROFILE_INSURANCE_ADDRESS_ROW:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Mitt hem
                    """
                case .PROFILE_INSURANCE_CERTIFICATE_ROW_HEADER:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Mitt försäkringsbrev
                    """
                case .PROFILE_INSURANCE_CERTIFICATE_ROW_TEXT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Tryck för att läsa
                    """
                case .PROFILE_PAYMENT_ROW_HEADER:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Min betalning
                    """
                case let .PROFILE_PAYMENT_ROW_TEXT(price):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["price": price]) {
                        return text
                    }

                    return """
                    \(price) kr/månad. Betalas via autogiro
                    """
                case .PROFILE_SAFETYINCREASERS_ROW_HEADER:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Mina trygghetshöjare
                    """
                case let .DASHBOARD_INSURANCE_AMOUNT_FOOTNOTE(student):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["student": student]) {
                        return text
                    }

                    return """
                    Prylarna försäkras totalt till \(student) kr
                    """
                case .CHAT_GIPHY_PICKER_NO_SEARCH_TEXT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Oh no, ingen GIF för denna sökning...
                    """
                case .CHAT_GIPHY_PICKER_TEXT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Sök på något för att få upp GIFar!
                    """
                case .CHAT_COULD_NOT_LOAD_FILE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Kunde inte ladda fil...
                    """
                case .CHAT_FILE_LOADING:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Laddar...
                    """
                case .CHAT_FILE_DOWNLOAD:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Bifogad fil
                    """
                case .AUDIO_INPUT_REDO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Gör om
                    """
                case .AUDIO_INPUT_SAVE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Spara
                    """
                case .AUDIO_INPUT_PLAY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Spela upp
                    """
                case .CHAT_FILE_UPLOADED:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    fil uppladdad
                    """
                case let .AUDIO_INPUT_RECORDING(seconds):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["SECONDS": seconds]) {
                        return text
                    }

                    return """
                    Spelar in: \(seconds)s
                    """
                case .GIF_BUTTON_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    GIF
                    """
                case .CHAT_UPLOAD_PRESEND:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Skicka
                    """
                case .CHAT_UPLOADING_ANIMATION_TEXT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Laddar upp...
                    """
                case .CHAT_GIPHY_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    GIPHY
                    """
                case .MY_INFO_CONTACT_DETAILS_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Kontaktuppgifter
                    """
                case .MY_INFO_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Min info
                    """
                case .PROFILE_MY_INFO_ROW_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Min info
                    """
                case .NETWORK_ERROR_ALERT_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Nätverksfel
                    """
                case .NETWORK_ERROR_ALERT_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Vi kunde inte nå Hedvig just nu, säker på att du har en internetuppkoppling?
                    """
                case .NETWORK_ERROR_ALERT_TRY_AGAIN_ACTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Försök igen
                    """
                case .NETWORK_ERROR_ALERT_CANCEL_ACTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Avbryt
                    """
                case .PHONE_NUMBER_ROW_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Telefonnummer
                    """
                case .PHONE_NUMBER_ROW_EMPTY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Inget angett
                    """
                case .PROFILE_MY_CHARITY_ROW_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Min välgörenhet
                    """
                case .EMAIL_ROW_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    E-postadress
                    """
                case .EMAIL_ROW_EMPTY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Inget angett
                    """
                case .PROFILE_MY_PAYMENT_METHOD:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Betalas via autogiro
                    """
                case .MY_PAYMENT_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Min betalning
                    """
                case .TAB_PROFILE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Profil
                    """
                case .TAB_DASHBOARD_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Min hemförsäkring
                    """
                case .LICENSES_SCREEN_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Licensrättigheter
                    """
                case .ABOUT_SCREEN_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Om appen
                    """
                case .OTHER_SECTION_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Annat
                    """
                case .ACKNOWLEDGEMENT_HEADER_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Hedvig tror starkt på open-source, här finner du en lista och tillhörande licenser för de biblioteken vi förlitar oss på 💕
                    """
                case .LOGOUT_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Logga ut
                    """
                case .LOGOUT_ALERT_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Är du säker på att du vill logga ut?
                    """
                case .LOGOUT_ALERT_ACTION_CONFIRM:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Ja
                    """
                case .LOGOUT_ALERT_ACTION_CANCEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Avbryt
                    """
                case .PROFILE_MY_HOME_ROW_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Mitt hem
                    """
                case .PROFILE_MY_INSURANCE_CERTIFICATE_ROW_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Mitt försäkringsbrev
                    """
                case .PROFILE_MY_INSURANCE_CERTIFICATE_ROW_SUBTITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Tryck för att läsa
                    """
                case .PROFILE_MY_INSURANCE_CERTIFICATE_ROW_DISABLED_SUBTITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Blir tillgängligt när din försäkring aktiveras
                    """
                case .MY_INSURANCE_CERTIFICATE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Mitt försäkringsbrev
                    """
                case .CHARITY_SCREEN_HEADER_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Du har ännu inte valt vilken välgörenhetsorganisation som din andel av årets överskott ska gå till.
                    """
                case .MY_PAYMENT_PAYMENT_ROW_LABEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Pris
                    """
                case .MY_PAYMENT_BANK_ROW_LABEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Bank
                    """
                case .CHARITY_OPTIONS_HEADER_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Välgörenhetsorganisationer
                    """
                case .MY_CHARITY_SCREEN_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Min välgörenhetsorganisation
                    """
                case .PROFILE_MY_CHARITY_ROW_NOT_SELECTED_SUBTITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Ingen välgörenhet vald
                    """
                case .DIRECT_DEBIT_FAIL_HEADING:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Något gick snett!
                    """
                case .DIRECT_DEBIT_FAIL_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    På grund av ett tekniskt fel kunde inte ditt bankkonto uppdateras. Försök igen eller skriv till Hedvig i chatten.
                    """
                case .DIRECT_DEBIT_FAIL_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Tillbaka
                    """
                case .DIRECT_DEBIT_SUCCESS_HEADING:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Kontobyte klart!
                    """
                case .DIRECT_DEBIT_SUCCESS_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Ditt bankkonto är nu uppdaterat och kommer synas inom kort. Nästa betalning kommer att dras från ditt nya bankkonto.
                    """
                case .DIRECT_DEBIT_SUCCESS_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Tillbaka
                    """
                case .DIRECT_DEBIT_DISMISS_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Avbryt
                    """
                case .DIRECT_DEBIT_SETUP_CHANGE_SCREEN_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Ändra bankkonto
                    """
                case .DIRECT_DEBIT_DISMISS_ALERT_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Är du säker?
                    """
                case .DIRECT_DEBIT_DISMISS_ALERT_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Du har ännu inte satt upp din betalning.
                    """
                case .DIRECT_DEBIT_DISMISS_ALERT_CONFIRM_ACTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Ja
                    """
                case .DIRECT_DEBIT_DISMISS_ALERT_CANCEL_ACTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Nej
                    """
                case .PROFILE_MY_COINSURED_ROW_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Mina medförsäkrade
                    """
                case let .PROFILE_MY_COINSURED_ROW_SUBTITLE(amountCoinsured):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["amountCoinsured": amountCoinsured]) {
                        return text
                    }

                    return """
                    Jag + \(amountCoinsured)
                    """
                case .MY_COINSURED_SCREEN_CIRCLE_SUBLABEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Medförsäkrade
                    """
                case .MY_COINSURED_COMING_SOON_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Snart kommer mer!
                    """
                case .MY_COINSURED_COMING_SOON_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Vi jobbar på utökad funktionalitet för medförsäkrade, såsom att alla medförsäkrade ska kunna logga in och att du ska kunna lägga till och ta bort medförsäkrade med ett knapptryck. 

                    Har du andra idéer eller förslag? Skriv till oss i chatten!
                    """
                case .MY_HOME_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Mitt hem
                    """
                case .MY_HOME_SECTION_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Bostad
                    """
                case .MY_HOME_ADDRESS_ROW_KEY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Adress
                    """
                case .MY_HOME_ROW_POSTAL_CODE_KEY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Postnummer
                    """
                case .MY_HOME_ROW_TYPE_KEY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Bostadsform
                    """
                case .MY_HOME_ROW_TYPE_RENTAL_VALUE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Hyresrätt
                    """
                case .MY_HOME_ROW_TYPE_CONDOMINIUM_VALUE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Bostadsrätt
                    """
                case .GENERIC_UNKNOWN:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Okänt
                    """
                case .MY_HOME_CHANGE_INFO_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Ändra bostadsinfo
                    """
                case .DIRECT_DEBIT_SETUP_SCREEN_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Koppla bankkonto
                    """
                case .MY_PAYMENT_DIRECT_DEBIT_REPLACE_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Ändra bankkonto
                    """
                case .MY_PAYMENT_DIRECT_DEBIT_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Koppla bankkonto
                    """
                case .MY_PAYMENT_DATE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                     
                    """
                case .MY_PAYMENT_TYPE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Autogiro
                    """
                case .MY_PAYMENT_NOT_CONNECTED:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Ej kopplat
                    """
                case .MY_INFO_CANCEL_ALERT_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Är du säker?
                    """
                case .MY_INFO_CANCEL_ALERT_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Dina ändringar kommer att gå förlorade
                    """
                case .MY_INFO_CANCEL_ALERT_BUTTON_CONFIRM:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Ja
                    """
                case .MY_INFO_CANCEL_ALERT_BUTTON_CANCEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Nej
                    """
                case .MY_INFO_EMAIL_MALFORMED_ERROR:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    E-postadressen verkar inte vara korrekt
                    """
                case .MY_INFO_EMAIL_EMPTY_ERROR:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Du glömde ange en e-postaddress
                    """
                case .MY_INFO_ALERT_SAVE_FAILURE_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    OK
                    """
                case .MY_INFO_ALERT_SAVE_FAILURE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Kunde inte spara
                    """
                case .MY_INFO_CANCEL_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Avbryt
                    """
                case .MY_INFO_PHONE_NUMBER_MALFORMED_ERROR:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Kontrollera att det telefonnummer du angett stämmer
                    """
                case .MY_INFO_PHONE_NUMBER_EMPTY_ERROR:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Du har inte angett något telefonnummer
                    """
                case .ABOUT_MEMBER_ID_ROW_KEY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Användar-id
                    """
                case .MY_INFO_SAVE_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Spara
                    """
                case .MY_PAYMENT_DEDUCTIBLE_CIRCLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Självrisk 1500 kr
                    """
                case .MY_PAYMENT_UPDATING_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Du har precis lagt till eller ändrat ditt bankkonto, ditt nya bankkonto kommer synas här efter din bank accepterat autogirot inom 2 arbetsdagar.
                    """
                case .MY_COINSURED_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Mina medförsäkrade
                    """
                case .MY_HOME_CHANGE_ALERT_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Vill du ändra din försäkring?
                    """
                case .MY_HOME_CHANGE_ALERT_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Skriv till Hedvig i chatten så får du hjälp direkt!
                    """
                case .MY_HOME_CHANGE_ALERT_ACTION_CANCEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Avbryt
                    """
                case .MY_HOME_CHANGE_ALERT_ACTION_CONFIRM:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Skriv till Hedvig
                    """
                case .FEEDBACK_IOS_EMAIL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    ios@hedvig.com
                    """
                case .FEEDBACK_SCREEN_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Feedback
                    """
                case .FEEDBACK_SCREEN_LABEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Hjälp oss bli bättre!
                    """
                case .FEEDBACK_SCREEN_REPORT_BUG_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Rapportera bugg
                    """
                case .FEEDBACK_SCREEN_REVIEW_APP_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Betygsätt appen
                    """
                case .FEEDBACK_SCREEN_REVIEW_APP_VALUE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    App Store
                    """
                case let .FEEDBACK_SCREEN_REPORT_BUG_EMAIL_ATTACHMENT(appVersion, device, memberId, systemName, systemVersion):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["appVersion": appVersion, "device": device, "memberId": memberId, "systemName": systemName, "systemVersion": systemVersion]) {
                        return text
                    }

                    return """
                    Device: \(device)
                    System: \(systemName) \(systemVersion)
                    App Version: \(appVersion)
                    Member ID: \(memberId)
                    """
                case .MAIL_VIEW_CANT_SEND_ALERT_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Kan inte öppna Mail
                    """
                case .MAIL_VIEW_CANT_SEND_ALERT_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Du har inte satt upp ett e-postkonto i Mail appen ännu, du måste göra det innan du kan maila till oss.
                    """
                case .MAIL_VIEW_CANT_SEND_ALERT_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    OK
                    """
                case .APP_STORE_REVIEW_URL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    itms-apps://itunes.apple.com/app/1303668531?action=write-review
                    """
                case .TRUSTLY_MISSING_BANK_ID_APP_ALERT_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Du saknar BankID på denna enheten
                    """
                case .TRUSTLY_MISSING_BANK_ID_APP_ALERT_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    För att kunna logga in på din bank så behöver du ha BankID-appen installerad.
                    """
                case .TRUSTLY_MISSING_BANK_ID_APP_ALERT_ACTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    OK
                    """
                case .OFFER_BUBBLES_START_DATE_CHANGE_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Ändra
                    """
                case .OFFER_BUBBLES_START_DATE_CHANGE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Ändra startdatum
                    """
                case .OFFER_BUBBLES_START_DATE_CHANGE_HEADING:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Vilket datum vill du att din hemförsäkring ska aktiveras?
                    """
                case .OFFER_BUBBLES_START_DATE_CHANGE_CONFIRM:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Välj datum
                    """
                case .OFFER_BUBBLES_START_DATE_CHANGE_RESET_NEW:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Aktivera idag
                    """
                case .OFFER_BUBBLES_START_DATE_CHANGE_RESET_SWITCHER:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    När min bindningstid går ut
                    """
                case let .REFERRALS_ROW_TITLE(incentive):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["incentive": incentive]) {
                        return text
                    }

                    return """
                    Få \(incentive) kr, ge bort \(incentive) kr!
                    """
                case .REFERRALS_ROW_SUBTITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Bjud in dina vänner till Hedvig
                    """
                case .REFERRALS_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Hedvig blir bättre när du får dela det med dina vänner!
                    """
                case .REFERRALS_OFFER_SENDER_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Du får
                    """
                case .REFERRALS_OFFER_RECEIVER_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Din vän får
                    """
                case let .REFERRALS_OFFER_RECEIVER_VALUE(incentive):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["incentive": incentive]) {
                        return text
                    }

                    return """
                    \(incentive) kr för att signa upp med Hedvig via din länk
                    """
                case let .REFERRALS_OFFER_SENDER_VALUE(incentive):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["incentive": incentive]) {
                        return text
                    }

                    return """
                    \(incentive) kr för varje person som skaffar Hedvig via din unika länk
                    """
                case .REFERRALS_SCREEN_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Bjud in dina vänner
                    """
                case .REFERRALS_SHARE_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Dela din länk
                    """
                case let .REFERRALS_SHARE_MESSAGE(incentive, link):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["incentive": incentive, "link": link]) {
                        return text
                    }

                    return """
                    Skaffa framtidens hemförsäkring från Hedvig och få \(incentive) kr! Har du redan hemförsäkring sköter Hedvig bytet åt dig!  🙌

                    Skaffa Hedvig via länken: \(link)
                    """
                case .REFERRALS_TERMS_ROW_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Villkor
                    """
                case .REFERRALS_TERMS_WEBSITE_URL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    https://www.hedvig.com/invite/terms
                    """
                case .REFERRAL_SHARE_SOCIAL_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Skaffa Hedvig!
                    """
                case .REFERRAL_SHARE_SOCIAL_DESCRIPTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Hedvig – Framtidens hemförsäkring
                    """
                case let .REFERRALS_DYNAMIC_LINK_LANDING(incentive, memberId):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["incentive": incentive, "memberId": memberId]) {
                        return text
                    }

                    return """
                    https://hedvig.com/invite/desktop?invitedBy=\(memberId)&incentive=\(incentive)
                    """
                case .MY_HOME_ROW_SIZE_KEY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Boyta
                    """
                case let .MY_HOME_ROW_SIZE_VALUE(livingSpace):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["livingSpace": livingSpace]) {
                        return text
                    }

                    return """
                    \(livingSpace) kvadratmeter
                    """
                case .PROFILE_MY_CHARITY_INFO_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Hur fungerar välgörenhet med Hedvig?
                    """
                case .PROFILE_MY_CHARITY_INFO_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Välgörenhet
                    """
                case .PROFILE_MY_CHARITY_INFO_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Hedvig tar en fast avgift oavsett hur mycket ersättning som betalas ut. Överskottet skänks till ett gott ändamål istället för att gå till extra vinst.

                    **Så funkar det**
                    **1.** Välj det ändamål du vill stötta

                    **2.** Vid årets slut summerar vi alla pengar som inte betalats ut i ersättningar till dig, eller till andra som valt samma ändamål

                    **3.** Tillsammans gör vi skillnad genom att skänka pengarna
                    """
                case .DASHBOARD_INFO_DEDUCTIBLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Din självrisk är 1 500 kr
                    """
                case .DASHBOARD_CHAT_ACTIONS_HEADER:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Vad vill du göra idag?
                    """
                case .DASHBOARD_INSURANCE_STATUS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Din försäkring är aktiv
                    """
                case .DASHBOARD_PERIL_FOOTER:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Klicka på ikonerna för mer info
                    """
                case .DASHBOARD_INFO_INSURANCE_AMOUNT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Prylarna försäkras till totalt 1 000 000 kr
                    """
                case .DASHBOARD_INFO_TRAVEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Gäller på resor runtom i världen
                    """
                case .DASHBOARD_INFO_HEADER:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Mer info
                    """
                case .DASHBOARD_INFO_SUBHEADER:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    om din hemförsäkring
                    """
                case .DASHBOARD_PENDING_HEADER:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Din försäkring är på gång!
                    """
                case .DASHBOARD_PENDING_MORE_INFO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Mer info
                    """
                case .DASHBOARD_PENDING_LESS_INFO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Mindre info
                    """
                case .DASHBOARD_PAYMENT_SETUP_INFO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    För att din försäkring ska gälla framöver behöver du koppla ditt bankkonto till Hedvig.
                    """
                case .DASHBOARD_PAYMENT_SETUP_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Koppla betalning
                    """
                case let .DASHBOARD_PENDING_HAS_DATE(date):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["date": date]) {
                        return text
                    }

                    return """
                    Du är fortfarande försäkrad hos ditt tidigare försäkringsbolag. Vi har påbörjat flytten och den \(date) är du är kund hos Hedvig!
                    """
                case .DASHBOARD_PENDING_NO_DATE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Du är fortfarande försäkrad hos ditt tidigare försäkringsbolag. Din Hedvig-försäkring aktiveras på samma dag som din nuvarande försäkring går ut.
                    """
                case .DASHBOARD_PENDING_MONTHS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    M
                    """
                case .DASHBOARD_PENDING_DAYS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    D
                    """
                case .DASHBOARD_PENDING_HOURS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    T
                    """
                case .DASHBOARD_PENDING_MINUTES:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    M
                    """
                case .OFFER_BANKID_SIGN_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Signera
                    """
                case .HONESTY_PLEDGE_DESCRIPTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Jag förstår att Hedvig bygger på tillit. Jag lover att jag berättat om händelsen precis som den var, och bara ta ut den ersättning jag har rätt till.
                    """
                case .HONESTY_PLEDGE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Ditt hederslöfte
                    """
                case .CLAIMS_HEADER_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Har det hänt något? Starta anmälan här!
                    """
                case .CLAIMS_HEADER_SUBTITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Har det hänt något med dig, ditt hem eller dina prylar? Anmäl det till Hedvig.
                    """
                case .CLAIMS_HEADER_ACTION_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Anmäl skada
                    """
                case .CLAIMS_QUICK_CHOICE_HEADER:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Snabbval
                    """
                case .DASHBOARD_SCREEN_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Hemförsäkring
                    """
                case .EMERGENCY_CALL_ME_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Prata med någon
                    """
                case .EMERGENCY_CALL_ME_DESCRIPTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Befinner du dig i en krisstuation kan vi ringa upp dig. Tänk på att meddela SOS Alarm först vid nödsituationer!
                    """
                case .EMERGENCY_CALL_ME_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Ring mig
                    """
                case .EMERGENCY_ABROAD_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Akut sjuk utomlands
                    """
                case .EMERGENCY_ABROAD_DESCRIPTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Är du akut sjuk eller skadad utomlands och behöver vård? Det första du behöver göra är att kontakta Hedvig Global Assistance.
                    """
                case .EMERGENCY_ABROAD_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Ring Hedvig Global Assistance
                    """
                case .EMERGENCY_ABROAD_BUTTON_ACTION_PHONE_NUMBER:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    +4538489461
                    """
                case .EMERGENCY_ABROAD_ALERT_NON_PHONE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Hedvig Global Assistance
                    """
                case .EMERGENCY_ABROAD_ALERT_NON_PHONE_OK_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    OK
                    """
                case .EMERGENCY_UNSURE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Osäker?
                    """
                case .EMERGENCY_UNSURE_DESCRIPTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Osäker på om ditt tillstånd räknas som akut? Kontakta Hedvig först!
                    """
                case .EMERGENCY_UNSURE_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Skriv till oss
                    """
                case .CLAIMS_SCREEN_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Skador
                    """
                case .CLAIMS_SCREEN_TAB:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Skador
                    """
                case .CLAIMS_INACTIVE_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Din försäkring är inte aktiv än, men när den blir det anmäler du skador här! Behöver du stöd eller hjälp redan nu så skriv till oss i chatten.
                    """
                case .CALL_ME_CHAT_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Det är kris, ring mig
                    """
                case .CLAIMS_CHAT_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Skadeanmälan
                    """
                case .CHAT_PREVIEW_OPEN_CHAT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Öppna chatten
                    """
                case .UPLOAD_FILE_IMAGE_OR_VIDEO_ACTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Bild eller film
                    """
                case .UPLOAD_FILE_SELECT_TYPE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Vad vill du skicka?
                    """
                case .UPLOAD_FILE_TYPE_CANCEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Avbryt
                    """
                case .UPLOAD_FILE_FILE_ACTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Fil
                    """
                case .FEATURE_PROMO_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Nyheter i appen!
                    """
                case .FEATURE_PROMO_HEADLINE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Bonusregn till folket!
                    """
                case .FEATURE_PROMO_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Hedvig blir bättre när du får dela det med dina vänner! Du och dina vänner får 10 kr lägre månadskostnad – för varje vän!
                    """
                case .FEATURE_PROMO_BTN:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Läs mer
                    """
                case .REFERRAL_PROGRESS_TOPBAR_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Bjud in dina vänner
                    """
                case .REFERRAL_PROGRESS_TOPBAR_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Mer info
                    """
                case .REFERRAL_PROGRESS_BAR_CTA:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Bjud in
                    """
                case let .REFERRAL_PROGRESS_CURRENT_PREMIUM_PRICE(currentPremiumPrice):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["CURRENT_PREMIUM_PRICE": currentPremiumPrice]) {
                        return text
                    }

                    return """
                    \(currentPremiumPrice) kr
                    """
                case .REFERRAL_PROGRESS_FREE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Gratis!
                    """
                case .REFERRAL_PROGRESS_HEADLINE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Sprid Hedvig och sänk ditt pris
                    """
                case let .REFERRAL_PROGRESS_BODY(referralValue):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["REFERRAL_VALUE": referralValue]) {
                        return text
                    }

                    return """
                    När någon skaffar Hedvig via din länk eller med din kod får ni båda \(referralValue) kr rabatt på månadskostnaden. 
                    """
                case .REFERRAL_PROGRESS_CODE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Din kod
                    """
                case .REFERRAL_INVITE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Dina inbjudningar
                    """
                case .REFERRAL_INVITE_EMPTYSTATE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Du har inte bjudit in någon än
                    """
                case .REFERRAL_INVITE_EMPTYSTATE_DESCRIPTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Låt oss ändra på det!
                    """
                case .REFERRAL_SHAREINVITE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Dela din länk
                    """
                case let .REFERRAL_SMS_MESSAGE(referralLink, referralValue):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["REFERRAL_LINK": referralLink, "REFERRAL_VALUE": referralValue]) {
                        return text
                    }

                    return """
                    Hej! Skaffa Hedvig med min tipslänk så får vi båda \(referralValue) kr rabatt på månadskostnaden. Följ länken: \(referralLink)
                    """
                case .REFERRAL_INVITE_NEWSTATE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Har skaffat Hedvig
                    """
                case .REFERRAL_INVITE_STARTEDSTATE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Har påbörjat onboarding
                    """
                case .REFERRAL_INVITE_QUITSTATE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Har lämnat Hedvig
                    """
                case .REFERRAL_INVITE_INVITEDYOUSTATE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Bjöd in dig till Hedvig
                    """
                case .REFERRAL_INVITE_ANON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Spöke
                    """
                case .REFERRAL_INVITE_ANONS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Spöken
                    """
                case .REFERRAL_PROGRESS_EDGECASE_HEADLINE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Sänk din månadskostnad!
                    """
                case let .REFERRAL_SUCCESS_HEADLINE(user):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["USER": user]) {
                        return text
                    }

                    return """
                    \(user) skaffade Hedvig tack vare dig!
                    """
                case let .REFERRAL_SUCCESS_HEADLINE_MULTIPLE(numberOfUsers):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["NUMBER_OF_USERS": numberOfUsers]) {
                        return text
                    }

                    return """
                    \(numberOfUsers) av dina vänner skaffade hedvig tack vare dig!
                    """
                case let .REFERRAL_SUCCESS_BODY(referralValue):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["REFERRAL_VALUE": referralValue]) {
                        return text
                    }

                    return """
                    Som tack får både du och dina vänner \(referralValue) kr lägre månadskostnad. Fortsätt bjuda in vänner för att sänka ditt pris ännu mer!
                    """
                case .REFERRAL_SUCCESS_BTN_CTA:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Bjud in fler vänner!
                    """
                case .REFERRAL_SUCCESS_BTN_CLOSE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Stäng
                    """
                case .REFERRAL_ULTIMATE_SUCCESS_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Din galning, du gjorde det!
                    """
                case .REFERRAL_ULTIMATE_SUCCESS_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Vi är förstummade. Wow. Du gjorde det – gratis försäkring! Vi är stolta bortom vad ord kan uttrycka!
                    """
                case .REFERRAL_ULTIMATE_SUCCESS_BTN_CTA:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Sök jobb hos Hedvig!
                    """
                case .REFERRAL_INVITE_OPENEDSTATE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Någon har öppnat din länk
                    """
                case let .REFERRAL_INVITE_ACTIVE_VALUE(referralValue):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["REFERRAL_VALUE": referralValue]) {
                        return text
                    }

                    return """
                    -\(referralValue) kr
                    """
                case .REFERRAL_LANDINGPAGE_BTN_WEB:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Fortsätt på webben
                    """
                case let .REFERRAL_STARTSCREEN_HEADLINE(referralValue):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["REFERRAL_VALUE": referralValue]) {
                        return text
                    }

                    return """
                    \(referralValue) kr rabatt varje månad väntar på dig – tacka din vän
                    """
                case let .REFERRAL_STARTSCREEN_BODY(referralValue):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["REFERRAL_VALUE": referralValue]) {
                        return text
                    }

                    return """
                    Det enda du behöver göra är att skaffa Hedvig. Sen får både du och din vän \(referralValue) kr rabatt varje månad. Är du redo?
                    """
                case .REFERRAL_STARTSCREEN_BTN_CTA:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Skaffa Hedvig med rabatt
                    """
                case .REFERRAL_STARTSCREEN_BTN_SKIP:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Fortsätt utan rabatt
                    """
                case .REFERRAL_OFFER_DISCOUNT_HEADLINE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Inbjudan!
                    """
                case let .REFERRAL_OFFER_DISCOUNT_BODY(referralValue):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["REFERRAL_VALUE": referralValue]) {
                        return text
                    }

                    return """
                    -\(referralValue) kr/mån rabatt
                    """
                case .REFERRAL_ADDCOUPON_HEADLINE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Lös in rabattkod
                    """
                case .REFERRAL_ADDCOUPON_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Skriv in din rabattkod nedan
                    """
                case .REFERRAL_ADDCOUPON_INPUTPLACEHOLDER:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Rabattkod
                    """
                case .REFERRAL_ADDCOUPON_BTN_SUBMIT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Lägg till rabattkod
                    """
                case let .REFERRAL_ADDCOUPON_TC(termsAndConditionsLink):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["TERMS_AND_CONDITIONS_LINK": termsAndConditionsLink]) {
                        return text
                    }

                    return """
                    Genom att klicka på “Lägg till rabattkod” så accepterar du \(termsAndConditionsLink)
                    """
                case .REFERRAL_ERROR_MISSINGCODE_HEADLINE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Rabatt saknas
                    """
                case .REFERRAL_ERROR_MISSINGCODE_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Din kod saknas, dubbelkolla gärna så att du skrivit den rätt
                    """
                case .REFERRAL_ERROR_MISSINGCODE_BTN:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    OK
                    """
                case .REFERRAL_ERROR_REPLACECODE_HEADLINE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Du har redan en rabattkod aktiverad
                    """
                case .REFERRAL_ERROR_REPLACECODE_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Vill du ersätta din nuvarande rabattkod?
                    """
                case .REFERRAL_ERROR_REPLACECODE_BTN_CANCEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Avbryt
                    """
                case .REFERRAL_ERROR_REPLACECODE_BTN_SUBMIT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Ersätt
                    """
                case let .REFERRAL_RECIEVER_WELCOME_HEADLINE(user):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["USER": user]) {
                        return text
                    }

                    return """
                    Välkommen som medlem \(user)!
                    """
                case let .REFERRAL_RECIEVER_WELCOME_BODY(referralValue):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["REFERRAL_VALUE": referralValue]) {
                        return text
                    }

                    return """
                    Hedvig blir bättre när du får dela det med dina vänner! Du och dina vänner får \(referralValue) kr lägre månadskostnad – för varje vän!
                    """
                case .REFERRAL_RECIEVER_WELCOME_BTN_CTA:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Bjud in vänner direkt! 👯‍♀️
                    """
                case .REFERRAL_RECIEVER_WELCOME_BTN_SKIP:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Kolla in appen
                    """
                case .PROFILE_ROW_NEW_REFERRAL_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Få gratis försäkring!
                    """
                case .PROFILE_ROW_NEW_REFERRAL_DESCRIPTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Rekommendera Hedvig
                    """
                case .NEWS_PROCEED:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Nästa
                    """
                case .NEWS_DISMISS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Gå till appen
                    """
                case let .REFERRAL_LINK_INVITATION_SCREEN_HEADLINE(name, referralValue):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["NAME": name, "REFERRAL_VALUE": referralValue]) {
                        return text
                    }

                    return """
                    Du har blivit inbjuden av \(name) och kommer få \(referralValue) kr rabatt i månaden
                    """
                case .REFERRAL_LINK_INVITATION_SCREEN_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Vill du acceptera inbjudan eller fortsätta utan rabatt?
                    """
                case .REFERRAL_LINK_INVITATION_SCREEN_BTN_ACCEPT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Ja, acceptera rabatten!
                    """
                case .REFERRAL_LINK_INVITATION_SCREEN_BTN_DECLINE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Nej, fortsätt utan rabatt
                    """
                case .NEWS_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Vad är nytt?
                    """
                case .NEWS_CLOSE_DESCRIPTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Stäng
                    """
                case let .REFERRAL_PROGRESS_HIGH_PREMIUM_DISCOUNT(discountValue):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["DISCOUNT_VALUE": discountValue]) {
                        return text
                    }

                    return """
                    -\(discountValue) kr
                    """
                case .REFERRAL_PROGRESS_HIGH_PREMIUM_DISCOUNT_SUBTITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    rabatt per månad
                    """
                case let .REFERRAL_PROGRESS_HIGH_PREMIUM_DESCRIPTION(monthlyCost):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["MONTHLY_COST": monthlyCost]) {
                        return text
                    }

                    return """
                    Nuvarande pris: \(monthlyCost) kr/mån
                    """
                case .PROFILE_PAYMENT_PRICE_LABEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Pris
                    """
                case let .PROFILE_PAYMENT_PRICE(price):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["PRICE": price]) {
                        return text
                    }

                    return """
                    \(price) kr/mån
                    """
                case .PROFILE_PAYMENT_DISCOUNT_LABEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Rabatt
                    """
                case let .PROFILE_PAYMENT_DISCOUNT(discount):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["DISCOUNT": discount]) {
                        return text
                    }

                    return """
                    \(discount) kr/mån
                    """
                case .PROFILE_PAYMENT_FINAL_COST_LABEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Din kostnad
                    """
                case let .PROFILE_PAYMENT_FINAL_COST(finalCost):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["FINAL_COST": finalCost]) {
                        return text
                    }

                    return """
                    \(finalCost) kr/mån
                    """
                case .PROFILE_ABOUT_APP_OPEN_WHATS_NEW:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Se nyheter
                    """
                case .PUSH_NOTIFICATIONS_ALERT_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Notiser
                    """
                case .PUSH_NOTIFICATIONS_ALERT_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Slå på notiser så att du inte missar när Hedvig svarar!
                    """
                case .PUSH_NOTIFICATIONS_ALERT_ACTION_OK:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Slå på
                    """
                case .PUSH_NOTIFICATIONS_ALERT_ACTION_NOT_NOW:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Inte nu
                    """
                case .REFERRALS_RECEIVER_TERMS_LINK:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    https://www.hedvig.com/TODO
                    """
                case .REFERRAL_PROGRESS_MORE_INFO_HEADLINE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Hur tänkte vi här?
                    """
                case .REFERRAL_PROGRESS_MORE_INFO_PARAGRAPH_ONE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Vi älskar dig. Du får vår värld att snurra runt. Därför vill vi belöna dig. Traditionella försäkringsbolag belönar folk genom årliga prishöjningar och hittar på alla möjliga anledningar till att inte betala. Vi tycker det är schysstare att sänka ditt pris. Nice.
                    """
                case .REFERRAL_PROGRESS_MORE_INFO_PARAGRAPH_TWO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Så här fungerar det
                    1. Dela din länk eller kod hur du vill, t.ex. på sms, mail eller i sociala medier.
                    2. Går en vän med får ni båda 10 kr rabatt.
                    3. När riktigt många går med sänks din månadsavgift till drömgränsen. 0 kr. Zero.
                    """
                case .REFERRAL_PROGRESS_MORE_INFO_CTA:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Läs villkor
                    """
                case .REFERRAL_PROGRESS_MORE_INFO_PARAGRAPH:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Vi älskar dig. Du får vår värld att snurra runt. Därför vill vi belöna dig. Traditionella försäkringsbolag belönar folk genom årliga prishöjningar och hittar på alla möjliga anledningar till att inte betala. Vi tycker det är schysstare att sänka ditt pris. Nice.

                    Så här fungerar det
                    1. Dela din länk eller din kod hur du vill, ex Instagram, Sms, Epost
                    2. Går en vän med får ni båda 10 kr rabatt.
                    3. När riktigt många går med sänks din månadsavgift till drömgränsen. 0 kr. Zero.
                    """
                case .OFFER_REMOVE_DISCOUNT_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Ta bort rabattkod
                    """
                case .OFFER_ADD_DISCOUNT_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Rabattkod
                    """
                case .REFERRAL_ADDCOUPON_TC_LINK:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    villkoren
                    """
                case .OFFER_SCREEN_INVITED_BUBBLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Inbjuden!
                    """
                case .INSURANCE_STATUS_TERMINATED_ALERT_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Din försäkring är inte aktiv
                    """
                case .INSURANCE_STATUS_TERMINATED_ALERT_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Du kan skriva till Hedvig om du vill aktivera din försäkring igen
                    """
                case .INSURANCE_STATUS_TERMINATED_ALERT_CTA:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Chatta med Hedvig
                    """
                case .OFFER_REMOVE_DISCOUNT_ALERT_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Ta bort rabattkod?
                    """
                case .OFFER_REMOVE_DISCOUNT_ALERT_DESCRIPTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Är du säker på att du vill ta bort din rabattkod?
                    """
                case .OFFER_REMOVE_DISCOUNT_ALERT_REMOVE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Ta bort
                    """
                case .OFFER_REMOVE_DISCOUNT_ALERT_CANCEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Avbryt
                    """
                case .REFERRAL_INVITE_CODE_COPIED_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Kod kopierad!
                    """
                case .REFERRAL_MORE_INFO_LINK:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    https://www.hedvig.com/invite/terms
                    """
                case .PRICE_MISSING:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Pris saknas
                    """
                case .TAB_REFERRALS_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Bjud in
                    """
                case .INSURANCE_STATUS_TERMINATED_ALERT_ACTION_CHAT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Chatta med Hedvig
                    """
                case .MARKETING_GET_HEDVIG:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Få prisförslag
                    """
                case .MARKETING_LOGIN:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Redan medlem? Logga in
                    """
                case .REFERRAL_REFERRED_BY_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Du har blivit inbjuden av
                    """
                case .MODERNA_FORSAKRING_APP:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Moderna Försäkringar
                    """
                case .ICA_FORSAKRING_APP:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    ICA Försäkring
                    """
                case .OTHER_INSURER_OPTION_APP:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    din nuvarande försäkring
                    """
                case .SIGN_MOBILE_BANK_ID:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Signera med ditt Mobilt BankID
                    """
                case .OFFER_NON_SWITCHABLE_PARAGRAPH_ONE_APP:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Kontakta ditt nuvarande försäkringsbolag och säg upp din hemförsäkring. Skriv till oss i chatten och berätta när din nuvarande försäkring går ut
                    """
                case .OFFER_SWITCH_COL_PARAGRAPH_ONE_APP:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Hedvig kontaktar ditt försäkringsbolag och säger upp din gamla försäkring
                    """
                case .OFFER_SWITCH_COL_THREE_PARAGRAPH_APP:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Vi ser till att din Hedvig-försäkring aktiveras automatiskt samma dag som din gamla går ut
                    """
                case let .OFFER_SWITCH_TITLE_APP(insurer):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["INSURER": insurer]) {
                        return text
                    }

                    return """
                    Hedvig sköter bytet från \(insurer)
                    """
                case .OFFER_SWITCH_TITLE_NON_SWITCHABLE_APP:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Så här byter du till Hedvig om du redan har en försäkring
                    """
                case let .REFERRAL_INVITE_OPENEDSTATE_MULTIPLE(numberOfInvites):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["NUMBER_OF_INVITES": numberOfInvites]) {
                        return text
                    }

                    return """
                    \(numberOfInvites) personer har öppnat din länk
                    """
                case .NEW_MEMBER_DISMISS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Utforska appen och bjud in
                    """
                case .NEW_MEMBER_PROCEED:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Nästa
                    """
                case .UPLOAD_FILE_BUTTON_HINT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Ladda upp fil
                    """
                case .REFERRALS_CODE_SHEET_COPY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Kopiera
                    """
                case let .REFERRAL_PROGRESS_HIGH_PREMIUM_DISCOUNT_NO_MINUS(discountValue):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["DISCOUNT_VALUE": discountValue]) {
                        return text
                    }

                    return """
                    \(discountValue) kr
                    """
                case .REFERRAL_REDEEM_SUCCESS_HEADLINE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Rabattkod tillagd!
                    """
                case .REFERRAL_REDEEM_SUCCESS_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Grattis! Rabattkoden har nu lagts till
                    """
                case .REFERRAL_REDEEM_SUCCESS_BTN:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    OK, nice!
                    """
                case .PUSH_NOTIFICATIONS_REFERRALS_ALERT_MESSSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Slå på notiser så att du inte missar när någon skaffar Hedvig via din länk!
                    """
                case .AUDIO_INPUT_RECORD_DESCRIPTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Spela in
                    """
                case .AUDIO_INPUT_STOP_DESCRIPTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Stopp
                    """
                case .AUDIO_INPUT_START_RECORDING:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Starta inspelning
                    """
                case let .AUDIO_INPUT_PLAYBACK_PROGRESS(seconds):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["SECONDS": seconds]) {
                        return text
                    }

                    return """
                    \(seconds)s
                    """
                case .PROFILE_MY_INFO_SAVE_SUCCESS_TOAST_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Ändringar sparade
                    """
                case .PROFILE_MY_INFO_SAVE_SUCCESS_TOAST_SYMBOL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    ✍️
                    """
                case .CHAT_EDIT_MESSAGE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Vill du ändra ditt svar?
                    """
                case .CHAT_EDIT_MESSAGE_SUBMIT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Ändra
                    """
                case .CHAT_EDIT_MESSAGE_CANCEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Avbryt
                    """
                case .CHAT_EDIT_MESSAGE_DESCRIPTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Ändra svar
                    """
                case .COPIED:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Kopierat!
                    """
                case let .OFFER_SCREEN_FREE_MONTHS_BUBBLE(freeMonth):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["free_month": freeMonth]) {
                        return text
                    }

                    return """
                    \(freeMonth) månader
                    gratis!
                    """
                case .OFFER_SCREEN_FREE_MONTHS_BUBBLE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Rabatt!
                    """
                case .MY_PAYMENT_FREE_UNTIL_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Gratis till
                    """
                case .OFFER_PRICE_PER_MONTH:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    kr/mån
                    """
                case .SIGN_START_BANKID:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Starta BankID-appen
                    """
                case .SIGN_SUCCESSFUL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Signering godkänd 👌
                    """
                case .SIGN_IN_PROGRESS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Signering pågår
                    """
                case .SIGN_CANCELED:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Signering avbruten 🙅
                    """
                case .SIGN_FAILED_REASON_UNKNOWN:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Ojdå! Okänt fel 🙈
                    """
                case .BANK_ID_NOT_INSTALLED:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    BankID-appen verkar inte finnas i din telefon. Installera den och hämta ett BankID hos din internetbank.
                    """
                case .OFFER_CHAT_ACCESSIBILITY_HINT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Öppna chatten
                    """
                case .CHAT_GIPHY_SEARCH_HINT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Sök...
                    """
                case .MARKETING_LOGO_ACCESSIBILITY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Hedvig
                    """
                case .DASHBOARD_RENEWAL_PROMPTER_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Din försäkring uppdateras
                    """
                case let .DASHBOARD_RENEWAL_PROMPTER_BODY(daysUntilRenewal):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["DAYS_UNTIL_RENEWAL": daysUntilRenewal]) {
                        return text
                    }

                    return """
                    Om \(daysUntilRenewal) dagar kommer din försäkring förnyas. Läs ditt uppdaterade försäkringsbrev här.
                    """
                case .DASHBOARD_RENEWAL_PROMPTER_CTA:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Läs nytt försäkringsbrev
                    """
                case .DASHBOARD_SETUP_DIRECT_DEBIT_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Koppla autogiro
                    """
                case .DASHBOARD_INFO_BOX_CLOSE_DESCRIPTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Stäng
                    """
                case .ONBOARDING_CONNECT_DD_HEADLINE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Koppla autogiro
                    """
                case .ONBOARDING_CONNECT_DD_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    För att försäkringen ska gälla så behöver du koppla ditt autogiro. Betalningen dras automatiskt från ditt bankkonto den 27:e varje månad.
                    """
                case .ONBOARDING_CONNECT_DD_BODY_SWITCHERS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Med autogiro sätter du livet på autopilot. Vi tar såklart betalt först när din försäkring aktiveras.
                    """
                case .ONBOARDING_CONNECT_DD_CTA:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Koppla autogiro
                    """
                case .TRUSTLY_SKIP_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Inte nu
                    """
                case .ONBOARDING_ACTIVATE_NOTIFICATIONS_PRE_HEADLINE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Don't check Hedvig 24/7 
                    """
                case .ONBOARDING_ACTIVATE_NOTIFICATIONS_HEADLINE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Activate notifications
                    """
                case .ONBOARDING_ACTIVATE_NOTIFICATIONS_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Allow notifications to receive messages from Hedvig. We don't spam, we promise.
                    """
                case .ONBOARDING_ACTIVATE_NOTIFICATIONS_CTA:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Allow notifications
                    """
                case .ONBOARDING_ACTIVATE_NOTIFICATIONS_DISMISS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Skip
                    """
                case .ONBOARDING_CONNECT_DD_PRE_HEADLINE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Psst, glöm inte...
                    """
                case .OFFER_TERMS_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Viktiga villkor
                    """
                case .OFFER_TERMS_NO_BINDING_PERIOD:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Sveriges enda försäkring helt utan bindningstid
                    """
                case .OFFER_TERMS_NO_COVERAGE_LIMIT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Lägenheten är försäkrad utan begränsning
                    """
                case let .OFFER_TERMS_MAX_COMPENSATION(maxCompensation):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["MAX_COMPENSATION": maxCompensation]) {
                        return text
                    }

                    return """
                    Maxersättning för prylarna i ditt hem är \(maxCompensation)
                    """
                case let .OFFER_TERMS_DEDUCTIBLE(deductible):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["DEDUCTIBLE": deductible]) {
                        return text
                    }

                    return """
                    Självrisken är \(deductible)
                    """
                case .OFFER_TERMS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Försäkrings-
                    villkor
                    """
                case .OFFER_PRESALE_INFORMATION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Förköps-
                    information
                    """
                case .OFFER_PRIVACY_POLICY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Personuppgifts-
                    policy
                    """
                case .MAX_COMPENSATION_STUDENT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    200 000 kr
                    """
                case .MAX_COMPENSATION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    1 miljon kr
                    """
                case .DEDUCTIBLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    1500 kr
                    """
                case .TRUSTLY_ALERT_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Är du säker?
                    """
                case .TRUSTLY_ALERT_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    För att din försäkring ska gälla framöver behöver du koppla autogiro från din bank.
                    """
                case .TRUSTLY_ALERT_POSITIVE_ACTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Ja, koppla sen
                    """
                case .TRUSTLY_ALERT_NEGATIVE_ACTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Nej, koppla nu
                    """
                case .PRIVACY_POLICY_URL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    https://s3.eu-central-1.amazonaws.com/com-hedvig-web-content/Hedvig+-+integritetspolicy.pdf
                    """
                case .ONBOARDING_CONNECT_DD_SUCCESS_HEADLINE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Autogiro kopplat!
                    """
                case .ONBOARDING_CONNECT_DD_SUCCESS_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Tack för det!
                    """
                case .ONBOARDING_CONNECT_DD_SUCCESS_CTA:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Fortsätt
                    """
                case .ONBOARDING_CONNECT_DD_FAILURE_HEADLINE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Ajdå, något gick snett…
                    """
                case .ONBOARDING_CONNECT_DD_FAILURE_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    För att din försäkring ska gälla framöver behöver du koppla autogiro från din bank. Du kan göra det senare i appen.
                    """
                case .ONBOARDING_CONNECT_DD_FAILURE_CTA_RETRY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Prova igen
                    """
                case .ONBOARDING_CONNECT_DD_FAILURE_CTA_LATER:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Gör det senare
                    """
                case .BANKID_INACTIVE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Avbruten pga inaktivitet
                    """
                case .BANKID_INACTIVE_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    BankId avbröts på grund av inaktivitet, vänligen försök igen.
                    """
                case .BANKID_INACTIVE_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    OK
                    """
                case .BANK_ID_AUTH_TITLE_INITIATED:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Öppnar BankId...
                    """
                case .CLAIMS_PLEDGE_SLIDE_LABEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Dra för att starta anmälan
                    """
                case .PROFILE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Profil
                    """
                case .DEMO_MODE_START:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Starta demoläge
                    """
                case .DEMO_MODE_CANCEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Avbryt
                    """
                case .BANKID_MISSING_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    BankID saknas på din enhet
                    """
                case .BANKID_MISSING_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Skanna QR-koden ovan i den enhet där du har BankID installerat
                    """
                case .CHAT_RESTART_ALERT_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Vill du starta om?
                    """
                case .CHAT_RESTART_ALERT_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    All information du fyllt i kommer att försvinna
                    """
                case .CHAT_RESTART_ALERT_CONFIRM:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    OK
                    """
                case .CHAT_RESTART_ALERT_CANCEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Avbryt
                    """
                case .SETTINGS_LOGIN_ROW:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Logga in
                    """
                case .BANKID_LOGIN_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Logga in
                    """
                case .ABOUT_LICENSES_ROW:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Licensrättigheter
                    """
                case .ABOUT_PUSH_ROW:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Aktivera pushnotiser
                    """
                case .ABOUT_SHOW_INTRO_ROW:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Visa intro
                    """
                case .PROFILE_FEEDBACK_ROW:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Feedback
                    """
                case .CHARTITY_PICK_OPTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Välj
                    """
                case .PROFILE_ABOUT_ROW:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Om appen
                    """
                case .PAYMENTS_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Min betalning
                    """
                case .PAYMENTS_CARD_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Nästa betalning
                    """
                case let .PAYMENTS_CURRENT_PREMIUM(currentPremium):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["CURRENT_PREMIUM": currentPremium]) {
                        return text
                    }

                    return """
                    \(currentPremium) kr
                    """
                case .PAYMENTS_CARD_DATE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Datum
                    """
                case .PAYMENTS_CARD_NO_STARTDATE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Startdatum ej satt
                    """
                case .PAYMENTS_SUBTITLE_PREVIOUS_PAYMENTS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Tidigare betalningar
                    """
                case .PAYMENTS_BTN_HISTORY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Se historik
                    """
                case .PAYMENTS_SUBTITLE_PAYMENT_METHOD:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Betalningsmetod
                    """
                case .PAYMENTS_SUBTITLE_ACCOUNT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Konto
                    """
                case .PAYMENTS_DIRECT_DEBIT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Autogiro
                    """
                case .PAYMENTS_DIRECT_DEBIT_ACTIVE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Aktivt
                    """
                case .PAYMENTS_BTN_CHANGE_BANK:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Ändra bankonto
                    """
                case let .PAYMENTS_LATE_PAYMENTS_MESSAGE(monthsLate, nextPaymentDate):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["MONTHS_LATE": monthsLate, "NEXT_PAYMENT_DATE": nextPaymentDate]) {
                        return text
                    }

                    return """
                    Du ligger \(monthsLate) månader efter med dina betalningar. Vi kommer att dra mer pengar än din ordinarie premie den \(nextPaymentDate).
                    """
                case let .PAYMENTS_FULL_PREMIUM(fullPremium):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["FULL_PREMIUM": fullPremium]) {
                        return text
                    }

                    return """
                    \(fullPremium) kr/mån
                    """
                case .PAYMENTS_SUBTITLE_DISCOUNT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Rabatt
                    """
                case .PAYMENTS_OFFER_MULTIPLE_MONTHS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Gratis
                    månader 
                    """
                case .PAYMENTS_OFFER_SINGLE_MONTH:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Gratis
                    månad
                    """
                case .PAYMENTS_SUBTITLE_CAMPAIGN:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Aktuell kampanj
                    """
                case .PAYMENTS_CAMPAIGN_OWNER:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Från
                    """
                case .PAYMENTS_NO_STARTDATE_HELP_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    När din gamla försäkring är uppsagd och vi har ett startdatum för din försäkring hos Hedvig kommer denna sektion uppdateras.
                    """
                case .PAYMENTS_SUBTITLE_PAYMENT_HISTORY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Betalningshistorik
                    """
                case .HEDVIG_LOGO_ACCESSIBILITY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    hedvig
                    """
                case .MARKETING_SCREEN_SAY_HELLO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Säg hej till Hedvig
                    """
                case .REFERRALS_FREE_LABEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Gratis!
                    """
                case .REFERRALS_INVITE_LABEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Bjud in
                    """
                case .OFFER_PRICE_BUBBLE_MONTH:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    kr/mån
                    """
                case .PROFILE_PAYMENT_CONNECT_DIRECT_DEBIT_WITH_LINK_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Koppla bankkonto (webbläsare)
                    """
                case .PAYMENTS_DISCOUNT_ZERO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Hedvig Zero
                    """
                case let .PAYMENTS_DISCOUNT_AMOUNT(discount):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["DISCOUNT": discount]) {
                        return text
                    }

                    return """
                    -\(discount) kr
                    """
                case .PAYMENTS_CAMPAIGN_LFD:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Sista gratisdatum
                    """
                case .PAYMENT_HISTORY_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Betalningshistorik
                    """
                case let .PAYMENT_HISTORY_AMOUNT(amount):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["AMOUNT": amount]) {
                        return text
                    }

                    return """
                    \(amount) kr
                    """
                case .PAYMENTS_DIRECT_DEBIT_NEEDS_SETUP:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Ej kopplat
                    """
                case .PAYMENTS_DIRECT_DEBIT_PENDING:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Under ändring
                    """
                case let .OFFER_HOUSE_SUMMARY_TITLE(userAdress):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["USER_ADRESS": userAdress]) {
                        return text
                    }

                    return """
                    \(userAdress)
                    """
                case .OFFER_HOUSE_SUMMARY_DESC:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Här är en snabb översikt över informationen du har gett oss om ditt hem.
                    """
                case .OFFER_HOUSE_SUMMARY_BUTTON_EXPAND:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Expandera
                    """
                case .OFFER_HOUSE_SUMMARY_BUTTON_MINIMIZE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Minimera
                    """
                case .OFFER_HOUSE_TRUST_HOUSE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Din villa är försäkrad till fullvärde
                    """
                case .OFFER_HOUSE_TRUST_HDI:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Hedvig backas av HDI, en av världens största försäkringskoncerner
                    """
                case .HOUSE_INFO_BOYTA:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Boyta
                    """
                case .HOUSE_INFO_BIYTA:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Biyta
                    """
                case .HOUSE_INFO_YEAR_BUILT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Byggnadsår
                    """
                case .HOUSE_INFO_BATHROOM:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Badrum
                    """
                case .HOUSE_INFO_RENTED:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Delvis uthyrd?
                    """
                case .HOUSE_INFO_TYPE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Hus
                    """
                case .HOUSE_INFO_EXTRABUILDINGS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Övriga byggnader
                    """
                case .HOUSE_INFO_GARAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Garage
                    """
                case .HOUSE_INFO_SHED:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Friggebod
                    """
                case .HOUSE_INFO_ATTEFALLS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Attefalls
                    """
                case .HOUSE_INFO_MISC:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Annan
                    """
                case .HOUSE_INFO_CONNECTED_WATER:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Indraget vatten
                    """
                case .MY_HOME_ROW_TYPE_HOUSE_VALUE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Hus
                    """
                case let .MY_HOME_ROW_ANCILLARY_AREA_VALUE(area):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["area": area]) {
                        return text
                    }

                    return """
                    \(area) kvm
                    """
                case .MY_HOME_ROW_ANCILLARY_AREA_KEY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Biyta
                    """
                case .MY_HOME_ROW_CONSTRUCTION_YEAR_KEY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Byggnadsår
                    """
                case .MY_HOME_ROW_BATHROOMS_KEY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Antal badrum
                    """
                case .MY_HOME_EXTRABUILDING_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Övriga byggnader
                    """
                case let .HOUSE_INFO_BOYTA_SQUAREMETERS(houseInfoAmountBoyta):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["HOUSE_INFO_AMOUNT_BOYTA": houseInfoAmountBoyta]) {
                        return text
                    }

                    return """
                    \(houseInfoAmountBoyta) kvadratmeter
                    """
                case let .HOUSE_INFO_BIYTA_SQUAREMETERS(houseInfoAmountBiyta):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["HOUSE_INFO_AMOUNT_BIYTA": houseInfoAmountBiyta]) {
                        return text
                    }

                    return """
                    \(houseInfoAmountBiyta) kvadratmeter
                    """
                case let .OFFER_INFO_OFFER_EXPIRES(offerExpieryDate):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["OFFER_EXPIERY_DATE": offerExpieryDate]) {
                        return text
                    }

                    return """
                    Försäkringsförslaget gäller till \(offerExpieryDate)
                    """
                case .HOUSE_INFO_COINSURED:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Antal medförsäkrade
                    """
                case .EXPANDABLE_CONTENT_EXPAND:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Se mer
                    """
                case .EXPANDABLE_CONTENT_COLLAPSE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Stäng
                    """
                case .OFFER_TRUST_INCREASED_DEDUCTIBLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    För vissa skador gäller en förhöjd självrisk, t.ex. översvämning och frysskador. Se våra villkor eller chatta med oss vid frågor.
                    """
                case .HOUSE_INFO_SUBLETED_TRUE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Ja
                    """
                case .HOUSE_INFO_SUBLETED_FALSE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Nej
                    """
                case .OFFER_INFO_TRUSTUS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Du är trygg hos oss
                    """
                case .HOUSE_INFO_COMPENSATION_GADGETS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    1,5 miljoner kr
                    """
                case let .MY_HOME_BUILDING_HAS_WATER_SUFFIX(base):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["base": base]) {
                        return text
                    }

                    return """
                    \(base), indraget vatten
                    """
                case .MY_HOME_ROW_SUBLETED_KEY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Delvis uthyrd?
                    """
                case .MY_HOME_ROW_SUBLETED_VALUE_YES:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Ja
                    """
                case .MY_HOME_ROW_SUBLETED_VALUE_NO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Nej
                    """
                case .MAX_COMPENSATION_HOUSE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    1.5 miljoner kronor
                    """
                case let .DASHBOARD_INFO_DEDUCTIBLE_HOUSE(deductible):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["deductible": deductible]) {
                        return text
                    }

                    return """
                    Din självrisk är \(deductible). 
                    För vissa skador gäller en förhöjd självrisk, t.ex. översvämning och frysskador. Se våra villkor eller chatta med oss vid frågor.
                    """
                case .DASHBOARD_INFO_HOUSE_VALUE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Din villa är försäkrad till fullvärde
                    """
                case let .DASHBOARD_INFO_INSURANCE_STUFF_AMOUNT(maxCompensation):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["maxCompensation": maxCompensation]) {
                        return text
                    }

                    return """
                    Maxersättning för dina prylar är 
                    \(maxCompensation)
                    """
                case .MY_HOME_INSURANCE_TYPE_HOUSE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Hus
                    """
                case .MY_HOME_CITY_LABEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Postort
                    """
                case .COST_MONTHLY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    kr/mån
                    """
                case .OFFER_TITLE_SAFE_WITH_US:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Du är trygg hos oss
                    """
                case .CHAT_TOAST_PUSH_NOTIFICATIONS_SUBTITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Aktivera pushnotiser
                    """
                case .ATTACH_GIF_IMAGE_SEND:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Skicka
                    """
                case .LABEL_SEARCH_GIF:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Sök på något för att få upp gifar!
                    """
                case .SEARCH_BAR_GIF:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Sök på gifar
                    """
                case .OFFER_SCREEN_PERCENTAGE_DISCOUNT_BUBBLE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Rabatt!
                    """
                case let .OFFER_SCREEN_PERCENTAGE_DISCOUNT_BUBBLE_TITLE_SINGULAR(percentage):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["percentage": percentage]) {
                        return text
                    }

                    return """
                    \(percentage)% i en månad
                    """
                case let .OFFER_SCREEN_PERCENTAGE_DISCOUNT_BUBBLE_TITLE_PLURAL(months, percentage):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["months": months, "percentage": percentage]) {
                        return text
                    }

                    return """
                    \(percentage)% i \(months) månader
                    """
                case .OFFER_START_DATE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Startar
                    """
                case .OFFER_START_DATE_TODAY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Idag
                    """
                case .CLAIMS_ACTIVATE_NOTIFICATIONS_HEADLINE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Aktivera pushnotiser
                    """
                case .CLAIMS_ACTIVATE_NOTIFICATIONS_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    För att du ska få information från oss gällande din skada och se när vi skriver till dig är det viktigt att du aktiverar dina notiser.
                    """
                case .CLAIMS_ACTIVATE_NOTIFICATIONS_CTA:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Aktivera notiser
                    """
                case .CLAIMS_ACTIVATE_NOTIFICATIONS_DISMISS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Hoppa över
                    """
                case let .PAYMENTS_DISCOUNT_PERCENTAGE_MONTHS_MANY(months, percentage):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["MONTHS": months, "PERCENTAGE": percentage]) {
                        return text
                    }

                    return """
                    "\(percentage)% rabatt i \(months) månader"
                    """
                case let .PAYMENTS_DISCOUNT_PERCENTAGE_MONTHS_ONE(percentage):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["PERCENTAGE": percentage]) {
                        return text
                    }

                    return """
                    "\(percentage)% rabatt i en månad"
                    """
                case .DRAGGABLE_STARTDATE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Byt startdatum
                    """
                case .DRAGGABLE_STARTDATE_DESCRIPTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Vilket datum vill du att din försäkring aktiveras?
                    """
                case .ACTIVATE_TODAY_BTN:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Aktivera idag
                    """
                case .ACTIVATE_INSURANCE_END_BTN:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Aktivera när din nuvarande försäkring går ut
                    """
                case .CHOOSE_DATE_BTN:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Välj datum
                    """
                case .START_DATE_BTN:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Startar
                    """
                case .START_DATE_TODAY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Idag
                    """
                case .ALERT_CONTINUE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Fortsätt
                    """
                case .ALERT_CANCEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Avbryt
                    """
                case .ALERT_TITLE_STARTDATE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Välj eget startdatum?
                    """
                case .ALERT_DESCRIPTION_STARTDATE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Om du väljer eget startdatum får du själv säga upp din nuvarande försäkring så att allt blir rätt
                    """
                case .START_DATE_EXPIRES:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    När min bindningstid går ut
                    """
                case let .LATE_PAYMENT_MESSAGE(date, months):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["date": date, "months": months]) {
                        return text
                    }

                    return """
                    Du ligger \(months) månader efter med dina betalningar. Vi kommer att dra mer pengar än din ordinarie premie den \(date).
                    """
                case .EDITABLE_ROW_EDIT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Ändra
                    """
                case .EDITABLE_ROW_SAVE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Spara
                    """
                case .KEY_GEAR_TAB_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Dina saker
                    """
                case .KEY_GEAR_START_EMPTY_HEADLINE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Få koll på dina saker
                    """
                case .KEY_GEAR_START_EMPTY_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Det ligger i sakens natur, att våra saker skadas eller försvinner. Logga dina saker enkelt för att kunna anmäla dem med ett klick, se hur de täcks och vad du får i ersättning.
                    """
                case .KEY_GEAR_ADD_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Lägg till en sak
                    """
                case .KEY_GEAR_ADDED_AUTOMATICALLY_TAG:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Tillagd automatiskt
                    """
                case .KEY_GEAR_MORE_INFO_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Mer info
                    """
                case .KEY_GEAR_MORE_INFO_HEADLINE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Så funkar Dina saker
                    """
                case .KEY_GEAR_MORE_INFO_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    I prylbanken kan du lägg till information om dina viktigaste prylar. Du lägger in information om vilken typ av pryl det är och när du köpte den, så får du detaljerad information om vad den täcks för och vad den värderas till om något skulle hända. Det är inte ett måste, du får göra det om du vill – dina prylar täcks såklart oavsett om du lagt in dem i prylbanken eller inte.
                    """
                case .KEY_GEAR_ADD_ITEM_PAGE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Lägg till sak
                    """
                case .KEY_GEAR_ADD_ITEM_PAGE_CLOSE_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Avbryt
                    """
                case .KEY_GEAR_ADD_ITEM_PAGE_CLOSE_ALERT_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Är du säker på att du vill avbryta?
                    """
                case .KEY_GEAR_ADD_ITEM_PAGE_CLOSE_ALERT_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Informationen du angett kommer inte att sparas
                    """
                case .KEY_GEAR_ADD_ITEM_PAGE_CLOSE_ALERT_DISMISS_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Nej, fortsätt
                    """
                case .KEY_GEAR_ADD_ITEM_PAGE_CLOSE_ALERT_CONTINUE_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Ja, avbryt
                    """
                case .KEY_GEAR_ADD_ITEM_ADD_PHOTO_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Lägg till foto
                    """
                case .KEY_GEAR_ADD_ITEM_TYPE_HEADLINE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Typ av sak
                    """
                case .KEY_GEAR_ADD_ITEM_SAVE_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Spara
                    """
                case let .KEY_GEAR_ADD_ITEM_SUCCESS(itemType):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["ITEM_TYPE": itemType]) {
                        return text
                    }

                    return """
                    Lagt till \(itemType)!
                    """
                case .KEY_GEAR_ITEM_VIEW_VALUATION_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Värderad till
                    """
                case .KEY_GEAR_ITEM_VIEW_VALUATION_EMPTY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Lägg till inköpsinfo +
                    """
                case .KEY_GEAR_ITEM_VIEW_DEDUCTIBLE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Självrisk
                    """
                case .KEY_GEAR_ITEM_VIEW_DEDUCTIBLE_VALUE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    1 500
                    """
                case .KEY_GEAR_ITEM_VIEW_DEDUCTIBLE_CURRENCY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    kr
                    """
                case .KEY_GEAR_ITEM_VIEW_COVERAGE_TABLE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Din försäkring täcker
                    """
                case .KEY_GEAR_ITEM_VIEW_NON_COVERAGE_TABLE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Din försäkring täcker inte
                    """
                case .KEY_GEAR_ITEM_VIEW_ITEM_NAME_TABLE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Namn
                    """
                case .KEY_GEAR_ITEM_VIEW_ITEM_NAME_EDIT_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Ändra
                    """
                case .KEY_GEAR_ITEM_VIEW_RECEIPT_TABLE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Kvitto
                    """
                case .KEY_GEAR_ITEM_VIEW_RECEIPT_CELL_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Kvitto
                    """
                case .KEY_GEAR_ITEM_VIEW_RECEIPT_CELL_ADD_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Lägg till +
                    """
                case .KEY_GEAR_ITEM_VIEW_RECEIPT_TABLE_FOOTER:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Du behöver inte lägga till kvittot, det kan bara vara skönt att veta var du har det.
                    """
                case .KEY_GEAR_ITEM_VIEW_ADD_PURCHASE_DATE_PAGE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Lägg till inköpsinfo
                    """
                case let .KEY_GEAR_ITEM_VIEW_ADD_PURCHASE_DATE_BODY(itemType):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["ITEM_TYPE": itemType]) {
                        return text
                    }

                    return """
                    Ange när du köpte din \(itemType) och för hur mycket för att beräkna vad den värderas till
                    """
                case .KEY_GEAR_ITEM_VIEW_ADD_PURCHASE_DATE_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Spara
                    """
                case .KEY_GEAR_ITEM_VIEW_VALUATION_PAGE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Värdering
                    """
                case .KEY_GEAR_ITEM_VIEW_VALUATION_PERCENTAGE_LABEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    av inköpspriset
                    """
                case let .KEY_GEAR_ITEM_VIEW_VALUATION_BODY(itemType, purchasePrice, valuationPercentage, valuationPrice):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["ITEM_TYPE": itemType, "PURCHASE_PRICE": purchasePrice, "VALUATION_PERCENTAGE": valuationPercentage, "VALUATION_PRICE": valuationPrice]) {
                        return text
                    }

                    return """
                    Vi försöker reparera i första hand, men om din \(itemType) skulle behöva ersättas helt (ex. om den blivit stulen) ersätts du med **\(valuationPercentage)%** av inköpspriset **\(purchasePrice) kr**, alltså **\(valuationPrice) kr**.
                    """
                case .KEY_GEAR_ITEM_VIEW_VALUATION_AGE_DEDUCTION_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Åldersavdrag
                    """
                case let .KEY_GEAR_ITEM_VIEW_VALUATION_AGE_DEDUCTION_BODY(itemType):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["ITEM_TYPE": itemType]) {
                        return text
                    }

                    return """
                    Vi ett avdrag med en viss procent beroende på hur länge sedan du köpte din \(itemType).
                    """
                case .KEY_GEAR_ITEM_VIEW_VALUATION_AGE_DEDUCTION_TABLE_EXPAND_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Expandera
                    """
                case .KEY_GEAR_ADD_PURCHASE_PRICE_CELL_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Inköpspris
                    """
                case .ITEM_TYPE_PHONE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Mobil
                    """
                case .ITEM_TYPE_COMPUTER:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Dator
                    """
                case .ITEM_TYPE_TV:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    TV
                    """
                case .ITEM_TYPE_BIKE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Cykel
                    """
                case .ITEM_TYPE_WATCH:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Klocka
                    """
                case .ITEM_TYPE_JEWELRY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Smycke
                    """
                case .KEY_GEAR_RECCEIPT_VIEW_PAGE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Kvitto
                    """
                case .KEY_GEAR_RECCEIPT_VIEW_CLOSE_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Stäng
                    """
                case .KEY_GEAR_RECCEIPT_VIEW_SHARE_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Dela
                    """
                case .KEY_GEAR_ADD_PURCHASE_INFO_PAGE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Lägg till inköpsinfo
                    """
                case let .KEY_GEAR_ADD_PURCHASE_INFO_BODY(itemType):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["ITEM_TYPE": itemType]) {
                        return text
                    }

                    return """
                    Ange när du köpte din \(itemType) och för hur mycket för att beräkna vad den värderas till
                    """
                case .KEY_GEAR_YEARMONTH_PICKER_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Inköpsdatum
                    """
                case .KEY_GEAR_YEARMONTH_PICKER_POS_ACTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    OK
                    """
                case .KEY_GEAR_YEARMONTH_PICKER_NEG_ACTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Avbryt
                    """
                case .KEY_GEAR_ITEM_VIEW_RECEIPT_SHOW:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Visa
                    """
                case .TOOLBAR_DONE_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Klar
                    """
                case .KEY_GEAR_RECEIPT_UPLOAD_SHEET_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Ladda upp kvitto
                    """
                case .ITEM_TYPE_PHONE_COVERED_ONE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Om du tappar den i marken
                    """
                case .ITEM_TYPE_PHONE_COVERED_TWO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Om du tappar den i vattnet
                    """
                case .ITEM_TYPE_PHONE_COVERED_THREE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Om du eller någon annan har sönder den
                    """
                case .ITEM_TYPE_PHONE_COVERED_FOUR:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Om den blir vattenskadad
                    """
                case .ITEM_TYPE_PHONE_COVERED_FIVE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Om den blir stulen
                    """
                case .ITEM_TYPE_PHONE_NOT_COVERED_ONE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Om du slarvar bort den
                    """
                case .ITEM_TYPE_PHONE_NOT_COVERED_TWO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Produktfel eller fel som täcks av garantin
                    """
                case .ITEM_TYPE_COMPUTER_COVERED_ONE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Om du tappar den i marken
                    """
                case .ITEM_TYPE_COMPUTER_COVERED_TWO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Om du tappar den i vattnet
                    """
                case .ITEM_TYPE_COMPUTER_COVERED_THREE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Om du eller någon annan har sönder den
                    """
                case .ITEM_TYPE_COMPUTER_COVERED_FOUR:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Om den blir vattenskadad
                    """
                case .ITEM_TYPE_COMPUTER_COVERED_FIVE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Om den blir stulen
                    """
                case .ITEM_TYPE_COMPUTER_NOT_COVERED_ONE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Om du slarvar bort den
                    """
                case .ITEM_TYPE_COMPUTER_NOT_COVERED_TWO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Produktfel eller fel som täcks av garantin
                    """
                case .ITEM_TYPE_TV_COVERED_ONE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Om du eller någon annan har sönder den
                    """
                case .ITEM_TYPE_TV_COVERED_TWO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Om du får inbrott och den blir stulen
                    """
                case .ITEM_TYPE_TV_COVERED_THREE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Eldsvåda
                    """
                case .ITEM_TYPE_TV_COVERED_FOUR:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Om den går sönder under flytt
                    """
                case .ITEM_TYPE_TV_NOT_COVERED_ONE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Produktfel eller fel som täcks av garantin
                    """
                case .ITEM_TYPE_TV_NOT_COVERED_TWO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Kortslutnings orsakad av vätska
                    """
                case .ITEM_TYPE_BIKE_COVERED_ONE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Om den blir stulen
                    """
                case .ITEM_TYPE_BIKE_COVERED_TWO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Om du eller någon annan har sönder den
                    """
                case .ITEM_TYPE_BIKE_COVERED_THREE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Ifall du ramlar med cykeln
                    """
                case .ITEM_TYPE_BIKE_COVERED_FOUR:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Skador som orskas av skadegörelse
                    """
                case .ITEM_TYPE_BIKE_NOT_COVERED_ONE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Skador orskade av annat fordon
                    """
                case .ITEM_TYPE_BIKE_NOT_COVERED_TWO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Personskador i samband med olycka
                    """
                case .ITEM_TYPE_BIKE_NOT_COVERED_THREE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Förslitningsskador som uppstår över tid
                    """
                case .ITEM_TYPE_WATCH_COVERED_ONE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Om den blir stulen
                    """
                case .ITEM_TYPE_WATCH_COVERED_TWO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Om du eller någon annan har sönder den
                    """
                case .ITEM_TYPE_WATCH_NOT_COVERED_ONE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Om du slarvar bort den
                    """
                case .ITEM_TYPE_WATCH_NOT_COVERED_TWO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Förslitningsskador som uppstår över tid
                    """
                case .ITEM_TYPE_JEWELRY_COVERED_ONE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Om den blir stulen
                    """
                case .ITEM_TYPE_JEWELRY_COVERED_TWO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Om någon har sönder den
                    """
                case .ITEM_TYPE_JEWELRY_NOT_COVERED_ONE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Om du slarvar bort den
                    """
                case .ITEM_TYPE_JEWELRY_NOT_COVERED_TWO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Förslitningsskador som uppstår över tid
                    """
                case .KEY_GEAR_IMAGE_PICKER_CAMERA:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Kamera
                    """
                case .KEY_GEAR_IMAGE_PICKER_PHOTO_LIBRARY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Fotobiblioteket
                    """
                case .KEY_GEAR_IMAGE_PICKER_DOCUMENT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Dokument
                    """
                case .KEY_GEAR_IMAGE_PICKER_CANCEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Avbryt
                    """
                case .KEY_GEAR_ITEM_DELETE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Radera
                    """
                case .KEY_GEAR_ITEM_OPTIONS_CANCEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Avbryt
                    """
                case .KEY_GEAR_ITEM_VIEW_ITEM_NAME_SAVE_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Spara
                    """
                case let .KEY_GEAR_ITEM_VIEW_VALUATION_MARKET_BODY(itemType, valuationPercentage):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["ITEM_TYPE": itemType, "VALUATION_PERCENTAGE": valuationPercentage]) {
                        return text
                    }

                    return """
                    Vi försöker reparera i första hand, men om din \(itemType) skulle behöva ersättas helt (ex. om den blivit stulen) ersätts du med **\(valuationPercentage)%** av marknadsvärdet.
                    """
                case .KEY_GEAR_ITEM_VIEW_VALUATION_MARKET_DESCRIPTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    av marknadsvärdet
                    """
                case .ITEM_TYPE_SMART_WATCH_COVERED_ONE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Om du tappar den i marken
                    """
                case .ITEM_TYPE_SMART_WATCH_COVERED_TWO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Om du tappar den i vattnet
                    """
                case .ITEM_TYPE_SMART_WATCH_COVERED_THREE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Om du eller någon annan har sönder den
                    """
                case .ITEM_TYPE_SMART_WATCH_COVERED_FOUR:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Om den blir vattenskadad
                    """
                case .ITEM_TYPE_SMART_WATCH_COVERED_FIVE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Om den blir stulen
                    """
                case .ITEM_TYPE_SMART_WATCH_NOT_COVERED_ONE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Om du slarvar bort den
                    """
                case .ITEM_TYPE_SMART_WATCH_NOT_COVERED_TWO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Produktfel eller fel som täcks av garantin
                    """
                case .ITEM_TYPE_SMART_WATCH:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Smartklocka
                    """
                case .KEY_GEAR_REPORT_CLAIM_ROW:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Anmäl skada
                    """
                case .ITEM_TYPE_TABLET:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Surfplatta
                    """
                case let .KEY_GEAR_NOT_COVERED(itemType):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["ITEM_TYPE": itemType]) {
                        return text
                    }

                    return """
                    Observera att din \(itemType) är dyrare än vad din drulleförsäkring täcker, vi rekommenderar att du skriver till oss i chatten för att köpa till en objektförsäkring för denna \(itemType).
                    """
                case .ITEM_TYPE_TABLET_COVERED_ONE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Om du tappar den i marken
                    """
                case .ITEM_TYPE_TABLET_COVERED_TWO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Om du tappar den i vattnet
                    """
                case .ITEM_TYPE_TABLET_COVERED_THREE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Om du eller någon annan har sönder den
                    """
                case .ITEM_TYPE_TABLET_COVERED_FOUR:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Om den blir vattenskadad
                    """
                case .ITEM_TYPE_TABLET_COVERED_FIVE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Om den blir stulen
                    """
                case .ITEM_TYPE_TABLET_NOT_COVERED_ONE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Om du slarvar bort den
                    """
                case .ITEM_TYPE_TABLET_NOT_COVERED_TWO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Produktfel eller fel som täcks av garantin
                    """
                case .MARKET_PICKER_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Välj land
                    """
                default: return String(describing: key)
                }
            }
        }

        struct en_SE {
            static func `for`(key: Localization.Key) -> String {
                switch key {
                case .OFFER_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Your home insurance
                    """
                case .DIRECT_DEBIT_DISMISS_ALERT_CANCEL_ACTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    No
                    """
                case .DIRECT_DEBIT_DISMISS_ALERT_CONFIRM_ACTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Yes
                    """
                case .PROFILE_MY_COINSURED_ROW_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    My coinsured
                    """
                case .MY_COINSURED_COMING_SOON_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Coming soon!
                    """
                case .MY_COINSURED_COMING_SOON_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    We are working on additional functionality for co-insured, in the future all your co-insured will be able to access the app and you will be able to add and remove them freely.

                    Have more ideas on neat features you wanna see in the app? Write to us in the chat!
                    """
                case .MY_HOME_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    My home
                    """
                case .MY_HOME_SECTION_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Residence
                    """
                case .MY_HOME_ADDRESS_ROW_KEY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Address
                    """
                case .MY_HOME_ROW_POSTAL_CODE_KEY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Postal code
                    """
                case .MY_HOME_ROW_TYPE_KEY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Type of housing
                    """
                case .MY_HOME_ROW_TYPE_RENTAL_VALUE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Rental
                    """
                case .MY_HOME_ROW_TYPE_CONDOMINIUM_VALUE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Condominium
                    """
                case .GENERIC_UNKNOWN:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Unknown
                    """
                case .MY_HOME_CHANGE_INFO_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Change details
                    """
                case .DIRECT_DEBIT_SETUP_SCREEN_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Connect bank account
                    """
                case .MY_PAYMENT_DIRECT_DEBIT_REPLACE_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Change bank account
                    """
                case .MY_PAYMENT_DIRECT_DEBIT_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Connect bank account
                    """
                case .MY_PAYMENT_TYPE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Direct debit
                    """
                case let .MY_PAYMENT_DATE(paymentDate):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["paymentDate": paymentDate]) {
                        return text
                    }

                    return """
                    Next payment is debited on \(paymentDate)
                    """
                case .MY_INFO_CANCEL_ALERT_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Are you sure?
                    """
                case .MY_INFO_CANCEL_ALERT_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Your changes will be lost
                    """
                case .MY_INFO_CANCEL_ALERT_BUTTON_CONFIRM:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Yes
                    """
                case .MY_INFO_CANCEL_ALERT_BUTTON_CANCEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    No
                    """
                case .MY_INFO_EMAIL_MALFORMED_ERROR:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    The entered email address doesn't seem correct
                    """
                case .MY_INFO_EMAIL_EMPTY_ERROR:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    You forgot to enter your email
                    """
                case .MY_INFO_ALERT_SAVE_FAILURE_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    OK
                    """
                case .MY_INFO_ALERT_SAVE_FAILURE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Couldn't save
                    """
                case .MY_INFO_CANCEL_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Cancel
                    """
                case .MY_INFO_PHONE_NUMBER_MALFORMED_ERROR:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Check that the phone number you've entered is correct
                    """
                case .MY_INFO_SAVE_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Save
                    """
                case .MY_PAYMENT_DEDUCTIBLE_CIRCLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Deductible 1500 kr
                    """
                case .FEEDBACK_IOS_EMAIL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    ios@hedvig.com
                    """
                case .FEEDBACK_SCREEN_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Feedback
                    """
                case .FEEDBACK_SCREEN_REPORT_BUG_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Report a bug
                    """
                case .FEEDBACK_SCREEN_REVIEW_APP_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Review the app
                    """
                case .FEEDBACK_SCREEN_REVIEW_APP_VALUE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    App Store
                    """
                case .APP_STORE_REVIEW_URL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    itms-apps://itunes.apple.com/app/1303668531?action=write-review
                    """
                case .OFFER_BUBBLES_START_DATE_CHANGE_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Change
                    """
                case .DASHBOARD_INFO_DEDUCTIBLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Your deductible is 1 500 kr
                    """
                case .DASHBOARD_CHAT_ACTIONS_HEADER:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    What would you like to do today?
                    """
                case .DASHBOARD_INSURANCE_STATUS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Your insurance is active
                    """
                case .DASHBOARD_PERIL_FOOTER:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Click an icon for more info
                    """
                case .DASHBOARD_INFO_INSURANCE_AMOUNT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Your stuff is insured for a total of 1 000 000 kr
                    """
                case .DASHBOARD_INFO_TRAVEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Valid on travels anywhere in the world
                    """
                case .DASHBOARD_INFO_HEADER:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    More info
                    """
                case .DASHBOARD_INFO_SUBHEADER:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    about your home insurance
                    """
                case .DASHBOARD_PENDING_HEADER:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Your insurance is on its way!
                    """
                case .DASHBOARD_PENDING_MORE_INFO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    More info
                    """
                case .DASHBOARD_PENDING_LESS_INFO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Less info
                    """
                case .DASHBOARD_PAYMENT_SETUP_INFO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    To have your insurance valid in the future, you need to connect your bank account with Hedvig.
                    """
                case .DASHBOARD_PAYMENT_SETUP_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Connect payment
                    """
                case .DASHBOARD_PENDING_HAS_DATE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    You're still insured by your previous insurance company. Your Hedvig insurance will be activated on the same day that your current insurance expires!
                    """
                case .DASHBOARD_PENDING_NO_DATE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    You're still insured by your previous insurance company. We have initiated the move and will inform you as soon as we know the starting date!
                    """
                case .DASHBOARD_PENDING_MONTHS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    M
                    """
                case .DASHBOARD_PENDING_DAYS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    D
                    """
                case .DASHBOARD_PENDING_HOURS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    H
                    """
                case .DASHBOARD_PENDING_MINUTES:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    M
                    """
                case .OFFER_BANKID_SIGN_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Sign
                    """
                case .CLAIMS_HEADER_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Has something happened? Start your claim here!
                    """
                case .CLAIMS_HEADER_SUBTITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Have you lost your phone or been the victim of theft? Report it to Hedvig.
                    """
                case .CLAIMS_HEADER_ACTION_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Start claim
                    """
                case .CLAIMS_QUICK_CHOICE_HEADER:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Quick choices
                    """
                case .FEATURE_PROMO_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    What's new?
                    """
                case .FEATURE_PROMO_HEADLINE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Bonusrain to the people!
                    """
                case .FEATURE_PROMO_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Hedvig becomes better when you share it with your friends! You and your friends gets (REFERRAL_VALUE) off your monthly payments – per friend!
                    """
                case .FEATURE_PROMO_BTN:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Read more
                    """
                case .REFERRAL_PROGRESS_TOPBAR_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Lower your price
                    """
                case .REFERRAL_PROGRESS_TOPBAR_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    More info
                    """
                case .REFERRAL_PROGRESS_BAR_CTA:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Invite
                    """
                case let .REFERRAL_PROGRESS_CURRENT_PREMIUM_PRICE(currentPremiumPrice):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["CURRENT_PREMIUM_PRICE": currentPremiumPrice]) {
                        return text
                    }

                    return """
                    \(currentPremiumPrice) kr
                    """
                case .REFERRAL_PROGRESS_FREE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Free!
                    """
                case .REFERRAL_PROGRESS_HEADLINE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Share Hedvig and lower your price
                    """
                case let .REFERRAL_PROGRESS_BODY(referralValue):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["REFERRAL_VALUE": referralValue]) {
                        return text
                    }

                    return """
                    You are giving away \(referralValue) kr discount and get \(referralValue) kr discount for each friend that you invite with your unique link! Can you get free insurance?
                    """
                case .REFERRAL_PROGRESS_CODE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Your code
                    """
                case .REFERRAL_INVITE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Your invites
                    """
                case .REFERRAL_INVITE_EMPTYSTATE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    You haven't invited anyone yet
                    """
                case .REFERRAL_INVITE_EMPTYSTATE_DESCRIPTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Let's fix that!
                    """
                case .REFERRAL_SHAREINVITE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Share your invite
                    """
                case let .REFERRAL_SMS_MESSAGE(referralLink, referralValue):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["REFERRAL_LINK": referralLink, "REFERRAL_VALUE": referralValue]) {
                        return text
                    }

                    return """
                    Hey! Get Hedvig using my link and we both get \(referralValue) kr per month discount on the monthly cost. Follow the link: \(referralLink)
                    """
                case .REFERRAL_INVITE_NEWSTATE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Has gotten Hedvig
                    """
                case .REFERRAL_INVITE_STARTEDSTATE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Has started onboarding
                    """
                case .REFERRAL_INVITE_QUITSTATE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Has left Hedvig
                    """
                case .REFERRAL_INVITE_INVITEDYOUSTATE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Invited you to Hedvig
                    """
                case .REFERRAL_INVITE_ANON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Ghost
                    """
                case .REFERRAL_INVITE_ANONS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Ghosts
                    """
                case .REFERRAL_PROGRESS_EDGECASE_HEADLINE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Lower your monthly cost!
                    """
                case let .REFERRAL_SUCCESS_HEADLINE(user):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["USER": user]) {
                        return text
                    }

                    return """
                    \(user) got Hedvig thanks to you!
                    """
                case let .REFERRAL_SUCCESS_HEADLINE_MULTIPLE(numberOfUsers):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["NUMBER_OF_USERS": numberOfUsers]) {
                        return text
                    }

                    return """
                    \(numberOfUsers) of your friends signed up to Hedvig because of you!
                    """
                case let .REFERRAL_SUCCESS_BODY(referralValue):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["REFERRAL_VALUE": referralValue]) {
                        return text
                    }

                    return """
                    As a thank you both you and your friends get \(referralValue) kr less in your monthly fee. Keep inviting friends to lower it even more!
                    """
                case .REFERRAL_SUCCESS_BTN_CTA:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Invite more friends!
                    """
                case .REFERRAL_SUCCESS_BTN_CLOSE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Close
                    """
                case .REFERRAL_ULTIMATE_SUCCESS_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    You did it!
                    """
                case .REFERRAL_ULTIMATE_SUCCESS_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Wow. You Did It - Free insurance! We are proud beyond what words can express!
                    """
                case .REFERRAL_ULTIMATE_SUCCESS_BTN_CTA:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Apply for a job at Hedvig!
                    """
                case .REFERRAL_INVITE_OPENEDSTATE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Someone has opened your link
                    """
                case let .REFERRAL_INVITE_ACTIVE_VALUE(referralValue):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["REFERRAL_VALUE": referralValue]) {
                        return text
                    }

                    return """
                    -\(referralValue) kr
                    """
                case .REFERRAL_LANDINGPAGE_BTN_WEB:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Continue on the web
                    """
                case let .REFERRAL_STARTSCREEN_HEADLINE(referralValue):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["REFERRAL_VALUE": referralValue]) {
                        return text
                    }

                    return """
                    You have been invited by a friend and will get \(referralValue) off your monthly payment
                    """
                case .REFERRAL_STARTSCREEN_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Do you want to accept the invite or continue without the discount?
                    """
                case .REFERRAL_STARTSCREEN_BTN_CTA:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Yes, accept discount!
                    """
                case .REFERRAL_STARTSCREEN_BTN_SKIP:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    No, continue without it
                    """
                case .REFERRAL_OFFER_DISCOUNT_HEADLINE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Invite!
                    """
                case let .REFERRAL_OFFER_DISCOUNT_BODY(referralValue):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["REFERRAL_VALUE": referralValue]) {
                        return text
                    }

                    return """
                    -\(referralValue) kr/month discount
                    """
                case .REFERRAL_ADDCOUPON_HEADLINE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Add discount code
                    """
                case .REFERRAL_ADDCOUPON_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Write your discount code below
                    """
                case .REFERRAL_ADDCOUPON_INPUTPLACEHOLDER:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Discount code
                    """
                case .REFERRAL_ADDCOUPON_BTN_SUBMIT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Add discount code
                    """
                case let .REFERRAL_ADDCOUPON_TC(termsAndConditionsLink):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["TERMS_AND_CONDITIONS_LINK": termsAndConditionsLink]) {
                        return text
                    }

                    return """
                    By tapping "Add discount code" you agree to our \(termsAndConditionsLink)
                    """
                case .REFERRAL_ERROR_MISSINGCODE_HEADLINE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Discount code missing
                    """
                case .REFERRAL_ERROR_MISSINGCODE_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Your code is missing, please spell check 
                    """
                case .REFERRAL_ERROR_MISSINGCODE_BTN:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    OK
                    """
                case .REFERRAL_ERROR_REPLACECODE_HEADLINE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    You already have a discount code activated
                    """
                case .REFERRAL_ERROR_REPLACECODE_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Do you want to replace your current discount code?
                    """
                case .REFERRAL_ERROR_REPLACECODE_BTN_CANCEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Cancel
                    """
                case .REFERRAL_ERROR_REPLACECODE_BTN_SUBMIT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Replace
                    """
                case let .REFERRAL_RECIEVER_WELCOME_HEADLINE(user):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["USER": user]) {
                        return text
                    }

                    return """
                    Welcome as a member \(user)!
                    """
                case .REFERRAL_RECIEVER_WELCOME_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Hedvig is better when you share it with your friends! You and your friends gets (REFERRAL_VALUE) off your monthly payments – per friend!
                    """
                case .REFERRAL_RECIEVER_WELCOME_BTN_CTA:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Invite friend straight away! 👯‍♀️
                    """
                case .REFERRAL_RECIEVER_WELCOME_BTN_SKIP:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Check out the app
                    """
                case .PROFILE_ROW_NEW_REFERRAL_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Get free insurance!
                    """
                case .PROFILE_ROW_NEW_REFERRAL_DESCRIPTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Recommend Hedvig
                    """
                case .NEWS_PROCEED:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Next
                    """
                case .NEWS_DISMISS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Go to app
                    """
                case let .REFERRAL_LINK_INVITATION_SCREEN_HEADLINE(name, referralValue):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["NAME": name, "REFERRAL_VALUE": referralValue]) {
                        return text
                    }

                    return """
                    You have been invited by \(name) and is going to get  \(referralValue) kr discount per month
                    """
                case .REFERRAL_LINK_INVITATION_SCREEN_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Do you want to accept the invitation or continue without a discount?
                    """
                case .REFERRAL_LINK_INVITATION_SCREEN_BTN_ACCEPT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Yes, I want the discount!
                    """
                case .REFERRAL_LINK_INVITATION_SCREEN_BTN_DECLINE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    No, continue without
                    """
                case .NEWS_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    What's new?
                    """
                case .NEWS_CLOSE_DESCRIPTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Close
                    """
                case let .REFERRAL_PROGRESS_HIGH_PREMIUM_DISCOUNT(discountValue):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["DISCOUNT_VALUE": discountValue]) {
                        return text
                    }

                    return """
                    -\(discountValue) kr
                    """
                case .REFERRAL_PROGRESS_HIGH_PREMIUM_DISCOUNT_SUBTITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    discount per month
                    """
                case let .REFERRAL_PROGRESS_HIGH_PREMIUM_DESCRIPTION(monthlyCost):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["MONTHLY_COST": monthlyCost]) {
                        return text
                    }

                    return """
                    Current price:  \(monthlyCost) kr/month
                    """
                case .PROFILE_PAYMENT_PRICE_LABEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Price
                    """
                case let .PROFILE_PAYMENT_PRICE(price):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["PRICE": price]) {
                        return text
                    }

                    return """
                    \(price) kr/month
                    """
                case .PROFILE_PAYMENT_DISCOUNT_LABEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Discount
                    """
                case let .PROFILE_PAYMENT_DISCOUNT(discount):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["DISCOUNT": discount]) {
                        return text
                    }

                    return """
                    \(discount) kr/month
                    """
                case .PROFILE_PAYMENT_FINAL_COST_LABEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Your price
                    """
                case let .PROFILE_PAYMENT_FINAL_COST(finalCost):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["FINAL_COST": finalCost]) {
                        return text
                    }

                    return """
                    \(finalCost) kr/month
                    """
                case .PROFILE_ABOUT_APP_OPEN_WHATS_NEW:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    See what's new
                    """
                case .PUSH_NOTIFICATIONS_ALERT_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Notifications
                    """
                case .PUSH_NOTIFICATIONS_ALERT_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Activate notifications so that you know when Hedvig has answered!
                    """
                case .PUSH_NOTIFICATIONS_ALERT_ACTION_OK:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Activate
                    """
                case .PUSH_NOTIFICATIONS_ALERT_ACTION_NOT_NOW:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Not now
                    """
                case .REFERRALS_RECEIVER_TERMS_LINK:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    https://www.hedvig.com/TODO
                    """
                case .REFERRAL_PROGRESS_MORE_INFO_HEADLINE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Invite a friend
                    """
                case let .REFERRAL_PROGRESS_MORE_INFO_PARAGRAPH_ONE(referralValue):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["REFERRAL_VALUE": referralValue]) {
                        return text
                    }

                    return """
                    Referrals with Hedvig are simple. Refer a friend with your unique code and both you and your friend gets a \(referralValue) kr discount.
                    """
                case .REFERRAL_PROGRESS_MORE_INFO_PARAGRAPH_TWO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    You can invite friends until your monthly price is 0 kr, so you can get completely free home insurance. The discount is valid only as long as both you and your friend are both active members. 
                    """
                case .REFERRAL_PROGRESS_MORE_INFO_CTA:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Read Terms & Conditions
                    """
                case let .REFERRAL_PROGRESS_MORE_INFO_PARAGRAPH(referralValue):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["REFERRAL_VALUE": referralValue]) {
                        return text
                    }

                    return """
                    Referrals with Hedvig are simple. Refer a friend with your unique code and both you and your friend gets a \(referralValue) kr discount.

                    You can invite friends until your monthly price is 0 kr, so you can get completely free home insurance. The discount is valid only as long as both you and your friend are both active members. 
                    """
                case .REFERRAL_ADDCOUPON_TC_LINK:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    terms and conditions
                    """
                case .INSURANCE_STATUS_TERMINATED_ALERT_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Your insurance is not active
                    """
                case .INSURANCE_STATUS_TERMINATED_ALERT_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    You can write to Hedvig if you want to activate your insurance again
                    """
                case .INSURANCE_STATUS_TERMINATED_ALERT_CTA:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Chat with Hedvig
                    """
                case .REFERRAL_MORE_INFO_LINK:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    https://www.hedvig.com/en/invite/terms
                    """
                case .PRICE_MISSING:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Price missing
                    """
                case .TAB_REFERRALS_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Invite
                    """
                case .INSURANCE_STATUS_TERMINATED_ALERT_ACTION_CHAT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Chat with Hedvig
                    """
                case .MARKETING_GET_HEDVIG:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Get Hedvig
                    """
                case .MARKETING_LOGIN:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Already a member? Log in
                    """
                case let .PROFILE_MY_COINSURED_ROW_SUBTITLE(amountCoinsured):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["amountCoinsured": amountCoinsured]) {
                        return text
                    }

                    return """
                    Me + \(amountCoinsured)

                    """
                case .MODERNA_FORSAKRING_APP:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Moderna Insurance
                    """
                case .ICA_FORSAKRING_APP:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    ICA Insurance
                    """
                case .OTHER_INSURER_OPTION_APP:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    your current insurance
                    """
                case .SIGN_MOBILE_BANK_ID:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Sign with your mobile BankID
                    """
                case .OFFER_NON_SWITCHABLE_PARAGRAPH_ONE_APP:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Contact your current insurer and terminate your home insurance. Write to us in the chat and tell us when your current insurance policy expires
                    """
                case .OFFER_SWITCH_COL_PARAGRAPH_ONE_APP:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Hedvig will contact your existing insurance company and cancel your policy
                    """
                case .OFFER_SWITCH_COL_THREE_PARAGRAPH_APP:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    We make sure that your Hedvig insurance is activated automatically on the day your old one terminates
                    """
                case let .OFFER_SWITCH_TITLE_APP(insurer):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["INSURER": insurer]) {
                        return text
                    }

                    return """
                    Hedvig will manage the switch from \(insurer)
                    """
                case .OFFER_SWITCH_TITLE_NON_SWITCHABLE_APP:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Here's how to switch to Hedvig if you already have insurance
                    """
                case let .REFERRAL_INVITE_OPENEDSTATE_MULTIPLE(numberOfInvites):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["NUMBER_OF_INVITES": numberOfInvites]) {
                        return text
                    }

                    return """
                    \(numberOfInvites)  persons has opened your link
                    """
                case .NEW_MEMBER_DISMISS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Explore the app and invite
                    """
                case .NEW_MEMBER_PROCEED:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Next
                    """
                case .UPLOAD_FILE_BUTTON_HINT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Upload a file
                    """
                case .REFERRALS_CODE_SHEET_COPY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Copy
                    """
                case let .REFERRAL_PROGRESS_HIGH_PREMIUM_DISCOUNT_NO_MINUS(discountValue):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["DISCOUNT_VALUE": discountValue]) {
                        return text
                    }

                    return """
                    \(discountValue) kr
                    """
                case .PUSH_NOTIFICATIONS_REFERRALS_ALERT_MESSSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Activate notifications so that you know when someone got Hedvig by using your link!
                    """
                case .AUDIO_INPUT_RECORD_DESCRIPTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Record
                    """
                case .AUDIO_INPUT_STOP_DESCRIPTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Stop
                    """
                case .AUDIO_INPUT_START_RECORDING:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Start recording
                    """
                case let .AUDIO_INPUT_PLAYBACK_PROGRESS(seconds):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["SECONDS": seconds]) {
                        return text
                    }

                    return """
                    \(seconds)s
                    """
                case .PROFILE_MY_INFO_SAVE_SUCCESS_TOAST_SYMBOL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    ✍️
                    """
                case .CHAT_EDIT_MESSAGE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Would you like to edit your message?
                    """
                case .CHAT_EDIT_MESSAGE_SUBMIT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Edit
                    """
                case .CHAT_EDIT_MESSAGE_CANCEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Cancel
                    """
                case .CHAT_EDIT_MESSAGE_DESCRIPTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Edit message
                    """
                case let .OFFER_SCREEN_FREE_MONTHS_BUBBLE(freeMonth):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["free_month": freeMonth]) {
                        return text
                    }

                    return """
                    \(freeMonth) month free!
                    """
                case .OFFER_SCREEN_FREE_MONTHS_BUBBLE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Discount!
                    """
                case .MY_PAYMENT_FREE_UNTIL_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Free until
                    """
                case .OFFER_PRICE_PER_MONTH:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    kr/month
                    """
                case .SIGN_START_BANKID:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Start the BankID-app
                    """
                case .SIGN_SUCCESSFUL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Sign successful 👌
                    """
                case .SIGN_IN_PROGRESS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Sign in progress
                    """
                case .SIGN_CANCELED:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Sign canceled 🙅
                    """
                case .SIGN_FAILED_REASON_UNKNOWN:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Whoops! Unknown error 🙈
                    """
                case .BANK_ID_NOT_INSTALLED:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    The BankID-app does not appear to be installed on your phone. Install it and acquire a BankID at your bank.
                    """
                case .OFFER_CHAT_ACCESSIBILITY_HINT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Open the chat
                    """
                case .CHAT_GIPHY_SEARCH_HINT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Search...
                    """
                case .MARKETING_LOGO_ACCESSIBILITY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Hedvig
                    """
                case .DASHBOARD_RENEWAL_PROMPTER_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Your insurance is renewed
                    """
                case let .DASHBOARD_RENEWAL_PROMPTER_BODY(daysUntilRenewal):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["DAYS_UNTIL_RENEWAL": daysUntilRenewal]) {
                        return text
                    }

                    return """
                    In \(daysUntilRenewal) days your insurance will be renewed. Read your updated inruance certificate here.
                    """
                case .DASHBOARD_RENEWAL_PROMPTER_CTA:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Read new insurance certificate
                    """
                case .DASHBOARD_SETUP_DIRECT_DEBIT_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Connect direct debit
                    """
                case .DASHBOARD_INFO_BOX_CLOSE_DESCRIPTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Close
                    """
                case .ONBOARDING_CONNECT_DD_HEADLINE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Connect direct debit
                    """
                case .ONBOARDING_CONNECT_DD_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    You need to connect direct debit for your insurance to be activated. The payment is made automatically from your bank account every month on the 27th.
                    """
                case .ONBOARDING_CONNECT_DD_BODY_SWITCHERS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    With direct debit, you put your life on autopilot. Of course we only charge once your insurance is activated.
                    """
                case .ONBOARDING_CONNECT_DD_CTA:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Connect direct debit
                    """
                case .TRUSTLY_SKIP_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Not now
                    """
                case .ONBOARDING_CONNECT_DD_PRE_HEADLINE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Psst, don't forget...
                    """
                case .MAX_COMPENSATION_STUDENT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    200 000 kr
                    """
                case .MAX_COMPENSATION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    1 million kr
                    """
                case .DEDUCTIBLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    1500 kr
                    """
                case .TRUSTLY_ALERT_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Are you sure?
                    """
                case .TRUSTLY_ALERT_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    For your insurance to stay active you need to connect direct debit from your bank.
                    """
                case .TRUSTLY_ALERT_POSITIVE_ACTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Yes, connect later
                    """
                case .TRUSTLY_ALERT_NEGATIVE_ACTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    No, connect now
                    """
                case .ONBOARDING_CONNECT_DD_SUCCESS_HEADLINE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Direct debit connected!
                    """
                case .ONBOARDING_CONNECT_DD_SUCCESS_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Thanks for that!
                    """
                case .ONBOARDING_CONNECT_DD_SUCCESS_CTA:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Continue
                    """
                case .ONBOARDING_CONNECT_DD_FAILURE_HEADLINE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Ouch, something went wrong...
                    """
                case .ONBOARDING_CONNECT_DD_FAILURE_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    For your insurance to stay active you need to connect direct debit from your bank. You can do it later in the app.
                    """
                case .ONBOARDING_CONNECT_DD_FAILURE_CTA_RETRY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Try again
                    """
                case .ONBOARDING_CONNECT_DD_FAILURE_CTA_LATER:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Do it later
                    """
                case .PROFILE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Profile
                    """
                case .DEMO_MODE_START:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Start demo-mode
                    """
                case .DEMO_MODE_CANCEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Cancel
                    """
                case .BANKID_MISSING_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    BankID missing on this device
                    """
                case .BANKID_MISSING_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Scan the QR-code with the BankID app on the phone where it's installed
                    """
                case .CHAT_RESTART_ALERT_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Do you want to restart?
                    """
                case .CHAT_RESTART_ALERT_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    All information you've entered so far will be removed
                    """
                case .CHAT_RESTART_ALERT_CONFIRM:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    OK
                    """
                case .CHAT_RESTART_ALERT_CANCEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Cancel
                    """
                case .SETTINGS_LOGIN_ROW:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Login
                    """
                case .BANKID_LOGIN_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Login
                    """
                case .ABOUT_SCREEN_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    About the app
                    """
                case .ABOUT_MEMBER_ID_ROW_KEY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Userid
                    """
                case .ABOUT_LICENSES_ROW:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    License-rights
                    """
                case .LICENSES_SCREEN_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    License-rights
                    """
                case .ACKNOWLEDGEMENT_HEADER_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Hedvig believes strongly in open-source, here's the libraries with belonging licenses that we use to build our iOS app
                    """
                case .ABOUT_PUSH_ROW:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Activate push-notififcations
                    """
                case .ABOUT_SHOW_INTRO_ROW:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Show intro
                    """
                case .PROFILE_FEEDBACK_ROW:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Feedback
                    """
                case .CHARTITY_PICK_OPTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Select
                    """
                case .PROFILE_ABOUT_ROW:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    About the app
                    """
                case .CHAT_FILE_DOWNLOAD:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Attached file
                    """
                case .FEEDBACK_SCREEN_LABEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Help us be better
                    """
                case .PAYMENTS_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    My payments
                    """
                case .PAYMENTS_CARD_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Next payment
                    """
                case let .PAYMENTS_CURRENT_PREMIUM(currentPremium):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["CURRENT_PREMIUM": currentPremium]) {
                        return text
                    }

                    return """
                    \(currentPremium) kr
                    """
                case .PAYMENTS_CARD_DATE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Date
                    """
                case .PAYMENTS_CARD_NO_STARTDATE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Start date not set
                    """
                case .PAYMENTS_SUBTITLE_PREVIOUS_PAYMENTS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Previous payments
                    """
                case .PAYMENTS_BTN_HISTORY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    View history
                    """
                case .PAYMENTS_SUBTITLE_PAYMENT_METHOD:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Payment method
                    """
                case .PAYMENTS_SUBTITLE_ACCOUNT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Account
                    """
                case .PAYMENTS_DIRECT_DEBIT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Direct Debit
                    """
                case .PAYMENTS_DIRECT_DEBIT_ACTIVE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Active
                    """
                case .PAYMENTS_BTN_CHANGE_BANK:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Change bank account
                    """
                case let .PAYMENTS_LATE_PAYMENTS_MESSAGE(monthsLate, nextPaymentDate):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["MONTHS_LATE": monthsLate, "NEXT_PAYMENT_DATE": nextPaymentDate]) {
                        return text
                    }

                    return """
                    You're \(monthsLate) months late with your payments. Your next payment will be higher than your ordinary monthly payment. We will charge you \(nextPaymentDate)
                    """
                case let .PAYMENTS_FULL_PREMIUM(fullPremium):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["FULL_PREMIUM": fullPremium]) {
                        return text
                    }

                    return """
                    \(fullPremium) kr/month
                    """
                case .PAYMENTS_SUBTITLE_DISCOUNT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Discount
                    """
                case .PAYMENTS_OFFER_MULTIPLE_MONTHS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Free
                    months
                    """
                case .PAYMENTS_OFFER_SINGLE_MONTH:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Free
                    month
                    """
                case .PAYMENTS_SUBTITLE_CAMPAIGN:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Current campaign
                    """
                case .PAYMENTS_CAMPAIGN_OWNER:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    From
                    """
                case .PAYMENTS_NO_STARTDATE_HELP_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    We will update this section when your old insurance is terminated and we have a startdate for your insurance at Hedvig.
                    """
                case .PAYMENTS_SUBTITLE_PAYMENT_HISTORY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Payments history
                    """
                case .HEDVIG_LOGO_ACCESSIBILITY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    hedvig
                    """
                case .MARKETING_SCREEN_SAY_HELLO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Say hello to Hedvig!
                    """
                case .REFERRALS_FREE_LABEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Free!
                    """
                case .REFERRALS_INVITE_LABEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Invite
                    """
                case .OFFER_PRICE_BUBBLE_MONTH:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    kr/per month
                    """
                case .PROFILE_PAYMENT_CONNECT_DIRECT_DEBIT_WITH_LINK_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Connect bank account (web browser)
                    """
                case .CLAIMS_INACTIVE_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Your Hedvig insurance isn't active yet but once it is you can file a claim here. If you need help right now feel free to contact us via the chat.
                    """
                case .OFFER_REMOVE_DISCOUNT_ALERT_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Remove discount code?
                    """
                case .OFFER_PRESALE_INFORMATION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Pre-sale information
                    """
                case .REFERRALS_SHARE_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Share your link
                    """
                case .UPLOAD_FILE_TYPE_CANCEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Cancel
                    """
                case .PROFILE_MY_INFO_SAVE_SUCCESS_TOAST_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Changes saved
                    """
                case .DASHBOARD_SCREEN_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Home insurance
                    """
                case .REFERRAL_INVITE_CODE_COPIED_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Code copied!
                    """
                case .OFFER_TERMS_NO_BINDING_PERIOD:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Sweden's only insurance without a fixed contract
                    """
                case .EMERGENCY_UNSURE_DESCRIPTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Unsure if it's an emergency? Contact Hedvig first!
                    """
                case let .REFERRALS_OFFER_SENDER_VALUE(incentive):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["incentive": incentive]) {
                        return text
                    }

                    return """
                    \(incentive) kr discount for each new person who joins via your link.
                    """
                case .EMERGENCY_ABROAD_ALERT_NON_PHONE_OK_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    OK
                    """
                case .REFERRAL_REDEEM_SUCCESS_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Congrats! The discount code was added
                    """
                case .REFERRAL_SHARE_SOCIAL_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Get Hedvig!
                    """
                case .EMERGENCY_ABROAD_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Call Hedvig Global Assistance
                    """
                case .TRUSTLY_MISSING_BANK_ID_APP_ALERT_ACTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    OK
                    """
                case .REFERRAL_REDEEM_SUCCESS_HEADLINE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Discount code added
                    """
                case .CALL_ME_CHAT_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    It's an emergency, call me
                    """
                case let .OFFER_TERMS_DEDUCTIBLE(deductible):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["DEDUCTIBLE": deductible]) {
                        return text
                    }

                    return """
                    The deductible is \(deductible)
                    """
                case .BANKID_INACTIVE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Canceled due to inactivity
                    """
                case .REFERRALS_ROW_SUBTITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Invite your friends to Hedvig
                    """
                case .REFERRAL_REFERRED_BY_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    You have been invited by
                    """
                case .TRUSTLY_MISSING_BANK_ID_APP_ALERT_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    You do not have BankID on this device
                    """
                case let .OFFER_TERMS_MAX_COMPENSATION(maxCompensation):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["MAX_COMPENSATION": maxCompensation]) {
                        return text
                    }

                    return """
                    The maximum compensation for belongings in your home is \(maxCompensation)
                    """
                case .ONBOARDING_ACTIVATE_NOTIFICATIONS_DISMISS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Skip 
                    """
                case .EMERGENCY_CALL_ME_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Speak with someone
                    """
                case .EMERGENCY_ABROAD_DESCRIPTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Are you ill or injured abroad and need care? The first thing you need to do is contact Hedvig Global Assistance.
                    """
                case .REFERRALS_TERMS_ROW_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Terms
                    """
                case .BANKID_INACTIVE_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    OK
                    """
                case .OFFER_REMOVE_DISCOUNT_ALERT_REMOVE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Remove
                    """
                case .OFFER_TERMS_NO_COVERAGE_LIMIT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    The apartment is insured without restrictions
                    """
                case .REFERRAL_REDEEM_SUCCESS_BTN:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    OK, nice!
                    """
                case .EMERGENCY_ABROAD_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Emergency illness abroad
                    """
                case .COPIED:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Copied!
                    """
                case .ONBOARDING_ACTIVATE_NOTIFICATIONS_PRE_HEADLINE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Don't check Hedvig 24/7
                    """
                case .REFERRALS_OFFER_SENDER_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    You get
                    """
                case .OFFER_TERMS_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Important terms
                    """
                case .CHAT_PREVIEW_OPEN_CHAT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Open the chat
                    """
                case .UPLOAD_FILE_IMAGE_OR_VIDEO_ACTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Picture or video
                    """
                case .EMERGENCY_CALL_ME_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Call me
                    """
                case .CLAIMS_CHAT_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Report a claim
                    """
                case .OFFER_TERMS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Insurance terms
                    """
                case let .REFERRALS_SHARE_MESSAGE(incentive, link):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["incentive": incentive, "link": link]) {
                        return text
                    }

                    return """
                    Get nice home insurance from Hedvig and receive \(incentive) kr! If you already have home insurance, Hedvig will handle the switch for you! 🙌 Get Hedvig here: \(link)
                    """
                case .CLAIMS_SCREEN_TAB:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Claims
                    """
                case .REFERRAL_SHARE_SOCIAL_DESCRIPTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Hedvig - Nice insurance
                    """
                case .CLAIMS_SCREEN_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Claims
                    """
                case .ONBOARDING_ACTIVATE_NOTIFICATIONS_HEADLINE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Enable notifications
                    """
                case .OFFER_PRIVACY_POLICY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Personal Data Policy
                    """
                case .EMERGENCY_CALL_ME_DESCRIPTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    If it's a crisis we can call you. Be sure to notify SOS Alarm first in case of emergency!
                    """
                case .TRUSTLY_MISSING_BANK_ID_APP_ALERT_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    To be able to log in to your bank you need to have the BankID app installed.
                    """
                case .ONBOARDING_ACTIVATE_NOTIFICATIONS_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Enable notification so you never miss a message from Hedvig. We won't spam, we promise.
                    """
                case .REFERRALS_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Hedvig get's better when you share with friends!
                    """
                case let .REFERRALS_OFFER_RECEIVER_VALUE(incentive):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["incentive": incentive]) {
                        return text
                    }

                    return """
                    \(incentive) kr for each Hedvig signup via your link
                    """
                case .UPLOAD_FILE_SELECT_TYPE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    What would you like to send?
                    """
                case .EMERGENCY_ABROAD_ALERT_NON_PHONE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Hedvig Global Assistance
                    """
                case .OFFER_REMOVE_DISCOUNT_ALERT_DESCRIPTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Are you sure you want to remove the discount code?
                    """
                case .REFERRALS_OFFER_RECEIVER_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    You friend gets
                    """
                case let .REFERRALS_ROW_TITLE(incentive):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["incentive": incentive]) {
                        return text
                    }

                    return """
                    Get \(incentive) kr, give \(incentive) kr!
                    """
                case .OFFER_REMOVE_DISCOUNT_ALERT_CANCEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Cancel
                    """
                case .EMERGENCY_UNSURE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Unsure?
                    """
                case .REFERRALS_SCREEN_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Invite your friends
                    """
                case .UPLOAD_FILE_FILE_ACTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    File
                    """
                case .BANKID_INACTIVE_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    BankID was canceled due to inactivity. Please try again.
                    """
                case .EMERGENCY_UNSURE_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Write to us
                    """
                case let .REFERRALS_DYNAMIC_LINK_LANDING(incentive, memberId):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["incentive": incentive, "memberId": memberId]) {
                        return text
                    }

                    return """
                    https://hedvig.com/invite/desktop?invitedBy=\(memberId)&incentive=\(incentive)
                    """
                case .REFERRALS_TERMS_WEBSITE_URL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    https://www.hedvig.com/invite/terms
                    """
                case .ONBOARDING_ACTIVATE_NOTIFICATIONS_CTA:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Enable notifications
                    """
                case .MY_INSURANCE_CERTIFICATE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    My insurance letter
                    """
                case .PROFILE_CACHBACK_ROW:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    My cause
                    """
                case .HONESTY_PLEDGE_DESCRIPTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    I understand that Hedvig is based on trust. I promise the information I give you regarding the incident is true and I claim only the compensation I am entitled to.
                    """
                case let .PROFILE_PAYMENT_ROW_TEXT(price):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["price": price]) {
                        return text
                    }

                    return """
                    \(price) kr/month. Pay via autogiro
                    """
                case .OFFER_GET_HEDVIG_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Get Hedvig
                    """
                case .OFFER_SCREEN_INVITED_BUBBLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Invite sent!
                    """
                case .DIRECT_DEBIT_DISMISS_ALERT_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Are you sure?
                    """
                case .PAYMENT_SUCCESS_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Hedvig will appear on your bank statement when you pay each month.
                    """
                case .OFFER_BUBBLES_START_DATE_CHANGE_RESET_NEW:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Activate today
                    """
                case .STUFF_PROTECTION_AMOUNT_STUDENT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    25 000kr
                    """
                case .OFFER_BUBBLES_TRAVEL_PROTECTION_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Travel insurance included
                    """
                case .DASHBOARD_PERILS_CATEGORY_INFO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Click the icons for more info
                    """
                case .PROFILE_MY_CHARITY_ROW_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    My charity
                    """
                case .PROFILE_MY_INSURANCE_CERTIFICATE_ROW_SUBTITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Click to read
                    """
                case .MY_COINSURED_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    My co-insured
                    """
                case let .DASHBOARD_BANNER_ACTIVE_TITLE(firstName):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["firstName": firstName]) {
                        return text
                    }

                    return """
                    Hi \(firstName)!
                    """
                case .RESTART_OFFER_CHAT_PARAGRAPH:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    If you press yes, the conversation will restart and your current quote will disappear
                    """
                case .CHAT_GIPHY_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    GIPHY
                    """
                case .MY_PAYMENT_NOT_CONNECTED:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Not connected
                    """
                case .DASHBOARD_BANNER_MINUTES:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    M
                    """
                case .MY_HOME_CHANGE_ALERT_ACTION_CANCEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Cancel
                    """
                case .OFFER_BUBBLES_BINDING_PERIOD_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Contract length
                    """
                case .OFFER_BUBBLES_INSURED_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Insured
                    """
                case .STUFF_PROTECTION_AMOUNT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    50 000kr
                    """
                case .DASHBOARD_NOT_STARTED_BANNER_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Your insurance is active!
                    """
                case .NETWORK_ERROR_ALERT_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Network failure
                    """
                case let .AUDIO_INPUT_RECORDING(seconds):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["SECONDS": seconds]) {
                        return text
                    }

                    return """
                    Record in: \(seconds)s
                    """
                case .DASHBOARD_BANNER_TERMINATED_INFO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Your insurance is inactive
                    """
                case .DASHBOARD_LESS_INFO_BUTTON_TEXT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Less info
                    """
                case .DASHBOARD_BANNER_ACTIVE_INFO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Your insurance is active
                    """
                case .DASHBOARD_HAVE_START_DATE_BANNER_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    You insurance actives in:
                    """
                case .MY_PAYMENT_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    My payment
                    """
                case .FILE_UPLOAD_ERROR_RETRY_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Try again
                    """
                case .CHAT_FILE_UPLOADED:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    file uploaded
                    """
                case .CHAT_GIPHY_PICKER_NO_SEARCH_TEXT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Oh no, there's no GIF for this search ...
                    """
                case .PROFILE_MY_CHARITY_INFO_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Charity
                    """
                case .MY_HOME_CHANGE_ALERT_ACTION_CONFIRM:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Write to Hedvig
                    """
                case .DIRECT_DEBIT_DISMISS_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Cancel
                    """
                case .PAYMENT_SUCCESS_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Autogiro active
                    """
                case .OFFER_BUBBLES_START_DATE_CHANGE_HEADING:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Which day would you like to start your insurance? 
                    """
                case .RESTART_OFFER_CHAT_BUTTON_DISMISS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    No
                    """
                case .MY_INFO_PHONE_NUMBER_EMPTY_ERROR:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    You have not entered a phone number
                    """
                case .RESTART_OFFER_CHAT_BUTTON_CONFIRM:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Yes
                    """
                case .MAIL_VIEW_CANT_SEND_ALERT_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Unable to open Mail
                    """
                case .PROFILE_MY_INSURANCE_CERTIFICATE_ROW_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    My insurance letter
                    """
                case .MY_PAYMENT_PAYMENT_ROW_LABEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Price
                    """
                case .PROFILE_MY_INSURANCE_CERTIFICATE_ROW_DISABLED_SUBTITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Becomes available when your insurance is active
                    """
                case .LOGOUT_ALERT_ACTION_CANCEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Cancel
                    """
                case let .DASHBOARD_INSURANCE_AMOUNT_FOOTNOTE(student):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["student": student]) {
                        return text
                    }

                    return """
                    Belonging are insured for a total of \(student) kr
                    """
                case .OFFER_PERSONAL_PROTECTION_DESCRIPTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Hedvig protects you from unexpected things happen that at home, and also when things go wrong when you are traveling.
                    """
                case .DIRECT_DEBIT_FAIL_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Due to a technical error, your bank account could not be updated. Please try again or write to Hedvig in the chat.
                    """
                case .PHONE_NUMBER_ROW_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Telephone number
                    """
                case .OTHER_SECTION_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Another
                    """
                case .MAIL_VIEW_CANT_SEND_ALERT_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    You have not set up an email account in the Mail app yet, you must do that before you can email us.
                    """
                case .DASHBOARD_TRAVEL_FOOTNOTE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Apple to trips anywhere in the world
                    """
                case .MY_PAYMENT_BANK_ROW_LABEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Bank
                    """
                case .OFFER_REMOVE_DISCOUNT_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Remove discount code
                    """
                case .TAB_DASHBOARD_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    My insurance
                    """
                case .RESTART_OFFER_CHAT_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Do you want to start over?
                    """
                case .PROFILE_MY_CHARITY_INFO_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    How does Hedvig work with charities?
                    """
                case .CASHBACK_NEEDS_SETUP_OVERLAY_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Pick a charitable organization
                    """
                case .MY_COINSURED_SCREEN_CIRCLE_SUBLABEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Insured
                    """
                case .DIRECT_DEBIT_SETUP_CHANGE_SCREEN_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Change bank account
                    """
                case .TRUSTLY_PAYMENT_SETUP_ACTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Set up payment
                    """
                case .DIRECT_DEBIT_SUCCESS_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Your bank account is now up to date and will be visible shortly. The next payment will be deducted from the new bank account.
                    """
                case .OFFER_SCROLL_HEADER:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    What Hedvig covers
                    """
                case let .FEEDBACK_SCREEN_REPORT_BUG_EMAIL_ATTACHMENT(appVersion, device, memberId, systemName, systemVersion):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["appVersion": appVersion, "device": device, "memberId": memberId, "systemName": systemName, "systemVersion": systemVersion]) {
                        return text
                    }

                    return """
                    Device: \(device)
                    System: \(systemName) \(systemVersion)
                    App Version: \(appVersion)
                    Member ID: \(memberId)
                    """
                case .DIRECT_DEBIT_SUCCESS_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Back
                    """
                case .PROFILE_INSURANCE_CERTIFICATE_ROW_TEXT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Press to read
                    """
                case .OFFER_BUBBLES_START_DATE_CHANGE_CONFIRM:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Choose date
                    """
                case .MY_INFO_CONTACT_DETAILS_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Contact details
                    """
                case .MY_HOME_CHANGE_ALERT_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Write to Hedvig in the chat and you'll get help right away!
                    """
                case .PAYMENT_FAILURE_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    No money will be deducted.


                    You can go back and try again.
                    """
                case .DASHBOARD_BANNER_DAYS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    D
                    """
                case .HONESTY_PLEDGE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Your pledge
                    """
                case .OFFER_BUBBLES_OWNED_ADDON_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Supplemental condo insurance included
                    """
                case .CHAT_UPLOADING_ANIMATION_TEXT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Uploading...
                    """
                case .CHAT_COULD_NOT_LOAD_FILE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Could not load the file...
                    """
                case .DASHBOARD_BANNER_MONTHS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    M
                    """
                case .MY_INFO_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    My info
                    """
                case .LOGOUT_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Log out
                    """
                case .PAYMENT_CURRENCY_OCCURRENCE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    kr/month
                    """
                case .DIRECT_DEBIT_FAIL_HEADING:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Something's gone wrong
                    """
                case .DIRECT_DEBIT_DISMISS_ALERT_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    You have not set up payment yet.
                    """
                case .MAIL_VIEW_CANT_SEND_ALERT_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    OK
                    """
                case .MY_HOME_ROW_SIZE_KEY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Living space
                    """
                case .PROFILE_INSURANCE_CERTIFICATE_ROW_HEADER:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    My insurance letter
                    """
                case .OFFER_ADD_DISCOUNT_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Discount code
                    """
                case .AUDIO_INPUT_PLAY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Play
                    """
                case .PROFILE_MY_PAYMENT_METHOD:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Pay via autogiro
                    """
                case .FILE_UPLOAD_ERROR:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    You have not given us access to your phone library, so we cannot display your photos here. Go to Settings on your phone to give us access to your photo library.
                    """
                case .MY_PAYMENT_UPDATING_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    You have just added or changed your bank account, your new bank account will appear here after your bank has accepted autogiro. Usually within 2 working days.
                    """
                case .OFFER_CHAT_HEADER:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Speak with Hedvig
                    """
                case let .DASHBOARD_READMORE_HAVE_START_DATE_TEXT(date):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["date": date]) {
                        return text
                    }

                    return """
                    You are still insured with your former insurance company. We have started the move and on \(date) your insurance with Hedvig will be activated!
                    """
                case .OFFER_BUBBLES_START_DATE_CHANGE_RESET_SWITCHER:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    When my contract expires
                    """
                case .OFFER_GET_HEDVIG_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Get Hedvig by clicking the button below and signing with BankID.
                    """
                case .TAB_PROFILE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Profile
                    """
                case .OFFER_APARTMENT_PROTECTION_DESCRIPTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Your home is your castle. That's why we provide really good protection, so you can feel safe at all times.
                    """
                case .EMAIL_ROW_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Email address
                    """
                case let .MY_HOME_ROW_SIZE_VALUE(livingSpace):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["livingSpace": livingSpace]) {
                        return text
                    }

                    return """
                    \(livingSpace) sqm
                    """
                case .PROFILE_MY_HOME_ROW_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    My home
                    """
                case .OFFER_STUFF_PROTECTION_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    My belongings
                    """
                case .DASHBOARD_BANNER_HOURS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    H
                    """
                case .OFFER_BUBBLES_START_DATE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Start date
                    """
                case .CASHBACK_NEEDS_SETUP_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    You have not chosen a charity organization
                    """
                case .AUDIO_INPUT_REDO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Redo
                    """
                case .PAYMENT_FAILURE_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Go back
                    """
                case .DIRECT_DEBIT_FAIL_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Go back
                    """
                case .PROFILE_SAFETYINCREASERS_ROW_HEADER:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    My safety increases
                    """
                case .NETWORK_ERROR_ALERT_CANCEL_ACTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Cancel
                    """
                case .OFFER_SIGN_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Sign up
                    """
                case .PAYMENT_FAILURE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Something's gone wrong
                    """
                case .MY_HOME_CHANGE_ALERT_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Do you want to change your insurance?
                    """
                case .LOGOUT_ALERT_ACTION_CONFIRM:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Yes
                    """
                case .CASHBACK_NEEDS_SETUP_OVERLAY_PARAGRAPH:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Choose which charity you want your share of any surplus to go to.
                    """
                case .NETWORK_ERROR_ALERT_TRY_AGAIN_ACTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Try again
                    """
                case .CHAT_GIPHY_PICKER_TEXT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Start searching to bring up GIFs!
                    """
                case let .OFFER_APARTMENT_PROTECTION_TITLE(address):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["address": address]) {
                        return text
                    }

                    return """
                    \(address)
                    """
                case .CASHBACK_NEEDS_SETUP_ACTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Pick a charitable organization
                    """
                case .OFFER_PERSONAL_PROTECTION_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    You
                    """
                case .PROFILE_INSURANCE_ADDRESS_ROW:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    My home
                    """
                case .CHAT_UPLOAD_PRESEND:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Send
                    """
                case .OFFER_PERILS_EXPLAINER:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Press the icons for more information
                    """
                case .CHAT_FILE_LOADING:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Loading...
                    """
                case let .OFFER_BUBBLES_INSURED_SUBTITLE(personsInHousehold):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["personsInHousehold": personsInHousehold]) {
                        return text
                    }

                    return """
                    \(personsInHousehold) people
                    """
                case .MY_CHARITY_SCREEN_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    My charity
                    """
                case .DASHBOARD_DEDUCTIBLE_FOOTNOTE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    You deductible is 1500kr
                    """
                case .DASHBOARD_MORE_INFO_BUTTON_TEXT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    More info
                    """
                case .AUDIO_INPUT_SAVE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Save
                    """
                case .OFFER_BUBBLES_START_DATE_SUBTITLE_SWITCHER:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    As soon as your contract expires
                    """
                case let .OFFER_STUFF_PROTECTION_DESCRIPTION(protectionAmount):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["protectionAmount": protectionAmount]) {
                        return text
                    }

                    return """
                    With Hedvig you get complete protection for your belongings. All-Risk insurance is included and covers belongings worth up to \(protectionAmount) a piece.
                    """
                case .EMAIL_ROW_EMPTY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Nothing specified
                    """
                case .OFFER_BUBBLES_START_DATE_CHANGE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Change start date
                    """
                case .DASHBOARD_OWNER_FOOTNOTE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    The apartment is insured for its full value
                    """
                case .DIRECT_DEBIT_SUCCESS_HEADING:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Account switch done!
                    """
                case .OFFER_BUBBLES_DEDUCTIBLE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Deductible
                    """
                case .PROFILE_MY_INFO_ROW_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    More info
                    """
                case .PHONE_NUMBER_ROW_EMPTY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Nothing specified
                    """
                case .OFFER_BUBBLES_BINDING_PERIOD_SUBTITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    No, that's not how Hedvig works
                    """
                case .GIF_BUTTON_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    GIF
                    """
                case .DASHBOARD_READMORE_NOT_STARTED_TEXT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    You are still insured with your former insurance company. We have started the switch to Hedvig and will inform you as soon as we know the activation date!
                    """
                case .PROFILE_PAYMENT_ROW_HEADER:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    My payments
                    """
                case .CHARITY_SCREEN_HEADER_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    You have not chosen which charity your share of any surplus should go.
                    """
                case .OFFER_BUBBLES_START_DATE_SUBTITLE_NEW:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    today
                    """
                case .TRUSTLY_PAYMENT_SETUP_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    In order for your insurance to be valid you need to connect autogiro from your bank account. We use Trustly for this.
                    """
                case .LOGOUT_ALERT_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Are you sure you want to log out?
                    """
                case .NETWORK_ERROR_ALERT_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    We couldn't reach Hedvig right now, do you have an internet connection?
                    """
                case .CHARITY_OPTIONS_HEADER_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Charity organizations
                    """
                case .OFFER_BUBBLES_DEDUCTIBLE_SUBTITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    1500 kr
                    """
                case .PROFILE_MY_CHARITY_ROW_NOT_SELECTED_SUBTITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    No charity chosen
                    """
                case .PAYMENT_SUCCESS_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Done
                    """
                case .PROFILE_MY_CHARITY_INFO_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    **That's how it works**

                    ** 1. ** Select the charity you want to support
                    ** 2. ** At the end of the year, we collect any surplus money that has not been paid out in compensation to you or to others who have chosen the same charity.
                    ** 3. ** Together we make a difference by donating the money
                    """
                case .EMERGENCY_ABROAD_BUTTON_ACTION_PHONE_NUMBER:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    +4538489461
                    """
                case .BANK_ID_AUTH_TITLE_INITIATED:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Start the BankID-app
                    """
                case .PRIVACY_POLICY_URL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    https://s3.eu-central-1.amazonaws.com/com-hedvig-web-content/Hedvig+-+integritetspolicy.pdf
                    """
                case .CLAIMS_PLEDGE_SLIDE_LABEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Slide to claim
                    """
                case .PAYMENTS_DISCOUNT_ZERO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Hedvig Zero
                    """
                case let .PAYMENTS_DISCOUNT_AMOUNT(discount):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["DISCOUNT": discount]) {
                        return text
                    }

                    return """
                    -\(discount) kr
                    """
                case .PAYMENTS_CAMPAIGN_LFD:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Free until
                    """
                case .PAYMENT_HISTORY_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Payment history
                    """
                case let .PAYMENT_HISTORY_AMOUNT(amount):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["AMOUNT": amount]) {
                        return text
                    }

                    return """
                    \(amount) kr
                    """
                case .PAYMENTS_DIRECT_DEBIT_NEEDS_SETUP:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Not connected
                    """
                case .PAYMENTS_DIRECT_DEBIT_PENDING:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Pending
                    """
                case let .OFFER_HOUSE_SUMMARY_TITLE(userAdress):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["USER_ADRESS": userAdress]) {
                        return text
                    }

                    return """
                    \(userAdress)
                    """
                case .OFFER_HOUSE_SUMMARY_DESC:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Here's a quick overview of the information you've given us about your home.
                    """
                case .OFFER_HOUSE_SUMMARY_BUTTON_EXPAND:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Expand
                    """
                case .OFFER_HOUSE_SUMMARY_BUTTON_MINIMIZE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Minimize
                    """
                case .OFFER_HOUSE_TRUST_HOUSE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Your house is insured full value
                    """
                case .OFFER_HOUSE_TRUST_HDI:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Hedvig is backed by HDI, part of one of the world's largest insurance groups
                    """
                case .HOUSE_INFO_BOYTA:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Living area
                    """
                case .HOUSE_INFO_BIYTA:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Ancillary space
                    """
                case .HOUSE_INFO_YEAR_BUILT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Year built
                    """
                case .HOUSE_INFO_BATHROOM:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Bathroom
                    """
                case .HOUSE_INFO_RENTED:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Partly subleted?
                    """
                case .HOUSE_INFO_TYPE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    House
                    """
                case .HOUSE_INFO_EXTRABUILDINGS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Extra buildings
                    """
                case .HOUSE_INFO_GARAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Garage
                    """
                case .HOUSE_INFO_SHED:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Shed
                    """
                case .HOUSE_INFO_ATTEFALLS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Attefalls
                    """
                case .HOUSE_INFO_MISC:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Annan
                    """
                case .HOUSE_INFO_CONNECTED_WATER:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Connected water main
                    """
                case .MY_HOME_ROW_TYPE_HOUSE_VALUE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    House
                    """
                case let .MY_HOME_ROW_ANCILLARY_AREA_VALUE(area):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["area": area]) {
                        return text
                    }

                    return """
                    \(area) sqm
                    """
                case .MY_HOME_ROW_ANCILLARY_AREA_KEY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Ancillary area
                    """
                case .MY_HOME_ROW_CONSTRUCTION_YEAR_KEY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Year of construction
                    """
                case .MY_HOME_ROW_BATHROOMS_KEY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    No. of bathrooms
                    """
                case .MY_HOME_EXTRABUILDING_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Other buildings
                    """
                case let .HOUSE_INFO_BOYTA_SQUAREMETERS(houseInfoAmountBoyta):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["HOUSE_INFO_AMOUNT_BOYTA": houseInfoAmountBoyta]) {
                        return text
                    }

                    return """
                    \(houseInfoAmountBoyta) sqm
                    """
                case let .HOUSE_INFO_BIYTA_SQUAREMETERS(houseInfoAmountBiyta):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["HOUSE_INFO_AMOUNT_BIYTA": houseInfoAmountBiyta]) {
                        return text
                    }

                    return """
                    \(houseInfoAmountBiyta) sqm
                    """
                case let .OFFER_INFO_OFFER_EXPIRES(offerExpieryDate):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["OFFER_EXPIERY_DATE": offerExpieryDate]) {
                        return text
                    }

                    return """
                    The insurance offer is valid until \(offerExpieryDate)
                    """
                case .HOUSE_INFO_COINSURED:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Number of co-insured
                    """
                case .EXPANDABLE_CONTENT_EXPAND:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Read more
                    """
                case .EXPANDABLE_CONTENT_COLLAPSE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Close
                    """
                case .OFFER_TRUST_INCREASED_DEDUCTIBLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    An increased deductible applies for certain claims, this applies to flooding and freeze damages, among other things. Please read the terms or contact us in the chat if you have any questions.
                    """
                case .HOUSE_INFO_SUBLETED_TRUE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Yes
                    """
                case .HOUSE_INFO_SUBLETED_FALSE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    No
                    """
                case .OFFER_INFO_TRUSTUS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    You are safe with us
                    """
                case .HOUSE_INFO_COMPENSATION_GADGETS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    1,5 million kr
                    """
                case let .MY_HOME_BUILDING_HAS_WATER_SUFFIX(base):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["base": base]) {
                        return text
                    }

                    return """
                    \(base), connected to main water
                    """
                case .MY_HOME_ROW_SUBLETED_KEY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Partly subleted?
                    """
                case .MY_HOME_ROW_SUBLETED_VALUE_YES:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Yes
                    """
                case .MY_HOME_ROW_SUBLETED_VALUE_NO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    No
                    """
                case .MAX_COMPENSATION_HOUSE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    1.5 million kr
                    """
                case .DASHBOARD_INFO_DEDUCTIBLE_HOUSE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    An increased deductible applies for certain claims, this applies to flooding and freeze damages, among other things. Please read the terms or contact us in the chat if you have any questions.
                    """
                case .DASHBOARD_INFO_HOUSE_VALUE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Your house is insured to its full value
                    """
                case let .DASHBOARD_INFO_INSURANCE_STUFF_AMOUNT(maxCompensation):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["maxCompensation": maxCompensation]) {
                        return text
                    }

                    return """
                    Max compensation for your items are
                    \(maxCompensation)
                    """
                case .MY_HOME_INSURANCE_TYPE_HOUSE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    House
                    """
                case .MY_HOME_CITY_LABEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    City
                    """
                case .COST_MONTHLY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    /monthly
                    """
                case .OFFER_TITLE_SAFE_WITH_US:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    You are safe with us
                    """
                case .CHAT_TOAST_PUSH_NOTIFICATIONS_SUBTITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Activate push notifications
                    """
                case .ATTACH_GIF_IMAGE_SEND:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Send
                    """
                case .LABEL_SEARCH_GIF:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Search for something to show gifs
                    """
                case .SEARCH_BAR_GIF:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Search for gifs
                    """
                case .OFFER_SCREEN_PERCENTAGE_DISCOUNT_BUBBLE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Discount!
                    """
                case let .OFFER_SCREEN_PERCENTAGE_DISCOUNT_BUBBLE_TITLE_SINGULAR(percentage):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["percentage": percentage]) {
                        return text
                    }

                    return """
                    \(percentage)% for one month
                    """
                case let .OFFER_SCREEN_PERCENTAGE_DISCOUNT_BUBBLE_TITLE_PLURAL(months, percentage):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["months": months, "percentage": percentage]) {
                        return text
                    }

                    return """
                    \(percentage)% for \(months) months
                    """
                case .OFFER_START_DATE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Starts
                    """
                case .OFFER_START_DATE_TODAY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Today
                    """
                case .CLAIMS_ACTIVATE_NOTIFICATIONS_HEADLINE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Activate push notifications
                    """
                case .CLAIMS_ACTIVATE_NOTIFICATIONS_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    In order for you to get information about your claim and see our messages, it is important that you activate your push notifications.
                    """
                case .CLAIMS_ACTIVATE_NOTIFICATIONS_CTA:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Enable notifications
                    """
                case .CLAIMS_ACTIVATE_NOTIFICATIONS_DISMISS:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Skip
                    """
                case let .PAYMENTS_DISCOUNT_PERCENTAGE_MONTHS_MANY(months, percentage):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["MONTHS": months, "PERCENTAGE": percentage]) {
                        return text
                    }

                    return """
                    "\(percentage)% discount for \(months) months"
                    """
                case let .PAYMENTS_DISCOUNT_PERCENTAGE_MONTHS_ONE(percentage):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["PERCENTAGE": percentage]) {
                        return text
                    }

                    return """
                    "\(percentage)% discount for a month"
                    """
                case .DRAGGABLE_STARTDATE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Change start date
                    """
                case .ACTIVATE_TODAY_BTN:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Activate today
                    """
                case .ACTIVATE_INSURANCE_END_BTN:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Activate when your current insurance expires
                    """
                case .CHOOSE_DATE_BTN:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Choose date
                    """
                case .DRAGGABLE_STARTDATE_DESCRIPTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    What date do you want your insurance to be activated?
                    """
                case .START_DATE_BTN:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Starts
                    """
                case .START_DATE_TODAY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Today
                    """
                case .ALERT_CONTINUE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Continue
                    """
                case .ALERT_CANCEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Cancel
                    """
                case .ALERT_TITLE_STARTDATE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Choose your own startdate?
                    """
                case .LATE_PAYMENT_MESSAGE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    TODO
                    """
                case .START_DATE_EXPIRES:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    When my current one expires
                    """
                case .ALERT_DESCRIPTION_STARTDATE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    If you pick your own start date you need to cancel your old insurance yourself so that everything goes smoothly.
                    """
                case .EDITABLE_ROW_EDIT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Edit
                    """
                case .EDITABLE_ROW_SAVE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Save
                    """
                case .KEY_GEAR_TAB_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Your things
                    """
                case .KEY_GEAR_START_EMPTY_HEADLINE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Get an overview of your things
                    """
                case .KEY_GEAR_START_EMPTY_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Sometimes we damage or lose our things. Simply log your things with us so you can make a claim with just a click, and see how they're covered and what you'll recieve if you have to make a claim.
                    """
                case .KEY_GEAR_ADD_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Add an item
                    """
                case .KEY_GEAR_ADDED_AUTOMATICALLY_TAG:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Auto added
                    """
                case .KEY_GEAR_MORE_INFO_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    More info
                    """
                case .KEY_GEAR_MORE_INFO_HEADLINE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    This is Your things
                    """
                case .KEY_GEAR_MORE_INFO_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    In Key Gear you can add information about your most important things. You input information about what type of item it is and when you bought it, and you'll get detailed information about the exact coverage and the estimated valuation if something were to happen to it. You don't have to add your things – they are of course covered whether you add them to Key Gear or not.
                    """
                case .KEY_GEAR_ADD_ITEM_PAGE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Add item
                    """
                case .KEY_GEAR_ADD_ITEM_PAGE_CLOSE_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Cancel
                    """
                case .KEY_GEAR_ADD_ITEM_PAGE_CLOSE_ALERT_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Are you sure you want to cancel?
                    """
                case .KEY_GEAR_ADD_ITEM_PAGE_CLOSE_ALERT_BODY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    The information you entered will not be saved
                    """
                case .KEY_GEAR_ADD_ITEM_PAGE_CLOSE_ALERT_DISMISS_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    No, continue
                    """
                case .KEY_GEAR_ADD_ITEM_PAGE_CLOSE_ALERT_CONTINUE_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Yes, cancel
                    """
                case .KEY_GEAR_ADD_ITEM_ADD_PHOTO_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Add photo
                    """
                case .KEY_GEAR_ADD_ITEM_TYPE_HEADLINE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Type of item
                    """
                case .KEY_GEAR_ADD_ITEM_SAVE_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Save
                    """
                case let .KEY_GEAR_ADD_ITEM_SUCCESS(itemType):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["ITEM_TYPE": itemType]) {
                        return text
                    }

                    return """
                    Added \(itemType)
                    """
                case .KEY_GEAR_ITEM_VIEW_VALUATION_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Valued at
                    """
                case .KEY_GEAR_ITEM_VIEW_VALUATION_EMPTY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Add purchase info +
                    """
                case .KEY_GEAR_ITEM_VIEW_DEDUCTIBLE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Deductible
                    """
                case .KEY_GEAR_ITEM_VIEW_DEDUCTIBLE_VALUE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    1 500
                    """
                case .KEY_GEAR_ITEM_VIEW_DEDUCTIBLE_CURRENCY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    SEK
                    """
                case .KEY_GEAR_ITEM_VIEW_COVERAGE_TABLE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Your insurance covers
                    """
                case .KEY_GEAR_ITEM_VIEW_NON_COVERAGE_TABLE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Your insurance does not cover
                    """
                case .KEY_GEAR_ITEM_VIEW_ITEM_NAME_TABLE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Item name
                    """
                case .KEY_GEAR_ITEM_VIEW_ITEM_NAME_EDIT_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Edit
                    """
                case .KEY_GEAR_ITEM_VIEW_RECEIPT_TABLE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Receipt
                    """
                case .KEY_GEAR_ITEM_VIEW_RECEIPT_CELL_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Receipt
                    """
                case .KEY_GEAR_ITEM_VIEW_RECEIPT_CELL_ADD_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Add +
                    """
                case .KEY_GEAR_ITEM_VIEW_RECEIPT_TABLE_FOOTER:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    You don't have to add the receipt, it can just be nice to know where it is.
                    """
                case .KEY_GEAR_ITEM_VIEW_ADD_PURCHASE_DATE_PAGE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Add purchase info
                    """
                case let .KEY_GEAR_ITEM_VIEW_ADD_PURCHASE_DATE_BODY(itemType):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["ITEM_TYPE": itemType]) {
                        return text
                    }

                    return """
                    Enter when you purchased the \(itemType) and how much it cost in order to calculate the estimated value
                    """
                case .KEY_GEAR_ITEM_VIEW_ADD_PURCHASE_DATE_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Save
                    """
                case .KEY_GEAR_ITEM_VIEW_VALUATION_PAGE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Valuation
                    """
                case .KEY_GEAR_ITEM_VIEW_VALUATION_PERCENTAGE_LABEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    of the purchase price
                    """
                case let .KEY_GEAR_ITEM_VIEW_VALUATION_BODY(itemType, purchasePrice, valuationPercentage, valuationPrice):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["ITEM_TYPE": itemType, "PURCHASE_PRICE": purchasePrice, "VALUATION_PERCENTAGE": valuationPercentage, "VALUATION_PRICE": valuationPrice]) {
                        return text
                    }

                    return """
                    We first try to repair your \(itemType), but if it needs to be replaced (e.g. if it was stolen) you will be compensated **\(valuationPercentage)%** of the purchase price **\(purchasePrice) SEK**, i.e **\(valuationPrice) SEK**.
                    """
                case .KEY_GEAR_ITEM_VIEW_VALUATION_AGE_DEDUCTION_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Age deduction
                    """
                case let .KEY_GEAR_ITEM_VIEW_VALUATION_AGE_DEDUCTION_BODY(itemType):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["ITEM_TYPE": itemType]) {
                        return text
                    }

                    return """
                    We deduct the value with a certain percentage based on how long since you purchased the \(itemType)
                    """
                case .KEY_GEAR_ITEM_VIEW_VALUATION_AGE_DEDUCTION_TABLE_EXPAND_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Expand
                    """
                case .KEY_GEAR_ADD_PURCHASE_PRICE_CELL_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Purchase price
                    """
                case .ITEM_TYPE_PHONE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Phone
                    """
                case .ITEM_TYPE_COMPUTER:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Computer
                    """
                case .ITEM_TYPE_TV:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    TV
                    """
                case .ITEM_TYPE_BIKE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Bike
                    """
                case .ITEM_TYPE_WATCH:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Watch
                    """
                case .ITEM_TYPE_JEWELRY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Jewelry
                    """
                case .KEY_GEAR_RECCEIPT_VIEW_PAGE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Receipt
                    """
                case .KEY_GEAR_RECCEIPT_VIEW_CLOSE_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Close
                    """
                case .KEY_GEAR_RECCEIPT_VIEW_SHARE_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Share
                    """
                case .KEY_GEAR_ADD_PURCHASE_INFO_PAGE_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Add purchase info
                    """
                case let .KEY_GEAR_ADD_PURCHASE_INFO_BODY(itemType):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["ITEM_TYPE": itemType]) {
                        return text
                    }

                    return """
                    Enter when you purchased the \(itemType) and how much it cost in order to calculate the estimated value
                    """
                case .KEY_GEAR_YEARMONTH_PICKER_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Purchase Date
                    """
                case .KEY_GEAR_YEARMONTH_PICKER_POS_ACTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    OK
                    """
                case .KEY_GEAR_YEARMONTH_PICKER_NEG_ACTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Cancel
                    """
                case .KEY_GEAR_ITEM_VIEW_RECEIPT_SHOW:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Show
                    """
                case .TOOLBAR_DONE_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Done
                    """
                case .KEY_GEAR_RECEIPT_UPLOAD_SHEET_TITLE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Upload receipt
                    """
                case .ITEM_TYPE_PHONE_COVERED_ONE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    If you drop it on the ground
                    """
                case .ITEM_TYPE_PHONE_COVERED_TWO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    If you drop it in water
                    """
                case .ITEM_TYPE_PHONE_COVERED_THREE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    If you or someone else damages it
                    """
                case .ITEM_TYPE_PHONE_COVERED_FOUR:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    If water damage occurs
                    """
                case .ITEM_TYPE_PHONE_COVERED_FIVE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    If it gets stolen
                    """
                case .ITEM_TYPE_PHONE_NOT_COVERED_ONE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    If you lose it
                    """
                case .ITEM_TYPE_PHONE_NOT_COVERED_TWO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Faults that are covered by warranty
                    """
                case .ITEM_TYPE_COMPUTER_COVERED_ONE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    If you drop it on the ground
                    """
                case .ITEM_TYPE_COMPUTER_COVERED_TWO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    If you drop it in water
                    """
                case .ITEM_TYPE_COMPUTER_COVERED_THREE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    If you or someone else damages it
                    """
                case .ITEM_TYPE_COMPUTER_COVERED_FOUR:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    If water damage occurs
                    """
                case .ITEM_TYPE_COMPUTER_COVERED_FIVE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    If it gets stolen
                    """
                case .ITEM_TYPE_COMPUTER_NOT_COVERED_ONE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    If you lose it
                    """
                case .ITEM_TYPE_COMPUTER_NOT_COVERED_TWO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Faults that are covered by warranty
                    """
                case .ITEM_TYPE_TV_COVERED_ONE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    If you or someone else damages it
                    """
                case .ITEM_TYPE_TV_COVERED_TWO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    If you have a break-in and someone steals it
                    """
                case .ITEM_TYPE_TV_COVERED_THREE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Damage caused by fire
                    """
                case .ITEM_TYPE_TV_COVERED_FOUR:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    If its damaged during a move
                    """
                case .ITEM_TYPE_TV_NOT_COVERED_ONE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Faults that are covered by warranty
                    """
                case .ITEM_TYPE_TV_NOT_COVERED_TWO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Short circuit caused by water
                    """
                case .ITEM_TYPE_BIKE_COVERED_ONE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    If it gets stolen
                    """
                case .ITEM_TYPE_BIKE_COVERED_TWO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    If you or someone else damages it
                    """
                case .ITEM_TYPE_BIKE_COVERED_THREE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    If you crash your bike
                    """
                case .ITEM_TYPE_BIKE_COVERED_FOUR:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    If it is vandalized
                    """
                case .ITEM_TYPE_BIKE_NOT_COVERED_ONE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Damage caused by an other vehicle 
                    """
                case .ITEM_TYPE_BIKE_NOT_COVERED_TWO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Personal injury caused by an accident
                    """
                case .ITEM_TYPE_BIKE_NOT_COVERED_THREE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Damage caused by usage over time
                    """
                case .ITEM_TYPE_WATCH_COVERED_ONE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    If it gets stolen
                    """
                case .ITEM_TYPE_WATCH_COVERED_TWO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    If you or someone else damages it
                    """
                case .ITEM_TYPE_WATCH_NOT_COVERED_ONE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    If you lose it
                    """
                case .ITEM_TYPE_WATCH_NOT_COVERED_TWO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Damage caused by wear and tear
                    """
                case .ITEM_TYPE_JEWELRY_COVERED_ONE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    If it gets stolen
                    """
                case .ITEM_TYPE_JEWELRY_COVERED_TWO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    If you or someone else damages it
                    """
                case .ITEM_TYPE_JEWELRY_NOT_COVERED_ONE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    If you lose it
                    """
                case .ITEM_TYPE_JEWELRY_NOT_COVERED_TWO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Damage caused by wear and tear
                    """
                case .KEY_GEAR_IMAGE_PICKER_PHOTO_LIBRARY:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Photo library
                    """
                case .KEY_GEAR_IMAGE_PICKER_DOCUMENT:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Document
                    """
                case .KEY_GEAR_IMAGE_PICKER_CANCEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Cancel
                    """
                case .KEY_GEAR_ITEM_DELETE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Delete
                    """
                case .KEY_GEAR_ITEM_OPTIONS_CANCEL:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Cancel
                    """
                case .KEY_GEAR_ITEM_VIEW_ITEM_NAME_SAVE_BUTTON:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Save
                    """
                case let .KEY_GEAR_ITEM_VIEW_VALUATION_MARKET_BODY(itemType, valuationPercentage):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["ITEM_TYPE": itemType, "VALUATION_PERCENTAGE": valuationPercentage]) {
                        return text
                    }

                    return """
                    We first try to repair your \(itemType), but if it needs to be replaced (e.g. if it was stolen) you will be compensated by **\(valuationPercentage)%** of it's current market value.
                    """
                case .KEY_GEAR_ITEM_VIEW_VALUATION_MARKET_DESCRIPTION:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    of the market value
                    """
                case .ITEM_TYPE_SMART_WATCH_COVERED_ONE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    If you drop it on the ground
                    """
                case .ITEM_TYPE_SMART_WATCH_COVERED_TWO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    If you drop it in water
                    """
                case .ITEM_TYPE_SMART_WATCH_COVERED_THREE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    If you or someone else damages it
                    """
                case .ITEM_TYPE_SMART_WATCH_COVERED_FOUR:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    If water damage occurs
                    """
                case .ITEM_TYPE_SMART_WATCH_COVERED_FIVE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    If it gets stolen
                    """
                case .ITEM_TYPE_SMART_WATCH_NOT_COVERED_ONE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    If you lose it
                    """
                case .ITEM_TYPE_SMART_WATCH_NOT_COVERED_TWO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Faults that are covered by warranty
                    """
                case .ITEM_TYPE_SMART_WATCH:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Smartwatch
                    """
                case .KEY_GEAR_REPORT_CLAIM_ROW:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Report claim
                    """
                case .KEY_GEAR_IMAGE_PICKER_CAMERA:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Camera
                    """
                case .ITEM_TYPE_TABLET:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Tablet
                    """
                case let .KEY_GEAR_NOT_COVERED(itemType):
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: ["ITEM_TYPE": itemType]) {
                        return text
                    }

                    return """
                    Observe that your \(itemType) is more expensive than what your all-risk covers, we recommend that you contact us through the chat to purchase extra insurance coverage for this \(itemType).
                    """
                case .ITEM_TYPE_TABLET_COVERED_ONE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    If you drop it on the ground
                    """
                case .ITEM_TYPE_TABLET_COVERED_TWO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    If you drop it in water
                    """
                case .ITEM_TYPE_TABLET_COVERED_THREE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    If you or someone else damages it
                    """
                case .ITEM_TYPE_TABLET_COVERED_FOUR:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    If water damage occurs
                    """
                case .ITEM_TYPE_TABLET_COVERED_FIVE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    If it gets stolen
                    """
                case .ITEM_TYPE_TABLET_NOT_COVERED_ONE:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    If you lose it
                    """
                case .ITEM_TYPE_TABLET_NOT_COVERED_TWO:
                    if let text = TranslationsRepo.findWithReplacements(key, replacements: [:]) {
                        return text
                    }

                    return """
                    Faults that are covered by warranty
                    """
                default: return String(describing: key)
                }
            }
        }

        struct en_NO {
            static func `for`(key: Localization.Key) -> String {
                switch key {
                default: return String(describing: key)
                }
            }
        }

        struct nb_NO {
            static func `for`(key: Localization.Key) -> String {
                switch key {
                default: return String(describing: key)
                }
            }
        }
    }
}
