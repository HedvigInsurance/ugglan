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
    }

    struct Translations {
        struct sv_SE {
            static func `for`(key: Localization.Key) -> String {
                switch key {
                case .OFFER_TITLE: return """
                Försäkringsförslag
                """

                case .OFFER_SUMMARY_PRICE_LABEL: return """
                kr/mån
                """

                case .OFFER_BUBBLES_BINDING_PERIOD_TITLE: return """
                Bindningstid
                """

                case .OFFER_BUBBLES_BINDING_PERIOD_SUBTITLE: return """
                Nope, så jobbar inte Hedvig
                """

                case .OFFER_BUBBLES_DEDUCTIBLE_TITLE: return """
                Självrisk
                """

                case .OFFER_BUBBLES_DEDUCTIBLE_SUBTITLE: return """
                1500 kr
                """

                case .OFFER_BUBBLES_INSURED_TITLE: return """
                Försäkrade
                """

                case .OFFER_BUBBLES_INSURED_SUBTITLE: return """
                {personsInHousehold} personer
                """

                case .OFFER_BUBBLES_START_DATE_TITLE: return """
                Startdatum
                """

                case .OFFER_BUBBLES_START_DATE_SUBTITLE_SWITCHER: return """
                Så fort din bindningstid går ut
                """

                case .OFFER_BUBBLES_START_DATE_SUBTITLE_NEW: return """
                idag
                """

                case .OFFER_BUBBLES_TRAVEL_PROTECTION_TITLE: return """
                Reseskydd ingår
                """

                case .OFFER_BUBBLES_OWNED_ADDON_TITLE: return """
                Bostadsrätts- tillägg ingår
                """

                case .OFFER_SIGN_BUTTON: return """
                Skaffa Hedvig
                """

                case .OFFER_SCROLL_HEADER: return """
                Vad Hedvig täcker
                """

                case .OFFER_CHAT_HEADER: return """
                Prata med Hedvig
                """

                case .OFFER_GET_HEDVIG_TITLE: return """
                Redo?
                """

                case .OFFER_GET_HEDVIG_BODY: return """
                Skaffa Hedvig genom att klicka på knappen nedan och signera med BankID.
                """

                case .OFFER_APARTMENT_PROTECTION_DESCRIPTION: return """
                Vi vet hur mycket ett hem betyder. Därför ger vi det ett riktigt bra skydd, så att du kan känna dig trygg i alla lägen.
                """

                case .OFFER_APARTMENT_PROTECTION_TITLE: return """
                {address}
                """

                case .OFFER_STUFF_PROTECTION_TITLE: return """
                Dina prylar
                """

                case .OFFER_STUFF_PROTECTION_DESCRIPTION: return """
                Med Hedvig får du ett komplett skydd för dina prylar. Drulleförsäkring ingår och täcker prylar värda upp till {protectionAmount} styck.
                """

                case .STUFF_PROTECTION_AMOUNT: return """
                50 000 kr
                """

                case .STUFF_PROTECTION_AMOUNT_STUDENT: return """
                25 000 kr
                """

                case .OFFER_PERSONAL_PROTECTION_TITLE: return """
                Dig
                """

                case .OFFER_PERSONAL_PROTECTION_DESCRIPTION: return """
                Hedvig skyddar dig mot obehagliga saker som kan hända på hemmaplan, och det mesta som kan hända när du är ute och reser.
                """

                case .OFFER_PERILS_EXPLAINER: return """
                Tryck på ikonerna för mer info
                """

                case .TRUSTLY_PAYMENT_SETUP_MESSAGE: return """
                För att din försäkring ska gälla framöver behöver du koppla autogiro från ditt bankkonto. Vi sköter det via Trustly.
                """

                case .TRUSTLY_PAYMENT_SETUP_ACTION: return """
                Sätt upp betalning
                """

                case .CASHBACK_NEEDS_SETUP_MESSAGE: return """
                Du har ännu inte valt din välgörenhets organisation
                """

                case .CASHBACK_NEEDS_SETUP_ACTION: return """
                Välj välgörenhetsorganisation
                """

                case .CASHBACK_NEEDS_SETUP_OVERLAY_TITLE: return """
                Välj välgörenhetsorganisation
                """

                case .CASHBACK_NEEDS_SETUP_OVERLAY_PARAGRAPH: return """
                Välj vilken välgörenhet du vill att din andel av årets överskott ska gå till.
                """

                case .PAYMENT_SUCCESS_TITLE: return """
                Autogirot aktivt
                """

                case .PAYMENT_SUCCESS_BODY: return """
                Hedvig kommer att synas på ditt kontoutdrag när vi tar betalt varje månad.
                """

                case .PAYMENT_SUCCESS_BUTTON: return """
                Klar
                """

                case .PAYMENT_FAILURE_TITLE: return """
                Något gick fel
                """

                case .PAYMENT_FAILURE_BODY: return """
                 Inga pengar kommer att dras.
                Du kan gå tillbaka för att försöka igen.
                """

                case .PAYMENT_FAILURE_BUTTON: return """
                Gå tillbaka
                """

                case .DASHBOARD_BANNER_ACTIVE_TITLE: return """
                Hej {firstName}!
                """

                case .DASHBOARD_BANNER_ACTIVE_INFO: return """
                Din försäkring är aktiv
                """

                case .DASHBOARD_HAVE_START_DATE_BANNER_TITLE: return """
                Din försäkring aktiveras om:
                """

                case .DASHBOARD_READMORE_HAVE_START_DATE_TEXT: return """
                Du är fortfarande försäkrad hos ditt tidigare försäkringsbolag. Vi har påbörjat flytten och den {date} aktiveras din försäkring hos Hedvig!
                """

                case .DASHBOARD_BANNER_MONTHS: return """
                M
                """

                case .DASHBOARD_BANNER_DAYS: return """
                D
                """

                case .DASHBOARD_BANNER_HOURS: return """
                H
                """

                case .DASHBOARD_BANNER_MINUTES: return """
                M
                """

                case .DASHBOARD_MORE_INFO_BUTTON_TEXT: return """
                Mer info
                """

                case .DASHBOARD_NOT_STARTED_BANNER_TITLE: return """
                Din försäkring är på gång!
                """

                case .DASHBOARD_READMORE_NOT_STARTED_TEXT: return """
                Du är fortfarande försäkrad hos ditt tidigare försäkringsbolag. Vi har påbörjat flytten till Hedvig och informerar dig så fort vi vet aktiveringsdatumet!
                """

                case .DASHBOARD_LESS_INFO_BUTTON_TEXT: return """
                Mindre info
                """

                case .FILE_UPLOAD_ERROR: return """
                Du gav oss inte tillgång till ditt bildbibliotek, vi kan därför inte visa dina bilder här. Gå till inställningar för att ge oss tillgång till ditt bildbibliotek.
                """

                case .FILE_UPLOAD_ERROR_RETRY_BUTTON: return """
                Försök igen
                """

                case .DASHBOARD_BANNER_TERMINATED_INFO: return """
                Din försäkring är inaktiv
                """

                case .RESTART_OFFER_CHAT_TITLE: return """
                Vill du börja om?
                """

                case .RESTART_OFFER_CHAT_PARAGRAPH: return """
                Om du trycker ja börjar konversationen om och ditt nuvarande förslag försvinner
                """

                case .RESTART_OFFER_CHAT_BUTTON_CONFIRM: return """
                Ja
                """

                case .RESTART_OFFER_CHAT_BUTTON_DISMISS: return """
                Nej
                """

                case .DASHBOARD_DEDUCTIBLE_FOOTNOTE: return """
                Din självrisk är 1 500 kr
                """

                case .DASHBOARD_OWNER_FOOTNOTE: return """
                Lägenheten försäkras till sitt fulla värde
                """

                case .DASHBOARD_PERILS_CATEGORY_INFO: return """
                Klicka på ikonerna för mer info
                """

                case .DASHBOARD_TRAVEL_FOOTNOTE: return """
                Gäller på resor varsomhelst i världen
                """

                case .PROFILE_CACHBACK_ROW: return """
                Min välgörenhet
                """

                case .PROFILE_INSURANCE_ADDRESS_ROW: return """
                Mitt hem
                """

                case .PROFILE_INSURANCE_CERTIFICATE_ROW_HEADER: return """
                Mitt försäkringsbrev
                """

                case .PROFILE_INSURANCE_CERTIFICATE_ROW_TEXT: return """
                Tryck för att läsa
                """

                case .PROFILE_PAYMENT_ROW_HEADER: return """
                Min betalning
                """

                case .PROFILE_PAYMENT_ROW_TEXT: return """
                {price} kr/månad. Betalas via autogiro
                """

                case .PROFILE_SAFETYINCREASERS_ROW_HEADER: return """
                Mina trygghetshöjare
                """

                case .DASHBOARD_INSURANCE_AMOUNT_FOOTNOTE: return """
                Prylarna försäkras totalt till {student} kr
                """

                case .CHAT_GIPHY_PICKER_NO_SEARCH_TEXT: return """
                Oh no, ingen GIF för denna sökning...
                """

                case .CHAT_GIPHY_PICKER_TEXT: return """
                Sök på något för att få upp GIFar!
                """

                case .CHAT_COULD_NOT_LOAD_FILE: return """
                Kunde inte ladda fil...
                """

                case .CHAT_FILE_LOADING: return """
                Laddar...
                """

                case .CHAT_FILE_DOWNLOAD: return """
                Ladda ner fil
                """

                case .AUDIO_INPUT_REDO: return """
                Gör om
                """

                case .AUDIO_INPUT_SAVE: return """
                Spara
                """

                case .AUDIO_INPUT_PLAY: return """
                Spela upp
                """

                case .CHAT_FILE_UPLOADED: return """
                fil uppladdad
                """

                case .AUDIO_INPUT_RECORDING: return """
                Spelar in:
                """

                case .GIF_BUTTON_TITLE: return """
                GIF
                """

                case .CHAT_UPLOAD_PRESEND: return """
                Skicka
                """

                case .CHAT_UPLOADING_ANIMATION_TEXT: return """
                Laddar upp...
                """

                case .CHAT_GIPHY_TITLE: return """
                GIPHY
                """

                case .MY_INFO_CONTACT_DETAILS_TITLE: return """
                KONTAKTUPPGIFTER
                """

                case .MY_INFO_TITLE: return """
                Min info
                """

                case .PROFILE_MY_INFO_ROW_TITLE: return """
                Min info
                """
                default: return String(describing: key)
                }
            }
        }

        struct en_SE {
            static func `for`(key: Localization.Key) -> String {
                switch key {
                case .OFFER_TITLE: return """
                Your home insurance
                """
                default: return String(describing: key)
                }
            }
        }
    }
}

// swiftlint:enable identifier_name type_body_length type_name line_length nesting file_length
