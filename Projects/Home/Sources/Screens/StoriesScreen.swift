import Kingfisher
import SwiftUI
import hCore
import hCoreUI

public struct StoriesScreen: View {
    @StateObject var vm: StoriesScreenViewModel

    public init(stories: [Story]) {
        self._vm = StateObject(wrappedValue: StoriesScreenViewModel(stories: stories))
    }

    public var body: some View {
        hSection {
            VStack {
                HStack {
                    ForEach(vm.stories) { story in
                        StoryProgressView(vm: vm, story: story)
                    }
                }
                Spacer()
                ZStack {
                    ForEach(vm.stories) { story in
                        StoryView(vm: vm, story: story)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gestureValue in
                            print(gestureValue)
                            if gestureValue.location.x < 100 {
                                vm.goToPreviousStory()
                            } else {
                                vm.goToNextStory()
                            }
                        }
                        .onEnded { gestureValue in
                        }
                )
                .disabled(vm.gestureDisabled)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(hBackgroundColor.primary)
        .sectionContainerStyle(.transparent)
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
            } else if vm.seenStories.contains(story) {
                ProgressView(value: 1)
                    .progressViewStyle(hProgressViewStyle())
            }
        }
    }
}
struct StoryView: View {
    @ObservedObject var vm: StoriesScreenViewModel
    let story: Story
    @State private var showTitle = false
    @State private var showSubtitle = false
    @State private var showImage = false
    @State private var cancellable: Task<(), any Error>?

    var body: some View {
        VStack {
            Spacer()
            if showTitle {
                hText(story.title, style: .heading3)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        )
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            if showSubtitle {
                hText(story.subtitle)
                    .foregroundColor(hTextColor.Opaque.secondary)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal:
                                .move(
                                    edge:
                                        .leading
                                )
                                .combined(with: .opacity)
                        )
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if showImage {
                if story.mimeType == .GIF {
                    KFAnimatedImage(story.imageUrl)
                        .targetCache(ImageCache.default)
                        .frame(width: 300, height: 300)
                        .contentShape(Rectangle())
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            )
                        )
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    KFImage(story.imageUrl)
                        .placeholder { _ in
                            ProgressView()
                                .foregroundColor(hTextColor.Opaque.primary)
                                .environment(\.colorScheme, .light)
                        }
                        .targetCache(ImageCache.default)
                        .resizable()
                        .aspectRatio(
                            contentMode: .fit
                        )
                        .cornerRadius(.padding16)
                        .frame(width: 350)
                        .contentShape(Rectangle())
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity).combined(with: .scale),
                                removal: .move(edge: .leading).combined(with: .opacity).combined(with: .scale)
                            )
                        )
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, .padding16)
        .onAppear {
            setTask()
        }
        .onChange(of: vm.currentStory) { value in
            setTask()
        }
    }

    private func setTask() {
        cancellable?.cancel()
        cancellable = Task {
            withAnimation {
                showImage = false
            }
            try await Task.sleep(seconds: 0.1)
            withAnimation {
                showSubtitle = false
            }

            try await Task.sleep(seconds: 0.2)
            withAnimation {
                showTitle = false
            }
            if vm.currentStory == story {
                try await Task.sleep(seconds: 1)
                try Task.checkCancellation()
                withAnimation {
                    showImage = true
                }
                try await Task.sleep(seconds: 1)
                try Task.checkCancellation()
                withAnimation {
                    showTitle = true
                }

                try await Task.sleep(seconds: 1)
                try Task.checkCancellation()
                withAnimation {
                    showSubtitle = true
                }
            }
        }
    }
}

@MainActor
class StoriesScreenViewModel: ObservableObject {
    var stories: [Story]
    var seenStories: [Story]
    @Published var currentStory: Story! {
        didSet {
            automaticProgressTask?.cancel()
            setNextStoryAutomatic()
        }
    }
    @Published var currentStoryProgress: Float = 0
    @Published var gestureDisabled = false
    @Published var animateProgress: Double = 0
    @State private var automaticProgressTask: Task<(), any Error>?

    var currentProgressTask: Task<Void, Never>?

