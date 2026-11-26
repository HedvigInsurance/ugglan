import AVKit
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

    /// Delays between the steps that reveal a story's content
    enum Reveal {
        /// Short, so a newly switched-to story doesn't sit blank
        static let titleDelay: TimeInterval = 0.2
        /// After the title
        static let mediaDelay: TimeInterval = 0.6
        /// After the media
        static let descriptionDelay: TimeInterval = 0.8
        /// After the description, so it has been read a bit before the action shows up
        static let actionDelay: TimeInterval = 1
    }

    /// Before switching story, the content fades out step by step in the reverse order it was revealed
    enum ContentFadeOut {
        /// How long each step takes to fade out
        static let duration: TimeInterval = 0.15
        /// Delay between one step starting to fade out and the next one
        static let stepDelay: TimeInterval = 0.05
    }

    /// Upper bounds for a story's media, so it doesn't grow huge on larger screens
    enum MediaSize {
        /// iPhone in portrait: as wide as the screen allows, but leaving room for the text above
        static let compactWidthMaxHeight: CGFloat = 400
        /// iPad: kept to a readable size instead of stretching over the whole screen
        static let regularMaxWidth: CGFloat = 500
        static let regularMaxHeight: CGFloat = 500
        /// Landscape: the media sits next to the text, so it shares the width with it
        static let compactHeightMaxWidth: CGFloat = 250
        static let compactHeightMaxHeight: CGFloat = 250
        /// Videos have no intrinsic size to fit, so they get a fixed height
        static let videoHeight: CGFloat = 300
    }

    enum Pillow {
        static let blurRadius: CGFloat = 30
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
                    StoryContentView(vm: vm)
                        .id(vm.currentIndex)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                }
            }
            .hFormAttachToBottom {
                if verticalSizeClass != .compact {
                    hSection {
                        StoryButtonsView(vm: vm)
                            .id(vm.currentIndex)
                    }
                }
            }
            .hFormBottomBackground {
                StoryPillowBackground(pillow: vm.currentPillow)
            }
            .sectionContainerStyle(.transparent)
            .hFormContentPosition(.center)
            // Simultaneous so the touch is not held back until the hForm scroll view's pan gesture fails,
            // which would only deliver it on finger up and make pausing on hold impossible
            .simultaneousGesture(touchGesture(midX: proxy.frame(in: .global).midX))
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

    /// In the global coordinate space so touches can be compared with the action button's frame
    private func touchGesture(midX: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onChanged { gesture in
                // The gesture is simultaneous, so a tap on the action button would otherwise also switch story
                guard !vm.actionButtonFrame.contains(gesture.startLocation) else { return }
                vm.touchBegan()
            }
            .onEnded { gesture in
                guard !vm.actionButtonFrame.contains(gesture.startLocation) else { return }
                vm.touchEnded(isOnLeadingHalf: gesture.location.x < midX)
            }
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

// MARK: - Content
/// The story's label, media and description, stacked top to bottom. In landscape the media sits on the right,
/// with the label and description on the left
private struct StoryContentView: View {
    let vm: StoriesScreenViewModel
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var body: some View {
        Group {
            if verticalSizeClass == .compact {
                VStack(alignment: .leading, spacing: .padding8) {
                    title
                    HStack(alignment: .top, spacing: .padding16) {
                        StoryMediaView(vm: vm)
                        VStack(alignment: .leading, spacing: .padding8) {
                            description
                            Spacer()
                            StoryButtonsView(vm: vm)
                                .id(vm.currentIndex)
                        }
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: .padding8) {
                    title
                    StoryMediaView(vm: vm)
                    description
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, .padding16)
    }

    private var title: some View {
        hText(vm.currentStory.title, style: .body1)
            .frame(maxWidth: .infinity, alignment: .leading)
            .opacity(vm.reveal.title ? 1 : 0)
    }

    private var description: some View {
        MarkdownView(
            config: .init(
                text: vm.currentStory.description,
                fontStyle: .body1,
                color: hTextColor.Opaque.secondary,
                linkColor: hTextColor.Opaque.primary,
                linkUnderlineStyle: .single,
                isSelectable: false,
                boldFont: Fonts.fontFor(style: .body1),
                boldColor: hTextColor.Opaque.primary
            ) { url in
                NotificationCenter.default.post(name: .openDeepLink, object: url)
            }
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
        .opacity(vm.reveal.description ? 1 : 0)
    }
}

// MARK: - Action
private struct StoryActionButton: View {
    @State private var isLoading = false
    let vm: StoriesScreenViewModel
    let action: StoryAction

    var body: some View {
        hButton(.large, .primary, content: .init(title: action.title)) {
            isLoading = true
            await vm.open(action)
            isLoading = false
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onGeometryChange(for: CGRect.self) { proxy in
            proxy.frame(in: .global)
        } action: { frame in
            vm.actionButtonFrame = frame
        }
        .hButtonIsLoading(isLoading)
        .disabled(isLoading)
    }
}

// MARK: - Buttons
private struct StoryButtonsView: View {
    let vm: StoriesScreenViewModel

    var body: some View {
        // Added rather than faded in, so it cannot be tapped before it is visible
        if let action = vm.currentStory.action, vm.reveal.action {
            StoryActionButton(vm: vm, action: action)
                .transition(.opacity)
        }
    }
}

// MARK: - Media
private struct StoryMediaView: View {
    let vm: StoriesScreenViewModel
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        if let media = vm.currentStory.media {
            MaxSizeLayout(maxSize: mediaMaxSize) {
                StoryMediaContent(media: media, isPaused: vm.isPaused)
                    .opacity(vm.reveal.media ? 1 : 0)
            }
        }
    }

    private var mediaMaxSize: CGSize {
        typealias Size = StoryConstants.MediaSize
        if verticalSizeClass == .compact {
            return CGSize(width: Size.compactHeightMaxWidth, height: Size.compactHeightMaxHeight)
        }
        if horizontalSizeClass == .regular {
            return CGSize(width: Size.regularMaxWidth, height: Size.regularMaxHeight)
        }
        return CGSize(width: .infinity, height: Size.compactWidthMaxHeight)
    }
}

/// Caps the size offered to its content, but unlike `.frame(maxWidth:maxHeight:)` takes only the size the content
/// ends up using, so an aspect-fit image doesn't leave empty space up to the maximum height
private struct MaxSizeLayout: Layout {
    let maxSize: CGSize

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
        subviews.first?.sizeThatFits(clamped(proposal)) ?? .zero
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
        subviews.first?
            .place(
                at: CGPoint(x: bounds.midX, y: bounds.midY),
                anchor: .center,
                proposal: clamped(proposal)
            )
    }

    private func clamped(_ proposal: ProposedViewSize) -> ProposedViewSize {
        ProposedViewSize(
            width: clamp(proposal.width, to: maxSize.width),
            height: clamp(proposal.height, to: maxSize.height)
        )
    }

    private func clamp(_ value: CGFloat?, to max: CGFloat) -> CGFloat? {
        guard let value else { return max.isFinite ? max : nil }
        return min(value, max)
    }
}

private struct StoryMediaContent: View {
    let media: StoryMedia
    let isPaused: Bool
    @State private var gifPlayback = GIFPlaybackController()

    var body: some View {
        Group {
            switch media {
            case let .gif(url):
                KFAnimatedImage(url)
                    .configure { [gifPlayback] imageView in
                        gifPlayback.imageView = imageView
                    }
                    .targetCache(ImageCache.default)
                    .aspectRatio(contentMode: .fit)
                    .accessibilityHidden(true)
            case let .image(url):
                KFImage(url)
                    .placeholder { _ in
                        ProgressView()
                            .foregroundColor(hTextColor.Opaque.primary)
                            .environment(\.colorScheme, .light)
                    }
                    .targetCache(ImageCache.default)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(.padding16)
                    .accessibilityHidden(true)
            case let .video(url):
                StoryVideoPlayer(url: url, isPaused: isPaused)
                    .frame(height: StoryConstants.MediaSize.videoHeight)
                    .cornerRadius(.padding16)
                    .accessibilityHidden(true)
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

/// Plays a story's video muted and on repeat, without controls, and pauses it while the story is held
private struct StoryVideoPlayer: UIViewRepresentable {
    let url: URL
    let isPaused: Bool

    func makeUIView(context _: Context) -> StoryVideoPlayerView {
        StoryVideoPlayerView(url: url)
    }

    func updateUIView(_ view: StoryVideoPlayerView, context _: Context) {
        view.setPaused(isPaused)
    }
}

private final class StoryVideoPlayerView: UIView {
    private let player = AVQueuePlayer()
    /// Keeps the video looping for as long as the view exists
    private let looper: AVPlayerLooper

    override static var layerClass: AnyClass { AVPlayerLayer.self }

    init(url: URL) {
        looper = AVPlayerLooper(player: player, templateItem: AVPlayerItem(url: url))
        super.init(frame: .zero)
        player.isMuted = true
        let playerLayer = layer as? AVPlayerLayer
        playerLayer?.player = player
        playerLayer?.videoGravity = .resizeAspect
        player.play()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setPaused(_ isPaused: Bool) {
        if isPaused {
            player.pause()
        } else {
            player.play()
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
        .embededInNavigation(tracking: "")
}
