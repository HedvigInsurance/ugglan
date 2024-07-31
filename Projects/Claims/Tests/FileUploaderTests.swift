import XCTest
import hCore

@testable import Claims

final class FileUploaderTests: XCTestCase {
    weak var sut: MockFileUploaderService?

    override func setUp() {
        super.setUp()
        sut = nil
    }

    override func tearDown() async throws {
        Dependencies.shared.remove(for: FileUploaderClient.self)
        try await Task.sleep(nanoseconds: 100)

        XCTAssertNil(sut)
    }

    func testUploadFileSuccess() async {
        let uploadedFile: UploadFileResponseModel = .init(audioUrl: "https://audioUrl")

        let mockService = MockData.createMockFileUploaderService(
            uploadFile: { flowId, file in
                uploadedFile
            }
        )
        self.sut = mockService

        let respondedFile = try! await mockService.uploadFile(
            "https://audioUrl",
            .init(data: .empty, name: "file", mimeType: "")
        )
        assert(respondedFile.audioUrl == uploadedFile.audioUrl)
    }
}