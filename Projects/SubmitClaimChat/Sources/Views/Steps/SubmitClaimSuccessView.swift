import Claims
import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimSuccessView: View {
    private let model: ClaimIntentOutcomeClaim
    @StateObject fileprivate var vm = SubmitClaimSuccessViewModel()
    @EnvironmentObject var navigationVm: SubmitClaimChatViewModel

    public init(
        model: ClaimIntentOutcomeClaim,
    ) {
        self.model = model
    }

    public var body: some View {
        hSection {
            VStack(spacing: .padding16) {
                hText(vm.titleText, style: .heading2)
                hFloatingTextField(
                    masking: Masking(type: .digits),
                    value: $vm.phoneNumber,
                    equals: $vm.type,
                    focusValue: .phoneNumber,
                    placeholder: L10n.phoneNumberRowTitle,
                    error: $vm.phoneNumberError
                )
                hButton(
                    .large,
                    .primary,
                    content: .init(
                        title: L10n.generalSaveButton
                    ),
                    {
                        vm.submitPhoneNumber()
                    }
                )
                .hButtonIsLoading(vm.state == .loading)
                hText("Your claim was submitted successfully")
                hButton(.medium, .secondary, content: .init(title: "Go to claim")) {
                    navigationVm.goToClaimDetails(model.claimId)
                }
            }
            .padding(.top, .padding8)
        }
        .trackErrorState(for: $vm.state)
        .hStateViewButtonConfig(
            .init(
                actionButton: .init(
                    buttonTitle: L10n.generalRetry,
                    buttonAction: {
                        Task {
                            await vm.fetchMemberPhone()
                        }
                    }
                )
            )
        )
        .sectionContainerStyle(.transparent)
    }
}

@MainActor
private class SubmitClaimSuccessViewModel: ObservableObject {
    @Inject var memberClient: ClaimIntentMemberClient
    @Published var state = ProcessingState.loading
    @Published var phoneNumber = ""
    @Published var type: ClaimsFlowContactType? = nil
    @Published var phoneNumberError: String?
    @Published var titleText = "Make sure we have right phone number in the case we need to contact you"
    init() {
        Task {
            await fetchMemberPhone()
        }
    }

    @MainActor
    func fetchMemberPhone() async {
        state = .loading
        do {
            let phoneNumber = try await memberClient.fetchPhoneNumber()
            if let phoneNumber {
                self.phoneNumber = phoneNumber
                titleText = "Make sure we have right phone number in the case we need to contact you"
            } else {
                titleText = "Please provide phone number in the case we need to contact you"
            }
            state = .success
        } catch {
            state = .error(errorMessage: error.localizedDescription)
        }
    }

    func submitPhoneNumber() {
        state = .loading
        Task {
            do {
                try await memberClient.updatePhoneNumber(phoneNumber: phoneNumber)
                state = .success
            } catch {
                state = .error(errorMessage: error.localizedDescription)
            }
        }
    }

    enum ClaimsFlowContactType: hTextFieldFocusStateCompliant {
        static var last: ClaimsFlowContactType {
            ClaimsFlowContactType.phoneNumber
        }

        var next: ClaimsFlowContactType? {
            switch self {
            default:
                return nil
            }
        }

        case phoneNumber
    }
}

#Preview {
    Localization.Locale.currentLocale.send(.en_SE)
    let demo = ClaimIntentClientDemo()
    Dependencies.shared.add(module: Module { () -> ClaimIntentClient in demo })
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    Dependencies.shared.add(module: Module { () -> ClaimIntentMemberClient in ClaimIntentMemberClientDemo() })

    let model = ClaimIntentOutcomeClaim(
        claimId: "claimId",
        claim: .init(
            id: "id",
            status: .beingHandled,
            outcome: nil,
            submittedAt: nil,
            signedAudioURL: nil,
            memberFreeText: nil,
            payoutAmount: nil,
            targetFileUploadUri: "",
            claimType: "",
            productVariant: nil,
            conversation: nil,
            appealInstructionsUrl: nil,
            isUploadingFilesEnabled: false,
            showClaimClosedFlow: false,
            infoText: nil,
            displayItems: []
        )
    )
    return SubmitClaimSuccessView(
        model: model
    )
    .environmentObject(
        SubmitClaimChatViewModel.init(
            input: .init(sourceMessageId: nil),
            goToClaimDetails: { _ in
            },
            openChat: {
            }
        )
    )
}
