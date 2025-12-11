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
            .onChange(of: fileUploadVm.hasFiles) { hasFiles in
                viewModel.setDisableSkip(to: hasFiles)
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
                                viewModel.submitResponse()
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
        .transition(.opacity.animation(.default))
        .sectionContainerStyle(.transparent)
        .animation(.default, value: fileUploadVm.hasFiles)
        .animation(.default, value: fileUploadVm.isLoading)
        .animation(.default, value: fileUploadVm.progress)
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
    let model = ClaimIntentClientDemo().demoFileUploadModel

    return SubmitClaimFileUploadView(viewModel: model)
        .task { [weak model] in
            try? await Task.sleep(seconds: 1)
            model?.fileUploadVm.fileGridViewModel.files
                .append(
                    .init(
                        id: "id1",
                        size: 0,
                        mimeType: .PNG,
                        name: "name",
                        source: .url(
                            url: URL(
                                string:
                                    "https://www.hedvig.com/_next/image?url=https%3A%2F%2Fassets.hedvig.com%2Ff%2F165473%2F2694x1200%2F017b95ad16%2Fhander-mobiltelefon-app-hedvig-2700.jpg&w=3840&q=70"
                            )!,
                            mimeType: .PNG
                        )
                    )
                )
            try? await Task.sleep(seconds: 2)
            model?.fileUploadVm.fileGridViewModel.files
                .append(
                    .init(
                        id: "id2",
                        size: 0,
                        mimeType: .PNG,
                        name: "name 2",
                        source: .url(
                            url: URL(
                                string:
                                    "https://www.hedvig.com/_next/image?url=https%3A%2F%2Fa.storyblok.com%2Ff%2F165473%2F1080x1080%2Fa44c261f97%2Fbetyg-konsumenternas-hedvig.png&w=3840&q=75"
                            )!,
                            mimeType: .PNG
                        )
                    )
                )
        }
}

struct SubmitClaimFileUploadResultView: View {
    let viewModel: SubmitClaimFileUploadStep
    var body: some View {
        FilesGridView(vm: viewModel.fileUploadVm.fileGridViewModel)
    }
}
