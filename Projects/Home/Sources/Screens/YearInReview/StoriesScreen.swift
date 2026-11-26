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

// MARK: - Text
private struct StoryTextView: View {
    let vm: StoriesScreenViewModel
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var body: some View {
        HStack {
            VStack(spacing: .padding16) {
                hPill(text: vm.currentStory.title, color: .grey)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(vm.reveal.title ? 1 : 0)
                    .padding(.bottom)
                hText(vm.currentStory.description, style: .body2)
                    .foregroundColor(hTextColor.Opaque.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .opacity(vm.reveal.text ? 1 : 0)
                // Added with the text rather than faded, so it cannot be tapped before it is visible
                if let action = vm.currentStory.action, vm.reveal.text {
                    StoryActionButton(vm: vm, action: action)
                        .transition(.opacity)
                }
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

// MARK: - Action
private struct StoryActionButton: View {
    @State private var isLoading = false
    let vm: StoriesScreenViewModel
    let action: StoryAction

    var body: some View {
        hButton(.medium, .secondary, content: .init(title: action.title)) {
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

// MARK: - Media
private struct StoryImageView: View {
    let vm: StoriesScreenViewModel
    @Environment(NavigationRouter.self) private var router

    var body: some View {
        VStack(spacing: .padding8) {
            if let media = vm.currentStory.media {
                StoryMediaContent(media: media, isPaused: vm.isPaused)
                    .opacity(vm.reveal.image ? 1 : 0)
            }

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
                    .frame(height: StoryConstants.imageSize)
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
        .environment(NavigationRouter())
}
