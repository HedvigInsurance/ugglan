import hCore

/// The voice POC's few UI strings, in the app's two locales.
/// TODO(voice-claim): move to Lokalise and `L10n` before the flag is opened beyond internal users.
@MainActor
enum VoiceClaimStrings {
    private static func text(sv: String, en: String) -> String {
        Localization.Locale.currentLocale.value == .sv_SE ? sv : en
    }

    static var talkItThrough: String { text(sv: "Berätta med rösten", en: "Talk it through") }
    static var typeItOut: String { text(sv: "Skriv i chatten", en: "Type it out") }
    static var connecting: String { text(sv: "Ringer upp…", en: "Connecting…") }
    static var listening: String { text(sv: "Jag lyssnar", en: "Listening") }
    static var thinking: String { text(sv: "Ett ögonblick…", en: "One moment…") }
    static var speaking: String { text(sv: "Hedvig pratar", en: "Hedvig is speaking") }
    static var muted: String { text(sv: "Mikrofonen är av", en: "Your microphone is off") }
    static var mute: String { text(sv: "Ljud av", en: "Mute") }
    static var unmute: String { text(sv: "Ljud på", en: "Unmute") }
    static var endCall: String { text(sv: "Lägg på", en: "End call") }
    static var switchToTyping: String { text(sv: "Fortsätt i chatten", en: "Switch to typing") }
    static var callEnded: String {
        text(
            sv: "Samtalet bröts. Det du har berättat är sparat.",
            en: "The call ended. What you've told us is saved."
        )
    }
    static var title: String { text(sv: "Anmäl skada", en: "Report a claim") }
    static var orbAccessibilityLabel: String { text(sv: "Röstsamtal med Hedvig", en: "Voice call with Hedvig") }
}
