import Foundation

final class SubmitChatStepModel: ObservableObject, Identifiable {
    var id: String { "\(step.id)-\(sender)" }
    let step: ClaimIntentStep
    let sender: SubmitClaimChatMesageSender
    @Published var isLoading: Bool
    @Published var isEnabled: Bool

    init(step: ClaimIntentStep, sender: SubmitClaimChatMesageSender, isLoading: Bool, isEnabled: Bool = true) {
        self.step = step
        self.sender = sender
        self.isLoading = isLoading
        self.isEnabled = isEnabled
    }
}

struct SingleItemModel: Equatable, Identifiable {
    static func == (lhs: SingleItemModel, rhs: SingleItemModel) -> Bool { lhs.id == rhs.id }
    let id: String
    let values: [SingleSelectValue]
}

enum SubmitClaimChatMesageSender {
    case hedvig
    case member
}
