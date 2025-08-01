@preconcurrency import XCTest
import hCore

@testable import SubmitClaim

@MainActor
final class FileUploaderTests: XCTestCase {
    weak var sut: MockFileUploaderService?

    override func tearDown() async throws {
        try await super.tearDown()
        Dependencies.shared.remove(for: FileUploaderClient.self)
        try await Task.sleep(nanoseconds: 100)

        XCTAssertNil(sut)
    }

    func testUploadFileSuccess() async {
        let uploadedFile: UploadFileResponseModel = .init(audioUrl: "https://audioUrl")

        let mockService = MockData.createMockFileUploaderService(
            uploadFile: { _, _ in
                uploadedFile
            }
        )
        sut = mockService

        let respondedFile = try! await mockService.uploadFile(
            "https://audioUrl",
            .init(data: .empty, name: "file", mimeType: "")
        )
        assert(respondedFile.audioUrl == uploadedFile.audioUrl)
    }
}
