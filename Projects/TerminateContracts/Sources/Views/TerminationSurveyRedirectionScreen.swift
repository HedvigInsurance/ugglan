import Kingfisher
import SwiftUI
import hCore
import hCoreUI

struct TerminationSurveyRedirectionScreen: View {
    let route: TerminationSurveyRedirectionRoute
    @EnvironmentObject var terminationFlowNavigationViewModel: TerminationFlowNavigationViewModel

    private var redirection: TerminationRedirection { route.redirection }

    var body: some View {
        hForm {
            content
        }
        .hFormTitle(
            title: .init(
                .small,
                .body2,
                L10n.terminationFlowCancellationTitle,
                alignment: .leading
            ),
            subTitle: .init(
                .small,
                .body2,
                L10n.terminationSurveyGenericSubtitle
            )
        )
        .hFormAlwaysAttachToBottom {
            hSection {
                VStack(spacing: .padding8) {
                    hButton(
                        .large,
                        .primary,
                        content: .init(title: redirection.actionText)
                    ) { [weak terminationFlowNavigationViewModel] in
                        terminationFlowNavigationViewModel?.handleRedirection(redirection)
                    }
                    hButton(
                        .large,
                        .secondary,
                        content: .init(title: L10n.terminationFlowContinueCancelling)
                    ) { [weak terminationFlowNavigationViewModel] in
                        terminationFlowNavigationViewModel?
                            .continueSurvey(option: route.option, comment: route.comment)
                    }
                }
            }
            .sectionContainerStyle(.transparent)
        }
    }

    private var content: some View {
        hSection {
            VStack(alignment: .leading, spacing: .padding8) {
                if let image = redirection.image, let imageUrl = URL(string: image.url) {
                    imageCard(url: imageUrl, overlayText: image.overlayText)
                }
                VStack(alignment: .leading, spacing: 2) {
                    hText(redirection.title, style: .body1)
                        .foregroundColor(hTextColor.Opaque.primary)
                    hText(redirection.description, style: .body1)
                        .foregroundColor(hTextColor.Translucent.secondary)
                }
                .accessibilityElement(children: .combine)
            }
            .padding(.top, .padding16)
        }
        .sectionContainerStyle(.transparent)
    }

    private func imageCard(url: URL, overlayText: String?) -> some View {
        KFImage(url)
            .fade(duration: 0.25)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 230)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusXL))
            .overlay(
                RoundedRectangle(cornerRadius: .cornerRadiusXL)
                    .strokeBorder(hBorderColor.primary, lineWidth: 1)
            )
            .overlay(alignment: .topLeading) {
                if let overlayText {
                    hPill(text: overlayText, color: .green)
                        .padding(.padding16)
                }
            }
            .accessibilityHidden(true)
    }
}

#Preview {
    Localization.Locale.currentLocale.send(.en_SE)
    let option = TerminationSurveyOption(
        id: "optionId",
        title: "I'm moving",
        feedbackRequired: false,
        suggestion: nil,
        redirection: .mock,
        subOptions: []
    )

    return NavigationView {
        TerminationSurveyRedirectionScreen(
            route: .init(option: option, comment: nil)!
        )
        .navigationBarTitleDisplayMode(.inline)
        .environmentObject(TerminationFlowNavigationViewModel(configs: [], terminateInsuranceViewModel: .init()))
    }
}
