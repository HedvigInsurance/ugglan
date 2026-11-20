import Foundation
import hCore

/// What a voice tool hands back to the ElevenLabs agent, as JSON: the engine's current step in a shape the agent's
/// LLM can turn into speech, plus an `instruction` saying what it may do with it. The engine stays the source of
/// every question; the agent only phrases them and maps the member's spoken answer back.
struct VoiceStepPayload: Encodable, Equatable {
    enum Status: String, Encodable {
        /// A step to ask now.
        case step
        /// The claim is submitted.
        case done
        /// Voice can't continue this claim; the agent says so and calls `hand_off_to_chat`.
        case handoff
        /// The engine is still working on the last answer; the agent fills the pause, then asks again.
        case processing
    }

    enum Kind: String, Encodable {
        case select
        case form
        case freeText = "free_text"
        case photos
        case notice
        case summary
        case none
    }

    struct Option: Encodable, Equatable {
        let id: String
        let label: String
        var subtitle: String? = nil
        /// For an option that is one of the member's policies: what it insures ("apartment (rented)").
        var covers: String? = nil
    }

    struct Field: Encodable, Equatable {
        let id: String
        let type: String
        let label: String
        let required: Bool
        let options: [Option]?
        let currentValues: [String]
        let min: String?
        let max: String?
        let suffix: String?
    }

    struct SummaryLine: Encodable, Equatable {
        let title: String
        let value: String
    }

    let status: Status
    let kind: Kind
    let stepId: String?
    let question: String?
    let skippable: Bool
    let options: [Option]?
    let fields: [Field]?
    let maxLength: Int?
    let summary: [SummaryLine]?
    var instruction: String
    /// Matches the app already searched for, for a step with a search field (see `note_story`).
    var searchResults: [Option]? = nil

    enum CodingKeys: String, CodingKey {
        case status, kind, question, skippable, options, fields, summary, instruction
        case searchResults = "search_results"
        case stepId = "step_id"
        case maxLength = "max_length"
    }

    static func handoff(reason: String) -> VoiceStepPayload {
        .init(
            status: .handoff,
            kind: .none,
            stepId: nil,
            question: nil,
            skippable: false,
            options: nil,
            fields: nil,
            maxLength: nil,
            summary: nil,
            instruction: """
                This claim continues in the app's chat (\(reason)). Tell the member warmly, in one or two sentences, \
                that you'll hand them over to the chat where everything they've said so far is saved. \
                Then call hand_off_to_chat.
                """
        )
    }

    /// The engine is still thinking about the member's last answer (a task step). The agent has already reacted to
    /// the answer (its one line before the tool call), so the first cue is silent; `again` is a pause long enough
    /// (10+ seconds) for one calm "just a moment" line.
    static func processing(again: Bool) -> VoiceStepPayload {
        .init(
            status: .processing,
            kind: .none,
            stepId: nil,
            question: nil,
            skippable: false,
            options: nil,
            fields: nil,
            maxLength: nil,
            summary: nil,
            instruction: again
                ? """
                Hedvig is still working on it; it's taking a little longer. Say one short, calm line, the way a \
                person noting things down would ("bear with me a second", "almost there", "just finishing this \
                bit"), worded differently from anything you've said before in this call. Nothing about waiting for \
                something, a next part or a next question, no question, nothing about the app. Then call \
                get_current_step.
                """
                : """
                Hedvig is still working on the answer. You've already reacted to it, so say nothing: call \
                get_current_step right away.
                """
        )
    }

    static let done = VoiceStepPayload(
        status: .done,
        kind: .none,
        stepId: nil,
        question: nil,
        skippable: false,
        options: nil,
        fields: nil,
        maxLength: nil,
        summary: nil,
        instruction: """
            The claim is submitted. In a calm, warm tone (not excited), thank the member, say a claims handler will \
            look at it and that they can follow it in the app. Do not promise any outcome, amount or timeline. Then \
            say goodbye. The call ends right after your goodbye, so make it your last sentence.
            """
    )
}

/// Turns the engine's typed steps into `VoiceStepPayload`s, and decides when a claim leaves voice.
enum VoiceStepAdapter {
    /// Triage option ids are the claims-service enum names (`ClaimSubmissionTriage.Category`, `.Subcategory`,
    /// `.ThingItem` in `InitialTriage.kt`). A select step offering any of these is a triage step.
    /// Hard-coded for the POC; it drifts if the backend adds triage options.
    static let triageOptionIds: Set<String> = [
        // Category
        "Things", "Home", "Travel", "Car", "Myself", "Family", "Dog", "Cat", "Employment", "QasaLandlord",
        // Subcategory
        "Burglary", "WhiteGoods", "Fire", "Water", "Glass", "Pest", "Fungus", "Liability", "Assault", "Legal",
        "IdProtection", "Evacuation", "BaggageDelay", "TravelDelay", "Phone", "Computer", "BikeTheft", "BikeDamaged",
        "BikeOther", "StrollerTheft", "StrollerDamaged", "StrollerOther", "ItemsTheft", "Accident", "Sickness",
        "Teeth", "CarTowing", "CarGlass", "CarOther", "Unemployment", "SickLeave",
        // ThingItem
        "Bike", "Stroller",
    ]

