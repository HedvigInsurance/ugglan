import Foundation
import Testing

@testable import Home

struct StoryMediaTests {
    @Test
    func storyWithoutFileUrlHasNoMedia() {
        let story = Story(id: "id", title: "title", description: "description", fileUrl: nil)

        #expect(story.media == nil)
    }

    @Test
    func storyWithFileUrlBuildsMediaFromIt() throws {
        let url = try #require(URL(string: "https://hedvig.com/story.mp4"))
        let story = Story(id: "id", title: "title", description: "description", fileUrl: url)

        #expect(story.media == .video(url))
    }

    @Test
    func gifExtensionIsGif() throws {
        let url = try #require(URL(string: "https://hedvig.com/story.gif"))

        #expect(StoryMedia(url: url) == .gif(url))
    }

    @Test(arguments: ["mp4", "mov"])
    func videoExtensionIsVideo(fileExtension: String) throws {
        let url = try #require(URL(string: "https://hedvig.com/story.\(fileExtension)"))

        #expect(StoryMedia(url: url) == .video(url))
    }

    @Test(arguments: ["jpg", "png"])
    func imageExtensionIsImage(fileExtension: String) throws {
        let url = try #require(URL(string: "https://hedvig.com/story.\(fileExtension)"))

        #expect(StoryMedia(url: url) == .image(url))
    }

    @Test
    func urlWithoutExtensionIsImage() throws {
        let url = try #require(URL(string: "https://hedvig.com/story"))

        #expect(StoryMedia(url: url) == .image(url))
    }

    @Test
    func prefetchableUrlIsTheUrlForImage() throws {
        let url = try #require(URL(string: "https://hedvig.com/story.jpg"))

        #expect(StoryMedia.image(url).prefetchableUrl == url)
    }

    @Test
    func prefetchableUrlIsTheUrlForGif() throws {
        let url = try #require(URL(string: "https://hedvig.com/story.gif"))

        #expect(StoryMedia.gif(url).prefetchableUrl == url)
    }

    @Test
    func prefetchableUrlIsNilForVideo() throws {
        let url = try #require(URL(string: "https://hedvig.com/story.mp4"))

        #expect(StoryMedia.video(url).prefetchableUrl == nil)
    }
}