    init(stories: [Story]) {
        self.stories = stories
        self.seenStories = []
        self.currentStory = stories.first!
    }

    private func setNextStoryAutomatic() {
        automaticProgressTask = Task { [weak self] in
            try await Task.sleep(seconds: 1)
            withAnimation(.easeInOut(duration: 5)) {
                self?.animateProgress = 1
            }
            try await Task.sleep(seconds: 5)
            try Task.checkCancellation()
            self?.goToNextStory()
        }
    }

    func goToNextStory() {
        gestureDisabled = true
        seenStories.append(currentStory)
        withAnimation {
            animateProgress = 1
        }

        Task {
            if let currentStoryIndex = stories.firstIndex(where: { $0 == currentStory }) {
                if currentStoryIndex < stories.count - 1 {
                    currentStory = stories[currentStoryIndex + 1]
                    animateProgress = 0
                }
            }
            try await Task.sleep(seconds: 0.1)
            gestureDisabled = false
        }
    }

    func goToPreviousStory() {
        gestureDisabled = true
        Task {
            seenStories.removeAll(where: { $0 == currentStory })
            if let currentStoryIndex = stories.firstIndex(where: { $0 == currentStory }) {
                if currentStoryIndex > 0 {
                    currentStory = stories[currentStoryIndex - 1]
                    animateProgress = 0
                }
            }
            try await Task.sleep(seconds: 1)
            gestureDisabled = false
        }
    }
}

public struct Story: Identifiable, Equatable {
    public let id: String
    let title: String
    let subtitle: String
    let imageUrl: URL
    let mimeType: MimeType

    public init(id: String, title: String, subtitle: String, imageUrl: URL, mimeType: MimeType) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.imageUrl = imageUrl
        self.mimeType = mimeType
    }
}

#Preview {
    StoriesScreen(stories: StoriesScreen.stories)
}

