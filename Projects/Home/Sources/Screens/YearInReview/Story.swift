import Foundation
import hCore

public struct Story: Identifiable, Equatable {
    public let id: String
    let title: String
    let description: String
    /// Nil for stories without a file, like the one showing how long the member has been insured
    let media: StoryMedia?
    let action: StoryAction?

    public init(
        id: String,
        title: String,
        description: String,
        fileUrl: URL?,
        action: StoryAction? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.media = fileUrl.map { StoryMedia(url: $0) }
        self.action = action
    }
}

/// A link a story can offer, like opening a page in the app
public struct StoryAction: Equatable {
    let title: String
    let url: URL

    public init(title: String, url: URL) {
        self.title = title
        self.url = url
    }
}

/// The file attached to a story; the kind is taken from the file extension
enum StoryMedia: Equatable {
    case image(URL)
    case gif(URL)
    case video(URL)

    init(url: URL) {
        let mimeType = MimeType.findBy(mimeType: url.mimeType)
        if mimeType == .GIF {
            self = .gif(url)
        } else if mimeType.isVideo {
            self = .video(url)
        } else {
            self = .image(url)
        }
    }

    /// Images and GIFs can be prefetched into the image cache, videos are streamed when shown
    var prefetchableUrl: URL? {
        switch self {
        case let .image(url), let .gif(url): return url
        case .video: return nil
        }
    }
}