    /// Triage answers that can still reach an agent playbook (`*Playbook.matches` in claims-service): the
    /// categories leading to them, and water, fire, glass, appliance (WhiteGoods), burglary and items theft.
    static let playbookTriageOptionIds: Set<String> = [
        "Home", "Things", "Water", "Fire", "Glass", "WhiteGoods", "Burglary", "ItemsTheft",
    ]

    /// Whether answering `optionId` on `content` routes the claim away from the agent playbooks
    /// (a deterministic flow like bike or travel, a deflection, or "Other").
    static func leavesPlaybooks(content: ClaimIntentStepContent, optionId: String) -> Bool {
        guard case let .singleSelect(model) = content else { return false }
        let isTriageStep = model.options.contains { triageOptionIds.contains($0.id) }
        return isTriageStep && !playbookTriageOptionIds.contains(optionId)
    }

    /// `policies` maps the member's contract ids to what each one insures (`PolicyKind.describe`), so options
    /// that are policies say what building or thing they cover.
    static func payload(for intent: ClaimIntent, policies: [String: String] = [:]) -> VoiceStepPayload {
        let step = intent.currentStep
        let question = [step.text, intent.hint].compactMap { $0 }.joined(separator: "\n\n")
        func make(
            _ kind: VoiceStepPayload.Kind,
            question: String? = nil,
            options: [VoiceStepPayload.Option]? = nil,
            fields: [VoiceStepPayload.Field]? = nil,
            maxLength: Int? = nil,
            summary: [VoiceStepPayload.SummaryLine]? = nil,
            instruction: String
        ) -> VoiceStepPayload {
            // The tone lives in the prompt, but some models follow the step's own instruction far more closely,
            // so every step that asks the member something carries the reminder too.
            let asks: Set<VoiceStepPayload.Kind> = [.select, .form, .freeText, .photos]
            return .init(
                status: .step,
                kind: kind,
                stepId: step.id,
                question: question,
                skippable: intent.isSkippable,
                options: options,
                fields: fields,
                maxLength: maxLength,
                summary: summary,
                instruction: asks.contains(kind) ? Self.askLikeAFriend + " " + instruction : instruction
            )
        }

        switch step.content {
        case let .singleSelect(model):
            return make(
                .select,
                question: question,
                options: model.options.map { .init(id: $0.id, label: $0.title, covers: policies[$0.id]) },
                instruction: """
                    If what the member already told you (or confirmed in your recap) answers this, call \
                    answer_select right away with that option id; don't ask or confirm it again. Otherwise ask it in \
                    your own words, without reading the options as a menu unless they're unsure, and end your turn \
                    with the question: say nothing after it and call nothing. Once the member has answered, call \
                    answer_select with exactly one option id. \(Self.inferTheInsurance)
                    """
            )
        case let .form(model):
            return make(
                .form,
                question: question,
                fields: model.fields.map { field(from: $0, policies: policies) },
                instruction: """
                    Fill in every field the member already answered (or confirmed in your recap) without asking \
                    again; ask naturally only for what's missing, ending your turn with the question (nothing after \
                    it, no tool call) and waiting for the answer. If you inferred a value, remember it for your one \
                    combined double-check later; don't confirm it now. Dates are YYYY-MM-DD; resolve "yesterday" from \
                    today's date in your instructions. An approximate date is still an answer: turn "about a year and \
                    a half ago" or "last spring" into an estimate (the first of that month) and include it in your \
                    double-check; never send a date field empty when the member gave one. For a field of type \
                    "search", call search_field with what \
                    the member said and talk about the matches the way a person would: brand and model names are \
                    fine, but never read out model numbers or codes like "GBB62BLGGC"; if they don't know the \
                    exact model, use the match marked "model unknown" (or skip_step if there's none), never an \
                    empty field. For a phone number, read it back once and let them confirm or correct it, \
                    even if it's already filled in. For select fields use the option ids. \
                    \(Self.inferTheInsurance) Then call answer_form with every field.
                    """
            )
        case let .audioRecording(model):
            return make(
                .freeText,
                question: question,
                maxLength: model.freeTextMaxLength,
                instruction: """
                    If this asks what happened and the member has already told you their story, don't ask them to \
                    repeat it: call answer_free_text right away, and the app sends their story in their own words. \
                    Otherwise ask it openly and end your turn with the question: say nothing after it and call \
                    nothing. Once the member has answered, call answer_free_text. The app sends the member's own \
                    transcribed words, so don't summarise; pass what they said.
                    """
            )
        case .fileUpload:
            return make(
                .photos,
                question: question,
                instruction: """
                    Always ask this, even if the member mentioned photos earlier: ask if they can add photos or \
                    documents for this. If yes, call request_photos straight away, before saying anything about \
                    it. Only if \
                    they say, to this question, that they can't now, call skip_step and say they can add files to \
                    the claim later in the app.
                    """
            )
        case let .information(model):
            return make(
                .notice,
                question: model.notice,
                instruction: """
                    This is important advice from Hedvig. Keep every instruction and fact in it, but say it gently, \
                    like a friend passing on a tip. Then wait for the member to respond, and only then call \
                    acknowledge_notice.
                    """
            )
        case let .summary(model):
            let lines = (model.keyDetails.isEmpty ? model.items : model.keyDetails)
                .map { VoiceStepPayload.SummaryLine(title: $0.title, value: $0.value) }
            return make(
                .summary,
                question: question,
                summary: lines,
                instruction: """
                    Call show_summary straight away, before saying anything about it: the summary opens on screen \
                    and the member taps to submit. Never submit for them.
                    """
            )
        case .task:
            // VoiceClaimToolbox advances task steps itself; reaching here means the engine is still working.
            return make(
                .none,
                instruction:
                    "Hedvig is still working on it. Say nothing; call get_current_step right away."
            )
        case .deflect, .deflectMessage:
            return .handoff(reason: "the member is redirected to another kind of help")
        }
    }

