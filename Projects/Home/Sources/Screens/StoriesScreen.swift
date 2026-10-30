import Kingfisher
import SwiftUI
import hCore
import hCoreUI

// MARK: - Constants
private enum StoryConstants {
    static let storyDuration: Float = 10.0
    static let tapThreshold: TimeInterval = 0.1
    static let gestureDebounce: Float = 0.05
    static let progressUpdateInterval: UInt64 = 100_000_000  // 0.1 seconds in nanoseconds
    static let swipeThreshold: CGFloat = 0.5

    enum Animation {
        static let fadeOutDelay: Float = 0.2
        static let titleFadeOutDelay: Float = 0.3
        static let initialDelay: Float = 0.5
        static let contentFadeInDelay: Float = 1.0
        static let finalDelay: Float = 2.0
    }

    enum Size {
        static let imageSize: CGFloat = 300
    }
}

// MARK: - Story Animation Coordinator
@MainActor
private class StoryAnimationCoordinator: ObservableObject {
    @Published var showTitle = false
    @Published var showSubtitle = false
    @Published var showImage = false
    @Published var showThankYouButton = false

    private var cancellable: Task<Void, Error>?

    func reset() {
        cancellable?.cancel()
        showTitle = false
        showSubtitle = false
        showImage = false
        showThankYouButton = false
    }

    func startAnimation(for story: Story, isLastStory: Bool, currentStory: Story?) async throws {
        reset()

        // Initial delays to fade out previous content
        try await Task.sleep(seconds: StoryConstants.Animation.fadeOutDelay)
        try await Task.sleep(seconds: StoryConstants.Animation.titleFadeOutDelay)

        guard story == currentStory else { return }

        // Show content in sequence
        try await Task.sleep(seconds: StoryConstants.Animation.initialDelay)
        try Task.checkCancellation()

        withAnimation {
            showImage = true
        }

        try await Task.sleep(seconds: StoryConstants.Animation.contentFadeInDelay)
        try Task.checkCancellation()

        withAnimation {
            showTitle = true
        }

        try await Task.sleep(seconds: StoryConstants.Animation.contentFadeInDelay)
        try Task.checkCancellation()

        withAnimation {
            showSubtitle = true
        }

        if isLastStory && story == currentStory {
            try await Task.sleep(seconds: StoryConstants.Animation.finalDelay)
            try Task.checkCancellation()

            withAnimation {
                showThankYouButton = true
            }
        }
    }

    func cancel() {
        cancellable?.cancel()
    }
}

// MARK: - Main Screen
public struct StoriesScreen: View {
    @StateObject private var vm: StoriesScreenViewModel
    @Environment(\.verticalSizeClass) var verticalSizeClass

    public init(stories: [Story]) {
        self._vm = StateObject(wrappedValue: StoriesScreenViewModel(stories: stories))
    }

    public var body: some View {
        GeometryReader { proxy in
            hForm {
                hSection {
                    StoryContentContainer(vm: vm)
                }
            }
            .hFormAttachToBottom {
                if verticalSizeClass == .regular {
                    hSection {
                        StoryImageView(vm: vm, story: vm.currentStory)
                            .id(vm.currentStory.id)
                    }
                }
            }
            .sectionContainerStyle(.transparent)
            .gesture(createStoryGesture(proxy: proxy))
        }
    }
    private func createStoryGesture(proxy: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in vm.handleGestureStart() }
            .onEnded { gesture in
                let normalizedOffset = gesture.location.x / proxy.size.width
                vm.handleGestureEnd(normalizedOffset: normalizedOffset)
            }
    }
}

// MARK: - Story Content Container
private struct StoryContentContainer: View {
    @ObservedObject var vm: StoriesScreenViewModel

