import Apollo
import SwiftUI
import hCore
import hCoreUI

public struct DeleteRequestLoadingView: View {
    var profileService = ProfileService()
    @EnvironmentObject var router: Router
    private var dismissAction: (ProfileNavigationDismissAction) -> Void

    public init(
        screenState: ScreenState,
        dismissAction: @escaping (ProfileNavigationDismissAction) -> Void
    ) {
        self.screenState = screenState
        self.dismissAction = dismissAction
    }

    public enum ScreenState: Hashable {
        case tryToDelete(with: MemberDetails)
        case success
        case error(errorMessage: String)
    }

    @State var screenState: ScreenState

    @ViewBuilder var sendingState: some View {
        VStack {
            DotsActivityIndicator(.standard).useDarkColor
        }
    }

    @ViewBuilder private var successState: some View {
        hForm {
            VStack(spacing: 0) {
                hCoreUIAssets.checkmark.view
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(hSignalColor.Green.element)
                    .padding(.bottom, .padding16)
                hText(L10n.DeleteAccount.processedTitle, style: .body1)
                    .foregroundColor(hTextColor.Opaque.primary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, .padding32)
        }
        .hFormContentPosition(.center)
        .hFormAttachToBottom {
            hSection {
                hCloseButton {
                    router.dismiss()
                    dismissAction(.makeHomeTabActive)
                }
            }
            .sectionContainerStyle(.transparent)
        }
    }

    @ViewBuilder private func errorState(errorMessage: String) -> some View {
        GenericErrorView(
            description: errorMessage,
            formPosition: .center
        )
        .hStateViewButtonConfig(
            .init(
                actionButton: .init(
                    buttonAction: {
                        dismissAction(.makeHomeTabActive)
                    }
                )
            )
        )
    }

    public var body: some View {
        switch screenState {
        case let .tryToDelete(memberDetails):
            sendingState
                .onAppear {
                    Task {
                        await sendSlackMessage(details: memberDetails)
                    }
                }
        case .success:
            successState
        case let .error(errorMessage):
            errorState(errorMessage: errorMessage)
        }
    }

    @MainActor
    private func sendSlackMessage(details: MemberDetails) async {
        do {
            try await profileService.postDeleteRequest()
            ApolloClient.saveDeleteAccountStatus(for: details.id)
            screenState = .success
        } catch {
            screenState = .error(errorMessage: L10n.General.errorBody)
        }
    }
}

#Preview {
    DeleteRequestLoadingView(screenState: .success, dismissAction: { _ in })
}
