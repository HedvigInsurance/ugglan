import Combine
import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimFileUploadView: View {
    @ObservedObject var viewModel: SubmitClaimFileUploadStep
    @ObservedObject var fileUploadVm: FilesUploadViewModel
    @State private var showFileSourcePicker = false

    init(
        viewModel: SubmitClaimFileUploadStep
    ) {
        fileUploadVm = viewModel.fileUploadVm
        self.viewModel = viewModel
    }

    var body: some View {
        showFilesView
            .showFileSourcePicker($showFileSourcePicker) { files in
                fileUploadVm.addFiles(with: files)
            }
    }

    private var showFilesView: some View {
        Group {
            if fileUploadVm.hasFiles {
                VStack {
                    FilesGridView(vm: fileUploadVm.fileGridViewModel)
                    HStack(spacing: .padding8) {
                        hButton(
                            .small,
                            .secondary,
                            content: .init(title: L10n.ClaimStatusDetail.addMoreFiles),
                            {
                                showFileSourcePicker = true
                            }
                        )
                        .hButtonIsLoading(false)
                        hButton(.small, .primary, content: .init(title: L10n.generalContinueButton)) {
                            Task {
                                try await viewModel.submitResponse()
                            }
                        }
                        .hButtonIsLoading(false)
                        .disabled(fileUploadVm.fileGridViewModel.files.isEmpty)
                        .overlay {
                            if fileUploadVm.isLoading {
                                GeometryReader { geo in
                                    Rectangle().fill(hGrayscaleTranslucent.greyScaleTranslucent800.inverted)
                                        .opacity(fileUploadVm.isLoading ? 1 : 0)
                                        .frame(width: fileUploadVm.progress * geo.size.width)
                                }
                            }
                        }
                    }
                }
            } else {
                hSection {
                    hButton(
                        .large,
                        .primary,
                        content: .init(title: L10n.ClaimStatusDetail.addFiles),
                        {
                            showFileSourcePicker = true
                        }
                    )
                    .hButtonIsLoading(fileUploadVm.isLoading)
                    .disabled(fileUploadVm.isLoading)
                }
                .sectionContainerStyle(.transparent)
            }
        }
    }
}

public struct FileUploadModel: Sendable {
    var uploadUri: String? = nil
    @State var uploads: [FileModel] = []
}

public struct FileModel: Codable, Equatable, Hashable, Sendable {
    let fileId: String
    let signedUrl: String
    let mimeType: String
    let name: String

    public init(fileId: String, signedUrl: String, mimeType: String, name: String) {
        self.fileId = fileId
        self.signedUrl = signedUrl
        self.mimeType = mimeType
        self.name = name
    }
}
