import Kingfisher
import SwiftUI
import hCore
import hCoreUI

// MARK: - Constants
enum StoryConstants {
    static let storyDuration: TimeInterval = 10
    /// How often the progress bar advances and a paused sleep checks whether it may continue
    static let tickInterval: TimeInterval = 0.05
    /// Touches shorter than this are taps that switch story, longer ones are holds that only pause
    static let tapThreshold: TimeInterval = 0.2
    /// How long a progress bar takes to fill up or empty when switching story
    static let barTransitionDuration: TimeInterval = 0.15
    static let imageSize: CGFloat = 300

    /// Delays between the steps that reveal a story's content
    enum Reveal {
        static let imageDelay: TimeInterval = 1
        static let stepDelay: TimeInterval = 1
        static let thankYouButtonDelay: TimeInterval = 2
    }

    enum Pillow {
        static let blurRadius: CGFloat = 40
        static let opacity: Double = 0.2
        static let fadeDuration: TimeInterval = 5
    }
}

// MARK: - Main Screen
/// Loads the stories and plays them once they are there
public struct StoriesScreen: View {
    @State private var vm = StoriesLoaderViewModel()

    public init() {}

    public var body: some View {
        Group {
            if let stories = vm.stories {
                StoryPlayer(stories: stories)
            }
        }
        .loading($vm.viewState)
        .hStateViewButtonConfig(
            .init(actionButton: .init(buttonAction: { Task { await vm.loadStories() } }))
        )
        .task {
            await vm.loadStories()
        }
    }
}

// MARK: - Player
private struct StoryPlayer: View {
    @State private var vm: StoriesScreenViewModel
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    init(stories: [Story]) {
        self._vm = State(wrappedValue: StoriesScreenViewModel(stories: stories))
    }

    var body: some View {
        GeometryReader { proxy in
            hForm {
                hSection {
                    StoryTextView(vm: vm)
                        .id(vm.currentIndex)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                }
            }
            .hFormAttachToBottom {
                if verticalSizeClass == .regular {
                    hSection {
                        StoryImageView(vm: vm)
                            .id(vm.currentIndex)
                    }
                }
            }
            .hFormBottomBackground {
                StoryPillowBackground(pillow: vm.currentPillow)
            }
            .sectionContainerStyle(.transparent)
            // Simultaneous so the touch is not held back until the hForm scroll view's pan gesture fails,
            // which would only deliver it on finger up and make pausing on hold impossible
            .simultaneousGesture(touchGesture(width: proxy.size.width))
            .toolbar {
                ToolbarItem(placement: .principal) {
                    StoryProgressBar(vm: vm)
                        .frame(width: max(proxy.size.width - 100, 0))
                        .padding(.leading, .padding8)
                }
            }
        }
        // Restarted for every story and cancelled when the screen goes away
        .task(id: vm.currentIndex) {
            await vm.playCurrentStory()
        }
    }

    private func touchGesture(width: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in vm.touchBegan() }
            .onEnded { gesture in vm.touchEnded(isOnLeadingHalf: gesture.location.x < width / 2) }
    }
}

// MARK: - Progress Bar
private struct StoryProgressBar: View {
    let vm: StoriesScreenViewModel

    var body: some View {
        HStack(spacing: .padding4) {
            ForEach(vm.stories.indices, id: \.self) { index in
                ProgressView(value: vm.barProgress[index])
                    .progressViewStyle(hProgressViewStyle())
            }
        }
    }
}

// MARK: - Text
private struct StoryTextView: View {
    let vm: StoriesScreenViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var body: some View {
        HStack {
            VStack(spacing: .padding16) {
                if let title = vm.currentStory.title {
                    hPill(text: title, color: .grey)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(vm.reveal.title ? 1 : 0)
                        .padding(.bottom)
                }
                Text(vm.currentStory.getAttributedText(schema: colorScheme))
                    .foregroundColor(hTextColor.Opaque.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .opacity(vm.reveal.text ? 1 : 0)
            }
            // In landscape the image sits next to the text instead of being attached to the bottom
            if verticalSizeClass == .compact {
                StoryImageView(vm: vm)
                    .frame(maxHeight: StoryConstants.imageSize)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, .padding16)
    }
}

// MARK: - Image
private struct StoryImageView: View {
    let vm: StoriesScreenViewModel
    @Environment(NavigationRouter.self) private var router

    var body: some View {
        VStack(spacing: .padding8) {
            StoryImage(story: vm.currentStory, isPaused: vm.isPaused)
                .opacity(vm.reveal.image ? 1 : 0)

            if vm.reveal.thankYouButton {
                hButton(.large, .secondary, content: .init(title: L10n.generalDoneButton)) {
                    router.dismiss()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, .padding16)
    }
}

private struct StoryImage: View {
    let story: Story
    let isPaused: Bool
    @State private var gifPlayback = GIFPlaybackController()

    var body: some View {
        Group {
            if story.mimeType == .GIF {
                KFAnimatedImage(story.imageUrl)
                    .configure { [gifPlayback] imageView in
                        gifPlayback.imageView = imageView
                    }
                    .targetCache(ImageCache.default)
                    .aspectRatio(contentMode: .fit)
            } else {
                KFImage(story.imageUrl)
                    .placeholder { _ in
                        ProgressView()
                            .foregroundColor(hTextColor.Opaque.primary)
                            .environment(\.colorScheme, .light)
                    }
                    .targetCache(ImageCache.default)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(.padding16)
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onChange(of: isPaused) { _, isPaused in
            gifPlayback.setPaused(isPaused)
        }
    }
}

/// Holds the image view behind `KFAnimatedImage`, whose `configure` block only runs when the view is created,
/// so playback can be stopped and resumed later on.
@MainActor
private final class GIFPlaybackController {
    weak var imageView: AnimatedImageView?

    func setPaused(_ isPaused: Bool) {
        if isPaused {
            imageView?.stopAnimating()
        } else {
            imageView?.startAnimating()
        }
    }
}

// MARK: - Pillow Background
private struct StoryPillowBackground: View {
    let pillow: PillowType

    var body: some View {
        // Color.clear takes the available size, so the filled image overflows evenly and stays centered
        Color.clear
            .overlay(alignment: .center) {
                pillow.bgImage
                    .resizable()
                    .scaledToFill()
                    .blur(radius: StoryConstants.Pillow.blurRadius)
                    .opacity(StoryConstants.Pillow.opacity)
                    .id(pillow)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: StoryConstants.Pillow.fadeDuration), value: pillow)
            }
            .clipped()
    }
}

// MARK: - Preview
#Preview {
    Dependencies.shared.add(module: Module { () -> YearInReviewClient in YearInReviewClientDemo() })
    return StoriesScreen()
        .environment(NavigationRouter())
}
