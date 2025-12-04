import Claims
import Combine
import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimFileUploadView: View {
    @ObservedObject var viewModel: SubmitClaimFileUploadStep
    @ObservedObject var fileUploadVm: FilesUploadViewModel

    init(
        viewModel: SubmitClaimFileUploadStep
    ) {
        fileUploadVm = viewModel.fileUploadVm
        self.viewModel = viewModel
    }

    var body: some View {
        showFilesView
            .showFileSourcePicker($viewModel.showFileSourcePicker) { files in
                fileUploadVm.addFiles(with: files)
            }
    }

    private var showFilesView: some View {
        Group {
            if fileUploadVm.hasFiles {
                hSection {
                    VStack {
                        FilesGridView(vm: fileUploadVm.fileGridViewModel)
                        HStack(spacing: .padding8) {
                            hButton(
                                .medium,
                                .secondary,
                                content: .init(title: L10n.ClaimStatusDetail.addMoreFiles),
                                { [weak viewModel] in
                                    viewModel?.showFileSourcePicker = true
                                }
                            )
                            .hButtonIsLoading(false)
                            hButton(.medium, .primary, content: .init(title: L10n.generalContinueButton)) {
                                Task {
                                    await viewModel.submitResponse()
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
                    .hButtonTakeFullWidth(true)
                }
            } else {
                hSection {
                    hButton(
                        .large,
                        .primary,
                        content: .init(title: L10n.ClaimStatusDetail.addFiles),
                        { [weak viewModel] in
                            viewModel?.showFileSourcePicker = true
                        }
                    )
                    .hButtonIsLoading(fileUploadVm.isLoading)
                    .disabled(fileUploadVm.isLoading)
                }
            }
        }
        .sectionContainerStyle(.transparent)
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

#Preview {
    SubmitClaimFileUploadView(viewModel: ClaimIntentClientDemo().demoFileUploadModel)
}

struct SubmitClaimFileUploadResultView: View {
    let viewModel: SubmitClaimFileUploadStep
    var body: some View {
        FilesGridView(vm: viewModel.fileUploadVm.fileGridViewModel)
    }
}
