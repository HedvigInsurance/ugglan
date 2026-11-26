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
            description:
                "Året börjar lida mot sitt slut. För att runda av **2024** har "
                + "vi på Hedvig sammanfattat några höjdpunkter och kuriosa från året som gått.",
            fileUrl: URL(
                string: "https://assets.hedvig.com/f/165473/1326x884/a6e90a2901/logo-hedvig-hojdpunkter-2024.png"
            )
        ),
        .init(
            id: "second",
            title: "Här växte vi mest",
            description: "Hedvig växer i bland annat Ånge, men flest antal nya medlemmar har vi fått i Stockholm.",
            fileUrl: URL(string: "https://assets.hedvig.com/f/165473/1080x1080/4a1d0a6e6d/animation-stader.gif")
        ),
        .init(
            id: "third",
            title: "Antal hanterade skador",
            description: "Vi hjälpte till med 29 125 skador under 2024. Hela 2 000 fler än förra året.",
            fileUrl: URL(string: "https://assets.hedvig.com/f/165473/1080x1080/ceecba5143/animation-antal-skador.gif")
        ),
        .init(
            id: "fourth",
            title: "Flest försäkringar på en person",
            description:
                "En medlem har skaffat försäkring för sina 8 katter, vilket "
                + "hittills är flest försäkringar tecknade av en person hos Hedvig.",
            fileUrl: URL(string: "https://assets.hedvig.com/f/165473/1500x1500/acdaefca75/katt-selfie-hedvig-1500.jpg")
        ),
        .init(
            id: "fifth",
            title: "Årets otursdagar",
            description:
                "De datum flest angett som skadetillfälle är 1 juli, 1 mars och 1 januari. Är den 1:a den nya 13:e?",
            fileUrl: URL(string: "https://assets.hedvig.com/f/165473/1080x1080/d2530910de/animation-otursdagar.gif")
        ),
        .init(
            id: "sixth",
            title: "Antal försäkrade husdjur",
            description:
                "Nu försäkrar vi 21 024 hundar och katter över "
                + "hela landet. Det är nästan en fördubbling mot förra året.",
            fileUrl: URL(string: "https://assets.hedvig.com/f/165473/1080x1080/5c0e698822/animation-antal-husdjur.gif")
        ),
        .init(
            id: "seventh",
            title: "Tredje bästa",
            description:
                "Vi har blivit utsedda till Sveriges tredje mest välansedda försäkringsbolag av Trust & Reputation.",
            fileUrl: URL(string: "https://assets.hedvig.com/f/165473/1080x1080/75123e2961/tre-stjarna.png")
        ),
        .init(
            id: "eight",
            title: "Årets snabbaste claim",
            description:
                "Vår snabbaste skadeanmälan i år var på 123 sekunder från anmäld skada till utbetald ersättning.",
            fileUrl: URL(string: "https://assets.hedvig.com/f/165473/1080x1080/050f68dbf0/animation-tidtagning.gif")
        ),
        .init(
            id: "ninth",
            title: "Årets mest försäkrade bil",
            description: "Den bilmodell som vi har försäkrat allra mest under året är Volkswagen Golf. En klassiker.",
            fileUrl: URL(string: "https://assets.hedvig.com/f/165473/1920x1080/99e0d1b868/summercar-bottom.jpg")
        ),
        .init(
            id: "tenth",
            title: "Djur-vabb",
            description:
                "Under året har 71 procent fler valt Djurförsäkring Premium, där ersättning för djur-vabb ingår.",
            fileUrl: URL(string: "https://assets.hedvig.com/f/165473/1080x1080/be939841d2/hund-springer.png"),
            action: URL(string: "https://www.hedvig.com/se/forsakringar/djurforsakring")
                .map { StoryAction(title: "Läs mer", url: $0) }
        ),
    ]
}
