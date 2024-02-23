import Foundation
import hCore

public class FetchClaimServiceDemo: hFetchClaimService {
    public init() {}
    public func get() async throws -> [ClaimModel] {
        return [
            ClaimModel(
                id: "claimId",
                status: .beingHandled,
                outcome: .none,
                submittedAt: "2023-11-11",
                closedAt: nil,
                signedAudioURL: "https://github.com/robovm/apple-ios-samples/blob/master/avTouch/sample.m4a",
                type: "associated type",
                memberFreeText: nil,
                payoutAmount: nil,
                targetFileUploadUri: ""
            )
        ]
    }
    public func getFiles() async throws -> [String: [File]] {
        let fileArray: [File] = [
            .init(
                id: "imageId1",
                size: 22332,
                mimeType: .PNG,
                name: "test-image",
                source: .url(
                    url: URL(string: "https://filesamples.com/samples/image/png/sample_640%C3%97426.png")!
                )
            ),

            .init(
                id: "imageId2",
                size: 53443,
                mimeType: MimeType.PNG,
                name: "test-image2",
                source: .url(
                    url: URL(
                        string:
                            "https://onlinepngtools.com/images/examples-onlinepngtools/giraffe-illustration.png"
                    )!
                )
            ),
            .init(
                id: "imageId3",
                size: 52176,
                mimeType: MimeType.PNG,
                name: "test-image3",
                source: .url(
                    url: URL(string: "https://cdn.pixabay.com/photo/2017/06/21/15/03/example-2427501_1280.png")!
                )
            ),
            .init(
                id: "imageId4",
                size: 52176,
                mimeType: MimeType.PNG,
                name: "test-image4",
                source: .url(url: URL(string: "https://flif.info/example-images/fish.png")!)
            ),
            .init(
                id: "imageId5",
                size: 52176,
                mimeType: MimeType.PDF,
                name: "test-pdf long name it is possible to have it is long name .pdf",
                source: .url(
                    url: URL(string: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf")!
                )
            ),
        ]
        return ["id": fileArray]
    }
}