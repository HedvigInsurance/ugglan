import Kingfisher
import Presentation
import SwiftUI
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

public struct ClaimDetailView: View {
    @State var claim: ClaimModel
    @PresentableStore var store: ClaimsStore
    @State var player: AudioPlayer?
    private let adaptiveColumn = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
    ]
    public init(
        claim: ClaimModel
    ) {
        self.claim = claim
        if let signedAudioURL = claim.signedAudioURL {
            _player = State(initialValue: AudioPlayer(url: URL(string: signedAudioURL)))
        }
    }

    private var statusParagraph: String {
        claim.statusParagraph
    }

    public var body: some View {
        hForm {
            VStack(spacing: 8) {
                ClaimStatus(claim: claim, enableTap: false)
                    .padding(.top, 8)
                    .padding(.horizontal, 16)
                hSection {
                    hRow {
                        hText(statusParagraph)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.leading)
                    }
                    hRow {
                        ContactChatView(
                            store: self.store,
                            id: self.claim.id,
                            status: self.claim.status.rawValue
                        )
                        .padding(.bottom, 4)
                    }
                }

                if let inputText = claim.memberFreeText {
                    hSection {
                        hRow {
                            hText(inputText)
                        }
                    }
                    .withHeader {
                        hText(L10n.ClaimStatusDetail.submittedMessage)
                            .padding(.leading, 2)
                    }
                    .padding(.top, 16)
                }

                if claim.showUploadedFiles {
                    hSection {
                        if let player {
                            ClaimDetailFilesView(
                                audioPlayer: player
                            )
                            .onReceive(player.objectWillChange.filter({ $0.playbackState == .finished })) { player in }
                        }
                    }
                    .withHeader {
                        HStack {
                            hText(L10n.ClaimStatusDetail.uploadedFiles)
                                .padding(.leading, 2)
                            Spacer()
                            InfoViewHolder(
                                title: L10n.ClaimStatusDetail.uploadedFilesInfoTitle,
                                description: L10n.ClaimStatusDetail.uploadedFilesInfoDescription
                            )
                        }
                    }
                    .padding(.top, 16)
                    hSection {
                        LazyVGrid(columns: adaptiveColumn, spacing: 8) {
                            ForEach(claim.files, id: \.self) { file in
                                FilePreview(file: file) {
                                    store.send(.navigation(action: .openFile(file: file)))
                                }
                                .aspectRatio(1, contentMode: .fit)
                                .cornerRadius(12)
                            }
                        }
                    }
                    .sectionContainerStyle(.transparent)
                }

                if claim.canAddFiles {
                    hSection {
                        hButton.LargeButton(type: .primaryAlt) {

                        } content: {
                            hText(L10n.ClaimStatusDetail.addMoreFiles)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
    }
}

struct ClaimDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let claim = ClaimModel(
            id: "claimId",
            status: .beingHandled,
            outcome: .none,
            submittedAt: "2023-11-11",
            closedAt: nil,
            signedAudioURL: "https://filesamples.com/samples/audio/m4a/sample3.m4a",
            type: "associated type",
            memberFreeText: nil,
            payoutAmount: nil,
            files: [
                .init(
                    id: "imageId1",
                    url: URL(string: "https://filesamples.com/samples/image/png/sample_640%C3%97426.png")!,
                    mimeType: MimeType.findBy(mimeType: "image/png"),
                    name: "test-image",
                    size: 52176
                ),
                .init(
                    id: "imageId2",
                    url: URL(
                        string: "https://onlinepngtools.com/images/examples-onlinepngtools/giraffe-illustration.png"
                    )!,
                    mimeType: MimeType.findBy(mimeType: "image/png"),
                    name: "test-image",
                    size: 52176
                ),
                .init(
                    id: "imageId3",
                    url: URL(string: "https://cdn.pixabay.com/photo/2017/06/21/15/03/example-2427501_1280.png")!,
                    mimeType: MimeType.findBy(mimeType: "image/png"),
                    name: "test-image",
                    size: 52176
                ),
                .init(
                    id: "imageId4",
                    url: URL(string: "https://flif.info/example-images/fish.png")!,
                    mimeType: MimeType.findBy(mimeType: "image/png"),
                    name: "test-image",
                    size: 52176
                ),
                .init(
                    id: "imageId5",
                    url: URL(string: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf")!,
                    mimeType: MimeType.PDF,
                    name: "test-pdf long name it is possible to have it is long name .pdf",
                    size: 52176
                ),
            ]
        )
        return ClaimDetailView(claim: claim)
    }
}

struct FilePreview: View {
    let file: File
    let onTap: () -> Void
    var body: some View {
        Group {
            if file.mimeType.isImage {
                KFImage(file.url)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
            } else {
                GeometryReader { geometry in
                    VStack(spacing: 4) {
                        Image(uiImage: hCoreUIAssets.pdf.image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(hTextColor.secondary)
                            .padding(.horizontal, geometry.size.width / 3)
                            .padding(.top, geometry.size.height / 5)
                        hText(file.name, style: .standardExtraExtraSmall)
                            .foregroundColor(hTextColor.secondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                    }
                }
                .background(hFillColor.opaqueOne)
            }
        }
        .onTapGesture {
            onTap()
        }
    }
}
