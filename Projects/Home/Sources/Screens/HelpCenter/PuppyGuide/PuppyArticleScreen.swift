import Kingfisher
import SwiftUI
import hCore
import hCoreUI

struct PuppyArticleScreen: View {
    @State private var vm: PuppyArticleViewModel

    init(id: String) {
        _vm = State(initialValue: PuppyArticleViewModel(id: id))
    }

    var body: some View {
        hForm {
            if let story = vm.story {
                content(for: story)
                    .transition(.opacity)
            }
        }
        .animation(.smooth(duration: 0.3), value: vm.story != nil)
        .loading(.constant(vm.viewState))
        .hStateViewButtonConfig(
            .init(
                actionButton: .init(buttonAction: {
                    Task { await vm.load() }
                }),
                dismissButton: nil
            )
        )
        .task { await vm.load() }
    }

    private func content(for story: PuppyGuideStory) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            hFillColor.Opaque.disabled
                .aspectRatio(16 / 9, contentMode: .fit)
                .frame(maxWidth: .infinity)
                .overlay {
                    KFImage(story.imageUrl)
                        .fade(duration: 0.25)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
                .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusM))
                .accessibilityHidden(true)
                .padding(.top, .padding8)
                .padding(.bottom, .padding16)
            hText(story.title, style: .heading2)
                .accessibilityAddTraits(.isHeader)
                .padding(.bottom, .padding4)
            hText(story.subtitle, style: .label)
                .foregroundColor(hTextColor.Translucent.secondary)
                .padding(.bottom, .padding24)
            MarkdownView(
                config: .init(
                    text: story.content,
                    fontStyle: .body1,
                    color: hTextColor.Translucent.secondary,
                    linkColor: hTextColor.Opaque.primary,
                    linkUnderlineStyle: .single,
                    isSelectable: false
                ) { url in
                    NotificationCenter.default.post(name: .openDeepLink, object: url)
                }
            )
            .padding(.bottom, .padding48)
            hText(L10n.puppyGuideRatingQuestion)
                .padding(.bottom, .padding16)
            PuppyArticleRatingSection(selectedRating: story.rating) { rating in
                Task { await vm.rate(rating) }
            }
            .padding(.bottom, .padding16)
            Color.clear
                .frame(height: 1)
                .onScrolledIntoView {
                    Task { await vm.markAsRead() }
                }
        }
        .padding(.horizontal, .padding16)
    }
}

private struct PuppyArticleRatingSection: View {
    let selectedRating: Int?
    let onRatingTap: (Int) -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: .padding8) {
            HStack(spacing: .padding6) {
                ForEach(1...5, id: \.self) { rating in
                    ratingButton(rating)
                }
            }
            HStack(alignment: .top, spacing: .padding8) {
                hText(L10n.puppyGuideRatingNotHelpful, style: .label)
                Spacer()
                hText(L10n.puppyGuideRatingVeryHelpful, style: .label)
                    .multilineTextAlignment(.trailing)
            }
            .foregroundColor(hTextColor.Translucent.secondary)
            .accessibilityHidden(true)
        }
        .sensoryFeedback(.selection, trigger: selectedRating)
    }

    private func ratingButton(_ rating: Int) -> some View {
        let isSelected = selectedRating == rating
        return Button {
            onRatingTap(rating)
        } label: {
            hText("\(rating)", style: .body1)
                .foregroundColor(isSelected ? hTextColor.Opaque.black : hTextColor.Translucent.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, .padding16)
                .background(
                    RoundedRectangle(cornerRadius: .cornerRadiusL)
                        .fill(isSelected ? hSignalColor.Green.fill : hSurfaceColor.Opaque.primary)
                )
                .scaleEffect(isSelected && !reduceMotion ? 1.06 : 1)
                .animation(.bouncy(duration: 0.35, extraBounce: 0.1), value: isSelected)
        }
        .buttonStyle(PuppyGuidePressableButtonStyle())
        .accessibilityLabel(accessibilityLabel(for: rating))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func accessibilityLabel(for rating: Int) -> String {
        switch rating {
        case 1: "\(rating), \(L10n.puppyGuideRatingNotHelpful)"
        case 5: "\(rating), \(L10n.puppyGuideRatingVeryHelpful)"
        default: "\(rating)"
        }
    }
}

extension View {
    fileprivate func onScrolledIntoView(perform action: @escaping () -> Void) -> some View {
        modifier(ScrolledIntoViewModifier(action: action))
    }
}

private struct ScrolledIntoViewModifier: ViewModifier {
    let action: () -> Void
    @State private var didFire = false

    func body(content: Content) -> some View {
        content.onGeometryChange(for: Bool.self) { proxy in
            guard let visibleBounds = proxy.bounds(of: .scrollView) else { return false }
            return visibleBounds.intersects(CGRect(origin: .zero, size: proxy.size))
        } action: { isVisible in
            guard isVisible, !didFire else { return }
            didFire = true
            action()
        }
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> PuppyGuideClient in PuppyGuideClientDemo() })
    Dependencies.shared.add(module: Module { () -> FeatureFlags in FeatureFlags.shared })
    Dependencies.shared.add(module: Module { () -> FeatureFlagsClient in FeatureFlagsDemo() })
    Dependencies.shared.add(module: Module { () -> HomeClient in HomeClientDemo() })
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    return PuppyArticleScreen(id: "puppy-training")
}
