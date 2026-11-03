import Foundation
import hCore

public final class YearInReviewClientDemo: YearInReviewClient {
    public init() {}

    public func getStories() async throws -> [Story] {
        Self.stories
    }
}

extension YearInReviewClientDemo {
    private static let stories: [Story] = [
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
