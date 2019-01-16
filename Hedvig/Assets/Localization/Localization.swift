// Generated automagically, don't edit yourself

import Foundation


// swiftlint:disable identifier_name type_body_length type_name line_length nesting file_length
public struct Localization {

enum Language {
case sv_SE
case en_SE
}

enum Key {
/// <null>
case OFFER_TITLE
/// <null>
case OFFER_BUBBLES_BINDING_PERIOD_TITLE
/// <null>
case OFFER_BUBBLES_BINDING_PERIOD_SUBTITLE
/// <null>
case OFFER_BUBBLES_DEDUCTIBLE_TITLE
/// <null>
case OFFER_BUBBLES_DEDUCTIBLE_SUBTITLE
/// <null>
case OFFER_BUBBLES_INSURED_TITLE
/// <null>
case OFFER_BUBBLES_INSURED_SUBTITLE
/// <null>
case OFFER_BUBBLES_START_DATE_TITLE
/// <null>
case OFFER_BUBBLES_START_DATE_SUBTITLE_SWITCHER
/// <null>
case OFFER_BUBBLES_START_DATE_SUBTITLE_NEW
/// <null>
case OFFER_BUBBLES_TRAVEL_PROTECTION_TITLE
/// <null>
case OFFER_BUBBLES_OWNED_ADDON_TITLE
/// <null>
case OFFER_SIGN_BUTTON
/// <null>
case OFFER_SCROLL_HEADER
/// <null>
case OFFER_CHAT_HEADER
/// <null>
case OFFER_GET_HEDVIG_TITLE
/// <null>
case OFFER_GET_HEDVIG_BODY
/// <null>
case HEDVIG_SAYS_HELLO
/// <null>
case OFFER_APARTMENT_PROTECTION_DESCRIPTION
/// <null>
case OFFER_APARTMENT_PROTECTION_TITLE
/// <null>
case OFFER_STUFF_PROTECTION_TITLE
/// <null>
case OFFER_STUFF_PROTECTION_DESCRIPTION
/// <null>
case STUFF_PROTECTION_AMOUNT
/// <null>
case STUFF_PROTECTION_AMOUNT_STUDENT
/// <null>
case OFFER_PERSONAL_PROTECTION_TITLE
/// <null>
case OFFER_PERSONAL_PROTECTION_DESCRIPTION
/// <null>
case OFFER_PERILS_EXPLAINER
/// <null>
case DOWNLOAD_INPUT_TITLE
/// <null>
case OFFER_SUMMARY_PRICE_LABEL
/// <null>
case SIGN_BANKID_USER_CANCEL
/// <null>
case SIGN_BANKID_WAITING_FOR_BANKID
/// <null>
case OFFER_SIGN_CTA_BOTTOM
/// <null>
case TRUSTLY_PAYMENT_SETUP_MESSAGE
/// <null>
case TRUSTLY_PAYMENT_SETUP_ACTION
/// <null>
case OFFER_TAB_INFO
/// <null>
case CASHBACK_NEEDS_SETUP_MESSAGE
/// <null>
case CASHBACK_NEEDS_SETUP_ACTION
/// <null>
case CASHBACK_NEEDS_SETUP_OVERLAY_TITLE
/// <null>
case CASHBACK_NEEDS_SETUP_OVERLAY_PARAGRAPH
/// <null>
case PAYMENT_SUCCESS_TITLE
/// <null>
case PAYMENT_SUCCESS_BODY
/// <null>
case PAYMENT_SUCCESS_BUTTON
/// <null>
case PAYMENT_FAILURE_TITLE
/// <null>
case PAYMENT_FAILURE_BODY
/// <null>
case PAYMENT_FAILURE_BUTTON
/// <null>
case DASHBOARD_BANNER_ACTIVE_TITLE
/// <null>
case DASHBOARD_BANNER_ACTIVE_INFO
/// <null>
case DASHBOARD_HAVE_START_DATE_BANNER_TITLE
/// <null>
case DASHBOARD_READMORE_HAVE_START_DATE_TEXT
/// <null>
case DASHBOARD_BANNER_MONTHS
/// <null>
case DASHBOARD_BANNER_DAYS
/// <null>
case DASHBOARD_BANNER_HOURS
/// <null>
case DASHBOARD_BANNER_MINUTES
/// <null>
case DASHBOARD_MORE_INFO_BUTTON_TEXT
/// <null>
case DASHBOARD_NOT_STARTED_BANNER_TITLE
/// <null>
case DASHBOARD_READMORE_NOT_STARTED_TEXT
/// <null>
case DASHBOARD_LESS_INFO_BUTTON_TEXT
/// <null>
case FILE_UPLOAD_ERROR
/// <null>
case FILE_UPLOAD_ERROR_RETRY_BUTTON
/// <null>
case DASHBOARD_BANNER_TERMINATED_INFO
/// <null>
case RESTART_OFFER_CHAT_TITLE
/// <null>
case RESTART_OFFER_CHAT_PARAGRAPH
/// <null>
case RESTART_OFFER_CHAT_BUTTON_CONFIRM
/// <null>
case RESTART_OFFER_CHAT_BUTTON_DISMISS
/// <null>
case DASHBOARD_DEDUCTIBLE_FOOTNOTE
/// <null>
case DASHBOARD_OWNER_FOOTNOTE
/// <null>
case DASHBOARD_PERILS_CATEGORY_INFO
/// <null>
case DASHBOARD_TRAVEL_FOOTNOTE
/// <null>
case PROFILE_CACHBACK_ROW
/// <null>
case PROFILE_INSURANCE_ADDRESS_ROW
/// <null>
case PROFILE_INSURANCE_CERTIFICATE_ROW_HEADER
/// <null>
case PROFILE_INSURANCE_CERTIFICATE_ROW_TEXT
/// <null>
case PROFILE_PAYMENT_ROW_HEADER
/// <null>
case PROFILE_PAYMENT_ROW_TEXT
/// <null>
case PROFILE_SAFETYINCREASERS_ROW_HEADER
/// <null>
case DASHBOARD_INSURANCE_AMOUNT_FOOTNOTE
/// <null>
case CHAT_GIPHY_PICKER_NO_SEARCH_TEXT
/// <null>
case CHAT_GIPHY_PICKER_TEXT
/// <null>
case CHAT_COULD_NOT_LOAD_FILE
/// <null>
case CHAT_FILE_LOADING
/// <null>
case CHAT_FILE_DOWNLOAD
/// <null>
case AUDIO_INPUT_REDO
/// <null>
case AUDIO_INPUT_SAVE
/// <null>
case AUDIO_INPUT_PLAY
/// <null>
case CHAT_FILE_UPLOADED
/// <null>
case AUDIO_INPUT_RECORDING
/// <null>
case GIF_BUTTON_TITLE
/// <null>
case CHAT_UPLOAD_PRESEND
/// <null>
case CHAT_UPLOADING_ANIMATION_TEXT
/// <null>
case CHAT_GIPHY_TITLE
/// <null>
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
/// Title for my payment row on profile page
case PROFILE_MY_PAYMENT_ROW_TITLE
/// Method used to pay fee
case PROFILE_MY_PAYMENT_METHOD
/// Title for "My payment" view
case MY_PAYMENT_TITLE
/// Text in deductible circle in my payment view
case MY_PAYMENT_DEDUCTIBLE_CIRCLE_TEX
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
}

struct Translations {