extension StoriesScreen {
    public static let stories: [Story] = [
        .init(
            id: "first",
            title: "Höjdpunkter från året som gått – Hedvig 2024",
            subtitle:
                "Året börjar lida mot sitt slut. För att runda av 2024 har vi på Hedvig sammanfattat några höjdpunkter och kuriosa från året som gått.",
            imageUrl: URL(
                string:
                    "https://www.hedvig.com/_next/image?url=https%3A%2F%2Fassets.hedvig.com%2Ff%2F165473%2F1326x884%2Fa6e90a2901%2Flogo-hedvig-hojdpunkter-2024.png&w=3840&q=70&dpl=dpl_3BjzrAa6PjJHiJgTXAHjEbRABFka"
            )!,
            mimeType: .PNG
        ),
        .init(
            id: "second",
            title: "Här växte vi mest",
            subtitle: "Hedvig växer i bland annat Ånge, men flest antal nya medlemmar har vi fått i Stockholm. ",
            imageUrl: URL(
                string:
                    "https://www.hedvig.com/_next/image?url=https%3A%2F%2Fassets.hedvig.com%2Ff%2F165473%2F1080x1080%2F4a1d0a6e6d%2Fanimation-stader.gif&w=3840&q=70&dpl=dpl_3BjzrAa6PjJHiJgTXAHjEbRABFka"
            )!,
            mimeType: .GIF
        ),
        .init(
            id: "third",
            title: "Antal hanterade skador",
            subtitle: "Vi hjälpte till med 29 125 skador under 2024. Hela 2 000 fler än förra året.",
            imageUrl: URL(
                string:
                    "https://www.hedvig.com/_next/image?url=https%3A%2F%2Fassets.hedvig.com%2Ff%2F165473%2F1080x1080%2Fceecba5143%2Fanimation-antal-skador.gif&w=3840&q=70&dpl=dpl_BBoqyXLnXvbtcYAVwg4of4Gr4UoK"
            )!,
            mimeType: .GIF
        ),
        .init(
            id: "fourth",
            title: "Flest försäkringar på en person",
            subtitle:
                "En medlem har skaffat försäkring för sina 8 katter, vilket hittills är flest försäkringar tecknade av en person hos Hedvig.",
            imageUrl: URL(
                string:
                    "https://www.hedvig.com/_next/image?url=https%3A%2F%2Fassets.hedvig.com%2Ff%2F165473%2F1500x1500%2Facdaefca75%2Fkatt-selfie-hedvig-1500.jpg&w=3840&q=70&dpl=dpl_BBoqyXLnXvbtcYAVwg4of4Gr4UoK"
            )!,
            mimeType: .PNG
        ),
        .init(
            id: "fifth",
            title: "Årets otursdagar",
            subtitle:
                "De datum flest angett som skadetillfälle är 1 juli, 1 mars och 1 januari. Är den 1:a den nya 13:e?",
            imageUrl: URL(
                string:
                    "https://www.hedvig.com/_next/image?url=https%3A%2F%2Fassets.hedvig.com%2Ff%2F165473%2F1080x1080%2Fd2530910de%2Fanimation-otursdagar.gif&w=3840&q=70&dpl=dpl_BBoqyXLnXvbtcYAVwg4of4Gr4UoK"
            )!,
            mimeType: .GIF
        ),
        .init(
            id: "sixth",
            title: "Antal försäkrade husdjur",
            subtitle:
                "Nu försäkrar vi 21 024 hundar och katter över hela landet. Det är nästan en fördubbling mot förra året.",
            imageUrl: URL(
                string:
                    "https://www.hedvig.com/_next/image?url=https%3A%2F%2Fassets.hedvig.com%2Ff%2F165473%2F1080x1080%2F5c0e698822%2Fanimation-antal-husdjur.gif&w=3840&q=70&dpl=dpl_BBoqyXLnXvbtcYAVwg4of4Gr4UoK"
            )!,
            mimeType: .GIF
        ),
        .init(
            id: "seventh",
            title: "Tredje bästa",
            subtitle:
                "Vi har blivit utsedda till Sveriges tredje mest välansedda försäkringsbolag av Trust & Reputation.",
            imageUrl: URL(
                string:
                    "https://www.hedvig.com/_next/image?url=https%3A%2F%2Fassets.hedvig.com%2Ff%2F165473%2F1080x1080%2F75123e2961%2Ftre-stjarna.png&w=3840&q=70&dpl=dpl_BBoqyXLnXvbtcYAVwg4of4Gr4UoK"
            )!,
            mimeType: .PNG
        ),
        .init(
            id: "eight",
            title: "Årets snabbaste claim",
            subtitle: "Vår snabbaste skadeanmälan i år var på 123 sekunder från anmäld skada till utbetald ersättning.",
            imageUrl: URL(
                string:
                    "https://www.hedvig.com/_next/image?url=https%3A%2F%2Fassets.hedvig.com%2Ff%2F165473%2F1080x1080%2F050f68dbf0%2Fanimation-tidtagning.gif&w=3840&q=70&dpl=dpl_BBoqyXLnXvbtcYAVwg4of4Gr4UoK"
            )!,
            mimeType: .GIF
        ),
        .init(
            id: "ninth",
            title: "Årets mest försäkrade bil",
            subtitle: "Den bilmodell som vi har försäkrat allra mest under året är Volkswagen Golf. En klassiker.",
            imageUrl: URL(
                string:
                    "https://www.hedvig.com/_next/image?url=https%3A%2F%2Fassets.hedvig.com%2Ff%2F165473%2F1920x1080%2F99e0d1b868%2Fsummercar-bottom.jpg&w=3840&q=70&dpl=dpl_BBoqyXLnXvbtcYAVwg4of4Gr4UoK"
            )!,
            mimeType: .PNG
        ),
        .init(
            id: "tenth",
            title: "Djur-vabb",
            subtitle: "Under året har 71 procent fler valt Djurförsäkring Premium, där ersättning för djur-vabb ingår.",
            imageUrl: URL(
                string:
                    "https://www.hedvig.com/_next/image?url=https%3A%2F%2Fassets.hedvig.com%2Ff%2F165473%2F1080x1080%2Fbe939841d2%2Fhund-springer.png&w=3840&q=70&dpl=dpl_BBoqyXLnXvbtcYAVwg4of4Gr4UoK"
            )!,
            mimeType: .PNG
        ),
    ]
}