    /// Which insurance, home or policy: members rarely name the policy, but usually say enough to pick it.
    static let inferTheInsurance = """
        When the choice is which insurance, home or policy it's about, work it out from what the member said instead \
        of asking: each such option's `covers` says what it insures (an apartment, a house or villa, a vacation \
        home, a car, a pet). "My apartment" is the option that covers an apartment, "my villa" or "my house" the one \
        that covers a house. Pick it without asking and mention it in your one double-check. Ask only if what they \
        said fits more than one option, or none.
        """

    /// How to ask any question: the engine's wording is a form's, the agent's should be a friend's.
    static let askLikeAFriend = """
        `question` is the engine's form wording, not yours: never read it out as written. When you ask it, put it \
        the way a friend helping out on the phone would: soft and warm, in your own everyday words, with a short \
        reason it matters, a gentle reminder or a soft check on how far they've got. Keep it neutral and short.
        """

    private static func field(
        from model: ClaimIntentStepContentForm.ClaimIntentStepContentFormField,
        policies: [String: String]
    ) -> VoiceStepPayload.Field {
        let type: String = {
            switch model.type {
            case .text: return "text"
            case .date: return "date"
            case .number: return "number"
            case .phoneNumber: return "phone_number"
            case .singleSelect: return "single_select"
            case .multiSelect: return "multi_select"
            case .binary: return "binary"
            case .search: return "search"
            }
        }()
        let options = model.options.map {
            VoiceStepPayload.Option(id: $0.value, label: $0.title, subtitle: $0.subtitle, covers: policies[$0.value])
        }
        return .init(
            id: model.id,
            type: type,
            label: model.title,
            required: model.isRequired,
            options: options.isEmpty ? nil : options,
            currentValues: model.currentValues.isEmpty ? model.defaultValues : model.currentValues,
            min: model.minValue,
            max: model.maxValue,
            suffix: model.suffix
        )
    }
}

/// What a policy insures, in words the agent can match to what the member says ("my apartment", "my villa").
enum PolicyKind {
    static func describe(_ type: TypeOfContract) -> String? {
        switch type {
        case .seApartmentRent, .seApartmentRentBas, .seApartmentRentMax, .seGroupApartmentRent:
            return "apartment (rented)"
        case .seApartmentBrf, .seApartmentBrfBas, .seApartmentBrfMax, .seGroupApartmentBrf:
            return "apartment (owned, bostadsrätt)"
        case .seApartmentStudentRent: return "student apartment (rented)"
        case .seApartmentStudentBrf: return "student apartment (owned, bostadsrätt)"
        case .seHouse, .seHouseBas, .seHouseMax: return "house or villa"
        case .seVacationHome: return "vacation home or summer house"
        case .seQasaShortTermRental, .seQasaLongTermRental: return "home rented out through Qasa"
        case .seQasaLandlord: return "property the member rents out (landlord)"
        case .seCarTraffic, .seCarHalf, .seCarFull, .seCarTrialHalf, .seCarTrialFull, .seCarDecommisioned:
            return "car"
        case .seDogBasic, .seDogStandard, .seDogPremium: return "dog"
        case .seCatBasic, .seCatStandard, .seCatPremium: return "cat"
        case .seAccident, .seAccidentStudent: return "accident insurance for a person"
        case .sePaymentProtection: return "payment protection"
        case .unknown: return nil
        }
    }
}