    var body: some View {
        VStack {
            StoryProgressBar(vm: vm)
            Spacer()
            StoryView(vm: vm, story: vm.currentStory)
                .id(vm.currentStory.id)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .disabled(vm.gestureDisabled)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Story Progress Bar
private struct StoryProgressBar: View {
    @ObservedObject var vm: StoriesScreenViewModel

    var body: some View {
        HStack(spacing: .padding4) {
            ForEach(vm.stories) { story in
                StoryProgressView(vm: vm, story: story)
            }
        }
    }
}

struct StoryProgressView: View {
    @ObservedObject var vm: StoriesScreenViewModel
    @State var task: Task<(), any Error>?
    let story: Story
    var body: some View {
        ZStack {
            ProgressView(value: 0)
                .progressViewStyle(hProgressViewStyle())
            if vm.currentStory == story {
                ProgressView(value: vm.animateProgress)
                    .progressViewStyle(hProgressViewStyle())
                    .transition(.opacity)
            } else if vm.seenStories.contains(story) {
                ProgressView(value: 1)
                    .progressViewStyle(hProgressViewStyle())
                    .transition(.opacity)
            }
        }
    }
}
// MARK: - Story Content View
struct StoryView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var vm: StoriesScreenViewModel
    @StateObject private var animator = StoryAnimationCoordinator()
    @Environment(\.verticalSizeClass) var verticalSizeClass

    let story: Story

    var body: some View {
        HStack {
            VStack(spacing: .padding16) {
                if let title = story.title {
                    hPill(text: title, color: .grey)
                        .transition(.opacity)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(animator.showTitle ? 1 : 0)
                        .padding(.bottom)
                }
                Text(story.getAttributedText(schema: colorScheme))
                    .foregroundColor(hTextColor.Opaque.secondary)
                    .transition(.opacity)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .opacity(animator.showSubtitle ? 1 : 0)
            }
            if verticalSizeClass == .compact {
                StoryImageView(vm: vm, story: vm.currentStory)
                    .frame(maxHeight: StoryConstants.Size.imageSize)
                    .id(vm.currentStory.id)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, .padding16)
        .task(id: vm.currentStory) {
            try? await animator.startAnimation(
                for: story,
                isLastStory: vm.isLastStory(story),
                currentStory: vm.currentStory
            )
        }
    }
}

// MARK: - Story Image View
struct StoryImageView: View {
    @ObservedObject var vm: StoriesScreenViewModel
    @StateObject private var animator = StoryAnimationCoordinator()
    @EnvironmentObject var router: Router
    let story: Story

    var body: some View {
        VStack(spacing: .padding8) {
            StoryImageContent(story: story, showImage: animator.showImage)

            if animator.showThankYouButton {
                hButton(.large, .secondary, content: .init(title: "Tack!")) {
                    router.dismiss()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, .padding16)
        .task(id: vm.currentStory) {
            try? await animator.startAnimation(
                for: story,
                isLastStory: vm.isLastStory(story),
                currentStory: vm.currentStory
            )
        }
    }
}

// MARK: - Story Image Content
private struct StoryImageContent: View {
    let story: Story
    let showImage: Bool

    var body: some View {
        Group {
            if story.mimeType == .GIF {
                KFAnimatedImage(story.imageUrl)
                    .targetCache(ImageCache.default)
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
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
                    .frame(maxWidth: .infinity)
            }
        }
        .contentShape(Rectangle())
        .transition(.opacity)
        .opacity(showImage ? 1 : 0)
    }
}

// MARK: - View Model
@MainActor
class StoriesScreenViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var stories: [Story]
    @Published private(set) var seenStories: [Story] = []
    @Published var currentStory: Story! {
        didSet {
            resetProgress()
            startAutomaticProgress()
        }
    }
    @Published private(set) var animateProgress: Double = 0
    @Published private(set) var gestureDisabled = false

    // MARK: - Private Properties
    private var gestureStartTime: Date?
    private var automaticProgressTask: Task<Void, Error>?

    // MARK: - Initialization
    init(stories: [Story]) {
        self.stories = stories
        self.currentStory = stories.first
        prefetchImages()
    }

    // MARK: - Public Methods
    func isLastStory(_ story: Story) -> Bool {
        story == stories.last
    }

    func handleGestureStart() {
        guard gestureStartTime == nil else { return }
        gestureStartTime = Date()
        automaticProgressTask?.cancel()
    }

    func handleGestureEnd(normalizedOffset: CGFloat) {
        defer {
            gestureStartTime = nil
        }

        guard let startTime = gestureStartTime else { return }

        let duration = Date().timeIntervalSince(startTime)

        if duration < StoryConstants.tapThreshold {
            if normalizedOffset < StoryConstants.swipeThreshold {
                navigateToPreviousStory()
            } else {
                navigateToNextStory()
            }
        } else {
            resumeProgress()
        }
    }

    // MARK: - Private Methods
    private func prefetchImages() {
        let urls = stories.map { $0.imageUrl }
        let prefetcher = ImagePrefetcher(
            urls: urls,
            options: [.targetCache(ImageCache.default)]
        )
        prefetcher.start()
    }

    private func resetProgress() {
        automaticProgressTask?.cancel()
        automaticProgressTask = nil
    }

    private func startAutomaticProgress() {
        startAutomaticProgress(duration: StoryConstants.storyDuration)
    }

    private func startAutomaticProgress(duration: Float) {
        automaticProgressTask = Task { [weak self] in
            guard let self else { return }

            let startProgress = Int(self.animateProgress * 100)
            let totalSteps = 100

            for step in startProgress...totalSteps {
                try Task.checkCancellation()
                await MainActor.run {
                    self.animateProgress = Double(step) / 100.0
                }
                try await Task.sleep(nanoseconds: StoryConstants.progressUpdateInterval)
            }

            try Task.checkCancellation()
            if !isLastStory(currentStory) {
                self.navigateToNextStory()
            }
        }
    }

    private func resumeProgress() {
        let remainingDuration = StoryConstants.storyDuration * Float(1 - animateProgress)
        startAutomaticProgress(duration: remainingDuration)
    }

    private func navigateToNextStory() {
        guard let currentIndex = currentStoryIndex else { return }

        setGestureDisabled(true)

        Task {
            defer { setGestureDisabled(false) }

            if currentIndex < stories.count - 1 {
                seenStories.append(currentStory)
                withAnimation {
                    currentStory = stories[currentIndex + 1]
                    animateProgress = 0
                }
            } else {
                resumeProgress()
            }

            try? await Task.sleep(seconds: StoryConstants.gestureDebounce)
        }
    }

    private func navigateToPreviousStory() {
        guard let currentIndex = currentStoryIndex else { return }

        setGestureDisabled(true)

        Task {
            defer { setGestureDisabled(false) }

            seenStories.removeAll { $0 == currentStory }

            if currentIndex > 0 {
                withAnimation {
                    currentStory = stories[currentIndex - 1]
                    animateProgress = 0
                }
            } else {
                startAutomaticProgress()
            }

            try? await Task.sleep(seconds: StoryConstants.gestureDebounce)
        }
    }

    private func setGestureDisabled(_ disabled: Bool) {
        Task { @MainActor in
            gestureDisabled = disabled
        }
    }

    private var currentStoryIndex: Int? {
        stories.firstIndex { $0 == currentStory }
    }
}

// MARK: - Story Model
public struct Story: Identifiable, Equatable {
    public let id: String
    let title: String?
    let startText: String
    let restOfTheText: String
    let imageUrl: URL
    let mimeType: MimeType

    public init(
        id: String,
        title: String?,
        startText: String,
        restOfTheText: String,
        imageUrl: URL,
        mimeType: MimeType
    ) {
        self.id = id
        self.title = title
        self.startText = startText
        self.restOfTheText = restOfTheText
        self.imageUrl = imageUrl
        self.mimeType = mimeType
    }

    @MainActor
    func getAttributedText(schema: ColorScheme) -> AttributedString {
        let colorSchemeType: SwiftUI.ColorScheme = schema == .light ? .light : .dark

        var startText = AttributedString(startText)
        startText.foregroundColor = hTextColor.Opaque.primary.colorFor(colorSchemeType, .base).color
        startText.font = Fonts.fontFor(style: .body2)

        var subtitleText = AttributedString(" " + restOfTheText)
        subtitleText.foregroundColor = hTextColor.Opaque.secondary.colorFor(colorSchemeType, .base).color
        subtitleText.font = Fonts.fontFor(style: .body2)

        return startText + subtitleText
    }
}

// MARK: - Preview
#Preview {
    StoriesScreen(stories: StoriesScreen.stories)
        .environmentObject(Router())
}

// MARK: - Preview Data
extension StoriesScreen {
    public static let stories: [Story] = [
        .init(
            id: "first",
            title: "Höjdpunkter från året som gått – Hedvig 2024",
            startText: "Året börjar lida mot sitt slut.",
            restOfTheText:
                "För att runda av 2024 har vi på Hedvig sammanfattat några höjdpunkter och kuriosa från året som gått.",
            imageUrl: URL(
                string:
                    "https://www.hedvig.com/_next/image?url=https%3A%2F%2Fassets.hedvig.com%2Ff%2F165473%2F1326x884%2Fa6e90a2901%2Flogo-hedvig-hojdpunkter-2024.png&w=3840&q=70&dpl=dpl_3BjzrAa6PjJHiJgTXAHjEbRABFka"
            )!,
            mimeType: .PNG
        ),
        .init(
            id: "second",
            title: "Här växte vi mest",
            startText: "Hedvig växer i bland annat Ånge,",
            restOfTheText: "men flest antal nya medlemmar har vi fått i Stockholm.",
            imageUrl: URL(
                string:
                    "https://www.hedvig.com/_next/image?url=https%3A%2F%2Fassets.hedvig.com%2Ff%2F165473%2F1080x1080%2F4a1d0a6e6d%2Fanimation-stader.gif&w=3840&q=70&dpl=dpl_3BjzrAa6PjJHiJgTXAHjEbRABFka"
            )!,
            mimeType: .GIF
        ),
        .init(
            id: "third",
            title: "Antal hanterade skador",
            startText: "Vi hjälpte till med 29 125 skador under 2024.",
            restOfTheText: "Hela 2 000 fler än förra året.",
            imageUrl: URL(
                string:
                    "https://www.hedvig.com/_next/image?url=https%3A%2F%2Fassets.hedvig.com%2Ff%2F165473%2F1080x1080%2Fceecba5143%2Fanimation-antal-skador.gif&w=3840&q=70&dpl=dpl_BBoqyXLnXvbtcYAVwg4of4Gr4UoK"
            )!,
            mimeType: .GIF
        ),
        .init(
            id: "fourth",
            title: "Flest försäkringar på en person",
            startText: "En medlem har skaffat försäkring för sina 8 katter,",
            restOfTheText: "vilket hittills är flest försäkringar tecknade av en person hos Hedvig.",
            imageUrl: URL(
                string:
                    "https://www.hedvig.com/_next/image?url=https%3A%2F%2Fassets.hedvig.com%2Ff%2F165473%2F1500x1500%2Facdaefca75%2Fkatt-selfie-hedvig-1500.jpg&w=3840&q=70&dpl=dpl_BBoqyXLnXvbtcYAVwg4of4Gr4UoK"
            )!,
            mimeType: .PNG
        ),
        .init(
            id: "fifth",
            title: "Årets otursdagar",
            startText: "De datum flest angett som skadetillfälle är 1 juli, 1 mars och 1 januari.",
            restOfTheText: "Är den 1:a den nya 13:e?",
            imageUrl: URL(
                string:
                    "https://www.hedvig.com/_next/image?url=https%3A%2F%2Fassets.hedvig.com%2Ff%2F165473%2F1080x1080%2Fd2530910de%2Fanimation-otursdagar.gif&w=3840&q=70&dpl=dpl_BBoqyXLnXvbtcYAVwg4of4Gr4UoK"
            )!,
            mimeType: .GIF
        ),
        .init(
            id: "sixth",
            title: "Antal försäkrade husdjur",
            startText: "Nu försäkrar vi 21 024 hundar och katter över hela landet.",
            restOfTheText: "Det är nästan en fördubbling mot förra året.",
            imageUrl: URL(
                string:
                    "https://www.hedvig.com/_next/image?url=https%3A%2F%2Fassets.hedvig.com%2Ff%2F165473%2F1080x1080%2F5c0e698822%2Fanimation-antal-husdjur.gif&w=3840&q=70&dpl=dpl_BBoqyXLnXvbtcYAVwg4of4Gr4UoK"
            )!,
            mimeType: .GIF
        ),
        .init(
            id: "seventh",
            title: "Tredje bästa",
            startText: "Vi har blivit utsedda till Sveriges tredje mest välansedda försäkringsbolag",
            restOfTheText: "av Trust & Reputation.",
            imageUrl: URL(
                string:
                    "https://www.hedvig.com/_next/image?url=https%3A%2F%2Fassets.hedvig.com%2Ff%2F165473%2F1080x1080%2F75123e2961%2Ftre-stjarna.png&w=3840&q=70&dpl=dpl_BBoqyXLnXvbtcYAVwg4of4Gr4UoK"
            )!,
            mimeType: .PNG
        ),
        .init(
            id: "eight",
            title: "Årets snabbaste claim",
            startText: "Vår snabbaste skadeanmälan i år var på 123 sekunder",
            restOfTheText: "från anmäld skada till utbetald ersättning.",
            imageUrl: URL(
                string:
                    "https://www.hedvig.com/_next/image?url=https%3A%2F%2Fassets.hedvig.com%2Ff%2F165473%2F1080x1080%2F050f68dbf0%2Fanimation-tidtagning.gif&w=3840&q=70&dpl=dpl_BBoqyXLnXvbtcYAVwg4of4Gr4UoK"
            )!,
            mimeType: .GIF
        ),
        .init(
            id: "ninth",
            title: "Årets mest försäkrade bil",
            startText: "Den bilmodell som vi har försäkrat allra mest under året är Volkswagen Golf.",
            restOfTheText: "En klassiker.",
            imageUrl: URL(
                string:
                    "https://www.hedvig.com/_next/image?url=https%3A%2F%2Fassets.hedvig.com%2Ff%2F165473%2F1920x1080%2F99e0d1b868%2Fsummercar-bottom.jpg&w=3840&q=70&dpl=dpl_BBoqyXLnXvbtcYAVwg4of4Gr4UoK"
            )!,
            mimeType: .PNG
        ),
        .init(
            id: "tenth",
            title: "Djur-vabb",
            startText: "Under året har 71 procent fler valt Djurförsäkring Premium,",
            restOfTheText: "där ersättning för djur-vabb ingår.",
            imageUrl: URL(
                string:
                    "https://www.hedvig.com/_next/image?url=https%3A%2F%2Fassets.hedvig.com%2Ff%2F165473%2F1080x1080%2Fbe939841d2%2Fhund-springer.png&w=3840&q=70&dpl=dpl_BBoqyXLnXvbtcYAVwg4of4Gr4UoK"
            )!,
            mimeType: .PNG
        ),
    ]
}