    struct sv_SE {
        static func `for`(key: Localization.Key) -> String {
            switch key {

                case .OFFER_TITLE:
                    if let text = TranslationsRepo.find(.OFFER_TITLE) {
                        return text
                    }

                    return """
                Försäkringsförslag
                """

                case .OFFER_SUMMARY_PRICE_LABEL:
                    if let text = TranslationsRepo.find(.OFFER_SUMMARY_PRICE_LABEL) {
                        return text
                    }

                    return """
                kr/mån
                """

                case .OFFER_BUBBLES_BINDING_PERIOD_TITLE:
                    if let text = TranslationsRepo.find(.OFFER_BUBBLES_BINDING_PERIOD_TITLE) {
                        return text
                    }

                    return """
                Bindningstid
                """

                case .OFFER_BUBBLES_BINDING_PERIOD_SUBTITLE:
                    if let text = TranslationsRepo.find(.OFFER_BUBBLES_BINDING_PERIOD_SUBTITLE) {
                        return text
                    }

                    return """
                Nope, så jobbar inte Hedvig
                """

                case .OFFER_BUBBLES_DEDUCTIBLE_TITLE:
                    if let text = TranslationsRepo.find(.OFFER_BUBBLES_DEDUCTIBLE_TITLE) {
                        return text
                    }

                    return """
                Självrisk
                """

                case .OFFER_BUBBLES_DEDUCTIBLE_SUBTITLE:
                    if let text = TranslationsRepo.find(.OFFER_BUBBLES_DEDUCTIBLE_SUBTITLE) {
                        return text
                    }

                    return """
                1500 kr
                """

                case .OFFER_BUBBLES_INSURED_TITLE:
                    if let text = TranslationsRepo.find(.OFFER_BUBBLES_INSURED_TITLE) {
                        return text
                    }

                    return """
                Försäkrade
                """

                case .OFFER_BUBBLES_INSURED_SUBTITLE:
                    if let text = TranslationsRepo.find(.OFFER_BUBBLES_INSURED_SUBTITLE) {
                        return text
                    }

                    return """
                {personsInHousehold} personer
                """

                case .OFFER_BUBBLES_START_DATE_TITLE:
                    if let text = TranslationsRepo.find(.OFFER_BUBBLES_START_DATE_TITLE) {
                        return text
                    }

                    return """
                Startdatum
                """

                case .OFFER_BUBBLES_START_DATE_SUBTITLE_SWITCHER:
                    if let text = TranslationsRepo.find(.OFFER_BUBBLES_START_DATE_SUBTITLE_SWITCHER) {
                        return text
                    }

                    return """
                Så fort din bindningstid går ut
                """

                case .OFFER_BUBBLES_START_DATE_SUBTITLE_NEW:
                    if let text = TranslationsRepo.find(.OFFER_BUBBLES_START_DATE_SUBTITLE_NEW) {
                        return text
                    }

                    return """
                idag
                """

                case .OFFER_BUBBLES_TRAVEL_PROTECTION_TITLE:
                    if let text = TranslationsRepo.find(.OFFER_BUBBLES_TRAVEL_PROTECTION_TITLE) {
                        return text
                    }

                    return """
                Reseskydd ingår
                """

                case .OFFER_BUBBLES_OWNED_ADDON_TITLE:
                    if let text = TranslationsRepo.find(.OFFER_BUBBLES_OWNED_ADDON_TITLE) {
                        return text
                    }

                    return """
                Bostadsrätts- tillägg ingår
                """

                case .OFFER_SIGN_BUTTON:
                    if let text = TranslationsRepo.find(.OFFER_SIGN_BUTTON) {
                        return text
                    }

                    return """
                Skaffa Hedvig
                """

                case .OFFER_SCROLL_HEADER:
                    if let text = TranslationsRepo.find(.OFFER_SCROLL_HEADER) {
                        return text
                    }

                    return """
                Vad Hedvig täcker
                """

                case .OFFER_CHAT_HEADER:
                    if let text = TranslationsRepo.find(.OFFER_CHAT_HEADER) {
                        return text
                    }

                    return """
                Prata med Hedvig
                """

                case .OFFER_GET_HEDVIG_TITLE:
                    if let text = TranslationsRepo.find(.OFFER_GET_HEDVIG_TITLE) {
                        return text
                    }

                    return """
                Redo?
                """

                case .OFFER_GET_HEDVIG_BODY:
                    if let text = TranslationsRepo.find(.OFFER_GET_HEDVIG_BODY) {
                        return text
                    }

                    return """
                Skaffa Hedvig genom att klicka på knappen nedan och signera med BankID.
                """

                case .OFFER_APARTMENT_PROTECTION_DESCRIPTION:
                    if let text = TranslationsRepo.find(.OFFER_APARTMENT_PROTECTION_DESCRIPTION) {
                        return text
                    }

                    return """
                Vi vet hur mycket ett hem betyder. Därför ger vi det ett riktigt bra skydd, så att du kan känna dig trygg i alla lägen.
                """

                case .OFFER_APARTMENT_PROTECTION_TITLE:
                    if let text = TranslationsRepo.find(.OFFER_APARTMENT_PROTECTION_TITLE) {
                        return text
                    }

                    return """
                {address}
                """

                case .OFFER_STUFF_PROTECTION_TITLE:
                    if let text = TranslationsRepo.find(.OFFER_STUFF_PROTECTION_TITLE) {
                        return text
                    }

                    return """
                Dina prylar
                """

                case .OFFER_STUFF_PROTECTION_DESCRIPTION:
                    if let text = TranslationsRepo.find(.OFFER_STUFF_PROTECTION_DESCRIPTION) {
                        return text
                    }

                    return """
                Med Hedvig får du ett komplett skydd för dina prylar. Drulleförsäkring ingår och täcker prylar värda upp till {protectionAmount} styck.
                """

                case .STUFF_PROTECTION_AMOUNT:
                    if let text = TranslationsRepo.find(.STUFF_PROTECTION_AMOUNT) {
                        return text
                    }

                    return """
                50 000 kr
                """

                case .STUFF_PROTECTION_AMOUNT_STUDENT:
                    if let text = TranslationsRepo.find(.STUFF_PROTECTION_AMOUNT_STUDENT) {
                        return text
                    }

                    return """
                25 000 kr
                """

                case .OFFER_PERSONAL_PROTECTION_TITLE:
                    if let text = TranslationsRepo.find(.OFFER_PERSONAL_PROTECTION_TITLE) {
                        return text
                    }

                    return """
                Dig
                """

                case .OFFER_PERSONAL_PROTECTION_DESCRIPTION:
                    if let text = TranslationsRepo.find(.OFFER_PERSONAL_PROTECTION_DESCRIPTION) {
                        return text
                    }

                    return """
                Hedvig skyddar dig mot obehagliga saker som kan hända på hemmaplan, och det mesta som kan hända när du är ute och reser.
                """

                case .OFFER_PERILS_EXPLAINER:
                    if let text = TranslationsRepo.find(.OFFER_PERILS_EXPLAINER) {
                        return text
                    }

                    return """
                Tryck på ikonerna för mer info
                """

                case .TRUSTLY_PAYMENT_SETUP_MESSAGE:
                    if let text = TranslationsRepo.find(.TRUSTLY_PAYMENT_SETUP_MESSAGE) {
                        return text
                    }

                    return """
                För att din försäkring ska gälla framöver behöver du koppla autogiro från ditt bankkonto. Vi sköter det via Trustly.
                """

                case .TRUSTLY_PAYMENT_SETUP_ACTION:
                    if let text = TranslationsRepo.find(.TRUSTLY_PAYMENT_SETUP_ACTION) {
                        return text
                    }

                    return """
                Sätt upp betalning
                """

                case .CASHBACK_NEEDS_SETUP_MESSAGE:
                    if let text = TranslationsRepo.find(.CASHBACK_NEEDS_SETUP_MESSAGE) {
                        return text
                    }

                    return """
                Du har ännu inte valt din välgörenhets organisation
                """

                case .CASHBACK_NEEDS_SETUP_ACTION:
                    if let text = TranslationsRepo.find(.CASHBACK_NEEDS_SETUP_ACTION) {
                        return text
                    }

                    return """
                Välj välgörenhetsorganisation
                """

                case .CASHBACK_NEEDS_SETUP_OVERLAY_TITLE:
                    if let text = TranslationsRepo.find(.CASHBACK_NEEDS_SETUP_OVERLAY_TITLE) {
                        return text
                    }

                    return """
                Välj välgörenhetsorganisation
                """

                case .CASHBACK_NEEDS_SETUP_OVERLAY_PARAGRAPH:
                    if let text = TranslationsRepo.find(.CASHBACK_NEEDS_SETUP_OVERLAY_PARAGRAPH) {
                        return text
                    }

                    return """
                Välj vilken välgörenhet du vill att din andel av årets överskott ska gå till.
                """

                case .PAYMENT_SUCCESS_TITLE:
                    if let text = TranslationsRepo.find(.PAYMENT_SUCCESS_TITLE) {
                        return text
                    }

                    return """
                Autogirot aktivt
                """

                case .PAYMENT_SUCCESS_BODY:
                    if let text = TranslationsRepo.find(.PAYMENT_SUCCESS_BODY) {
                        return text
                    }

                    return """
                Hedvig kommer att synas på ditt kontoutdrag när vi tar betalt varje månad.
                """

                case .PAYMENT_SUCCESS_BUTTON:
                    if let text = TranslationsRepo.find(.PAYMENT_SUCCESS_BUTTON) {
                        return text
                    }

                    return """
                Klar
                """

                case .PAYMENT_FAILURE_TITLE:
                    if let text = TranslationsRepo.find(.PAYMENT_FAILURE_TITLE) {
                        return text
                    }

                    return """
                Något gick fel
                """

                case .PAYMENT_FAILURE_BODY:
                    if let text = TranslationsRepo.find(.PAYMENT_FAILURE_BODY) {
                        return text
                    }

                    return """
                 Inga pengar kommer att dras.
                Du kan gå tillbaka för att försöka igen.
                """

                case .PAYMENT_FAILURE_BUTTON:
                    if let text = TranslationsRepo.find(.PAYMENT_FAILURE_BUTTON) {
                        return text
                    }

                    return """
                Gå tillbaka
                """

                case .DASHBOARD_BANNER_ACTIVE_TITLE:
                    if let text = TranslationsRepo.find(.DASHBOARD_BANNER_ACTIVE_TITLE) {
                        return text
                    }

                    return """
                Hej {firstName}!
                """

                case .DASHBOARD_BANNER_ACTIVE_INFO:
                    if let text = TranslationsRepo.find(.DASHBOARD_BANNER_ACTIVE_INFO) {
                        return text
                    }

                    return """
                Din försäkring är aktiv
                """

                case .DASHBOARD_HAVE_START_DATE_BANNER_TITLE:
                    if let text = TranslationsRepo.find(.DASHBOARD_HAVE_START_DATE_BANNER_TITLE) {
                        return text
                    }

                    return """
                Din försäkring aktiveras om:
                """

                case .DASHBOARD_READMORE_HAVE_START_DATE_TEXT:
                    if let text = TranslationsRepo.find(.DASHBOARD_READMORE_HAVE_START_DATE_TEXT) {
                        return text
                    }

                    return """
                Du är fortfarande försäkrad hos ditt tidigare försäkringsbolag. Vi har påbörjat flytten och den {date} aktiveras din försäkring hos Hedvig!
                """

                case .DASHBOARD_BANNER_MONTHS:
                    if let text = TranslationsRepo.find(.DASHBOARD_BANNER_MONTHS) {
                        return text
                    }

                    return """
                M
                """

                case .DASHBOARD_BANNER_DAYS:
                    if let text = TranslationsRepo.find(.DASHBOARD_BANNER_DAYS) {
                        return text
                    }

                    return """
                D
                """

                case .DASHBOARD_BANNER_HOURS:
                    if let text = TranslationsRepo.find(.DASHBOARD_BANNER_HOURS) {
                        return text
                    }

                    return """
                H
                """

                case .DASHBOARD_BANNER_MINUTES:
                    if let text = TranslationsRepo.find(.DASHBOARD_BANNER_MINUTES) {
                        return text
                    }

                    return """
                M
                """

                case .DASHBOARD_MORE_INFO_BUTTON_TEXT:
                    if let text = TranslationsRepo.find(.DASHBOARD_MORE_INFO_BUTTON_TEXT) {
                        return text
                    }

                    return """
                Mer info
                """

                case .DASHBOARD_NOT_STARTED_BANNER_TITLE:
                    if let text = TranslationsRepo.find(.DASHBOARD_NOT_STARTED_BANNER_TITLE) {
                        return text
                    }

                    return """
                Din försäkring är på gång!
                """

                case .DASHBOARD_READMORE_NOT_STARTED_TEXT:
                    if let text = TranslationsRepo.find(.DASHBOARD_READMORE_NOT_STARTED_TEXT) {
                        return text
                    }

                    return """
                Du är fortfarande försäkrad hos ditt tidigare försäkringsbolag. Vi har påbörjat flytten till Hedvig och informerar dig så fort vi vet aktiveringsdatumet!
                """

                case .DASHBOARD_LESS_INFO_BUTTON_TEXT:
                    if let text = TranslationsRepo.find(.DASHBOARD_LESS_INFO_BUTTON_TEXT) {
                        return text
                    }

                    return """
                Mindre info
                """

                case .FILE_UPLOAD_ERROR:
                    if let text = TranslationsRepo.find(.FILE_UPLOAD_ERROR) {
                        return text
                    }

                    return """
                Du gav oss inte tillgång till ditt bildbibliotek, vi kan därför inte visa dina bilder här. Gå till inställningar för att ge oss tillgång till ditt bildbibliotek.
                """

                case .FILE_UPLOAD_ERROR_RETRY_BUTTON:
                    if let text = TranslationsRepo.find(.FILE_UPLOAD_ERROR_RETRY_BUTTON) {
                        return text
                    }

                    return """
                Försök igen
                """

                case .DASHBOARD_BANNER_TERMINATED_INFO:
                    if let text = TranslationsRepo.find(.DASHBOARD_BANNER_TERMINATED_INFO) {
                        return text
                    }

                    return """
                Din försäkring är inaktiv
                """

                case .RESTART_OFFER_CHAT_TITLE:
                    if let text = TranslationsRepo.find(.RESTART_OFFER_CHAT_TITLE) {
                        return text
                    }

                    return """
                Vill du börja om?
                """

                case .RESTART_OFFER_CHAT_PARAGRAPH:
                    if let text = TranslationsRepo.find(.RESTART_OFFER_CHAT_PARAGRAPH) {
                        return text
                    }

                    return """
                Om du trycker ja börjar konversationen om och ditt nuvarande förslag försvinner
                """

                case .RESTART_OFFER_CHAT_BUTTON_CONFIRM:
                    if let text = TranslationsRepo.find(.RESTART_OFFER_CHAT_BUTTON_CONFIRM) {
                        return text
                    }

                    return """
                Ja
                """

                case .RESTART_OFFER_CHAT_BUTTON_DISMISS:
                    if let text = TranslationsRepo.find(.RESTART_OFFER_CHAT_BUTTON_DISMISS) {
                        return text
                    }

                    return """
                Nej
                """

                case .DASHBOARD_DEDUCTIBLE_FOOTNOTE:
                    if let text = TranslationsRepo.find(.DASHBOARD_DEDUCTIBLE_FOOTNOTE) {
                        return text
                    }

                    return """
                Din självrisk är 1 500 kr
                """

                case .DASHBOARD_OWNER_FOOTNOTE:
                    if let text = TranslationsRepo.find(.DASHBOARD_OWNER_FOOTNOTE) {
                        return text
                    }

                    return """
                Lägenheten försäkras till sitt fulla värde
                """

                case .DASHBOARD_PERILS_CATEGORY_INFO:
                    if let text = TranslationsRepo.find(.DASHBOARD_PERILS_CATEGORY_INFO) {
                        return text
                    }

                    return """
                Klicka på ikonerna för mer info
                """

                case .DASHBOARD_TRAVEL_FOOTNOTE:
                    if let text = TranslationsRepo.find(.DASHBOARD_TRAVEL_FOOTNOTE) {
                        return text
                    }

                    return """
                Gäller på resor varsomhelst i världen
                """

                case .PROFILE_CACHBACK_ROW:
                    if let text = TranslationsRepo.find(.PROFILE_CACHBACK_ROW) {
                        return text
                    }

                    return """
                Min välgörenhet
                """

                case .PROFILE_INSURANCE_ADDRESS_ROW:
                    if let text = TranslationsRepo.find(.PROFILE_INSURANCE_ADDRESS_ROW) {
                        return text
                    }

                    return """
                Mitt hem
                """

                case .PROFILE_INSURANCE_CERTIFICATE_ROW_HEADER:
                    if let text = TranslationsRepo.find(.PROFILE_INSURANCE_CERTIFICATE_ROW_HEADER) {
                        return text
                    }

                    return """
                Mitt försäkringsbrev
                """

                case .PROFILE_INSURANCE_CERTIFICATE_ROW_TEXT:
                    if let text = TranslationsRepo.find(.PROFILE_INSURANCE_CERTIFICATE_ROW_TEXT) {
                        return text
                    }

                    return """
                Tryck för att läsa
                """

                case .PROFILE_PAYMENT_ROW_HEADER:
                    if let text = TranslationsRepo.find(.PROFILE_PAYMENT_ROW_HEADER) {
                        return text
                    }

                    return """
                Min betalning
                """

                case .PROFILE_PAYMENT_ROW_TEXT:
                    if let text = TranslationsRepo.find(.PROFILE_PAYMENT_ROW_TEXT) {
                        return text
                    }

                    return """
                {price} kr/månad. Betalas via autogiro
                """

                case .PROFILE_SAFETYINCREASERS_ROW_HEADER:
                    if let text = TranslationsRepo.find(.PROFILE_SAFETYINCREASERS_ROW_HEADER) {
                        return text
                    }

                    return """
                Mina trygghetshöjare
                """

                case .DASHBOARD_INSURANCE_AMOUNT_FOOTNOTE:
                    if let text = TranslationsRepo.find(.DASHBOARD_INSURANCE_AMOUNT_FOOTNOTE) {
                        return text
                    }

                    return """
                Prylarna försäkras totalt till {student} kr
                """

                case .CHAT_GIPHY_PICKER_NO_SEARCH_TEXT:
                    if let text = TranslationsRepo.find(.CHAT_GIPHY_PICKER_NO_SEARCH_TEXT) {
                        return text
                    }

                    return """
                Oh no, ingen GIF för denna sökning...
                """

                case .CHAT_GIPHY_PICKER_TEXT:
                    if let text = TranslationsRepo.find(.CHAT_GIPHY_PICKER_TEXT) {
                        return text
                    }

                    return """
                Sök på något för att få upp GIFar!
                """

                case .CHAT_COULD_NOT_LOAD_FILE:
                    if let text = TranslationsRepo.find(.CHAT_COULD_NOT_LOAD_FILE) {
                        return text
                    }

                    return """
                Kunde inte ladda fil...
                """

                case .CHAT_FILE_LOADING:
                    if let text = TranslationsRepo.find(.CHAT_FILE_LOADING) {
                        return text
                    }

                    return """
                Laddar...
                """

                case .CHAT_FILE_DOWNLOAD:
                    if let text = TranslationsRepo.find(.CHAT_FILE_DOWNLOAD) {
                        return text
                    }

                    return """
                Ladda ner fil
                """

                case .AUDIO_INPUT_REDO:
                    if let text = TranslationsRepo.find(.AUDIO_INPUT_REDO) {
                        return text
                    }

                    return """
                Gör om
                """

                case .AUDIO_INPUT_SAVE:
                    if let text = TranslationsRepo.find(.AUDIO_INPUT_SAVE) {
                        return text
                    }

                    return """
                Spara
                """

                case .AUDIO_INPUT_PLAY:
                    if let text = TranslationsRepo.find(.AUDIO_INPUT_PLAY) {
                        return text
                    }

                    return """
                Spela upp
                """

                case .CHAT_FILE_UPLOADED:
                    if let text = TranslationsRepo.find(.CHAT_FILE_UPLOADED) {
                        return text
                    }

                    return """
                fil uppladdad
                """

                case .AUDIO_INPUT_RECORDING:
                    if let text = TranslationsRepo.find(.AUDIO_INPUT_RECORDING) {
                        return text
                    }

                    return """
                Spelar in:
                """

                case .GIF_BUTTON_TITLE:
                    if let text = TranslationsRepo.find(.GIF_BUTTON_TITLE) {
                        return text
                    }

                    return """
                GIF
                """

                case .CHAT_UPLOAD_PRESEND:
                    if let text = TranslationsRepo.find(.CHAT_UPLOAD_PRESEND) {
                        return text
                    }

                    return """
                Skicka
                """

                case .CHAT_UPLOADING_ANIMATION_TEXT:
                    if let text = TranslationsRepo.find(.CHAT_UPLOADING_ANIMATION_TEXT) {
                        return text
                    }

                    return """
                Laddar upp...
                """

                case .CHAT_GIPHY_TITLE:
                    if let text = TranslationsRepo.find(.CHAT_GIPHY_TITLE) {
                        return text
                    }

                    return """
                GIPHY
                """

                case .MY_INFO_CONTACT_DETAILS_TITLE:
                    if let text = TranslationsRepo.find(.MY_INFO_CONTACT_DETAILS_TITLE) {
                        return text
                    }

                    return """
                KONTAKTUPPGIFTER
                """

                case .MY_INFO_TITLE:
                    if let text = TranslationsRepo.find(.MY_INFO_TITLE) {
                        return text
                    }

                    return """
                Min info
                """

                case .PROFILE_MY_INFO_ROW_TITLE:
                    if let text = TranslationsRepo.find(.PROFILE_MY_INFO_ROW_TITLE) {
                        return text
                    }

                    return """
                Min info
                """

                case .NETWORK_ERROR_ALERT_TITLE:
                    if let text = TranslationsRepo.find(.NETWORK_ERROR_ALERT_TITLE) {
                        return text
                    }

                    return """
                Nätverksfel
                """

                case .NETWORK_ERROR_ALERT_MESSAGE:
                    if let text = TranslationsRepo.find(.NETWORK_ERROR_ALERT_MESSAGE) {
                        return text
                    }

                    return """
                Vi kunde inte nå Hedvig just nu, säker på att du har en internetuppkoppling?
                """

                case .NETWORK_ERROR_ALERT_TRY_AGAIN_ACTION:
                    if let text = TranslationsRepo.find(.NETWORK_ERROR_ALERT_TRY_AGAIN_ACTION) {
                        return text
                    }

                    return """
                Försök igen
                """

                case .NETWORK_ERROR_ALERT_CANCEL_ACTION:
                    if let text = TranslationsRepo.find(.NETWORK_ERROR_ALERT_CANCEL_ACTION) {
                        return text
                    }

                    return """
                Avbryt
                """

                case .PHONE_NUMBER_ROW_TITLE:
                    if let text = TranslationsRepo.find(.PHONE_NUMBER_ROW_TITLE) {
                        return text
                    }

                    return """
                Telefonnummer
                """

                case .PHONE_NUMBER_ROW_EMPTY:
                    if let text = TranslationsRepo.find(.PHONE_NUMBER_ROW_EMPTY) {
                        return text
                    }

                    return """
                Inget angett
                """

                case .PROFILE_MY_CHARITY_ROW_TITLE:
                    if let text = TranslationsRepo.find(.PROFILE_MY_CHARITY_ROW_TITLE) {
                        return text
                    }

                    return """
                Min välgörenhet
                """

                case .EMAIL_ROW_TITLE:
                    if let text = TranslationsRepo.find(.EMAIL_ROW_TITLE) {
                        return text
                    }

                    return """
                E-postadress
                """

                case .EMAIL_ROW_EMPTY:
                    if let text = TranslationsRepo.find(.EMAIL_ROW_EMPTY) {
                        return text
                    }

                    return """
                Inget angett
                """

                case .PROFILE_MY_PAYMENT_METHOD:
                    if let text = TranslationsRepo.find(.PROFILE_MY_PAYMENT_METHOD) {
                        return text
                    }

                    return """
                Betalas via autogiro
                """

                case .MY_PAYMENT_TITLE:
                    if let text = TranslationsRepo.find(.MY_PAYMENT_TITLE) {
                        return text
                    }

                    return """
                Min betalning
                """

                case .TAB_PROFILE_TITLE:
                    if let text = TranslationsRepo.find(.TAB_PROFILE_TITLE) {
                        return text
                    }

                    return """
                Profil
                """

                case .TAB_DASHBOARD_TITLE:
                    if let text = TranslationsRepo.find(.TAB_DASHBOARD_TITLE) {
                        return text
                    }

                    return """
                Min hemförsäkring
                """

                case .LICENSES_SCREEN_TITLE:
                    if let text = TranslationsRepo.find(.LICENSES_SCREEN_TITLE) {
                        return text
                    }

                    return """
                Licensrättigheter
                """

                case .ABOUT_SCREEN_TITLE:
                    if let text = TranslationsRepo.find(.ABOUT_SCREEN_TITLE) {
                        return text
                    }

                    return """
                Om appen
                """

                case .OTHER_SECTION_TITLE:
                    if let text = TranslationsRepo.find(.OTHER_SECTION_TITLE) {
                        return text
                    }

                    return """
                Annat
                """
                default: return String(describing: key)
            }
        }
    }

    struct en_SE {
        static func `for`(key: Localization.Key) -> String {
            switch key {

                case .OFFER_TITLE:
                    if let text = TranslationsRepo.find(.OFFER_TITLE) {
                        return text
                    }

                    return """
                Your home insurance
                """
                default: return String(describing: key)
            }
        }
    }
}

}
// swiftlint:enable identifier_name type_body_length type_name line_length nesting file_length
