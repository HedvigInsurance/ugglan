import Kingfisher
import SwiftUI
import hCore
import hCoreUI

struct PuppyGuideScreen: View {
    @Environment(NavigationRouter.self) private var router
    @State private var vm = PuppyGuideViewModel()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AccessibilityFocusState private var focusedCategory: String?

    var body: some View {
        ScrollViewReader { proxy in
            hForm {
                if let puppyGuide = vm.puppyGuide {
                    content(for: puppyGuide, scrollProxy: proxy)
                        .transition(.opacity.combined(with: .offset(y: reduceMotion ? 0 : 16)))
                }
            }
            .animation(.smooth(duration: 0.4), value: vm.puppyGuide != nil)
        }
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

    private func content(for puppyGuide: PuppyGuide, scrollProxy: ScrollViewProxy) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(.top, .padding8)
                .padding(.bottom, .padding48)
                .withSectionPadding()
            categoriesRow(puppyGuide.categories, scrollProxy: scrollProxy)
                .padding(.bottom, .padding24)
            ForEach(puppyGuide.categories, id: \.self) { category in
                PuppyGuideCategorySection(
                    category: category,
                    stories: puppyGuide.stories(in: category),
                    focusedCategory: $focusedCategory
                ) { story in
                    router.push(PuppyGuideRoute.article(id: story.id))
                }
                .id(category)
                .padding(.bottom, .padding48)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: .padding8) {
            hCoreUIAssets.hundarBadarPet.view
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusXL))
                .accessibilityHidden(true)
                .padding(.bottom, .padding8)
            hText(L10n.puppyGuideTitle)
                .accessibilityAddTraits(.isHeader)
            hText(L10n.puppyGuideInfo)
                .foregroundColor(hTextColor.Opaque.secondary)
        }
    }

    private func categoriesRow(_ categories: [String], scrollProxy: ScrollViewProxy) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: .padding8) {
                ForEach(categories, id: \.self) { category in
                    hButton(.medium, .secondary, content: .init(title: category)) {
                        withAnimation {
                            scrollProxy.scrollTo(category, anchor: .top)
                        }
                        focusedCategory = category
                    }
                }
            }
        }
        .withSectionContentPadding()
    }
}

private struct PuppyGuideCategorySection: View {
    let category: String
    let stories: [PuppyGuideStory]
    let focusedCategory: AccessibilityFocusState<String?>.Binding
    let onStoryTap: (PuppyGuideStory) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: .padding12) {
            hText(category, style: .heading2)
                .accessibilityAddTraits(.isHeader)
                .accessibilityFocused(focusedCategory, equals: category)
                .withSectionPadding()
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: .padding24) {
                    ForEach(stories) { story in
                        PuppyGuideStoryItem(story: story) {
                            onStoryTap(story)
                        }
                    }
                }
            }
            .withSectionContentPadding()
        }
    }
}

private struct PuppyGuideStoryItem: View {
    let story: PuppyGuideStory
    let onTap: () -> Void
    private let size: CGFloat = 148

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                image
                    .padding(.bottom, .padding8)
                hText(story.title, style: .label)
                    .multilineTextAlignment(.leading)
                hText(story.subtitle, style: .label)
                    .foregroundColor(hTextColor.Translucent.secondary)
                    .multilineTextAlignment(.leading)
            }
            .frame(width: size, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(PuppyGuidePressableButtonStyle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(.isButton)
    }

    private var image: some View {
        KFImage(story.imageUrl)
            .placeholder { hFillColor.Opaque.disabled }
            .fade(duration: 0.25)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .accessibilityHidden(true)
            .frame(width: size, height: size)
            .overlay(alignment: .topTrailing) {
                if story.showsAsRead {
                    ZStack(alignment: .topTrailing) {
                        Color.black.opacity(0.4)
                        PuppyGuideReadLabel()
                            .padding(.padding12)
                            .transition(.scale(scale: 0.6, anchor: .topTrailing).combined(with: .opacity))
                    }
                    .transition(.opacity)
                }
            }
            .animation(.bouncy(duration: 0.4), value: story.showsAsRead)
            .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusM))
    }

    private var accessibilityLabel: String {
        let base = "\(story.title), \(story.subtitle)"
        return story.showsAsRead ? "\(base). \(L10n.a11YReadLabelHack)" : base
    }
}

private struct PuppyGuideReadLabel: View {
    var body: some View {
        HStack(spacing: .padding2) {
            hText(L10n.puppyGuideLabelRead, style: .label)
            hCoreUIAssets.checkmark.view
                .resizable()
                .frame(width: 20, height: 20)
        }
        .foregroundColor(hTextColor.Opaque.primary)
        .padding(.horizontal, .padding8)
        .padding(.vertical, .padding2)
        .background(
            RoundedRectangle(cornerRadius: .cornerRadiusXS)
                .fill(hSurfaceColor.Opaque.primary)
        )
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> PuppyGuideClient in PuppyGuideClientDemo() })
    Dependencies.shared.add(module: Module { () -> FeatureFlagsClient in FeatureFlagsDemo() })
    Dependencies.shared.add(module: Module { () -> HomeClient in HomeClientDemo() })
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    return PuppyGuideScreen()
        .environment(NavigationRouter())
}
